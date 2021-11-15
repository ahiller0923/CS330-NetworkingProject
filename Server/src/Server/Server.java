package Server;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.util.ArrayList;


public class Server {
	DatagramSocket socket;
	byte[] receive = new byte[1000];
	byte[] response = new byte[1000];
	DatagramPacket responsePacket;
	DatagramPacket receivePacket;
	Protocol protocol = new Protocol(this);
	
	Server() {
		try {
			socket = new DatagramSocket(8082);
		}
		catch(Exception ex) {
			ex.printStackTrace();
		}
	}
	
	public void start() {
		receivePacket = new DatagramPacket(receive, receive.length);

		clientUpdate update = new clientUpdate(this);
		Thread updateThread = new Thread(update, "Update");
		updateThread.start();
		
		if (socket != null) {
			System.out.println("Server is running.");
			while(!socket.isClosed()) {
				
				if(socket == null) {
					break;
				}
				try {
					socket.receive(receivePacket);
					response = protocol.processRequest(receivePacket.getData());
					responsePacket = new DatagramPacket(response, response.length, receivePacket.getAddress(), receivePacket.getPort());
					socket.send(responsePacket);
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
