package Server;

import java.util.Timer;

public class clientUpdate implements Runnable {
	Protocol protocol;
	Server server;
	int playerID;
	Timer timer;
	long ms;
	long dataSent;
	long startTime;
	long totalData;
	
	clientUpdate(Server activeServer) {
		protocol = activeServer.protocol;
		server = activeServer;
		timer = new Timer();
		ms = (1000 / 30);
		startTime = System.currentTimeMillis();
	}
	
	public void run() {
		
		timer.schedule(new scheduledUpdate(this), 0,  ms);
		
		System.out.println("Starting updates...");
		
		while(server.protocol.game.inProgress) {
			
			if(System.currentTimeMillis() - startTime >= 10000) {
				if(totalData >= 1000) {
					System.out.println((totalData / 10000) + " KBps");
				}
				else if(totalData >= 1000000) {
					System.out.println((totalData / 10000000) + " MBps");
				}
				else {
					System.out.println(totalData + "Bps");
				}
				startTime = System.currentTimeMillis();
				totalData = 0;
				//System.out.println(server.responsePacket.getData().length);
			}
		}
	}
}
