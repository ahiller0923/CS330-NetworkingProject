import java.util.ArrayList;
import java.util.Timer;

public class Game {
  ArrayList<Player> playerList;
  ArrayList<Bonus> bonusPoints;
  boolean startGame;
  Ring boundary;
  int windowSize = 1000;
  Player localPlayer;
  int PlayersAlive;
  long ping = 0;
  int seqNum = 0;
  int lastAcked;
  int lastSent;
  Input[] inputs =new Input[60];
  int maxPlayers = 8;
  int connectedPlayers = 0;
  boolean connected = false;
  float rotation = 0;
  
  /**
  *  Contructor for Game
  */
  Game() {
    playerList = new ArrayList<Player>();
    bonusPoints = new ArrayList<Bonus>();
    
    startGame = false;
    
    boundary = new Ring(windowSize/2);
    
    // Initalize bonus points list
    for(int i = 0; i < 11; i++) {
      bonusPoints.add(new Bonus(new PVector(-1000, -1000)));
    } 
  }
  
  /**
  *  Returns the player with the inputted id
  *  @param id  identifier to search for
  *  @return  player object with matching id
  */
  Player getPlayer(int id) {
    return playerList.get(id - 1);
  }
  
  /**
  *  Calculates the distance between two objects on a 2D plane
  *  @param x1  object 1's x-coordinate
  *  @param y1  object 1's y-coordinate
  *  @param x2  object 2's x-coordinate
  *  @param y2  object 2's y-coordinate
  *  @return  distance between the two objects
  */
  float distance(float x1, float y1, float x2, float y2) {
    return sqrt(pow(x1-x2, 2) + pow(y1 - y2, 2));
  }
  
  /**
  *  Draws the client game state on the screen
  */
  void drawGameState() {
    background(64);
    stroke(0);
    frameRate(60);
    
    // If the game has started
    if (startGame) {
      // Draw the boundary
      boundary.draw();
      textSize(32);
      text(ping + " ms", 800, 100);
  
      for (int i = 0; i < game.playerList.size(); i++) {
        if (playerList.get(i).alive) {
          fill(255);
          playerList.get(i).draw(localPlayer.id == playerList.get(i).id);
          
          fill(255);
          if(PlayersAlive == 1) {
            textSize(100);
            text("Player " + playerList.get(i).id + " wins!", 500, 500);
          }
        }
      }
      
      for (int i = 0; i < bonusPoints.size(); i++) {
        Bonus point = bonusPoints.get(i);
        point.draw();
      }
    }
    // If waiting for the game to start
    else if(connected) {
      textSize(100);
      textAlign(CENTER);
      text("Waiting for Players...", 500, 500);
      textSize(32);
      text(connectedPlayers + " / " + maxPlayers + " Players", 500, 600);
      
      if (connectedPlayers > 1) {
        rectMode(CORNER);
        text("Start Game", 500, 700);
        noFill();
        stroke(255);
        rect(420, 667, 160, 50);
      }
    }
    
    else {
      // Credit to Mann from open processing.org for the loading animation https://openprocessing.org/sketch/822494
      frameRate(16);
      fill(0,0,0,35);
      rectMode(CENTER);
      rect(width/2,height/2,width,height);
      translate(width/2,height/2);
      rotate(rotation);
      fill(255,255,255);
      ellipse(50,50,20,20);
      rotation=rotation+.5;
    }
    
  }
  
  /**
  *  Stores local user input in input array and sends it to the server
  */
  void takeInput() {
    Input input = localPlayer.takeInput(seqNum);
    if(input != null) {
      inputs[seqNum] = input;
      lastSent = seqNum;
      seqNum++;
     
      if(seqNum == 60) {
        seqNum = 0;
      }
      
      sendInput(input);
    }
  }
  
  /**
  *  Sends input to the server
  *  @param input  input to be sent to the server
  */
  void sendInput(Input input) {
    int[] data = new int[4];
    data[0] = 1;
    data[1] = input.seq;
    data[2] = game.localPlayer.id;
    data[3] = input.value;
   
    protocol.send(data);
  }
}
 
