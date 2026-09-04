#include <jni.h>
#include <getopt.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#include "params.h"

extern int server_fd;

int main(int argc, char **argv);

// main() is not reentrant: parse_args() leaves flags it can only clear, and
// clear_params() releases the allocations but not the scalars. Restoring the
// value the loader saw is what makes a second run behave like the first.
static struct params pristine;
static int pristine_saved;

static void free_argv(char **argv, int argc) {
    for (int i = 0; i < argc; i++) {
        free(argv[i]);
    }
    free(argv);
}

JNIEXPORT jint JNICALL
Java_com_reclash_byedpi_ByeDpiNative_nativeStart(JNIEnv *env, jobject thiz, jobjectArray args) {
    (void) thiz;
    if (!pristine_saved) {
        pristine = params;
        pristine_saved = 1;
    } else {
        params = pristine;
    }

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
    const int status = main(argc, argv);
    free_argv(argv, argc);
    return status;
}

// Stopping through shutdown() lets run() return so main() still reaches
// dump_all_cache(); closing the socket outright throws the tuning away.
JNIEXPORT void JNICALL
Java_com_reclash_byedpi_ByeDpiNative_nativeStop(JNIEnv *env, jobject thiz) {
    (void) env;
    (void) thiz;
    if (server_fd > 0) {
        shutdown(server_fd, SHUT_RDWR);
    }
}

JNIEXPORT void JNICALL
Java_com_reclash_byedpi_ByeDpiNative_nativeForceClose(JNIEnv *env, jobject thiz) {
    (void) env;
    (void) thiz;
    if (server_fd > 0) {
        close(server_fd);
    }
}
