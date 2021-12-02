package Server;

import java.net.DatagramPacket;
import java.util.TimerTask;

public class scheduledUpdate extends TimerTask{
	private Server server;
	private Protocol protocol;
	float bytesPerSecond;
	long startTime;
	long totalData = 0;
	int keepRunning = 20;
	
	scheduledUpdate(Protocol activeProtocol) {
		protocol = activeProtocol;
		server = protocol.server;
		startTime = System.currentTimeMillis();
	}
	public void run() {
		if(protocol.game.inProgress) {
			protocol.game.updateGameState();
			server.response = protocol.formatResponse(1);
			for(int i = 0; i < protocol.game.players.size(); i++) {
				try {
					server.responsePacket = new DatagramPacket(server.response, server.response.length, 
							protocol.game.players.get(i).clientInfo.address, 
							protocol.game.players.get(i).clientInfo.port);
					
					server.socket.send(server.responsePacket);
					
					totalData += server.responsePacket.getData().length;

				}
				catch(Exception ex) {
					ex.printStackTrace();
				}
			}
			/*if(protocol.game.playersAlive < 2) {
				if(keepRunning == 20) {
					System.out.println("Game has ended, halting communication...");
				}
				keepRunning--;
			}*/
		}
		
		
		if(System.currentTimeMillis() - startTime >= 10000) {
			bytesPerSecond = (totalData/(System.currentTimeMillis() - startTime)) * 1000;
			
			if(bytesPerSecond >= 1000 && bytesPerSecond < 10000000) {
				System.out.println((bytesPerSecond / 1000) + " KBps");
			}
			else if(bytesPerSecond >= 1000000) {
				System.out.println((bytesPerSecond / 1000000) + " MBps");
			}
			else {
				System.out.println(bytesPerSecond + "Bps");
			}
			startTime = System.currentTimeMillis();
			totalData = 0;
		}
	}
}


