package Server;
import java.util.ArrayList;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.ThreadLocalRandom;

public class Game {
	ArrayList<Player> players;
	int playersConnected;
	ArrayList<Bonus> bonusPoints;
	boolean inProgress;
	int windowSize = 1000;
	Ring boundary;
	
	Game() {
		players = new ArrayList<Player>();
		bonusPoints = new ArrayList<Bonus>();
		boundary = new Ring(windowSize/2);
		playersConnected = 0;
	}

	Player getPlayer(int ID) {
		return players.get(ID - 1);
	}
	
	void bonusPointGeneration() {
		int isBonus = ThreadLocalRandom.current().nextInt(1, 1000);
		
		if(isBonus == 7 && bonusPoints.size() < 11) {
			bonusPoints.add(new Bonus());
		}
	}
	
	void updateGameState() {
		if(players.size() > 1) {
			
			// Generate bonus points
			bonusPointGeneration();
			
			// Handle Player States
			for(int i = 1; i <= players.size(); i++ ) {
				Player player = getPlayer(i);
				if (distance(player.position.x, player.position.y, boundary.position, boundary.position) > boundary.size/2) {
					player.alive = false;
				}
				if(player.alive) { 
					for(int x = i + 1; x <= players.size(); x++) {
						getPlayer(i).checkCollision(getPlayer(x));
					}
					getPlayer(i).position.add(getPlayer(i).velocity);
					
					for(int y = 0; y < bonusPoints.size(); y++) {
						Bonus point = bonusPoints.get(y);
						if (distance(player.position.x, player.position.y, point.position.x, point.position.y) < player.size/2) {
							bonusPoints.remove(y);
							player.size += 5;
						}
					}
				}
			}
		}
	}
	
	float distance(float x1, float y1, float x2, float y2) {
		return (float) Math.sqrt(Math.pow(x1-x2, 2) + Math.pow(y1 - y2, 2));
	}
	  
	  void startGame() {
		  Timer timer = new Timer();
		  timer.schedule(new scheduledUpdate(), 1, 15);
		  inProgress = true;
		  System.out.println("Game Started");
	  }
	  
	  class scheduledUpdate extends TimerTask {
		  public void run() {
			  updateGameState();
		  }
	  }

	
	
}