import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
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
  ManageGameState updateTask;
  boolean packetLoss = false;
  int connectionTries = 0;
  
  /**
  *  Constructor for protocol
  *  @param target  ip address of the server
  *  @param portNumber  port to contact server through
  *  @param bufSize  integer indicating what size the outgoing and incoming buffers should be
  *  @param localGame  the local game object which will maintain the client game state
  */
  Protocol (InetAddress target, int portNumber, Game localGame) {
    outgoingBuf = new byte[50];
    incomingBuf = new byte[1000];
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
    
  /**
  *  Formats an array of int data into an array of byte data wrapped in a DatagramPacket
  *  @param intData  array of integer values to be converted to bytes
  *  @return  Datagram Packet with integer data in byte form
  */
  DatagramPacket prepareForTransmission(int[] intData) {
    ByteBuffer byteData = ByteBuffer.allocate(4 * intData.length);
    
    if (intData.length > 0) {
      for (int i = 0; i < intData.length; i++) {
        byteData.putInt(intData[i]);
      }
    }
    else {
      System.out.println("Transmission data is null.");
    }
    
    return new DatagramPacket(byteData.array(), byteData.array().length, server, port);
  }
  
  /**
  *  Establishes a connection with the server
  */
  void Connect() {
    if(state == "WAITING") {
      connectionTries = 0;
      // Create a packet with type byte of 0 (connection request)
      ByteBuffer byteBuffer = ByteBuffer.wrap(outgoingBuf);
      byteBuffer.putInt(0);
      outgoingBuf = byteBuffer.array();
      outgoingPacket = new DatagramPacket(outgoingBuf, outgoingBuf.length, server, port);
      try {
        socket.send(outgoingPacket); // Send the packet
        socket.setSoTimeout(2000); // Wait
        socket.receive(incomingPacket);
        processResponse(incomingPacket.getData()); // Process the connection data

        while(!game.connected) {
          // Connection data confirmation
          int data[] = new int[2];
          data[0] = 2;
          data[1] = game.localPlayer.id;
          send(data);

          try {
            socket.receive(incomingPacket);
            processResponse(incomingPacket.getData());
          }
          catch(Exception ex) {
            System.out.println("Trying again...");
            if(connectionTries < 20) {
              continue; 
            }
            else {
              System.out.println("Couldn't connect");
              break; 
            }
          }
          
        }
        
        // If connection data is received, set timeout to be higher since we don't want to throw repeated exceptions while waiting for game to start
        socket.setSoTimeout(100000000);
       
      } catch(Exception ex) {
        // If any part fails, try connection again
        System.out.println("Connection Error: " + ex + "\n\r Retrying...");
        if(connectionTries < 20) {
          connectionTries++;
          Connect();
        }
        else {
          System.out.println("Couldn't Connect"); 
        }
      }
      finally {
        state = "CONNECTED";
      }
    }
  }
  /**
  *  Listens on the socket for incoming server packets and passes them along to the processResponse() function
  */
  void Listen() {
    try {
      if(game.startGame) {
        //socket.setSoTimeout(200);
      }
      socket.receive(incomingPacket);
      processResponse(incomingPacket.getData());
    }
    catch(Exception ex) {
      ex.printStackTrace();
      return;
    }
  }
  
  void send(int[] data) {
    outgoingPacket = prepareForTransmission(data);
    try {
      socket.send(outgoingPacket);
    }
    catch(Exception ex) {
      ex.printStackTrace();
    }
  }
  /** 
  *  Checks the type byte of the server packet and either parses the rest of the data or 
  *  performs some other functionality based on the type of the packet
  *  @param serverResponse  byte array of data from the server
  */
  void processResponse(byte[] serverResponse) {
    ByteBuffer byteBuffer = ByteBuffer.wrap(serverResponse);
    try {
      switch(byteBuffer.getInt()) {
        case 0:
          System.out.println("Connection Data Received");
          parseData(byteBuffer, 0);
          break;
        case 1: 
          //System.out.println("Update Data Received");
          parseData(byteBuffer, 1);
          break;
        case 2:
          game.lastAcked = byteBuffer.getInt();
          game.inputs[game.lastAcked].ack = true;
          
          //System.out.println("ACKED");
          break;
          
        case 3:
          game.connectedPlayers = byteBuffer.getInt();
          break;
          
        case 4:
          game.connected = true;
          System.out.println("connected");
          break;
          
        case -1:
          System.out.println("Connection Terminated");
          state = "WAITING";
          break;
          
        default:
          System.out.println("Data not parsed");
      }
    }
    catch(Exception ex) {
      ex.printStackTrace();
    }
  }
  
  /**
  *  Parses data received from server based on the type bit. 
  *  @param byteBuffer  a buffer containing data from the server
  *  @param dataContentIndicator  an int indicating what type of packet the data belongs to
  */
  void parseData(ByteBuffer byteBuffer, int dataContentIndicator) {
    int id = 1;
    Player Player; // local player variable to avoid repetitive get functions
    
    switch(dataContentIndicator) {
      case 0:
        if(state == "WAITING") {
          int localPlayerID = byteBuffer.getInt(); // Get the id which correlates to which player the local user is
           
          // Get all player data 
          while(byteBuffer.get() == 1) {
            game.playerList.add(new Player(id));
            game.PlayersAlive += 1;
            Player = game.getPlayer(id);
            
            Player.position.x = byteBuffer.getFloat();
            Player.position.y = byteBuffer.getFloat();
            Player.velocity.x = byteBuffer.getFloat();
            Player.velocity.y = byteBuffer.getFloat();
            Player.size = byteBuffer.getFloat();
            
            id++;
          }
          
          game.localPlayer = game.getPlayer(localPlayerID); // Local player is the player which has the localPlayerID
          
          game.connectedPlayers = game.playerList.size();
        }
          
        break;
        
      case 1:
        game.startGame = true; // If we receive a regular server update, that means the game has started
        
        game.ping =  (System.currentTimeMillis() - byteBuffer.getLong()); // Ping
        
        // While byte is 0, collect more player data
        while(byteBuffer.get() == 1) {
          if(id > game.playerList.size()) {
            game.playerList.add(new Player(id));
            game.PlayersAlive += 1;
          }
          Player = game.getPlayer(id);
          
          // Check if player has died
          if (byteBuffer.get() == 0) {
            if(Player.alive == true) {
              Player.alive = false;
              game.PlayersAlive -= 1;
            }
          }
          // Get alive player data from server
          else {
            Player.position.x = byteBuffer.getFloat();
            Player.position.y = byteBuffer.getFloat();
            
            Player.velocity.x = byteBuffer.getFloat();
            Player.velocity.y = byteBuffer.getFloat();
            Player.size = byteBuffer.getFloat();
          }
          
          id++;
        }
        
        int i = 0;
        
        // Get bonus point data from server
        while(byteBuffer.get() == 1) {
          game.bonusPoints.get(i).position = new PVector(byteBuffer.getFloat(), byteBuffer.getFloat());
          i++;
        }
        
        // Put collected vectors out of sight
        while(i < game.bonusPoints.size()) {
          game.bonusPoints.get(i).position = new PVector(-1000, -1000);
          i++;
        }
        
        break;
      }
    }
  }
