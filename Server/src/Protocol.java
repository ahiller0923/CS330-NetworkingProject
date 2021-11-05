import java.net.DatagramSocket;
import java.nio.*;
import java.util.LinkedList;

public class Protocol {
	String state;
	byte[] responseBuffer = new byte[1000];
	Game game = new Game();
	
	Protocol() {
		state = "WAITING";
	}
	
	byte[] processRequest(byte[] incomingData, DatagramSocket server) {
		ByteBuffer byteBuffer = ByteBuffer.wrap(incomingData);
		try {
			switch(byteBuffer.getInt()) {
				// Connection Request
				case 0:
					//System.out.println("Connection request received.");
					return formatResponse(game.players, game.bonusPoints, 0);
				// Input
				case 1:
					//System.out.println("User Input Received");
					game.getPlayer(byteBuffer.getInt()).takeInput(byteBuffer.getInt());
					return formatResponse(game.players, game.bonusPoints, 1);
				case 2:
					//System.out.println("Update Requested");
					return formatResponse(game.players, game.bonusPoints, 1);
				default:
					System.out.println("Unrecognized Packet");
					server.close();
					return new byte[0];
			}
		}
		catch(Exception ex) {
			ex.printStackTrace();
			System.out.println(incomingData[0]);
			server.close();
			return new byte[0];
		}
		
	}
	
	byte[] formatResponse(LinkedList<Player> players, LinkedList<Bonus> bonusPoints, int responseType) {
		ByteBuffer byteBuffer = ByteBuffer.wrap(responseBuffer);
		switch(responseType) {
			case 0:
				if(state != "GAMEINPROGRESS") {
					game.players.add(new Player(game.players.size() + 1));
					byteBuffer.putInt(0); // Type byte
					byteBuffer.putInt(game.players.getLast().id); // Player ID
					System.out.println("Player " + game.players.getLast().id + " has joined!");
					
					// Add player information to the buffer
					for (int i = 1; i <= players.size(); i++) {
						byteBuffer.putInt(0); // Byte indicating another player is coming
						byteBuffer.putFloat(game.getPlayer(i).position.x);
						byteBuffer.putFloat(game.getPlayer(i).position.y);
						byteBuffer.putFloat(game.getPlayer(i).velocity.x);
						byteBuffer.putFloat(game.getPlayer(i).velocity.y);
						byteBuffer.putFloat(game.getPlayer(i).size);
					}
					byteBuffer.putInt(-1); // Byte indicating that there are no more players
					
					if(game.players.size() > 1) {
						startGame();
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
				for (int i = 1; i <= players.size(); i++) {
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
				for(int x = 0; x < bonusPoints.size(); x++) {
					byteBuffer.putInt(0); // Byte indicating that more bonus point info is coming
					byteBuffer.putFloat(bonusPoints.get(x).position.x);
					byteBuffer.putFloat(bonusPoints.get(x).position.y);
				}
				byteBuffer.putInt(-1); // Byte indicating that no more bonus points are coming
				
				return byteBuffer.array();
				
			default:
				return byteBuffer.array();
				
		}
	}
	
	void startGame() {
		game.inProgress = true;
		state = "GAMEINPROGRESS";
		game.startGame();
		
	}
}
