public class spacer {

  public boolean horizontal;
  public float xPos, yPos, min, max;
  private area parent;

  private boolean mouseOver = false, dragged = false;
  private float dragx = 0, dragy = 0;

  public spacer(float x, float y, boolean h, float mi, float ma, area p) {
    xPos = x;
    yPos = y;
    horizontal = h;
    min = mi;
    max = ma;
    parent = p;
  }

  public void draw() {
    stroke(vCol);
    strokeWeight(1);
    float x = xPos*scF;
    float y = yPos*scF;
    if (!mouseOver) {
      if (horizontal) {
        line(x-10, y, x+10, y);
      } else {
        line(x, y-10, x, y+10);
      }
    } else {
      if (!dragged) {
        line(x-5, y-5, x+5, y+5);
        line(x+5, y-5, x-5, y+5);
        
        if (horizontal) {
          line(x+5, y+10, x, y+15);
          line(x-5, y+10, x, y+15);
          line(x+5, y-10, x, y-15);
          line(x-5, y-10, x, y-15);
        } else {
          line(x-10, y+5, x-15, y);
          line(x-10, y-5, x-15, y);
          line(x+10, y+5, x+15, y);
          line(x+10, y-5, x+15, y);
        }
      } else {
        if (horizontal) {
          line(x-20, y, x+20, y);
        } else {
          line(x, y-20, x, y+20);
        }
      }
    }
  }

  public void mouseMoved(float mx, float my) {
    if (!mouseOver && sqrt(sq(mx-xPos)+sq(my-yPos)) <= 20/scF) {
      mouseOver = true;
    }
    if (mouseOver && sqrt(sq(mx-xPos)+sq(my-yPos)) > 30/scF) {
      mouseOver = false;
    }
  }

  public void mouseClicked(float mx, float my) {
    if (sqrt(sq(mx-xPos)+sq(my-yPos)) <= 10/scF) {
      parent.rebuild();
    }
  }

  public void mousePressed(float mx, float my) {
    if (mouseOver && sqrt(sq(mx-xPos)+sq(my-yPos)) > 10/scF && sqrt(sq(mx-xPos)+sq(my-yPos)) < 30/scF) {
      dragged = true;
      dragx = xPos - mx;
      dragy = yPos - my;
    }
  }

  public void mouseDragged(float mx, float my) {
    if (dragged) {
      if (horizontal) {
        yPos = max(min, min(max, my + dragy));
        parent.transform(yPos, horizontal);
      } else {
        xPos = max(min, min(max, mx + dragx));
        parent.transform(xPos, horizontal);
      }
    }
  }

  public void mouseReleased(float mx, float my) {
    dragged = false;
  }
}