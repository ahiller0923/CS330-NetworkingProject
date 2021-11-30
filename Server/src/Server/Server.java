package Server;
import java.net.DatagramPacket;
import java.net.DatagramSocket;

public class Server {
	DatagramSocket socket;
	byte[] receive = new byte[200];
	byte[] response = new byte[200];
	DatagramPacket responsePacket;
	DatagramPacket receivePacket;
	Protocol protocol = new Protocol(this);
	
	Server() {
		try {
			socket = new DatagramSocket(8081);
		}
		catch(Exception ex) {
			ex.printStackTrace();
		}
	}
	
	
	/**
	 * Opens up the server to receive packets from clients
	 */
	public void start() {
		// Initialize packet which will store incoming data
		receivePacket = new DatagramPacket(receive, receive.length);
		
		// As long as the socket is not null and is not closed, listen for incoming communication
		if (socket != null) {
			System.out.println("Server is running.");
			while(!socket.isClosed()) {
				try {
					socket.receive(receivePacket);
					// Process the incoming data using the protocol
					response = protocol.processRequest(receivePacket.getData());
					responsePacket = new DatagramPacket(response, response.length, receivePacket.getAddress(), receivePacket.getPort());
					// If response is not empty, send it
					if(responsePacket.getData().length > 0) {
						socket.send(responsePacket);
					}
				}
				catch(Exception ex) {
					ex.printStackTrace();
				}
				
			}
		}
	}
	
	public static void main(String args[]) {
		Server server = new Server();
		server.start();
	}
}
