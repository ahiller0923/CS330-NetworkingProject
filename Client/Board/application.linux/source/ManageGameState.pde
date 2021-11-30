import java.util.Timer;
import java.util.TimerTask;
import java.util.ArrayList;
import java.util.concurrent.TimeUnit;

public class ManageGameState extends TimerTask {
  Game game;
  ArrayList<Game> predictions;
  ArrayList<Game> state;
  long avgLatency;
  int tick = 0;
  
  
  ManageGameState(Game activeGame) {
    game = activeGame;
    avgLatency = game.ping;
  }
  /**
  *  Provides client-side prediction
  *  Periodically update player positions based on their current velocity.
  *  Track if a player collects a bonus point and preemptively remove it
  *  Check if local player inputs have been acknowledged by the server and retransmit unacknowledged inputs every 60 ms
  */
  public void run() {
    // Update position
     for (int i = 0; i < game.playerList.size(); i++) {
       Player player = game.playerList.get(i);
       if (player.alive) {
         player.position.add(game.playerList.get(i).velocity);
       }
       
       for(int y = 0; y < game.bonusPoints.size(); y++) {
           Bonus point = game.bonusPoints.get(y);
           if (game.distance(player.position.x, player.position.y, point.position.x, point.position.y) < player.size/2) {
             game.bonusPoints.get(y).position = new PVector(-1000, -1000);
             player.size += 5;
         }
       }
     }
     
     for (int i = game.lastAcked; i != game.lastSent; i++) {
       if(game.inputs[i] != null) {
         if(game.inputs[i].ack == false) {
           if(game.inputs[i].timeSinceTransmission > 60) {
             game.sendInput(game.inputs[i]);
             game.inputs[i].timeSinceTransmission = 0;
             System.out.println("Retransmitted");
           }
           else {
             game.inputs[i].timeSinceTransmission += 16;
           }
         }
       }
       
       if(i == 59) {
         i = -1;
       }
       else {
         break;
       }
     }
   } 
}
