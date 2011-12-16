/* quick app that reads from a file, and sends the contents to a service one
 * byte at a time based on the -s and -u arguments (default 1.0/s)
 *
 * written because I couldn't find anything else that could do this. Helpful
 * when debugging non-blocking servers which parse data.
 *
 * Compile: gcc ob.c -o ob -levent
 *
 * Author: ellzey@strcpy.net
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdint.h>
#include <errno.h>
#include <time.h>
#include <ctype.h>

#include <event.h>
#include <event2/dns.h>


struct event       * sev;
struct event_base  * evbase;
struct bufferevent * bev;

const char         * help   = "-a <addr> -p <port> -f <file> [-s <sec between send> -u <usec between send>";
const char         * optstr = "hf:s:u:a:p:";
const char         * filename;
FILE               * input_file;
char               * addr;
uint16_t             port;
char                 fbyte;
int                  sec;
int                  usec;

void
eventcb(struct bufferevent * bev, short events, void * ptr) {
    if (events & BEV_EVENT_CONNECTED) {
        struct timeval tv;

        tv.tv_sec  = sec;
        tv.tv_usec = usec;

        evtimer_add(sev, &tv);
        return;
    } else if (events & (BEV_EVENT_ERROR | BEV_EVENT_EOF)) {
        struct event_base * base = ptr;
        if (events & BEV_EVENT_ERROR) {
            int err = bufferevent_socket_get_dns_error(bev);

            if (err) {
                printf("DNS error: %s\n", evutil_gai_strerror(err));
            }
        }
        printf("Closing\n");
        bufferevent_free(bev);
        event_base_loopexit(base, NULL);
    }
}

int
parse_args(int argc, char ** argv) {
    extern char * optarg;
    extern int    optind;
    extern int    opterr;
    extern int    optopt;
    int           c;

    sec  = 1;
    usec = 0;
    addr = strdup("127.0.0.1");

    while ((c = getopt(argc, argv, optstr)) != -1) {
        switch (c) {
            case 'f':
                filename = strdup(optarg);
                break;
            case 's':
                sec = atoi(optarg);
                break;
            case 'u':
                usec = atoi(optarg);
                break;
            case 'a':
                addr = strdup(optarg);
                break;
            case 'p':
                port = atoi(optarg);
                break;
            case 'h':
                printf("Usage: %s %s\n", argv[0], help);
                return -1;
            default:
                printf("invalid opt -%c %s\n", c, optarg);
                return -1;
        } /* switch */
    }

    if (filename == NULL || !port) {
        printf("Need input file and port\n");
        return -1;
    }

    if (!(input_file = fopen(filename, "r"))) {
        printf("Error opening input file %s: %s\n", filename, strerror(errno));
        return -1;
    }

    return 0;
} /* parse_args */

void
send_byte(int sock, short event, void * arg) {
    char           fbyte;
    struct timeval tv;

    if (fread(&fbyte, 1, 1, input_file) == 1) {
        printf("sending: '%c' (%x)\n", isprint(fbyte) ? fbyte : ' ', fbyte);

        evbuffer_add(bufferevent_get_output(bev), &fbyte, 1);

        tv.tv_sec  = sec;
        tv.tv_usec = usec;

        evtimer_add(sev, &tv);
    }
}

void
readcb(struct bufferevent * bev, void * ptr) {
    char              buf[1024];
    int               n;
    struct evbuffer * input = bufferevent_get_input(bev);

    while ((n = evbuffer_remove(input, buf, sizeof(buf))) > 0) {
        fwrite(buf, 1, n, stdout);
	fflush(stdout);
    }
}

int
main(int argc, char ** argv) {
    struct evdns_base * dns_base;
    struct timeval      tv;

    if (parse_args(argc, argv) < 0) {
        exit(1);
    }

    tv.tv_sec  = sec;
    tv.tv_usec = usec;

    evbase     = event_base_new();
    dns_base   = evdns_base_new(evbase, 1);
    bev        = bufferevent_socket_new(evbase, -1, BEV_OPT_CLOSE_ON_FREE);
    sev        = evtimer_new(evbase, send_byte, bev);

    bufferevent_setcb(bev, readcb, NULL, eventcb, evbase);
    bufferevent_enable(bev, EV_READ | EV_WRITE);
    bufferevent_socket_connect_hostname(bev, dns_base, AF_UNSPEC, addr, port);

    event_base_loop(evbase, 0);

    while (fread(&fbyte, 1, 1, input_file) == 1) {
        fprintf(stdout, "sending: '%c' (%x)\n", isprint(fbyte) ? fbyte : ' ', fbyte);
    }

    return 0;
}

