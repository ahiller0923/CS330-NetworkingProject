public class Ring {
  int size;
  int position;
  /**
  *  Constructor for ring object
  *  pos  position of ring (will be mirrored for x and y)
  */
  Ring(float pos) {
    size = 700;
    position = (int)pos;
  }
  
  void draw() {
    noFill();
    stroke(255);
    ellipse(position, position, size, size);
  }
}
