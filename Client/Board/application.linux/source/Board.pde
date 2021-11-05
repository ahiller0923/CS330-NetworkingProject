import java.lang.Math;
import java.util.LinkedList;
import java.net.InetAddress;
import java.util.Timer;
import java.util.TimerTask;

Protocol protocol;
boolean restart = false;
Game game;
RequestUpdate requestUpdate;
InetAddress server;

void setup() {
  size(1000, 1000);
    game = new Game();
  try {
    server = InetAddress.getLocalHost();
    protocol = new Protocol(server, 8080, 1000, game);
    protocol.Connect();
  } 
  catch (Exception ex) {
    ex.printStackTrace();
  }
  
  requestUpdate = new RequestUpdate(protocol);
  Thread networkThread = new Thread(requestUpdate, "Network");
  networkThread.start();
}

void keyPressed() {
  game.takeInput();
}

void draw() {
    game.updateGameState();
}
