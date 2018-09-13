//
//  Networking.c
//  NetworkTester
//
//  Created by Jelle Alten on 13-12-14.
//  Copyright (c) 2014 Alt-N. All rights reserved.
//

#import <sys/sysctl.h>
#import <sys/socket.h>
#import <stdlib.h>
#import <net/if.h>
#import <Foundation/Foundation.h>
#include "NetworkInfo.h"


#define ROUNDUP(a) \
((a) > 0 ? (1 + (((a) - 1) | (sizeof(long) - 1))) : sizeof(long))


char* malloc_routesBuffer(size_t* bufferSizePtr) {
    
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET, NET_RT_FLAGS, RTF_GATEWAY};
    size_t bufferLength;
    
    if(sysctl(mib, sizeof(mib)/sizeof(int), 0, &bufferLength, 0, 0) < 0) {
        return NULL;
    }
    
    char* routesBuffer = malloc(bufferLength);
    if (routesBuffer!=NULL) {
        if(sysctl(mib, sizeof(mib)/sizeof(int), routesBuffer, &bufferLength, 0, 0) < 0) {
            free(routesBuffer);
            routesBuffer = NULL;
        }
    }
    *bufferSizePtr = bufferLength;
    return routesBuffer;
}


char* malloc_arpBuffer(size_t* bufferSizePtr) {
    
    int mib[6] = {CTL_NET, PF_ROUTE, 0, AF_INET, NET_RT_FLAGS, RTF_LLINFO };
    size_t arpBufferSize = 0;
    
    if ((sysctl(mib, sizeof(mib) / sizeof(mib[0]), NULL, &arpBufferSize, NULL, 0) < 0))
        return NULL;
    
    char * arpBuffer = (char*)malloc(arpBufferSize);
    if (arpBuffer!=NULL) {
        if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), arpBuffer, &arpBufferSize, NULL, 0) < 0) {
            free(arpBuffer);
            arpBuffer =  NULL;
        }
    }
    
    *bufferSizePtr = arpBufferSize;
    return arpBuffer;
}

NSDictionary * getGateways() {

    NSMutableDictionary *gateways = [[NSMutableDictionary alloc] init];
    in_addr_t gwAddr = 0;

    size_t bufferLength = 0;
    char * routesBuffer, * currentPointer;
    struct sockaddr * ipTable[RTAX_MAX];

    struct routing_msghdr* routingMsghdr;

    routesBuffer = malloc_routesBuffer(&bufferLength);

    for(currentPointer = routesBuffer; currentPointer < routesBuffer + bufferLength; currentPointer +=routingMsghdr->rtm_msglen) {
        routingMsghdr = (struct routing_msghdr*) currentPointer;
        struct sockaddr * sockaddr = (struct sockaddr *)(routingMsghdr + 1);
        for(int i=0; i<RTAX_MAX; i++) {
            if (routingMsghdr->rtm_addrs & (1 << i)) {
                ipTable[i] = sockaddr;
                sockaddr = (struct sockaddr *)((char *) sockaddr + ROUNDUP(sockaddr->sa_len));
            } else {
                ipTable[i] = NULL;
            }
        }

        if( ((routingMsghdr->rtm_addrs & (RTA_DST|RTA_GATEWAY)) == (RTA_DST|RTA_GATEWAY))
                && ipTable[RTAX_DST]->sa_family == AF_INET
                && ipTable[RTAX_GATEWAY]->sa_family == AF_INET) {


            if(((struct sockaddr_in *) ipTable[RTAX_DST])->sin_addr.s_addr == 0) {
                char ifName[128];
                if_indextoname(routingMsghdr->rtm_index,ifName);

                NSString* interfaceName = [NSString stringWithUTF8String:ifName];

                gwAddr = ((struct sockaddr_in *)(ipTable[RTAX_GATEWAY]))->sin_addr.s_addr;
                gateways[interfaceName] = inetToIpString(gwAddr);
            }
        }
    }
    free(routesBuffer);
    return [gateways copy];
}

in_addr_t getdefaultgateway()
{
    assert([NSThread currentThread] != [NSThread mainThread]);
    
    if([NSThread currentThread] == [NSThread mainThread]) {
        NSLog(@"getdefaultgateway called on main thread");
        exit(-1);
    }

    in_addr_t gwAddr = 0;
    
    size_t bufferLength = 0;
    char * routesBuffer, * currentPointer;
    struct sockaddr * ipTable[RTAX_MAX];
    
    struct routing_msghdr* routingMsghdr;
    
    routesBuffer = malloc_routesBuffer(&bufferLength);
    
    for(currentPointer = routesBuffer; currentPointer < routesBuffer + bufferLength; currentPointer +=routingMsghdr->rtm_msglen) {
        routingMsghdr = (struct routing_msghdr*) currentPointer;
        struct sockaddr * sockaddr = (struct sockaddr *)(routingMsghdr + 1);
        for(int i=0; i<RTAX_MAX; i++) {
            if (routingMsghdr->rtm_addrs & (1 << i)) {
                ipTable[i] = sockaddr;
                sockaddr = (struct sockaddr *)((char *) sockaddr + ROUNDUP(sockaddr->sa_len));
            } else {
                ipTable[i] = NULL;
            }
        }
        
        if( ((routingMsghdr->rtm_addrs & (RTA_DST|RTA_GATEWAY)) == (RTA_DST|RTA_GATEWAY))
           && ipTable[RTAX_DST]->sa_family == AF_INET
           && ipTable[RTAX_GATEWAY]->sa_family == AF_INET) {
            
            
            if(((struct sockaddr_in *) ipTable[RTAX_DST])->sin_addr.s_addr == 0) {
                char ifName[128];
                if_indextoname(routingMsghdr->rtm_index,ifName);
                
//                NSLog(@"checking gateway of interface %s",ifName);
                
                NSArray* validInterfaceNames = @[@"en0", @"en1"];
                
                NSString* interfaceName = [NSString stringWithUTF8String:ifName];
                if([validInterfaceNames containsObject:interfaceName]) {
                    gwAddr = ((struct sockaddr_in *)(ipTable[RTAX_GATEWAY]))->sin_addr.s_addr;
                }
            }
        }
    }
    free(routesBuffer);
    
    return gwAddr;
}


NSString *inetToIpString(in_addr_t inetAddress) {
    struct in_addr address = {inetAddress};
    
    char * gateway = inet_ntoa(address);
    NSString *gatewayIpStr = [NSString stringWithUTF8String:gateway];
    return gatewayIpStr;
}

NSString* getDefaultGatewayIp() {
    return inetToIpString(getdefaultgateway());
}
