package Server;

import java.util.Timer;

public class clientUpdate implements Runnable {
	Protocol protocol;
	Server server;
	int playerID;
	Timer timer;
	int ms;
	
	clientUpdate(Server activeServer) {
		protocol = activeServer.protocol;
		server = activeServer;
		timer = new Timer();
		ms = 1000 / 60;
	}
	
	public void run() {
		timer.schedule(new scheduledUpdate(server), 0, ms);
	}
}
