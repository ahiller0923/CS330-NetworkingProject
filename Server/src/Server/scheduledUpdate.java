package Server;

import java.net.DatagramPacket;
import java.util.TimerTask;

public class scheduledUpdate extends TimerTask{
	clientUpdate callerFunction;
	private Server server;
	float bytesPerSecond;
	long startTime;
	
	scheduledUpdate(clientUpdate caller) {
		callerFunction = caller;
		server = caller.server;
		startTime = System.currentTimeMillis();
	}
	public void run() {
		if(server.protocol.game.inProgress) {
			server.response = server.protocol.formatResponse(1);
			for(int i = 0; i < server.protocol.game.players.size(); i++) {
				try {
					server.responsePacket = new DatagramPacket(server.response, server.response.length, 
							server.protocol.game.players.get(i).clientInfo.address, 
							server.protocol.game.players.get(i).clientInfo.port);
					
					server.socket.send(server.responsePacket);
					
					callerFunction.totalData += server.responsePacket.getData().length;

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


