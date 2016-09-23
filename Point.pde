public class Point {

  public float x, y, data;
  public boolean hovered, drag;
  public int size = 10;

  public Point(float xPos, float yPos) {
    x = xPos;
    y = yPos;
    hovered = false;
    drag = false;
    listeners.put(this.toString(), new OnChangeListener() {
      float savex = x, savey = y;
      boolean wait = false;
      public void saveForRender() {
        savex = x;
        savey = y;
        wait = true;
      }
      public void onChangeBy(int i) {
      }
      public void onChange(Object o) {
        if (!wait) {
          savex = x;
          savey = y;
        }
        x = ((Point)o).x;
        y = ((Point)o).y;
      }
      public void onRender(boolean h) {
        if (h) {
          history.add(new Action(new Point(savex, savey), new Point(x, y), "Changed Curve Point", this));
        }
      }
    }
    );
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

  public boolean drag(float mx, float my) {
    if (hovered) {
      if (!drag) {
        listeners.get(this.toString()).saveForRender();
      }
      drag = true;
      listeners.get(this.toString()).onChange(new Point(mx, my));
    } else {
      drag = false;
    }
    return drag;
  }

  public void release() {
    if (drag) {listeners.get(this.toString()).onRender(true);
    drag = false;
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