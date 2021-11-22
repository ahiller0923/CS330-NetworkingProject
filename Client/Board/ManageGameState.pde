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
  
  public void run() {
    // Update position
     for (int i = 0; i < game.playerList.size(); i++) {
       Player player = game.playerList.get(i);
       if (player.alive) {
         if (player.serverPosition != player.position) {
           //player.position.x = player.position.x * 1 + player.serverPosition.x * 0;
           //player.position.y = player.position.y * 1 + player.serverPosition.y * 0;
         }
         player.position.add(game.playerList.get(i).velocity);
         
       /*for(int y = 0; y < game.bonusPoints.size(); y++) {
           Bonus point = game.bonusPoints.get(y);
           if (game.distance(player.position.x, player.position.y, point.position.x, point.position.y) < player.size/2) {
             game.bonusPoints.remove(y);
             player.size += 5;
         }*/
       }
     }
     
     for (int i = game.lastAcked; i != game.lastSent; i++) {
       if(game.inputs[i] != null) {
         if(game.inputs[i].ack == false) {
           game.sendInput(game.inputs[i]);
           //System.out.println("Retransmitted");
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
