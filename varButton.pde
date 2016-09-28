public class varButton {

  public String icona, iconb;
  public float xPos, yPos;
  public boolean hori;

  private int s = 20;
  private boolean[] mouseOver = new boolean[3], pressed = new boolean[3];
  private float presspoint;
  private OnChangeListener listener;

  public varButton(String ia, String ib, float x, float y, boolean h, OnChangeListener l) {
    icona = ia;
    iconb = ib;
    xPos = x;
    yPos = y;
    hori = h;
    listener = l;
  }

  public void draw(boolean inv) {
    noStroke();
      textAlign(CENTER, CENTER);
      textSize(15);
    if (mouseOver[0] || pressed[0]) {
      fill(inv?bgCol:vCol);
      rect(hori?xPos-s-s/8:xPos-s/2, hori?yPos-s/2:yPos-s-s/8, hori?2.25*s:s, hori?s:2.25*s, s/2);
      fill(inv?vCol:bgCol);
      text(hori?"<":"▲", hori?xPos-s/2-s/8:xPos, hori?yPos-3:yPos-s/2-s/8-3);
      text(hori?">":"▼", hori?xPos+s/2+s/8:xPos, hori?yPos-3:yPos+s/2+s/8-3);
    } else {
      fill((inv^mouseOver[1])^pressed[1]?vCol:bgCol);
      ellipse(hori?xPos-s/2-s/8:xPos, hori?yPos:yPos-s/2-s/8, s, s);
      fill((inv^mouseOver[2])^pressed[2]?vCol:bgCol);
      ellipse(hori?xPos+s/2+s/8:xPos, hori?yPos:yPos+s/2+s/8, s, s);
      fill((inv^mouseOver[1])^pressed[1]?bgCol:vCol);
      text(icona, hori?xPos-s/2-s/8:xPos, hori?yPos-3:yPos-s/2-s/8-3);
      fill((inv^mouseOver[2])^pressed[2]?bgCol:vCol);
      text(iconb, hori?xPos+s/2+s/8:xPos, hori?yPos-3:yPos+s/2+s/8-3);
    }
  }

  public void mouseMoved(float mx, float my) {
    if (sqrt(sq(mx-(hori?xPos-s/2-s/8:xPos))+sq(my-(hori?yPos:yPos-s/2-s/8))) < s/2) {
      mouseOver[1] = true;
    } else {
      mouseOver[1] = false;
    }
    if (sqrt(sq(mx-xPos)+sq(my-yPos)) < s/4) {
      mouseOver[0] = true;
    } else {
      mouseOver[0] = false;
    }
    if (sqrt(sq(mx-(hori?xPos+s/2+s/8:xPos))+sq(my-(hori?yPos:yPos+s/2+s/8))) < s/2) {
      mouseOver[2] = true;
    } else {
      mouseOver[2] = false;
    }
  }

  public void mouseClicked(float mx, float my) {
    if (sqrt(sq(mx-(hori?xPos-s/2-s/8:xPos))+sq(my-(hori?yPos:yPos-s/2-s/8))) < s/2) {
      listener.onChangeBy(-1);
      listener.onRender(true);
    }
    if (sqrt(sq(mx-(hori?xPos+s/2+s/8:xPos))+sq(my-(hori?yPos:yPos+s/2+s/8))) < s/2) {
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
      presspoint = hori?mx:my;
    }
  }

  public void mouseDragged(float mx, float my) {
    if (pressed[0]) {
      int fini = 5;
      listener.onChangeBy((int)(((hori?mx:my)-presspoint)/fini));
      presspoint = hori?mx-((mx-presspoint)%fini):my-((my-presspoint)%fini);
    }
  }

  public void mouseReleased() {
    if (pressed[0]) {
      pressed[0] = false;
      listener.onRender(true);
    }
    pressed[1] = false;
    pressed[2] = false;
  }
}