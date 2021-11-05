# Circle Bash Protocol Documentation

## Request Types
There are a number of request types which can be sent from a client. The type of request contained in a packet is designated by the first byte which is called the <strong> type byte </strong>.

<strong> Connection Request </strong>
<p>
	A connection request is indicated by a type byte of 0. This request is sent when a client wants to make a "connection". Since this protocol is build upon UPD, an 	actual connection is not build here. Instead, the client is put in a game and assigned an ID. In this way, the server can identify a client and keep track of some 	sort of state for them without having an actual connection in the networking sense.
</p>

<strong> Input Request </strong>
<p>
	An input request is used to communicate player input to the server which keeps track of values such as player position and velocity. An input request is indicated by 	a type byte of 1 and contains the player ID and input value as data.
</p>

<strong> Update Request </strong>
<p>
	The update request is the most commonly sent request of them all. This request is denoted by a type byte of 2 and is used by the client to request the updated state 	of the game. It is also used as a means for the server to make sure that any host in the game is still there as update requests should be sent consistently.
</p>

## Response Types
