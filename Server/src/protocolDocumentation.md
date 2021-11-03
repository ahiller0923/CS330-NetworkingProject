# Circle Bash Protocol Documentation

## Data Type Header

The first byte of data indicates what information the message includes.

<strong> Translation Guide </strong>
<ul>
	<li> 0 = Connection Request/Response </li>
	<li> 1 = Player State Update </li>
	<li> 2 = Bonus State Update </li>
</ul>

## Response to Connection Request
The server response to each connection request will follow the same routine for each case.

1) Send the client their player data.
 <ul>
 	<li> Player ID </li>
 	<li> Player Position </li>
 	<li> Player Size </li>