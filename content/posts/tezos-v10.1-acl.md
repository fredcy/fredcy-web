---
title: "Default ACL in Tezos v10.1"
date: 2021-08-07T08:30:00-05:00
draft: false
---

TL;DR:  Configure the tezos-node RPC port with `--rpc-addr localhost:8732` rather than (or in addition to, if providing remote RPC access) `--rpc-addr :8732`

## Default ACL for RPC

The v10.1 release of the Octez software adds a new [default ACL for
RPC](https://tezos.gitlab.io/user/node-configuration.html#default-acl-for-rpc) feature, and the way it works is subtle.

> If the listening address resolves to the loopback network interface, then full access to all endpoints is granted

> If the listening address is a network address, then a more restrictive policy applies.

The upshot of these is that specifying the node's RPC listening address as `:8732` -- as it does not explicitly mention `localhost` or `127.0.0.1` -- is treated as the network address case and the restrictive default policy applies, even when the client is connecting to `localhost`.  The baker and endorser clients connect to `localhost:8732` by default and are thus blocked by the default restrictive policy, resulting in messages that include:

    error: The server doesn't authorize this endpoint (ACL filtering). 

## What to do if you get the ACL error

If your node's RPC is not accessed from outside the server, then you probably want to restrict the RPC port to listen only on `localhost` (or, equivalently, `127.0.0.1`)

If you manage your node's config file you can do this and restart tezos-node:

    tezos-node config update --rpc-addr localhost:8732
	
If you use the default config file, setting options on the run command line, then you could start tezos-node this way:

	tezos-node run --rpc-addr localhost:8732 ...other options here...
	
If your node's RPC _is_ accessed remotely then (per Pierre Boutillier) you probably want to set up two RPC listeners, one for `localhost` and one for remote access. For the latter you will probably want to set up [explicit ACL rules](https://tezos.gitlab.io/user/node-configuration.html#rpc-parameters) to allow/deny specific RPCs to protect the node (which is beyond the scope of this posting). The `--rpc-addr` option can be specified multiple times to `tezos-node run` or `tezos-node config update` to specify multiple listeners:

    ... --rpc-addr localhost:8732 --rpc-addr :8732
	
A quick and insecure way to allow all RPCs for remote access is by adding the `--allow-all-rpc :8732` option to the above.

### Alternative explanation 

Here is how Pierre Boutillier puts it on the Baking Slack (lightly edited by me):

If you configured `--rpc-addr` to something else than `localhost:...` and want to do something forbidden by the ACL, you have two possibilities:

* if your baker/endorser/accusser/client/... is actually on the same machine, add an extra `--rpc-addr localhost:...` in addition of your old `--rpc-addr` and use `localhost` as the target of your RPCs. This configuration is safe (as long as access on your machine is secured)

* if not; use `--allow-all-rpc [XXX]` with `[XXX]` being the exact same string as what you put as `--rpc-addr` argument. This configuration may not be safe.
