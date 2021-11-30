package Server;
import java.io.IOException;
import java.net.DatagramPacket;
import java.net.InetAddress;
import java.nio.*;
import java.util.Timer;
import java.util.concurrent.TimeUnit;

public class Protocol{
	String state;
	Game game = new Game();
	Server server;
	boolean alreadyConnected;
	
	Protocol(Server activeServer) {
		state = "WAITING";
		server = activeServer;
	}
	
	byte[] processRequest(byte[] incomingData) {
		ByteBuffer byteBuffer = ByteBuffer.wrap(incomingData);
		ByteBuffer response;
		Player player = null;
		
		try {
			switch(byteBuffer.getInt()) {
				// Connection Request
				case 0:
					return formatResponse(0);
				// Input
				case 1:
					int seqNumber = byteBuffer.getInt();
					player = game.getPlayer(byteBuffer.getInt());
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
					response = ByteBuffer.wrap(new byte[8]);
					response.putInt(2);
					response.putInt(seqNumber);
					return response.array();
					
				case 2:
					player = game.getPlayer(byteBuffer.getInt());
					if (player.connected != true) {
						player.connected = true;
						game.playersConnected++;
						newPlayer(game.getPlayer(game.players.size()).clientInfo);
						System.out.println("Player " + player.id + " has joined!");
					}
					
					response = ByteBuffer.wrap(new byte[4]);
					response.putInt(4);
					return response.array();

					
					
				case 3:
					if(game.playersConnected > 1 && game.playersConnected > 1) {
						startGame();
						System.out.println("Game Started");
					}
					return new byte[0];
					
				default:
					System.out.println("Unrecognized Packet");
					return new byte[0];
			}
		}
		catch(Exception ex) {
			ex.printStackTrace();
			System.out.println(incomingData[0]);
			return new byte[0];
		}
		
	}
	
	byte[] formatResponse(int responseType) {
		ByteBuffer byteBuffer = ByteBuffer.wrap(new byte[500]);
		switch(responseType) {
			case 0:
				Player player = null;
				byteBuffer.putInt(0); // Type byte
				if(state != "GAMEINPROGRESS") {
					for(int i = 0; i < game.players.size(); i++) {
						
						if(game.getPlayer(i + 1).clientInfo.address == server.receivePacket.getAddress() && game.getPlayer(i + 1) .clientInfo.port == server.receivePacket.getPort()) {
							player = game.getPlayer(i + 1);
							alreadyConnected = true;
							break;
						}
					}
					
					if(!alreadyConnected) {
						game.players.add(new Player(game.players.size() + 1, new Client(server.receivePacket.getAddress(), server.receivePacket.getPort())));
						byteBuffer.putInt(game.players.get(game.players.size()-1).id); // Player ID
					}
					else {
						byteBuffer.putInt(player.id);
						alreadyConnected = false;
					}
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
	
					return byteBuffer.array();
				}
				else {
					return new byte[] {-1};
				}
				
			case 1:
				byteBuffer.putInt(1);
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
				
				return byteBuffer.array();	
				
			default:
				return byteBuffer.array();
				
		}
	}
	
	void newPlayer(Client exclude) {
		ByteBuffer newPlayerMsg = ByteBuffer.wrap(new byte[8]);
		newPlayerMsg.putInt(3);
		newPlayerMsg.putInt(game.playersConnected);
		
		for(int i = 0; i < game.players.size(); i++) {
			try {
				server.responsePacket = new DatagramPacket(newPlayerMsg.array(), newPlayerMsg.array().length, 
						game.players.get(i).clientInfo.address, 
						game.players.get(i).clientInfo.port);
				
				server.socket.send(server.responsePacket);
			}
			catch(Exception ex) {
				ex.printStackTrace();
			}
		}
	}
	
	void startGame() {
		game.inProgress = true;
		state = "GAMEINPROGRESS";
		Player player = null;
		ByteBuffer byteBuffer = ByteBuffer.wrap(new byte[4]);
		byteBuffer.putInt(-1);
		for(int i = 1; i <= game.players.size(); i++) {
			player = game.getPlayer(i);
			if(player.connected != true) {
				try {
					server.socket.send(new DatagramPacket(byteBuffer.array(), byteBuffer.array().length, player.clientInfo.address, player.clientInfo.port));
					player.alive = false;
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
		Timer Timer = new Timer();
		scheduledUpdate update = new scheduledUpdate(this);
		Timer.schedule(update, 0, game.ms);
	}
}
