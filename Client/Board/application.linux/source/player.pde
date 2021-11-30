import java.awt.Color;
import java.util.concurrent.TimeUnit;

public class Player {
  int id;
  PVector position;
  PVector serverPosition;
  PVector velocity;
  float size;
  boolean alive;
  float m;
  Color hue;
  
  /**
  *  Constructor for player object
  *  @param identifier  integer to be set as Player's id
  */
  Player(int identifier) {
    id = identifier;
    position = new PVector();
    serverPosition = new PVector();
    velocity = new PVector(0, 0);
    size = 30;
    alive = true;
    m = (size/2) *.1;
    hue = new Color((int)random(0, 255), (int)random(0, 255), (int)random(0, 255));
  }
  
  void draw(boolean localPlayer) {
    fill(hue.getRGB());
    if (localPlayer) {
      textSize(50);
      text("Player " + id, 100, 100);
    }

    m = (size/2) *.1;
    ellipse(position.x, position.y, size, size);
    fill(0);
  }
  
  /**
  *  Handles the local elements of taking input
  *  Based on keystroke, changes the player velocity
  *  Creates an input object which will eventually be stored locally and sent to the server
  *  @parm seqNum  interger indicating where this input occurred relative to others
  *  @return   input object containing seqNum and the keyCode of the key pressed
  */
  Input takeInput(int seqNum) {
    int keyInput = 0;
     switch(keyCode) {
       case(UP):
       if (velocity.y > -3) {
         velocity.y -= 1;
         keyInput = 38;
         //System.out.println("UP");
       }
         break;
       case(DOWN):
       if (velocity.y < 3) {
          velocity.y += 1;
          keyInput = 40;
          //System.out.println("DOWN");
        }
         break;
       case(RIGHT):
        if (velocity.x < 3) {
          velocity.x += 1;
          keyInput = 39;
        }
         
         break;
       case(LEFT):
         if (velocity.x > -3) {
          velocity.x -= 1;
          keyInput = 37;
         }
         break;
       default:
         return null;
     }
     
     if(keyInput != 0) {
       return new Input(seqNum, keyInput);
     }
     else {
       return null;
     }
  }
};
