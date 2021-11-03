import java.util.LinkedList;

public class Game {
  LinkedList<player> playerList;
  LinkedList<bonus> bonusPoints;
  boolean startGame;
  ring boundary;
  int windowSize = 1000;
  int localPlayerID;
  
  Game() {
    playerList = new LinkedList<player>();
    bonusPoints = new LinkedList<bonus>();
    startGame = false;
    boundary = new ring(windowSize/2);
  }
  
  player getPlayer(int id) {
    return playerList.get(id - 1);
  }
  
  void bonusPointGeneration() {
      // Bonus Points
      int isBonus = (int)random(1, 100);
      
      if(isBonus == 7 && bonusPoints.size() < 10) {
        bonusPoints.add(new bonus());
      }
  }
  
  float distance(float x1, float y1, float x2, float y2) {
    return sqrt(pow(x1-x2, 2) + pow(y1 - y2, 2));
  }
  
  void updateGameState() {
    background(64);
    stroke(0);
    if (playerList.size() > 1) {
      // Draw the boundary
      boundary.draw();
    
      // Check if the player has lost
      for (int i = 0; i < game.playerList.size(); i++) {
        if (distance(playerList.get(i).position.x, playerList.get(i).position.y, boundary.position, boundary.position) > boundary.size/2) {
          textSize(72);
          playerList.remove(i);
          
          if (playerList.size() == 1) {
             break;
          }
        }
        
        if (playerList.get(i).alive) {
          for(int x = 0; x < playerList.size(); x++) {
            if (i != x){
              playerList.get(i).checkCollision(playerList.get(x));
            }
          }
          
          for(int y = 0; y < bonusPoints.size(); y++) {
            bonus point = bonusPoints.get(y);
            if (distance(playerList.get(i).position.x, playerList.get(i).position.y, point.position.x, point.position.y) < playerList.get(0).size/2) {
              bonusPoints.remove(y);
              playerList.get(i).size += 5;
            }
          }
          fill(255);
          playerList.get(i).draw(localPlayerID == playerList.get(i).id);
        }
      }
    }
    
    for (int i = 0; i < bonusPoints.size(); i++) {
      bonus point = bonusPoints.get(i);
      point.draw();
    }
    
    if (playerList.size() == 1) {
     text("Player " + playerList.get(0).id + " wins!", 100, 500);
     text("Press 'r' to start a new game", 100, 600);
     
      if(restart) {
        restart = false;
       
        setup();
      }
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
 
