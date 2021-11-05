import java.util.LinkedList;

public class Game {
  LinkedList<player> playerList;
  LinkedList<bonus> bonusPoints;
  boolean startGame;
  ring boundary;
  int windowSize = 1000;
  int localPlayerID;
  int playersAlive;
  
  Game() {
    playerList = new LinkedList<player>();
    bonusPoints = new LinkedList<bonus>();
    startGame = false;
    boundary = new ring(windowSize/2);
  }
  
  player getPlayer(int id) {
    return playerList.get(id - 1);
  }
  
  
  float distance(float x1, float y1, float x2, float y2) {
    return sqrt(pow(x1-x2, 2) + pow(y1 - y2, 2));
  }
  
  void updateGameState() {
    background(64);
    stroke(0);
    // Draw the boundary
    boundary.draw();

    for (int i = 0; i < game.playerList.size(); i++) {
      if (playerList.get(i).alive) {
        fill(255);
        playerList.get(i).draw(localPlayerID == playerList.get(i).id);
        
        if(playersAlive == 1) {
          text("Player " + playerList.get(i).id + " wins!", 100, 500);
        }
      }
    }
    
    for (int i = 0; i < bonusPoints.size(); i++) {
      bonus point = bonusPoints.get(i);
      point.draw();
    }
  }
  
  void takeInput() {
    int[] data = new int[3];
    int keyInput;
    if (key == CODED) {
     switch(keyCode) {
       case(UP):
         keyInput = 38;
         break;
       case(DOWN):
         keyInput = 40;
         break;
       case(RIGHT):
         keyInput = 39;
         break;
       case(LEFT):
         keyInput = 37;
         break;
       default:
         return;
     }
     data[0] = 1;
     data[1] = localPlayerID;
     data[2] = keyInput;
     
     protocol.send(1, data);
  }
  
  else {
    if(key == 'q') {
      
    }
  }
  }
}
 
