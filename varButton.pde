public class varButton {

  public String icona, iconb;
  public float xPos, yPos;

  private int s = 20;
  private boolean[] mouseOver = new boolean[3], pressed = new boolean[3];
  private float presspoint;
  private OnChangeListener listener;

  public varButton(String ia, String ib, float x, float y, OnChangeListener l) {
    icona = ia;
    iconb = ib;
    xPos = x;
    yPos = y;
    listener = l;
  }

  public void draw(boolean inv) {
    noStroke();
      textAlign(CENTER, CENTER);
      textSize(15);
    if (mouseOver[0] || pressed[0]) {
      fill(inv?bgCol:vCol);
      rect(xPos-s-s/8, yPos-s/2, 2.25*s, s, s/2);
      fill(inv?vCol:bgCol);
      text("<", xPos-s/2-s/8, yPos-3);
      text(">", xPos+s/2+s/8, yPos-3);
    } else {
      fill((inv^mouseOver[1])^pressed[1]?vCol:bgCol);
      ellipse(xPos-s/2-s/8, yPos, s, s);
      fill((inv^mouseOver[2])^pressed[2]?vCol:bgCol);
      ellipse(xPos+s/2+s/8, yPos, s, s);
      fill((inv^mouseOver[1])^pressed[1]?bgCol:vCol);
      text(icona, xPos-s/2-s/8, yPos-3);
      fill((inv^mouseOver[2])^pressed[2]?bgCol:vCol);
      text(iconb, xPos+s/2+s/8, yPos-3);
    }
  }

  public void mouseMoved(float mx, float my) {
    if (sqrt(sq(mx-(xPos-s/2-s/8))+sq(my-yPos)) < s/2) {
      mouseOver[1] = true;
    } else {
      mouseOver[1] = false;
    }
    if (sqrt(sq(mx-xPos)+sq(my-yPos)) < s/4) {
      mouseOver[0] = true;
    } else {
      mouseOver[0] = false;
    }
    if (sqrt(sq(mx-(xPos+s/2+s/8))+sq(my-yPos)) < s/2) {
      mouseOver[2] = true;
    } else {
      mouseOver[2] = false;
    }
  }

  public void mouseClicked(float mx, float my) {
    if (sqrt(sq(mx-(xPos-s/2-s/8))+sq(my-yPos)) < s/2) {
      listener.onChangeBy(-1);
      listener.onRender(true);
    }
    if (sqrt(sq(mx-(xPos+s/2+s/8))+sq(my-yPos)) < s/2) {
      listener.onChangeBy(1);
      listener.onRender(true);
    }
  }

  public void mousePressed(float mx, float my) {
    if (mouseOver[1]) {
      pressed[1] = true;
    }
    if (mouseOver[2]) {
      pressed[2] = true;
    }
    if (mouseOver[0]) {
      pressed[0] = true;
      listener.saveForRender();
      presspoint = mx;
    }
  }

  public void mouseDragged(float mx, float my) {
    if (pressed[0]) {
      listener.onChangeBy((int)((mx-presspoint)));
      presspoint = mx;
    }
  }

  public void mouseReleased(float mx, float my) {
    if (pressed[0]) {
      pressed[0] = false;
      listener.onRender(true);
    }
    pressed[1] = false;
    pressed[2] = false;
  }
}

public interface OnChangeListener {
  public void saveForRender();
  public void onChangeBy(int i);
  public void onChange(Object o);
  public void onRender(boolean h);
}