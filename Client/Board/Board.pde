import java.lang.Math;
import java.util.LinkedList;
import java.net.InetAddress;
import java.util.Timer;
import java.util.TimerTask;

Protocol protocol;
boolean restart = false;
Game game;

void setup() {
  size(1000, 1000);
    game = new Game();
    Timer timer = new Timer();
  try {
    protocol = new Protocol(InetAddress.getLocalHost(), 8000, 1000, game);
    protocol.Connect();
  } 
  catch (Exception ex) {
    ex.printStackTrace();
  }
  
  TimerTask requestUpdate = new requestUpdate(protocol);
  timer.schedule(requestUpdate, 1); 
}

void keyPressed() {
  game.takeInput();
}

void draw() {
  if (game.startGame) {
    game.bonusPointGeneration();
    game.updateGameState();
  }
}
