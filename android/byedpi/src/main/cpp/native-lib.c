#include <jni.h>
#include <arpa/inet.h>
#include <getopt.h>
#include <pthread.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#include "engine_dns.h"
#include "params.h"

extern int server_fd;
extern int wake_fd;

int main(int argc, char **argv);

// main() is not reentrant: parse_args() leaves flags it can only clear, and
// clear_params() releases the allocations but not the scalars. Restoring the
// value the loader saw is what makes a second run behave like the first.
static struct params pristine;
static int pristine_saved;

// One run at a time, and that includes the params reset: a second start
// nulling `params.mempool` under a live event loop dies in cache_add, and a
// loop stuck in a blocking resolve outlives a 2-second join by minutes. A
// start that arrives while the previous run has not exited waits instead.
static pthread_mutex_t run_lock = PTHREAD_MUTEX_INITIALIZER;

// The listener and wake fds live in engine globals while main() runs, but the
// JNI side touches them from other threads: stop() races the moment main()
// returns, and a number that outlived its fd makes fdsan abort the whole
// process the next time the kernel reuses it.
static pthread_mutex_t fd_lock = PTHREAD_MUTEX_INITIALIZER;

// A stop that lands before main() has created the listener has no fd to wake,
// so it leaves this mark for the run it was aimed at. The next start may not
// inherit it: the flag is consumed by whoever was running when it was set.
static int cancel_pending;
static pthread_mutex_t cancel_lock = PTHREAD_MUTEX_INITIALIZER;

static void free_argv(char **argv, int argc) {
    for (int i = 0; i < argc; i++) {
        free(argv[i]);
    }
    free(argv);
}

JNIEXPORT jint JNICALL
Java_com_reclash_byedpi_ByeDpiNative_nativeStart(JNIEnv *env, jobject thiz, jobjectArray args) {
    (void) thiz;
    const jsize count = (*env)->GetArrayLength(env, args);
    const int argc = (int) count + 1;
    char **argv = calloc((size_t) argc + 1, sizeof(char *));
    if (!argv) {
        return -1;
    }
    argv[0] = strdup("ciadpi");
    for (jsize i = 0; i < count; i++) {
        jstring item = (jstring) (*env)->GetObjectArrayElement(env, args, i);
        const char *chars = (*env)->GetStringUTFChars(env, item, 0);
        argv[i + 1] = strdup(chars ? chars : "");
        (*env)->ReleaseStringUTFChars(env, item, chars);
        (*env)->DeleteLocalRef(env, item);
    }

    optind = 1;
    pthread_mutex_lock(&run_lock);
    pthread_mutex_lock(&cancel_lock);
    if (cancel_pending) {
        cancel_pending = 0;
        pthread_mutex_unlock(&cancel_lock);
        pthread_mutex_unlock(&run_lock);
        free_argv(argv, argc);
        return 0;
    }
    pthread_mutex_unlock(&cancel_lock);
    if (!pristine_saved) {
        pristine = params;
        pristine_saved = 1;
    } else {
        params = pristine;
    }
    const int status = main(argc, argv);
    pthread_mutex_lock(&fd_lock);
    server_fd = 0;
    wake_fd = -1;
    pthread_mutex_unlock(&fd_lock);
    pthread_mutex_unlock(&run_lock);
    free_argv(argv, argc);
    return status;
}

// Set before the branch starts; the event loop reads it without a lock, so a
// change while the engine runs only takes effect on the next start.
JNIEXPORT void JNICALL
Java_com_reclash_byedpi_ByeDpiNative_nativeSetDns(JNIEnv *env, jobject thiz, jstring ip) {
    (void) thiz;
    memset(&engine_dns_server, 0, sizeof(engine_dns_server));
    if (!ip) {
        return;
    }
    const char *chars = (*env)->GetStringUTFChars(env, ip, 0);
    if (chars) {
        struct in_addr addr;
        if (inet_pton(AF_INET, chars, &addr) == 1) {
            engine_dns_server.sin_family = AF_INET;
            engine_dns_server.sin_addr = addr;
            engine_dns_server.sin_port = htons(53);
        }
        (*env)->ReleaseStringUTFChars(env, ip, chars);
    }
}

// Stopping through shutdown() lets run() return so main() still reaches
// dump_all_cache(); closing the socket outright throws the tuning away. The
// wake write is the part that actually ends epoll_wait: shutdown() alone does
// not wake it on every kernel, and a close() from this thread never does.
// Both run under fd_lock: past it, main() may exit and free the numbers.
JNIEXPORT void JNICALL
Java_com_reclash_byedpi_ByeDpiNative_nativeStop(JNIEnv *env, jobject thiz) {
    (void) env;
    (void) thiz;
    pthread_mutex_lock(&fd_lock);
    const int sfd = server_fd;
    const int wfd = wake_fd;
    if (sfd > 0) {
        shutdown(sfd, SHUT_RDWR);
    }
    else {
        pthread_mutex_lock(&cancel_lock);
        cancel_pending = 1;
        pthread_mutex_unlock(&cancel_lock);
    }
    if (wfd > 0) {
        const uint64_t one = 1;
        ssize_t ignored = write(wfd, &one, sizeof(one));
        (void) ignored;
    }
    pthread_mutex_unlock(&fd_lock);
}
