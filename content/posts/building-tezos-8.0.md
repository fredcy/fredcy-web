---
title: "Building Tezos 8.0"
date: 2020-12-22T14:23:05-06:00
draft: false
---

Building and running Tezos version 8.0 on an Ubuntu 18.04 system was a bit more complicated than usual. Here is a build procedure that works.

### Install rust

Follow the directions at http://tezos.gitlab.io/introduction/howtoget.html#install-rust.
This only needs to be done once on any given build machine.

### Get the version 8.0 code

Assuming one already has the 'latest-release' branch checked out, just do the usual

```
git pull
```

### Start the build as usual

```
make build-deps
```

This will work for a while and then fail with a message about "fatal: unknown value for config 'protocol.version': 2".

### Patch the git problem (Ubuntu 18.04 only)

Run the following from the top of the build directory:

```
git -C _build_rust/opam-repository config --local protocol.version 1
```

Note that we can't apply this patch until we've run `make build-deps` at least once as it depends on files created by that step.

### Continue the build as usual

```
make build-deps
eval $(opam env)
make
```

This time the build-deps step should finish without error.

### Running the node

The tezos-node service now needs to access some Zcash parameters at runtime, and if it can't it will fail with a message about "Failed to initialize Zcash parameters".

Option 1: One workaround is to run `eval $(opam env)` from the build directory before running tezos-node.

Option 2: For running tezos-node via systemctl I found that setting the `OPAM_SWITCH_PREFIX` environment variable to the same value set as by `opam env` suffices.

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

Option 3: Perhaps the best option is to install the Zcash parameters independently from the build directory. This is described at https://tezos.gitlab.io/introduction/howtoget.html#install-rust where it recommends downloading and running https://raw.githubusercontent.com/zcash/zcash/master/zcutil/fetch-params.sh. This does result in about 740MB of data in ~/.zcash-params. The tezos-node runtime automatically finds the Zcash parameters there.

## Credits

Thanks to Romain Bardou for some corrections to what I originally wrote here.

