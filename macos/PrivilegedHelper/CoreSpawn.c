#include "CoreSpawn.h"
#include <errno.h>
#include <fcntl.h>
#include <grp.h>
#include <poll.h>
#include <sandbox.h>
#include <signal.h>
#include <spawn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

static long long rc_millis(void) {
    struct timespec time;
    clock_gettime(CLOCK_MONOTONIC, &time);
    return (long long)time.tv_sec * 1000 + time.tv_nsec / 1000000;
}

int rc_spawn_bootstrap(const char *helper, int child_fd, int parent_fd, pid_t *pid) {
    posix_spawn_file_actions_t actions;
    posix_spawnattr_t attributes;
    int error = posix_spawn_file_actions_init(&actions);
    if (error) return error;
    error = posix_spawnattr_init(&attributes);
    if (error) { posix_spawn_file_actions_destroy(&actions); return error; }
    sigset_t defaults, mask;
    sigemptyset(&mask);
    sigemptyset(&defaults);
    sigaddset(&defaults, SIGTERM);
    sigaddset(&defaults, SIGINT);
    sigaddset(&defaults, SIGPIPE);
    short flags = POSIX_SPAWN_CLOEXEC_DEFAULT | POSIX_SPAWN_SETSIGDEF |
                  POSIX_SPAWN_SETSIGMASK | POSIX_SPAWN_SETPGROUP;
    error = posix_spawnattr_setflags(&attributes, flags);
    if (!error) error = posix_spawnattr_setsigdefault(&attributes, &defaults);
    if (!error) error = posix_spawnattr_setsigmask(&attributes, &mask);
    if (!error) error = posix_spawnattr_setpgroup(&attributes, 0);
    if (!error) error = posix_spawn_file_actions_addclose(&actions, parent_fd);
    if (!error) error = posix_spawn_file_actions_adddup2(&actions, child_fd, 3);
    if (!error && child_fd != 3) error = posix_spawn_file_actions_addclose(&actions, child_fd);
    for (int stream = 0; !error && stream < 3; stream++) {
        error = posix_spawn_file_actions_addopen(&actions, stream, "/dev/null", O_RDWR, 0);
    }
    char *argv[] = {(char *)helper, "--reclash-core-exec", "--bootstrap-fd", "3", NULL};
    char *environment[] = {"PATH=/usr/bin:/bin:/usr/sbin:/sbin", "LANG=en_US.UTF-8", NULL};
    if (!error) error = posix_spawn(pid, helper, &actions, &attributes, argv, environment);
    posix_spawnattr_destroy(&attributes);
    posix_spawn_file_actions_destroy(&actions);
    return error;
}

static int rc_wait_fd(int fd, short events, long long deadline) {
    for (;;) {
        long long remaining = deadline - rc_millis();
        if (remaining <= 0) { errno = ETIMEDOUT; return -1; }
        struct pollfd descriptor = {.fd = fd, .events = events};
        int result = poll(&descriptor, 1, (int)remaining);
        if (result > 0) return 0;
        if (result < 0 && errno == EINTR) continue;
        if (result == 0) errno = ETIMEDOUT;
        return -1;
    }
}

int rc_read_line(int fd, char *buffer, size_t capacity, int timeout_ms) {
    long long deadline = rc_millis() + timeout_ms;
    size_t offset = 0;
    while (offset + 1 < capacity) {
        if (rc_wait_fd(fd, POLLIN, deadline)) return -1;
        ssize_t read_count = read(fd, buffer + offset, 1);
        if (read_count < 0 && errno == EINTR) continue;
        if (read_count <= 0) { if (!read_count) errno = ECONNRESET; return -1; }
        if (buffer[offset++] == '\n') { buffer[offset] = 0; return (int)offset; }
    }
    errno = EMSGSIZE;
    return -1;
}

int rc_write_all(int fd, const void *buffer, size_t length, int timeout_ms) {
    long long deadline = rc_millis() + timeout_ms;
    size_t offset = 0;
    while (offset < length) {
        if (rc_wait_fd(fd, POLLOUT, deadline)) return -1;
        ssize_t written = write(fd, (const char *)buffer + offset, length - offset);
        if (written < 0 && errno == EINTR) continue;
        if (written <= 0) return -1;
        offset += (size_t)written;
    }
    return 0;
}

int rc_poll_child(pid_t pid) {
    int status;
    pid_t result;
    do { result = waitpid(pid, &status, WNOHANG); } while (result < 0 && errno == EINTR);
    return result == pid ? 1 : (result == 0 ? 0 : -1);
}

int rc_stop_child(pid_t pid, int timeout_ms) {
    int state = rc_poll_child(pid);
    if (state != 0) return state;
    if (kill(pid, SIGTERM) != 0 && errno != ESRCH) return -1;
    long long start = rc_millis();
    long long deadline = start + timeout_ms;
    long long force_at = start + (timeout_ms > 2000 ? timeout_ms - 2000 : 0);
    int forced = 0;
    while (rc_millis() < deadline) {
        state = rc_poll_child(pid);
        if (state != 0) return state;
        if (!forced && rc_millis() >= force_at) {
            if (kill(pid, SIGKILL) != 0 && errno != ESRCH) return -1;
            forced = 1;
        }
        usleep(10000);
    }
    return rc_poll_child(pid);
}

static char *rc_profile_string(const char *value) {
    size_t length = strlen(value);
    char *escaped = calloc(length * 2 + 1, 1);
    if (!escaped) return NULL;
    size_t offset = 0;
    for (size_t i = 0; i < length; i++) {
        unsigned char character = value[i];
        if (character < 32 || character == 127) { free(escaped); return NULL; }
        if (character == '"' || character == '\\') escaped[offset++] = '\\';
        escaped[offset++] = character;
    }
    return escaped;
}

int rc_exec_core(const char *core, const char *home, const char *account_home,
                 uid_t uid, gid_t gid, int fd) {
    char *scope = rc_profile_string(home);
    char *binary = rc_profile_string(core);
    char *profile = NULL;
    if (!scope || !binary || asprintf(&profile,
        "(version 1)(allow default)"
        "(deny file-write* (require-all (require-not (subpath \"%s\"))"
        " (require-not (literal \"/dev/null\"))))"
        "(deny file-read-data (require-all (require-not (subpath \"%s\"))"
        " (require-not (literal \"%s\"))"
        " (require-not (subpath \"/System\"))"
        " (require-not (subpath \"/usr/lib\"))"
        " (require-not (subpath \"/usr/share\"))"
        " (require-not (literal \"/etc/hosts\"))"
        " (require-not (literal \"/private/etc/hosts\"))"
        " (require-not (literal \"/etc/resolv.conf\"))"
        " (require-not (literal \"/private/etc/resolv.conf\"))"
        " (require-not (literal \"/etc/localtime\"))"
        " (require-not (literal \"/private/etc/localtime\"))"
        " (require-not (literal \"/dev/null\"))"
        " (require-not (literal \"/dev/urandom\"))"
        " (require-not (literal \"/dev/random\"))))"
        "(deny process-fork)(deny process-exec (require-not (literal \"%s\")))",
        scope, scope, binary, binary) < 0) {
        free(scope); free(binary); return ENOMEM;
    }
    free(scope); free(binary);
    char *sandbox_error = NULL;
    int result = sandbox_init(profile, 0, &sandbox_error);
    free(profile);
    if (sandbox_error) sandbox_free_error(sandbox_error);
    if (result != 0) return EPERM;
    if (setgroups(0, NULL) || setregid(gid, gid) || setreuid(uid, 0)) return errno;
    if (fcntl(fd, F_SETFD, 0) || chdir(home)) return errno;
    char *home_environment = NULL;
    if (asprintf(&home_environment, "HOME=%s", account_home) < 0) return ENOMEM;
    char *argv[] = {(char *)core, "--reclash-macos-managed", "--bootstrap-fd", "3", NULL};
    char *environment[] = {home_environment, "PATH=/usr/bin:/bin:/usr/sbin:/sbin",
                           "LANG=en_US.UTF-8", NULL};
    execve(core, argv, environment);
    int error = errno;
    free(home_environment);
    return error;
}
