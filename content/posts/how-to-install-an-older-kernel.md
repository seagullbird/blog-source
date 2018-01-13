---
title: "How to Install an Older Kernel on Ubuntu"
date: 2017-03-31T14:06:04+08:00
draft: false
tags: ["Linux", "Ubuntu"]
---

A simple tutorial for installing an older kernel on Ubuntu.

<!--more-->

These days I've been working on our SDN project. Our project is based on a customed OVS which used an older version of OVS as its fundation. The problem is, this version of OVS cannot be properly built on a machine with Linux kernel version higher than 3.8 or lower than 2.7. At the beginning I downloaded and installed a Ubuntu 12.04.1 with Linux kernel 3.2.0-29-generic as its original kernel. However, Ubuntu 12.04 is relatively old now and some of its apt sources are out-dated. This caused problems when installing prerequisites for my project. Thus, I figured out a way to install and use an older kernel on the latest version of Ubuntu, so that I can get my project properly built while leveraging the best of latest apt sources. Here's how I installed linux-3.2.0-56-generic on my Ubuntu 16.04 and boot with it. It's actually quite simple.

## Install Ubuntu

Just download the latest LTS version of Ubuntu (for me now it is 16.04) from its official site and install it with your VMware or anything.

## Install Older Kernel

In your newly intalled Ubuntu, use browser and navigate [here](http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.2.56-precise/) to download the following files (xxxxxx will be replaced with numbers indicating the kernel version. Assuming you have a 64bit OS):

*linux-headers-xxxxxx-generic-xxxxxx_amd64.deb*

*linux-headers-xxxxxx_all.deb*

*linux-image-xxxxxx-generic-xxxxxx_amd64.deb*

Then there is one more thing you have to get before installing:

```shell
$ sudo apt install -y module-init-tools
```

After this, move all there files you've just downloaded to a new folder and `cd` to the new folder and run:

```shell
$ sudo dpkg -i *.deb
```

## Boot Into the 'New' Kernel

Reboot your computer.

Press left (or right, you should try both) `SHIFT` key at the booting stage and log into Grub. Choose your newly installed kernel to boot, and you're ready to go!
