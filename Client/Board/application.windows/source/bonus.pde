import java.lang.Math;

public class bonus {
  int size;
  PVector position;;
  
  bonus(PVector pos) {
    size = 10;
    position = pos;
  }
  
  void draw() {
    fill(255);
    ellipse(position.x, position.y, size, size);
  }
}
