public class ring {
  int size;
  int position;
  
  ring(float pos) {
    size = 900;
    position = (int)pos;
  }
  
  void draw() {
    noFill();
    stroke(255);
    ellipse(position, position, size, size);
  }
}
