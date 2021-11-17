import java.util.ArrayList;
import java.util.Timer;

public class Game {
  ArrayList<Player> playerList;
  ArrayList<Bonus> bonusPoints;
  boolean startGame;
  Ring boundary;
  int windowSize = 1000;
  int localPlayerID;
  int PlayersAlive;
  long ping = 0;
  
  Game() {
    playerList = new ArrayList<Player>();
    bonusPoints = new ArrayList<Bonus>();
    startGame = false;
    boundary = new Ring(windowSize/2);
    bonusPoints = new ArrayList<Bonus>();
    
    // Initalize bonus points list
    for(int i = 0; i < 11; i++) {
      bonusPoints.add(new Bonus(new PVector(-1000, -1000)));
    } 
  }
  
  Player getPlayer(int id) {
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
        
        fill(255);
        text(ping + " ms", 800, 100);
        
        if(PlayersAlive == 1) {
          text("Player " + playerList.get(i).id + " wins!", 100, 500);
        }
      }
    }
    
    for (int i = 0; i < bonusPoints.size(); i++) {
      Bonus point = bonusPoints.get(i);
      point.draw();
    }
  }
}
 
