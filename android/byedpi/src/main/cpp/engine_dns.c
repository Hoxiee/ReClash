#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdint.h>
#include <poll.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#include "engine_dns.h"
#include "byedpi/error.h"
#include "byedpi/extend.h"

#define DNS_TIMEOUT_MS 3000

struct sockaddr_in engine_dns_server;

int engine_dns_ready(void) {
    return engine_dns_server.sin_family == AF_INET;
}

static ssize_t build_query(char *out, const char *host, int len) {
    if (len < 1 || len > 253) {
        return -1;
    }
    size_t o = 13;
    size_t label_start = 12;
    for (int i = 0; i < len; i++) {
        if (host[i] == '.') {
            size_t label_len = o - label_start - 1;
            if (label_len < 1 || label_len > 63) {
                return -1;
            }
            out[label_start] = (char) label_len;
            label_start = o;
            o++;
        }
        else {
            out[o++] = host[i];
        }
    }
    size_t last_len = o - label_start - 1;
    if (last_len < 1 || last_len > 63) {
        return -1;
    }
    out[label_start] = (char) last_len;
    out[o++] = 0;
    const uint16_t tail[] = { htons(1), htons(1) };
    memcpy(out + o, tail, 4);
    const uint16_t header[] =
        { 0x5eed, htons(0x0100), htons(1), 0, 0, 0 };
    memcpy(out, header, 12);
    return (ssize_t) (o + 4);
}

static uint16_t read16(const char *p) {
    return (uint16_t) ((uint8_t) p[0] << 8 | (uint8_t) p[1]);
}

int engine_dns_query(const char *host, int len, struct in_addr *out) {
    char q[280], resp[512];
    const ssize_t qn = build_query(q, host, len);
    if (qn < 0) {
        return -1;
    }
    const int fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (fd < 0) {
        return -1;
    }
    // The query must leave the tunnel like every other dial, or it loops
    // back into the local proxy that asked for the lookup.
    if (socket_mod(fd)) {
        close(fd);
        return -1;
    }
    if (sendto(fd, q, qn, 0,
            (struct sockaddr *) &engine_dns_server,
            sizeof(engine_dns_server)) != qn) {
        uniperror("engine dns sendto");
        close(fd);
        return -1;
    }
    struct pollfd pfd = { .fd = fd, .events = POLLIN };
    if (poll(&pfd, 1, DNS_TIMEOUT_MS) != 1) {
        close(fd);
        return -1;
    }
    const ssize_t n = recv(fd, resp, sizeof(resp), 0);
    close(fd);

    if (n < 12 || memcmp(resp, q, 2) != 0 || (resp[3] & 0x0f) != 0) {
        return -1;
    }
    size_t i = 12;
    while (i < (size_t) n && (uint8_t) resp[i]) {
        if (((uint8_t) resp[i] & 0xc0) == 0xc0) {
            i++;
            break;
        }
        i += 1 + (uint8_t) resp[i];
    }
    i += 5;
    while (i + 12 <= (size_t) n) {
        if (((uint8_t) resp[i] & 0xc0) == 0xc0) {
            i += 2;
        }
        else {
            while (i < (size_t) n && (uint8_t) resp[i]) {
                i += 1 + (uint8_t) resp[i];
            }
            if (i >= (size_t) n) {
                return -1;
            }
            i++;
        }
        if (i + 10 > (size_t) n) {
            return -1;
        }
        const uint16_t type = read16(resp + i);
        const uint16_t rdlen = read16(resp + i + 8);
        i += 10;
        if (type == 1 && rdlen == 4 && i + 4 <= (size_t) n) {
            memcpy(&out->s_addr, resp + i, 4);
            return 0;
        }
        i += rdlen;
    }
    return -1;
}
