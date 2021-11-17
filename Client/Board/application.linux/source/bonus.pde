import java.lang.Math;

public class Bonus {
  int size;
  PVector position;;
  
  Bonus(PVector pos) {
    size = 10;
    position = pos;
  }
  
  void draw() {
    fill(255);
    ellipse(position.x, position.y, size, size);
  }
}
