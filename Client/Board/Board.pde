import java.lang.Math;
import java.net.InetAddress;

Protocol protocol;
boolean restart = false;
Game game;
RequestUpdate requestUpdate;
InetAddress server;

void setup() {
  size(1000, 1000);
    game = new Game();
  try {
    //server = InetAddress.getByName("155.98.38.76");
    server = InetAddress.getLocalHost();
    protocol = new Protocol(server, 8082, 1000, game);
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
  game.getPlayer(game.localPlayerID).takeInput();
}

void draw() {
    game.updateGameState();
}
