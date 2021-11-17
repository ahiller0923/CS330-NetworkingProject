public class Ring {
  int size;
  int position;
  
  Ring(float pos) {
    size = 900;
    position = (int)pos;
  }
  
  void draw() {
    noFill();
    stroke(255);
    ellipse(position, position, size, size);
  }
}
