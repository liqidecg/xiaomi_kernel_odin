#ifndef __RE_KERNEL_H
#define __RE_KERNEL_H

#include <linux/types.h>
#include <linux/netlink.h>
#include <net/netlink.h>
#include <net/sock.h>

#define NETLINK_REKERNEL_MAX        26
#define NETLINK_REKERNEL_MIN        22

#define REKERNEL_USER_PORT          100
#define REKERNEL_PACKET_SIZE        256

#define REKERNEL_MAX_SYSTEM_UID     2000
#define REKERNEL_MIN_USERAPP_UID    10000

/*
 * Binder async warning threshold
 */
#define REKERNEL_RESERVE_ORDER      17
#define REKERNEL_WARN_AHEAD_SPACE   (1 << REKERNEL_RESERVE_ORDER)

extern struct sock *rekernel_netlink;
extern int rekernel_netlink_unit;

extern struct net init_net;

#endif /* __RE_KERNEL_H */
