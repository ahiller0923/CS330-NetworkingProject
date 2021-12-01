package Server;

import java.util.concurrent.ThreadLocalRandom;
import processing.core.PVector;
import java.lang.Math;

public class Player {
	int id;
	  PVector position;
	  PVector velocity;
	  float size;
	  boolean alive;
	  float m;
	  boolean connected;
	  Client clientInfo;
	  int[] processedInputs = new int[60];
	  
	  Player(int identifier, Client client) {
	    id = identifier;
	    position = new PVector((float)ThreadLocalRandom.current().nextInt(150, 600), (float)ThreadLocalRandom.current().nextInt(150, 600));
	    velocity = new PVector(0, 0);
	    size = 20;
	    alive = true;
	    m = (float) ((size/2) *.1);
	    connected = false;
	    clientInfo = client;
	  }
	
	/* Collision physics found on processing.org shared by Ira Greenberg
    https://processing.org/examples/circlecollision.html */
    
 void checkCollision(Player other) {

   // Get distances between the balls components
   PVector distanceVect = PVector.sub(other.position, position);

   // Calculate magnitude of the PVector separating the balls
   float distanceVectMag = distanceVect.mag();

   // Minimum distance before they are touching
   float minDistance = size/2 + other.size/2;

   if (distanceVectMag < minDistance) {
     float distanceCorrection = (float) ((minDistance-distanceVectMag)/2.0);
     PVector d = distanceVect.copy();
     PVector correctionPVector = d.normalize().mult(distanceCorrection);
     other.position.add(correctionPVector);
     position.sub(correctionPVector);

     // get angle of distanceVect
     float theta  = distanceVect.heading();
     // precalculate trig values
     float sine = (float) Math.sin(theta);
     float cosine = (float) Math.cos(theta);

     /* bTemp will hold rotated ball positions. You 
      just need to worry about bTemp[1] position*/
     PVector[] bTemp = {
       new PVector(), new PVector()
     };

     /* this ball's position is relative to the other
      so you can use the PVector between them (bVect) as the 
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
 
 void takeInput(int keyPress) {
	 switch(keyPress) {
	 	// UP
	 	case(38):
	 		if (velocity.y > -3) {
	 			velocity.y -= 1;
	 		}  
	     	break;
	    // DOWN
	    case(40):
	    	if (velocity.y < 3) {
	    		velocity.y += 1;
	    	}
	       	break;
	    // RIGHT
	    case(39):
	    	if (velocity.x < 3) {
	    		velocity.x += 1;
	    	}
	       	break;
	    // LEFT
	    case(37):
	    	if (velocity.x > -3) {
	    		velocity.x -= 1;
	    	}
	       	break;
	 }
 }
}
