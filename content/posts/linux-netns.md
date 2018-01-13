---
title: "Linux Network Namespace"
date: 2018-01-03T09:24:39+08:00
draft: false
tags: ["Linux", "netns"]
---

This article focuses on introducing what linux network namespace is by conducting experiments.
Just remember one thing before we start:

Always treat a network namespace as another computer. 

<!--more-->

# Part one: LAN

First, we create two network namespace.

```
$ ip netns add ns1
$ ip netns add ns2
```

Now the computer has three network namespaces: the main network namespace, `ns1` and `ns2`.

To connect the three, we need a bridge:

```
$ brctl addbr br0
```

If `brctl` is not installed, you can run `sudo apt install bridge-tools` to install it.

Because eventually we want the bridge to be the default gateway of created namespaces (`ns1` and `ns2`), we should give it an IP address.

```
$ ip addr add 192.168.0.1/24 dev br0    # add IP address
$ ip link set dev br0 up                # set it up
```

Now we want to connect `ns1` with the main network namespace, we just need to connect it with `br0`.

```
$ ip link add veth1 type veth peer name veth1-br        # add a pair of veth interface
$ ip link set veth1 netns ns1                           # add one end to ns1
$ brctl addif br0 veth1-br                              # connect the other end to the bridge we just created
$ ip link set dev veth1-br up
```

Now you should not see `veth1` anymore when running `ip link`, because it is already in another network namespace `ns1`. (Remember? Always treat a network namespace as another computer.)

We are almost there. Just now we used a pair of `veth` interface to connect two namespaces. For more information of `veth`, please use google.

In order to let `ns1` be able to communicate with the main network namespace, we ought to git `veth1` an IP address, and set a default gateway for `ns1`.

The way to execute commands inside a namespace, is to add `ip netns exec <namespace>` in front of the command.

```
$ ip netns exec ns1 ip addr add 192.168.0.2/24 dev veth1
$ ip netns exec ns1 ip link set dev lo up
$ ip netns exec ns1 ip link set dev veth1 up
$ ip netns exec ns1 ip route add default via 192.168.0.1 dev veth1
```

**Notice**: the default gateway is the bridge we created, not `veth1`! Thus we should write `via 192.168.0.1` instead of `via 192.168.0.2`. This is a very simple point, but cost me hours to find out.

Now we test.

```
$ ip netns exec ns1 ping -c1 192.168.0.1
```

Pinging should success.

If there is a physical interface on the host machine (say, `eth0`), try to ping it from `ns1`. It should also be a successful ping, even though `eth0` is not in the network `192.168.0.0/24`. Think about why?

Now, we use the same way to connect `ns2`:

```
$ ip link add veth2 type veth peer name veth2-br
$ ip link set veth2 netns ns2
$ brctl addif br0 veth2-br
$ ip link set dev veth2-br up
$ ip netns exec ns2 ip addr add 192.168.0.3/24 dev veth2
$ ip netns exec ns2 ip link set dev lo up
$ ip netns exec ns2 ip link set dev veth2 up
$ ip netns exec ns2 ip route add default via 192.168.0.1 dev veth2
```

And test with:

```
$ ip netns exec ns2 ping -c1 192.168.0.1
```

Also success. Meaning that `ns2` is connected to the main network namespace successfully as `ns1` does. 

More excitingly:

```
$ ip netns exec ns2 ping -c1 192.168.0.2
```

Or any inter-pings among the main network namespace, `ns1` and  `ns2` should also success. 

**If not:**

There are two things you can do.

**One**, check if *ip forwarding* is enabled. 

```
$ cat /proc/sys/net/ipv4/ip_forward
```

If the output is `0`, means it's not enabled.

To enable *ip forwarding*, simply:

```
$ echo 1 > /proc/sys/net/ipv4/ip_forward
```

Just notice that this action will lose effect after rebooting, because it's temporary. The permanant way is to edit file `/etc/sysctl.conf`, uncomment the line `net.ipv4.ip_forward = 1`, and run `sysctl -p /etc/sysctl.conf` for the change to take effect.

**Two**, change `FORWARD` default policy.

I will not talk about `iptables` right now. However, if you run:

```
$ iptables -L
```

And see the line `Chain FORWARD (policy DROP)`, which means the default action for `FORWARD` chain is `DROP`, you can:

```
$ iptables -P FORWARD ACCEPT
```

To change it to `ACCEPT`.

If doing this still does not help, try:

```
$ iptables -F FORWARD
```

To clear `FORWARD` chain and execute the former command again.

After these two things are taken care of, inter-pings among the three network namespaces should work just fine.

# Part two: Internet

In part one we created a LAN consisting of `ns1`, `ns2` and the host machine (i.e. the main network namespace). These namespaces can naturally communicate with each other since they are connected by the bridge `br0` we created. Now we are going to let `ns1` and `ns2` be able to access the Internet.

Before continuing, some knowledge of Linux firewall tool `iptables` should be talked about.

[This page](http://cn.linux.vbird.org/linux_server/0250simple_firewall.php#netfilter_syntax) gives a detailed introduction to `iptables`. I am not going to copy-paste any information here, but this picture should always be clear in mind (it omitted the *mangle* table):

![](/images/linux-netns-iptables_04.gif)

First of all, it explains why we should set the default policy of `FORWARD` to `ACCEPT` just now:

When `ns1` is pinging `ns2`, the ICMP package firstly arrives at `br0`, which finds out that this is not a package for its network namespace, thus *Route B* (in the picture) is chosen. We must let the package pass `FORWARD` chain in the *filter* table so that it can be routed to `ns2`, vice versa.

Now, to let `ns1` and `ns2` gain the ability of successfully pinging the outside world (say, www.google.com), we should:

```
$ iptables -t nat -A POSTROUTING -s 192.168.0.0/24 ! -o br0 -j MASQUERADE
```

This command added a rule to the *nat* table's `POSTROUTING` chain, matching packages **from network 192.168.0.0/24 and not output to br0**, taking the action of `MASQUERADE`. About `MASQUERADE` please refer to the page I just mentioned.

Now, try to ping any **IP address** from `ns1` or `ns2` outside the host machine, it should success.

But we still cannot ping www.google.com, because we haven't added a DNS server.

```
$ ip netns exec ns1 ping -c1 www.google.com
ping: www.google.com: Name or service not known
```

In my own experiment, I simply choose the same DNS server as the host machine for the network namespaces I created.

My host machine's physical network interface is `ens33`, thus we go:

```
$ systemd-resolve --status
```

And look for `ens33`:

```
Link 2 (ens33)
      Current Scopes: DNS LLMNR/IPv4 LLMNR/IPv6
       LLMNR setting: yes
MulticastDNS setting: no
      DNSSEC setting: no
    DNSSEC supported: no
         DNS Servers: 10.3.9.4
                      10.3.9.5
                      10.3.9.6
```

Found a DNS address `10.3.9.4`.

Now we add this address as the DNS server of `ns1`:

```
$ mkdir -p /etc/netns/ns1/
$ touch /etc/netns/ns1/resolv.conf
$ echo "nameserver 10.3.9.4" > /etc/netns/ns1/resolv.conf
```

Now run:

```
$ ip netns exec ns1 ping -c1 www.google.com
```

Should get a success ping.

For `ns2`, everything works the same. Except that you don't have to add that `POSTROUTING` rule twice. Just set the proper DNS server for `ns2`.

Finally, if you find adding `ip netns exec <namespace>` to every command executed inside a namespace too annoying, there is a way to enter a certain network namespace:

```
$ export NS=ns1
$ ip netns exec ${NS} /bin/bash --rcfile <(echo "PS1=\"${NS}> \"")
```

And...

That's it! Hope you had fun and met no strange problems.

Happy pinging!
