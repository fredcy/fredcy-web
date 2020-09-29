---
title: Building Tezos on Ubuntu 14.04
author: fred
type: post
date: 2016-11-23T17:46:37+00:00
url: /2016/11/23/building-tezos-on-ubuntu-14-04/
categories:
  - Uncategorized

---
Install opam and ocaml utilities. At this time this results in opam version 1.2.2 and ocaml 4.02.3.

    add-apt-repository ppa:avsm/ppa
    apt-get update
    apt-get install ocaml ocaml-native-compilers camlp4-extra opam
    

Add repo needed for libsodium-dev (at least) that the Tezos installation scripts will install.

    add-apt-repository ppa:ondrej/php
    apt-get update
    

Switch to Ocaml 4.03.0. [update: using 4.04.2 on 2017/09/05]

    opam init
    opam switch 4.03.0
    eval `opam config env`
    

Clone the tezos source repo to /opt/tezos.

Build dependencies per https://github.com/tezos/tezos

    cd /opt/tezos
    make build-deps
    

Install additional dependency manually. [update: no longer seems to be needed on 2017/09/05]

    opam install irmin.0.11.1
    

Build Tezos binaries.

    make
    

# Addendum

Thanks to @arthurb on the Tezos slack and to the folks on the #ocaml IRC list for all the help.

When I ran into trouble and had to start from near scratch, here are the (drastic) steps. (I don&#8217;t have other Ocaml projects, yet).

    rm -r $HOME/.opam
    cd /opt/tezos
    git clean -dxf
    

Then start again at `opam init`.