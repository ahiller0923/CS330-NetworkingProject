package Server;
import java.util.ArrayList;
import java.util.concurrent.ThreadLocalRandom;

public class Game {
	ArrayList<Player> players;
	int playersConnected;
	int playersAlive = 0;
	ArrayList<Bonus> bonusPoints;
	boolean inProgress;
	int windowSize = 750;
	Ring boundary;
	int ms;
	
	Game() {
		players = new ArrayList<Player>();
		bonusPoints = new ArrayList<Bonus>();
		boundary = new Ring(windowSize/2);
		playersConnected = 0;
		ms = 1000 / 30;
	}

	Player getPlayer(int ID) {
		return players.get(ID - 1);
	}
	
	void bonusPointGeneration() {
		int isBonus = ThreadLocalRandom.current().nextInt(1, 100);
		
		if(isBonus == 7 && bonusPoints.size() < 11) {
			bonusPoints.add(new Bonus());
		}
	}
	
	void updateGameState() {
		playersAlive = 0;
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
					playersAlive++;
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
	
	/* Not very efficient but a last minute safeguard against wacky behavior at the start of the game
	 * In theory, this should not trigger very often.
	 * Change of triggering increases as player count increases
	 */
	void startingPositions() {
		for(int i = 1; i <= players.size(); i++) {
			System.out.println("Checking");
			for(int x = 1; x <= players.size(); x++) {
				if(distance(getPlayer(i).position.x, getPlayer(i).position.y, getPlayer(x).position.x, getPlayer(x).position.y) <= getPlayer(i).size &&
						i != x) {
					getPlayer(i).newPosition();
					x = 1;
				}
			}
		}
		System.out.println("Done!");
	}
}