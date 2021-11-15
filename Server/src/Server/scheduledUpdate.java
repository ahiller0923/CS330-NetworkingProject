package Server;

import java.net.DatagramPacket;
import java.util.TimerTask;

public class scheduledUpdate extends TimerTask{
	private Server server;
	
	scheduledUpdate(Server activeServer) {
		server = activeServer;
	}
	public void run() {
		while(!server.socket.isClosed()) {
			if(server.protocol.game.inProgress) {
				for(int i = 0; i < server.protocol.game.players.size(); i++) {
					try {
						server.response = server.protocol.formatResponse(1);
						server.responsePacket = new DatagramPacket(server.response, server.response.length, 
								server.protocol.game.players.get(i).clientInfo.address, 
								server.protocol.game.players.get(i).clientInfo.port);
						server.socket.send(server.responsePacket);
						System.out.println("Sent data");
					}
					catch(Exception ex) {
						ex.printStackTrace();
					}
				}
			}
			
			else if(server.protocol.game.playersConnected != server.protocol.game.players.size()) {
				for(int i = 0; i < server.protocol.game.players.size(); i++) {
					//server.response = protocol.formatResponse(0);
				}
			}
		}
	}
}

