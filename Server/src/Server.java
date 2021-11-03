import java.util.LinkedList;
import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;


public class Server {
	DatagramSocket socket;
	byte[] receive = new byte[1000];
	static byte[] response = new byte[1000];
	static DatagramPacket responsePacket;
	Protocol protocol = new Protocol();
	
	Server() {
		try {
			socket = new DatagramSocket(8080);
		}
		catch(Exception ex) {
			ex.printStackTrace();
		}
	}
	
	public static void main(String args[]) {
		Server server = new Server();
		DatagramPacket receivePacket = new DatagramPacket(server.receive, server.receive.length);
		
		if (server.socket != null) {
			System.out.println("Server is running.");
			while(!server.socket.isClosed()) {
				
				if(server.socket == null) {
					break;
				}
				try {
					server.socket.receive(receivePacket);
					response = server.protocol.processRequest(receivePacket.getData(), server.socket);
					responsePacket = new DatagramPacket(response, response.length, receivePacket.getAddress(), receivePacket.getPort());
					server.socket.send(responsePacket);
				}
				catch(Exception ex) {
					ex.printStackTrace();
				}
				
			}
		}
	}
}
