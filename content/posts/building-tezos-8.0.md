---
title: "Building Tezos 8.0"
date: 2020-12-22T14:23:05-06:00
draft: false
---

Building and running Tezos version 8.0 on an Ubuntu 18.04 system was a bit more complicated than usual.

### Install rust

Follow the directions at http://tezos.gitlab.io/introduction/howtoget.html#install-rust

### Get the version 8.0 code

Assuming one already has the 'latest-release' branch checked out, just do the usual

```
git pull
```

### Patch the git problem (Ubuntu 18.04 only)

Run the following from the top of the build directory:

```
git -C _build_rust/opam-repository config --local protocol.version 1
```

Without this the `make build-deps` step may fail with a message about "fatal: unknown value for config 'protocol.version': 2".

### Build as usual

```
make build-deps
eval $(opam env)
make
```

### Running the node

The tezos-node service now needs to access some Zcash parameters at runtime, and if it can't it will fail with a message about "Failed to initialize Zcash parameters".

One workaround is to run `eval $(opam env)` from the build directory before running tezos-node.

For running tezos-node via systemctl I found that setting the `OPAM_SWITCH_PREFIX` environment variable to the same value set as by `opam env` suffices.

```
diff -r cea309c135b3 systemd/system/tezos-node.service
--- a/systemd/system/tezos-node.service Tue Dec 22 13:54:50 2020 -0600
+++ b/systemd/system/tezos-node.service Tue Dec 22 14:11:02 2020 -0600
@@ -12,6 +12,7 @@
 Group          = fred
 WorkingDirectory= /home/fred/
 ExecStart      = /home/fred/bin-main/tezos-node run
+Environment    = "OPAM_SWITCH_PREFIX=/home/fred/tezos/_opam"
 Restart         = on-failure
 TimeoutSec     = 600
 FinalKillSignal        = SIGQUIT
 ```
 

