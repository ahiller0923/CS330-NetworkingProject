import java.lang.Math;

public class Bonus {
  int size;
  PVector position;;
  
  /**
  *  Constructor for bonus point
  *  @param pos  position of bonus point
  */
  Bonus(PVector pos) {
    size = 5;
    position = pos;
  }
  
  void draw() {
    fill(255);
    ellipse(position.x, position.y, size, size);
  }
}
