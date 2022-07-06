---
title: "Tezos Tickets"
date: 2022-07-05T12:00:00-05:00
draft: false
---

Here my understanding of tickets in the Jarkarta protocol of the Tezos blockchain, from the perspective of a developer interested in working with tickets.

----

A ticket comprises a _creator_, a _value_, and an _amount_.

A ticket's _creator_ (or _ticketer_) is the address of the contract that created the ticket.
Tickets are created only by the `TICKET` Michelson instruction in that smart contract's code.

A ticket's _value_ is set by the creator when it creates the ticket, and cannot be changed later.
Such a ticket value can be any [comparable type](https://tezos.gitlab.io/michelson-reference/#types) in Michelson: int, string, bytes, etc.

A ticket's _amount_, a `nat` value (non-negative integer) is also set by the creator, and cannot be changed later.

A ticket can be split into two tickets, each of which has the same creator and value (sometimes called the _ticket key_) as the original ticket and whose amounts sum to the amount of the original ticket. This consumes the original ticket and creates two tickets in its place.

Two tickets with the same creator and value (ticket key) can be joined into a single ticket whose amount is the sum of the amounts of the joined tickets.  This consumes the two original tickets and creates a single ticket in their place.

A ticket can be interpreted as if it were a value that has been signed (or "stamped") by its creator.
A contract cannot create tickets with a creator other than itself.
A contract knows that any tickets with itself as creator are ones that it created itself; they cannot be forged any other way.

A smart contract can pass a ticket to another contract as the parameter of a transaction or when creating that contract.

There is no special instruction for transferring tickets; instead they are passed as a contract call parameter as above.

Tickets cannot be copied. When passed from one contract to another, the sending contract no longer has that ticket and the receiving contract does.

Tickets exist only as explicit values in the storage of smart contracts (or on the stack when when executing Michelson code).

Said a different way, tickets do not exist as an implicit account balance the way that the tez balance of an account does.  There is no accessible ledger (account table) in the chain context that defines the tickets owned by each account.[^ticket_table]

[^ticket_table]: There does seem to be "ticket-balance table" or "table of tickets" that Octez uses to validate that no tickets are being created improperly. And I have seen hints that this is also being used to hold ticket balances for implicit accounts. But this ticket table is not accessible by contact code or via RPC. Source, anyone?

If a contract creates a ticket, for the ticket to persist the contract must either add the new ticket to its storage or pass it as parameter value to another contract; otherwise, the ticket is lost.

If a contract receives a ticket as a parameter, it must either add that ticket to its storage or pass it on to another contract; otherwise that ticket is lost.

Implicit accounts (those without smart contracts: tz1, tz2, tz3...) cannot create tickets, nor can they send or receive them. Only smart contract accounts (KT1...) can do that.[^implicit_sender]

[^implicit_sender]: Again, this might not be correct given work done to support TORU. Sources, anyone?

Similarly, tickets cannot be created from outside of a smart contract, say from a dApp or the tezos-codec utility.
There is no way to forge a ticket other than by a smart contract calling the `TICKET` instruction.
Tickets can be passed from one contract to another, but not into the initial entry transaction into a contract.

## My conclusions

There is no general way to create a "wallet" contract to receive, hold, and send arbitrary tickets sent to it.
This is because there are an unbounded number of types of tickets (in terms of the Michelson type, such as `ticket (pair int string)`, and each ticket type needs its own entrypoint and storage place to hold that ticket type.

A wallet for a single ticket type, such as `ticket bytes`, is feasible. The wallet contract could hold ticket values in a `big_map (pair address bytes) (ticket bytes)` where the big_map key is a ticket creator and content (bytes) value and the big_map value is the ticket joined from all received tickets with that key. [^deku_bridge]

[^deku_bridge]: Looks like the [contract for the Deku bridge](https://better-call.dev/jakartanet/KT1Pva88UhurSSYF1efm4AVpM1xTZ3kYDm1T/code) does something like that.

## Questions

1. When happens when a `JOIN_TICKET` instruction call returns `None`, as in the cases where the input tickets do not share the same ticket key?  Are the input tickets lost? Or does the code execution fail and retract such that the input tickets survice in the storage or in the caller (when passed as parameters)?

2. Similarly, what happens when a `SPLIT_TICKET` instruction call returns `None`, as when the requested amounts do not sum to the amount of the input ticket?

## References

[Tickets on Tezos](https://adoption-support.nomadic-labs.com/wp-content/uploads/2021/07/tickets_en.pdf): Brief whitepaper by Nomadic Labs 

[Tickets on Tezos — Part 1](https://medium.com/tqtezos/tickets-on-tezos-part-1-a7cad8cc71cd): Introduction to tickets on the Edo protocol, by TQ Tezos, Jan 2021.

[Ticket-tutorials](https://github.com/tqtezos/ticket-tutorials): Github repo with example Ligo Michelson code for tickets.

[Operations on tickets](https://tezos.gitlab.io/active/michelson.html?highlight=ticket#operations-on-tickets): Tezos developer docs.

[Contract signatures](https://forum.tezosagora.org/t/contract-signatures/1458/12): Original discussion in Tezos Agora.

[Tickets for dummies](https://forum.tezosagora.org/t/tickets-for-dummies/4564)

[Tickets](https://docs.nomadic-labs.com/nomadic-labs-knowledge-center/tickets-on-tezos): Summary of tickets by Nomadic Labs Knowledge Center.
