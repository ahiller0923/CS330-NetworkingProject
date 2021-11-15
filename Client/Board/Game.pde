import java.util.ArrayList;

public class Game {
  ArrayList<player> playerList;
  ArrayList<bonus> bonusPoints;
  boolean startGame;
  ring boundary;
  int windowSize = 1000;
  int localPlayerID;
  int playersAlive;
  
  Game() {
    playerList = new ArrayList<player>();
    bonusPoints = new ArrayList<bonus>();
    startGame = false;
    boundary = new ring(windowSize/2);
    bonusPoints = new ArrayList<bonus>();
    
    // Initalize bonus points list
    for(int i = 0; i < 11; i++) {
      bonusPoints.add(new bonus(new PVector(-1000, -1000)));
    }
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
        playerList.get(i).position.add(playerList.get(i).velocity);
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
}
 
