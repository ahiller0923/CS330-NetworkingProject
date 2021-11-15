package Server;

import java.net.InetAddress;

public class Client {
	InetAddress address;
	int port;
	
	Client(InetAddress srcAddress, int srcPort) {
		address = srcAddress;
		port = srcPort;
	}
}
