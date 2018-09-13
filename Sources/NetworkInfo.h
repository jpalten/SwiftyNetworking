//
//  Networking.h
//  NetworkTester
//
//  Created by Jelle Alten on 13-12-14.
//  Copyright (c) 2014 Alt-N. All rights reserved.
//

#ifndef __NetworkTester__Networking__
#define __NetworkTester__Networking__

#include <stdio.h>
#include <net/if.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <net/if_dl.h>
#import <sys/sysctl.h>
#include <net/if.h>
#import <Foundation/Foundation.h>


#define	RTF_UP		0x1		/* route usable */
#define	RTF_GATEWAY	0x2		/* destination is a gateway */
#define	RTF_HOST	0x4		/* host entry (net otherwise) */
#define	RTF_REJECT	0x8		/* host or net unreachable */
#define	RTF_DYNAMIC	0x10		/* created dynamically (by redirect) */
#define	RTF_MODIFIED	0x20		/* modified dynamically (by redirect) */
#define RTF_DONE	0x40		/* message confirmed */
#define RTF_DELCLONE	0x80		/* delete cloned route */
#define RTF_CLONING	0x100		/* generate new routes on use */
#define RTF_XRESOLVE	0x200		/* external daemon resolves name */
#define RTF_LLINFO	0x400		/* generated by link layer (e.g. ARP) */
#define RTF_STATIC	0x800		/* manually added */
#define RTF_BLACKHOLE	0x1000		/* just discard pkts (during updates) */
#define RTF_PROTO2	0x4000		/* protocol specific routing flag */
#define RTF_PROTO1	0x8000		/* protocol specific routing flag */

#define RTF_PRCLONING	0x10000		/* protocol requires cloning */
#define RTF_WASCLONED	0x20000		/* route generated through cloning */
#define RTF_PROTO3	0x40000		/* protocol specific routing flag */
/* 0x80000 unused */
#define RTF_PINNED	0x100000	/* future use */
#define	RTF_LOCAL	0x200000	/* route represents a local address */
#define	RTF_BROADCAST	0x400000	/* route represents a bcast address */
#define	RTF_MULTICAST	0x800000	/* route represents a mcast address */
#define RTF_IFSCOPE	0x1000000	/* has valid interface scope */
#define RTF_CONDEMNED	0x2000000	/* defunct; no longer modifiable */
/* 0x4000000 and up unassigned */

/*
 * Index offsets for sockaddr array for alternate internal encoding.
 */
#define RTAX_DST	0	/* destination sockaddr present */
#define RTAX_GATEWAY	1	/* gateway sockaddr present */
#define RTAX_NETMASK	2	/* netmask sockaddr present */
#define RTAX_GENMASK	3	/* cloning mask sockaddr present */
#define RTAX_IFP	4	/* interface name sockaddr present */
#define RTAX_IFA	5	/* interface addr sockaddr present */
#define RTAX_AUTHOR	6	/* sockaddr for author of redirect */
#define RTAX_BRD	7	/* for NEWADDR, broadcast or p-p dest addr */
#define RTAX_MAX	8	/* size of array to allocate */


/*
 * Bitmask values for rtm_addrs.
 */
#define RTA_DST		0x1	/* destination sockaddr present */
#define RTA_GATEWAY	0x2	/* gateway sockaddr present */
#define RTA_NETMASK	0x4	/* netmask sockaddr present */
#define RTA_GENMASK	0x8	/* cloning mask sockaddr present */
#define RTA_IFP		0x10	/* interface name sockaddr present */
#define RTA_IFA		0x20	/* interface addr sockaddr present */
#define RTA_AUTHOR	0x40	/* sockaddr for author of redirect */
#define RTA_BRD		0x80	/* for NEWADDR, broadcast or p-p dest addr */



/*
 * These numbers are used by reliable protocols for determining
 * retransmission behavior and are included in the routing structure.
 */
struct routing_metrics {
    u_int32_t	rmx_locks;	/* Kernel must leave these values alone */
    u_int32_t	rmx_mtu;	/* MTU for this path */
    u_int32_t	rmx_hopcount;	/* max hops expected */
    int32_t		rmx_expire;	/* lifetime for route, e.g. redirect */
    u_int32_t	rmx_recvpipe;	/* inbound delay-bandwidth product */
    u_int32_t	rmx_sendpipe;	/* outbound delay-bandwidth product */
    u_int32_t	rmx_ssthresh;	/* outbound gateway buffer limit */
    u_int32_t	rmx_rtt;	/* estimated round trip time */
    u_int32_t	rmx_rttvar;	/* estimated rtt variance */
    u_int32_t	rmx_pksent;	/* packets sent using this route */
    u_int32_t	rmx_filler[4];	/* will be used for T/TCP later */
};

/*
 * Structures for routing messages.
 */
struct routing_msghdr {
    u_short	rtm_msglen;		/* to skip over non-understood messages */
    u_char	rtm_version;		/* future binary compatibility */
    u_char	rtm_type;		/* message type */
    u_short	rtm_index;		/* index for associated ifp */
    int	rtm_flags;		/* flags, incl. kern & message, e.g. DONE */
    int	rtm_addrs;		/* bitmask identifying sockaddrs in msg */
    pid_t	rtm_pid;		/* identify sender */
    int	rtm_seq;		/* for sender to identify action */
    int	rtm_errno;		/* why failed */
    int	rtm_use;		/* from rtentry */
    u_int32_t rtm_inits;		/* which metrics we are initializing */
    struct routing_metrics rtm_rmx;	/* metrics themselves */
};


//#define CTL_NET         4               /* network, see socket.h */


char* malloc_routesBuffer(size_t* bufferLength);

char* malloc_arpBuffer(size_t* arpBufferSize);
char* malloc_routesBuffer(size_t* bufferLength);


NSString *inetToIpString(in_addr_t address);
NSString* getDefaultGatewayIp(void);
in_addr_t getdefaultgateway(void);

#endif /* defined(__NetworkTester__Networking__) */