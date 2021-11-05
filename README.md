# CS330-NetworkingProject: <i>Diametrical Brawl</i>
## Running the Program
### Server
In order to run the server, open the <i>Server</i> project folder in an IDE (I use Eclipse) and set the run configuration to run the main class in <i>Server.java</i>

If restarting the program, make sure to terminate the current execution. If you do not, the socket will not be closed and you will run into trouble when trying to run the server again since it the socket is already in use.

As of now, the server is set up to ignore connection requests after two players have joined. Because of this, if you want to start a new game, you will need to terminate the server and restart it.

### Client
I have included executables for Windows and Linux machines for the client program. Navigate to <i>Client/Board/application.linux</i> or <i>Client/Board/application.windows</i> to locate the executable files for each.

<i>*Note: Make sure to run the server in the IDE before running the client program. You can ensure the server is running since it will print to the console saying so. If you do not run the server first, the client will still try to contact it and thus it will not work.</i>

As of now, you must run the client twice before playing the game. The server will not start the game until there are more than two players. When only one player joins, it will think that single player has won the game and will behave as such. Ideally this will not be the case in the future, but for now, just make sure to run the program twice before attempting to play.
