#ifndef ENGINE_DNS_H
#define ENGINE_DNS_H

#include <netinet/in.h>

extern struct sockaddr_in engine_dns_server;

int engine_dns_ready(void);

int engine_dns_query(const char *host, int len, struct in_addr *out);

#endif
