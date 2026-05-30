#ifndef __RE_KERNEL_H
#define __RE_KERNEL_H

#include <linux/types.h>
#include <linux/netlink.h>
#include <net/netlink.h>
#include <net/sock.h>

#define NETLINK_REKERNEL_MAX    26
#define NETLINK_REKERNEL_MIN    22

#define REKERNEL_USER_PORT      100
#define REKERNEL_PACKET_SIZE    256

extern struct sock *rekernel_netlink;
extern int rekernel_netlink_unit;

extern struct net init_net;

#endif /* __RE_KERNEL_H */