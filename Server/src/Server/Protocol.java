package Server;

import java.net.InetAddress;
import java.nio.*;

public class Protocol{
	String state;
	byte[] responseBuffer = new byte[200];
	Game game = new Game();
	Server server;
	
	Protocol(Server activeServer) {
		state = "WAITING";
		server = activeServer;
	}
	
	byte[] processRequest(byte[] incomingData) {
		ByteBuffer byteBuffer = ByteBuffer.wrap(incomingData);
		try {
			switch(byteBuffer.getInt()) {
				// Connection Request
				case 0:
					return formatResponse(0);
				// Input
				case 1:
					game.getPlayer(byteBuffer.getInt()).takeInput(byteBuffer.getInt());
					return new byte[0];
				case 2:
					
					game.getPlayer(byteBuffer.getInt()).connected = true;
					game.playersConnected++;
					if (game.playersConnected > 1 && game.playersConnected == game.players.size()) {
						startGame();
					}
					return formatResponse(1);
				default:
					System.out.println("Unrecognized Packet");
					return new byte[0];
			}
		}
		catch(Exception ex) {
			ex.printStackTrace();
			System.out.println(incomingData[0]);
			server.socket.close();
			return new byte[0];
		}
		
	}
	
	byte[] formatResponse(int responseType) {
		ByteBuffer byteBuffer = ByteBuffer.wrap(responseBuffer);
		switch(responseType) {
			case 0:
				if(state != "GAMEINPROGRESS") {
					game.players.add(new Player(game.players.size() + 1, new Client(server.receivePacket.getAddress(), server.receivePacket.getPort())));
					byteBuffer.putInt(0); // Type byte
					byteBuffer.putInt(game.players.get(game.players.size()-1).id); // Player ID
					System.out.println("Player " + game.players.get(game.players.size()-1).id + " has joined!");
					
					// Add player information to the buffer
					for (int i = 1; i <= game.players.size(); i++) {
						byteBuffer.putInt(0); // Byte indicating another player is coming
						byteBuffer.putFloat(game.getPlayer(i).position.x);
						byteBuffer.putFloat(game.getPlayer(i).position.y);
						byteBuffer.putFloat(game.getPlayer(i).velocity.x);
						byteBuffer.putFloat(game.getPlayer(i).velocity.y);
						byteBuffer.putFloat(game.getPlayer(i).size);
					}
					byteBuffer.putInt(-1); // Byte indicating that there are no more players
					
					if(game.players.size() > 1) {
						byteBuffer.putInt(1); // Byte indicating that game has started
					}
					else {
						byteBuffer.putInt(0); // Byte indicating that game has not started
					}
	
					return byteBuffer.array();
				}
				else {
					return new byte[] {-1};
				}
				
			case 1:
				byteBuffer.putInt(1);
				for (int i = 1; i <= game.players.size(); i++) {
					byteBuffer.putInt(0);
					if(game.getPlayer(i).alive == false) {
						byteBuffer.putInt(0); // Byte indicating that player has lost
					}
					else {
						byteBuffer.putInt(1); // Byte indicating that player is still in the game
						byteBuffer.putFloat(game.getPlayer(i).position.x);
						byteBuffer.putFloat(game.getPlayer(i).position.y);
						byteBuffer.putFloat(game.getPlayer(i).velocity.x);
						byteBuffer.putFloat(game.getPlayer(i).velocity.y);
						byteBuffer.putFloat(game.getPlayer(i).size);
					}
				}
				byteBuffer.putInt(-1);
				
				// Add bonus point information
				for(int x = 0; x < game.bonusPoints.size(); x++) {
					byteBuffer.putInt(0); // Byte indicating that more bonus point info is coming
					byteBuffer.putFloat(game.bonusPoints.get(x).position.x);
					byteBuffer.putFloat(game.bonusPoints.get(x).position.y);
				}
				byteBuffer.putInt(-1); // Byte indicating that no more bonus points are coming
				byteBuffer.putInt(0);
				
				return byteBuffer.array();
				
			default:
				return byteBuffer.array();
				
		}
	}
	
	void startGame() {
		game.inProgress = true;
		state = "GAMEINPROGRESS";
		game.startGame();
		clientUpdate update = new clientUpdate(server);
		Thread updateThread = new Thread(update, "Update");
		updateThread.start();
		
	}
}
