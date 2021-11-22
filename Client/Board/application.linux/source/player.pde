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
      textSize(72);
      text("Player " + id, 50, 100);
    }

    m = (size/2) *.1;
    ellipse(position.x, position.y, size, size);
    fill(0);
  }

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
