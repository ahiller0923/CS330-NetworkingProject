import java.lang.Math;

public class bonus {
  int size;
  PVector position;;
  
  bonus() {
    size = 10;
    position = new PVector((int)random(200, 800), (int)random(200, 800));
  }
  
  void draw() {
    fill(255);
    ellipse(position.x, position.y, size, size);
  }
}
