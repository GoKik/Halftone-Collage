public class Point {

  public float x, y, data;
  public boolean hovered;
  public int size = 10;

  public Point(float xPos, float yPos) {
    x = xPos;
    y = yPos;
    hovered = false;
  }

  public Point(float xPos, float yPos, float d) {
    this(xPos, yPos);
    data = d;
  }

  public void draw() {
    noFill();
    ellipse(x, y, size, size);
  }
  
  public void draw(float scale) {
    noFill();
    ellipse(x*scale, y*scale, size, size);
  }

  public boolean press(float mx, float my) {
    if (hovered) {
      x = mx;
      y = my;
      return true;
    } else {
      return false;
    }
  }

  public boolean hover(float mx, float my) {
    if (mx > x-size && mx < x+size && my > y-size && my < y+size) {
      hovered = true;
      size = 20;
    } else {
      hovered = false;
      size = 10;
    }
    return hovered;
  }
}