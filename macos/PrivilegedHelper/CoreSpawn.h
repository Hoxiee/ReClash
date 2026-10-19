#ifndef RECLASH_CORE_SPAWN_H
#define RECLASH_CORE_SPAWN_H
#include <stddef.h>
#include <sys/types.h>

int rc_spawn_bootstrap(const char *helper, int child_fd, int parent_fd, pid_t *pid);
int rc_read_line(int fd, char *buffer, size_t capacity, int timeout_ms);
int rc_write_all(int fd, const void *buffer, size_t length, int timeout_ms);
int rc_poll_child(pid_t pid);
int rc_stop_child(pid_t pid, int timeout_ms);
int rc_exec_core(const char *core, const char *home, const char *account_home,
                 uid_t uid, gid_t gid, int fd);
#endif
