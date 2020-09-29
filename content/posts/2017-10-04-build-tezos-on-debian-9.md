---
title: Build Tezos from source for alphanet on Debian 9
author: fred
type: post
date: 2017-10-04T21:24:58+00:00
draft: true
private: true
url: /2017/10/04/build-tezos-on-debian-9/
categories:
  - technical
tags:
  - tezos

---
This explains how to build a Tezos node from source on Debian 9 such that it runs on the alphanet. Building from source is more complicated than just running the docker image but it allows us to easily place the Tezos data in a filesystem that is tuned for the purpose and makes better use of the available disk space.

Build instructions also appear at https://github.com/tezos/tezos. This document just gives some specifics for Debian 9 and optimizes the file space as above.

(If you are not concerned about disk space, just ignore the steps below that refer to the &#8220;home&#8221; partition or &#8220;/dev/sdc&#8221;. Similarly, this uses Debian 9 as the base since that distro is fairly lightweight, easily available on linode.com, and has the necessary dependent packages for building tezos. Other distros will work but you may have issues getting the right version of libsodium / libsodium-dev.)

At linode.com [[1]][1], create a new 1024 Linode instance ($5/month)  
_[edit, March 2018: The alphanet at level 98000 seems to require to require an 8192 instance! Even a 4096 instance seems to lag and require restarts.]_

  1. Deploy the Debian 9 image on it allocating 2000 MB.
  2. Create a new disk labeled as &#8220;home&#8221;, raw/unformatted, using all remaining available space.
  3. Assign that &#8220;home&#8221; disk to /dev/sdc in the configuration profile.
  4. Boot the linode.

Login to the server and update it.

    $ ssh root@173.255.xxx.xxx
    $ apt-get update
    $ apt-get upgrade -y
    

Create the filesystem that will hold the Tezos blockchain and other meta-data. This data comprises many small files so we override ext4 defaults to use small blocks, more inodes, and the minimal inode size.

    $ mkfs.ext4 -b 1024 -i 1024 -I 128 /dev/sdc
    $ mount /dev/sdc /home
    

Create the user [[2]][1] where we will finish the installation and run Tezos:

    $ adduser tezos
    $ adduser tezos sudo
    $ su - tezos
    

Install the base packages needed:

    $ sudo apt-get install -y patch unzip make gcc m4 git g++
    

Install the necessary OPAM (Ocaml) tools. (These steps can take five or so minutes apiece):

    $ wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | sh -s /usr/local/bin
    $ opam switch "tezos" --alias-of 4.04.2
    $ eval `opam config env`
    

Get tezos code:

    $ git clone -b alphanet https://github.com/tezos/tezos.git
    $ cd tezos
    

Build (takes a long time; there are several user-prompts requiring responses early on; this will install some additional packages as needed such as leveldb[[3]][1]):

    $ make build-deps
    $ make
    

Note: The above two build steps fail as of 2017/12/06. See [a workaround][2] at GitHub issues.

See https://github.com/tezos/tezos/tree/alphanet#compilation-from-sources for the steps to run your alphanet node.

Here is one way to start the node service so that the RPC port (8732) is available remotely and CORS support is enabled:

    $ ./tezos-node run --rpc-addr='*' --connections=16 --cors-header='content-type' --cors-origin='*'
    

I run it inside a `screen` session so that it hangs around after I log out.

Another option is to run it in the background this way (with no CORS support, arbitrarily):

    $ nohup ./tezos-node run --rpc-addr='*' --connections=16 >node.log 2>&1 &
    

That runs tezos-node in the background (because of the final `&`), writes its output to a node.log file, and continues after you log out (because of the initial `nohup` command wrapper).

#### Footnotes {#footnotes}

  1. Linode only because that&#8217;s the VPS host I know best. If you should happen to create an account at linode, my referral code is [da62f5a3a544121428ed41f357c3056c1f51091a][3] &#8212; I&#8217;d get $20 credit and you&#8217;d get my gratitude.
  2. It&#8217;s not strictly necessary to create a new user (`tezos` in the above) to build and run tezos &#8212; you can do it as the default root user &#8212; but it&#8217;s good security practice to do as little as possible as root.
  3. Version 1.18 of the leveldb libraries is required. Newer versions may compile but are prone to runtime errors when used with tezos. Building on Debian 9 currently gets the correct version; if you build on the latest Ubuntu you&#8217;ll have to force-install leveldb 1.18 somehow before running `make build-deps`.

 [1]: #footnotes
 [2]: https://github.com/tezos/tezos/issues/142
 [3]: https://www.linode.com/?r=da62f5a3a544121428ed41f357c3056c1f51091a