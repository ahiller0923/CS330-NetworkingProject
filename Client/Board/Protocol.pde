import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.util.LinkedList;
import java.util.Arrays;
import java.nio.ByteBuffer;

public class Protocol {
  byte[] incomingBuf;
  byte[] outgoingBuf;
  DatagramPacket outgoingPacket;
  DatagramPacket incomingPacket;
  InetAddress server;
  DatagramSocket socket;
  int port;
  String state;
  Game game;
  
  Protocol (InetAddress target, int portNumber, int bufSize, Game localGame) {
    outgoingBuf = new byte[bufSize];
    incomingBuf = new byte[bufSize];
    incomingPacket = new DatagramPacket(incomingBuf, incomingBuf.length);
    server = target;
    port = portNumber;
    game = localGame;
    state = "WAITING";
    try {
      socket = new DatagramSocket();
    }
    catch(Exception ex) {
      System.out.println(ex);
    }
  }
    
  // Prepare data to be sent
  DatagramPacket prepareForTransmission(int[] intData) {
    ByteBuffer byteData = ByteBuffer.allocate(4 * intData.length);
    
    if (intData != null && intData.length > 0) {
      for (int i = 0; i < intData.length; i++) {
        byteData.putInt(intData[i]);
      }
    }
    else {
      System.out.println("Transmission data is null.");
    }
    
    return new DatagramPacket(byteData.array(), byteData.array().length, server, port);
  }
  
  // Request connection to server
  void Connect() {
    if(state == "WAITING") {
      ByteBuffer byteBuffer = ByteBuffer.wrap(outgoingBuf);
      byteBuffer.putInt(0);
      byteBuffer.put("Connect".getBytes());
      outgoingBuf = byteBuffer.array();
      outgoingPacket = new DatagramPacket(outgoingBuf, outgoingBuf.length, server, port);
      try {
        socket.send(outgoingPacket);
      } catch(Exception ex) {
        System.out.println("Connection Error: " + ex);
      }
      finally {
        state = "CONNECTION_REQUESTED";
        System.out.println("Connection Request Sent Successfully");
      }
    }
  }
  
  void Listen() {
    try {
      socket.setSoTimeout(200);
      socket.receive(incomingPacket);
      processResponse(incomingPacket.getData());
    }
    catch(Exception ex) {
      ex.printStackTrace();
      return;
    }
  }
  
  void send(int transmissionType, int[] data) {
    outgoingPacket = prepareForTransmission(data);
    try {
      socket.send(outgoingPacket);
    }
    catch(Exception ex) {
      ex.printStackTrace();
    }
  }
  
  void requestUpdate() {
    int[] data = new int[] {2};
    
    send(2, data);
    
    Listen();
  }
  
  void processResponse(byte[] serverResponse) {
    ByteBuffer byteBuffer = ByteBuffer.wrap(serverResponse);
    try {
      switch(byteBuffer.getInt()) {
        case 0:
          parseData(byteBuffer, 0);
          break;
        case 1: 
          parseData(byteBuffer, 1);
          System.out.println("Update Received");
          break;
        default:
          System.out.println("Data not parsed");
      }
    }
    catch(Exception ex) {
      ex.printStackTrace();
    }
  }
  
  void parseData(ByteBuffer byteBuffer, int dataContentIndicator) {
    int id = 1;
    player player;
    
    switch(dataContentIndicator) {
      case 0:
        game.localPlayerID = byteBuffer.getInt();
        System.out.println(game.localPlayerID);
        
        while(byteBuffer.getInt() == 0) {
          game.playerList.add(new player(id));
          player = game.getPlayer(id);
          
          player.position.x = byteBuffer.getFloat();
          player.position.y = byteBuffer.getFloat();
          player.velocity.x = byteBuffer.getFloat();
          player.velocity.y = byteBuffer.getFloat();
          player.size = byteBuffer.getFloat();
          
          //System.out.println("Player " + game.getPlayer(id).id + " position: " + game.getPlayer(id).position + "velocity: " + game.getPlayer(id).velocity + " size: " +game.getPlayer(id).size);
          //System.out.println(game.playerList.size());
          
          id++;
        }
        
        state = "CONNECTED";
        
        if (byteBuffer.getInt() == 1) {
          game.startGame = true;
        }
        
        break;
        
      case 1:
        while(byteBuffer.getInt() == 0) {
          if(id >= game.playerList.size()) {
            game.playerList.add(new player(id));
          }
          player = game.getPlayer(id);
          
          player.position.x = byteBuffer.getFloat();
          player.position.y = byteBuffer.getFloat();
          player.velocity.x = byteBuffer.getFloat();
          player.velocity.y = byteBuffer.getFloat();
          player.size = byteBuffer.getFloat();
          
          //System.out.println("Player " + game.getPlayer(id).id + " position: " + game.getPlayer(id).position + "velocity: " + game.getPlayer(id).velocity + " size: " +game.getPlayer(id).size);
          //System.out.println(game.playerList.size());
          
          id++;
        }
        
        break;
      }
    }
  }
