import java.lang.Math;
import java.net.InetAddress;

Protocol protocol;
boolean restart = false;
Game game;
RequestUpdate requestUpdate;
InetAddress server;
int ms = 1000/30;
long startTime;

void setup() {
  size(1000, 1000);
  game = new Game();
  try {
    //server = InetAddress.getByName("155.98.39.148");
    server = InetAddress.getLocalHost();
    protocol = new Protocol(server, 8081, 1000, game);
    //protocol.Connect();
  } 
  catch (Exception ex) {
    ex.printStackTrace();
  }
  
  requestUpdate = new RequestUpdate(protocol);
  Thread networkThread = new Thread(requestUpdate, "Network");
  networkThread.start();
  
  Timer timer = new Timer();
  ManageGameState update = new ManageGameState(game);
  timer.schedule(update, 0, ms);
}

void keyPressed() {
  game.takeInput();
}

void mousePressed() {
  if (mouseX >= 420 && mouseX <= 580 && mouseY >= 667 && mouseY <= 717 && game.connectedPlayers > 1) {
    int[] data = {3};
    protocol.send(data);
    startTime = System.currentTimeMillis();
    while(protocol.game.startGame != true) {
      protocol.Listen();
      if(startTime - System.currentTimeMillis() == 100) {
        protocol.send(data);
        startTime = System.currentTimeMillis();
      }
    }
  } 
}

void draw() {
    game.drawGameState();
}
