public class spacer {

  public boolean horizontal;
  public float xPos, yPos;
  private area parent;

  private boolean mouseOver = false, dragged = false;
  private float dragx = 0, dragy = 0;

  public spacer(float x, float y, boolean h, area p) {
    xPos = x;
    yPos = y;
    horizontal = h;
    parent = p;
  }

  public void draw() {
    stroke(vCol);
    fill(vCol);
    strokeWeight(1);
    float x = xPos*scF;
    float y = yPos*scF;
    if (!mouseOver) {
      if (horizontal) {
        rect(x-10, y-2, 20, 4, 2);
      } else {
        rect(x-2, y-10, 4, 20, 2);
      }
    } else {
        fill(bgCol, 200);
        noStroke();
        rectMode(CENTER);
        rect(x, y, horizontal?24:55, horizontal?55:24, 12);
        rectMode(CORNER);
        stroke(vCol);
        line(x-5, y-5, x+5, y+5);
        line(x+5, y-5, x-5, y+5);
        
        if (horizontal) {
          line(x+5, y+14, x, y+19);
          line(x-5, y+14, x, y+19);
          line(x+5, y-14, x, y-19);
          line(x-5, y-14, x, y-19);
        } else {
          line(x-14, y+5, x-19, y);
          line(x-14, y-5, x-19, y);
          line(x+14, y+5, x+19, y);
          line(x+14, y-5, x+19, y);
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
      prints.add(parent);
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
        yPos = getDivPos(this, my + dragy);
        parent.transform(yPos, horizontal);
      } else {
        xPos = getDivPos(this, mx + dragx);
        parent.transform(xPos, horizontal);
      }
    }
  }

  public void mouseReleased(float mx, float my) {
    dragged = false;
  }
}