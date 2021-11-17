import java.awt.Color;
import java.util.concurrent.TimeUnit;

public class Player {
  int id;
  PVector position;
  PVector velocity;
  float size;
  boolean alive;
  float m;
  Color hue;
  
  Player(int identifier) {
    id = identifier;
    position = new PVector((int)random(200, 800), (int)random(200, 800));
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
  /* Collision physics found on processing.org shared by Ira Greenberg
     https://processing.org/examples/circlecollision.html */
     
  void checkCollision(Player other) {

    // Get distances between the balls components
    PVector distanceVect = PVector.sub(other.position, position);

    // Calculate magnitude of the vector separating the balls
    float distanceVectMag = distanceVect.mag();

    // Minimum distance before they are touching
    float minDistance = size/2 + other.size/2;

    if (distanceVectMag < minDistance) {
      float distanceCorrection = (minDistance-distanceVectMag)/2.0;
      PVector d = distanceVect.copy();
      PVector correctionVector = d.normalize().mult(distanceCorrection);
      other.position.add(correctionVector);
      position.sub(correctionVector);

      // get angle of distanceVect
      float theta  = distanceVect.heading();
      // precalculate trig values
      float sine = sin(theta);
      float cosine = cos(theta);

      /* bTemp will hold rotated ball positions. You 
       just need to worry about bTemp[1] position*/
      PVector[] bTemp = {
        new PVector(), new PVector()
      };

      /* this ball's position is relative to the other
       so you can use the vector between them (bVect) as the 
       reference point in the rotation expressions.
       bTemp[0].position.x and bTemp[0].position.y will initialize
       automatically to 0.0, which is what you want
       since b[1] will rotate around b[0] */
      bTemp[1].x  = cosine * distanceVect.x + sine * distanceVect.y;
      bTemp[1].y  = cosine * distanceVect.y - sine * distanceVect.x;

      // rotate Temporary velocities
      PVector[] vTemp = {
        new PVector(), new PVector()
      };
      
      vTemp[0].x  = (cosine * velocity.x + sine * velocity.y);
      vTemp[0].y  = (cosine * velocity.y - sine * velocity.x);
      vTemp[1].x  = (cosine * other.velocity.x + sine * other.velocity.y);
      vTemp[1].y  = (cosine * other.velocity.y - sine * other.velocity.x);

      /* Now that velocities are rotated, you can use 1D
       conservation of momentum equations to calculate 
       the final velocity along the x-axis. */
      PVector[] vFinal = {  
        new PVector(), new PVector()
      };

      // final rotated velocity for b[0]
      vFinal[0].x = ((m - other.m) * (vTemp[0].x * 0) + 2 * other.m * vTemp[1].x) / (m + other.m);
      vFinal[0].y = vTemp[0].y;

      // final rotated velocity for b[0]
      vFinal[1].x = ((other.m - m) * vTemp[1].x + 2 * m * vTemp[0].x) / (m + other.m);
      vFinal[1].y = vTemp[1].y;

      // hack to avoid clumping
      bTemp[0].x += vFinal[0].x;
      bTemp[1].x += vFinal[1].x;

      /* Rotate ball positions and velocities back
       Reverse signs in trig expressions to rotate 
       in the opposite direction */
      // rotate balls
      PVector[] bFinal = { 
        new PVector(), new PVector()
      };

      bFinal[0].x = cosine * bTemp[0].x - sine * bTemp[0].y;
      bFinal[0].y = cosine * bTemp[0].y + sine * bTemp[0].x;
      bFinal[1].x = cosine * bTemp[1].x - sine * bTemp[1].y;
      bFinal[1].y = cosine * bTemp[1].y + sine * bTemp[1].x;

      // update balls to screen position
      other.position.x = position.x + bFinal[1].x;
      other.position.y = position.y + bFinal[1].y;

      position.add(bFinal[0]);

      // update velocities
      velocity.x = (cosine * vFinal[0].x - sine * vFinal[0].y) * (other.size / 32);
      velocity.y = (cosine * vFinal[0].y + sine * vFinal[0].x) * (other.size / 32);
      other.velocity.x = (cosine * vFinal[1].x - sine * vFinal[1].y) * (size / 32);
      other.velocity.y = (cosine * vFinal[1].y + sine * vFinal[1].x) * (size / 32);
    }
  }
  
  void takeInput() {
    int[] data = new int[3];
    int keyInput;
    if (key == CODED) {
     switch(keyCode) {
       case(UP):
       if (velocity.y > -3) {
         velocity.y -= 1;
         System.out.println("UP");
       }
         keyInput = 38;
         break;
       case(DOWN):
       if (velocity.y < 3) {
          velocity.y += 1;
          System.out.println("DOWN");
        }
         keyInput = 40;
         break;
       case(RIGHT):
        if (velocity.x < 3) {
          velocity.x += 1;
        }
         keyInput = 39;
         break;
       case(LEFT):
         if (velocity.x > -3) {
          velocity.x -= 1;
         }
         keyInput = 37;
         break;
       default:
         return;
     }
     data[0] = 1;
     data[1] = game.localPlayerID;
     data[2] = keyInput;
     try {
        TimeUnit.MILLISECONDS.sleep(100); // Simulate latency
      } catch (InterruptedException e) {
        // TODO Auto-generated catch block
        e.printStackTrace();
      }
     protocol.send(data);
  }
  
  else {
    if(key == 'q') {
      
    }
  }
  }
};
