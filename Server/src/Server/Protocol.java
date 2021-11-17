package Server;
import java.nio.*;
import java.util.Timer;

public class Protocol{
	String state;
	Game game = new Game();
	Server server;
	int tick = 0;
	boolean packetLoss = false;
	
	
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
					int seqNumber = byteBuffer.getInt();
					Player player = game.getPlayer(byteBuffer.getInt());
					if(player.processedInputs[seqNumber] == 0) {
						int input = byteBuffer.getInt();
						player.takeInput(input);
						player.processedInputs[seqNumber] = input;
						
						if(seqNumber + 1 < 60) {
							player.processedInputs[seqNumber + 1] = 0;
						}
						else {
							player.processedInputs[0] = 0;
						}
					}
					ByteBuffer response = ByteBuffer.wrap(new byte[8]);
					response.putInt(2);
					response.putInt(seqNumber);
					return response.array();
					
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
		ByteBuffer byteBuffer = ByteBuffer.wrap(new byte[500]);
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
				byteBuffer.putInt(tick);
				byteBuffer.putLong(System.currentTimeMillis());
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
				
				/*try {
					TimeUnit.MILLISECONDS.sleep(100); // Simulate latency
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}*/
				
				// Simulate packet loss
				if(packetLoss) {
					packetLoss = false;
					return new byte[0];
				}
				else {
					packetLoss = true;
				}
				
				return byteBuffer.array();
				
			default:
				return byteBuffer.array();
				
		}
	}
	
	void startGame() {
		game.inProgress = true;
		state = "GAMEINPROGRESS";
		Timer Timer = new Timer();
		scheduledUpdate update = new scheduledUpdate(this);
		Timer.schedule(update, 0, game.ms);
	}
}
