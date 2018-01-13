---
title: "Mininet Installation and Walkthrough"
date: 2017-03-03T16:23:47+08:00
draft: false
tags: ["Mininet", "Openflow", "SDN"]
---

Record of Mininet installation and walkthrough.

<!--more-->

## Installation

I installed Mininet on my native machine thus did not go the VM way (which is recommended on the official site). Here's just a record of how to manually install Mininet on my native Ubuntu 16.04.

```shell
$ git clone git://github.com/mininet/mininet
$ sudo mininet/util/install.sh -a
```

Where `-a` means "install all". Including OVS, OpenFlow wireshark dissector and POX.

After the installation is finished, test the basic Mininet functionality:

```shell
$ sudo mn --test pingall
```



## Walkthrough

### Part 1: Everyday Usage

#### Start Wireshark

Open wireshark in the background:

```shell
$ sudo wireshark &
```

In wireshark filter box, enter:

```
openflow
```

Click Capture>Options, select Start on the loopback interface (`lo`).

For now, there should be no OpenFlow packets displayed in the main window.

#### Interact with Hosts and Switches

Start another terminal and enter:

```shell
$ sudo mn
```

To start a minimal (default) topology, which includes one OpenFlow kernel switch connected to two hosts, plus the OpenFlow reference controller.

With the Mininet CLI comes up,
