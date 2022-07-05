---
title: "Tezos Tickets"
date: 2022-07-05T12:00:00-05:00
draft: false
---

Here my understanding of tickets in the Jarkarta protocol of the Tezos blockchain, from the perspective of a developer interested in working with tickets.

----

A _ticket_ contains _content_: a value (string, number, list, etc) that is known to have been created by a particular Tezos account.
That account is known as the _creator_ or _ticketer_.

A ticket can be interpreted as if it were a value that has been signed by its creator.
A contract cannot create tickets with a creator other than itself.

Each ticket also has an associated _amount_, a non-negative number.

Tickets are created only by the *CREATE_TICKET* Michelson instruction.
The contract whose code executes that instruction becomes the creator of that ticket.

A smart contract can pass a ticket to another contract as the parameter of a transaction or when creating that contract.

There is no special instruction for transferring tickets; instead they are passed as a contract call parameter as above.

Tickets cannot be copied. When passed from one contract to another, the sending contract no longer has that ticket and the receiving contract does.

Tickets exist only in the storage of smart contracts (or on the stack when when executing Michelson code).

Said a different way, tickets do not exist as an account balance the way that the tez balance of an account does.  There is no ledger (account table) in the chain context that defines the tickets owned by each account.[^ticket_table]

[^ticket_table]: There does seem to be "ticket-balance table" or "table of tickets" that Octez uses to validate that no tickets are being created improperly. And I have seen hints that this is also being used to hold ticket balances for implicit accounts. Source, anyone?

If a contract creates a ticket, for the ticket to persist the contract must either add the new ticket to its storage, or pass it as parameter value to another contract; otherwise, the ticket is lost.

If a contract receives a ticket as a parameter, it must either add that ticket to its storage or pass it on to another contract; otherwise that ticket is lost.

The creator and content value of a ticket cannot be modifed.

Two tickets with the same creator and content value can be joined into a single ticket whose amount is the sum of the amounts of the joined tickets.  This consumes the two original tickets.

A ticket can be split into tickets, each of which has the same creator and content value as the original ticket and whose amounts sum to the amount of the original ticket. This consumes the original ticket.

Implicit accounts (those without smart contracts: tz1, tz2, tz3...) cannot create tickets, nor can they send or receive them. Only smart contract accounts (KT1...) can do that.[^implicit_sender]

[^implicit_sender]: Again, this might not be correct given work done to support TORU. Sources, anyone?

## My conclusions

There is no general way to create a "wallet" contract to receive, hold, and send arbitrary tickets sent to it.
This is because there are an unbounded number of types of tickets (in terms of the Michelson type, such as `ticket (pair int string)`, and each ticket type needs its own entrypoint and storage place to hold that ticket type.

A wallet for a single ticket type, such as `ticket string`, is feasible. The wallet contract could hold ticket values in a `big_map (pair address string) (ticket string)` where the big_map key is a ticket creator and content (string) value and the big_map value is the ticket joined from all received tickets with that key.

## Questions

1. When happens when a JOIN_TICKET instruction call fails? Are the original two tickets lost?

2. Similarly, what happens when a SPLIT_TICKET instruction call fails?

## References

[Tickets on Tezos](https://adoption-support.nomadic-labs.com/wp-content/uploads/2021/07/tickets_en.pdf): Brief whitepaper by Nomadic Labs 

[Tickets on Tezos — Part 1](https://medium.com/tqtezos/tickets-on-tezos-part-1-a7cad8cc71cd): Introduction to tickets on the Edo protocol, by TQ Tezos, Jan 2021.

[Ticket-tutorials](https://github.com/tqtezos/ticket-tutorials): Github repo with example Ligo Michelson code for tickets.

[Operations on tickets](https://tezos.gitlab.io/active/michelson.html?highlight=ticket#operations-on-tickets): Tezos developer docs.

[Contract signatures](https://forum.tezosagora.org/t/contract-signatures/1458/12): Original discussion in Tezos Agora.

[Tickets for dummies](https://forum.tezosagora.org/t/tickets-for-dummies/4564)
