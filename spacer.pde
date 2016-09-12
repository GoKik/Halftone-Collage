public class spacer {

  public boolean horizontal;
  public float xPos, yPos;
  private area parent;

  private boolean mouseOver = false, dragged = false;
  private float dragx = 0, dragy = 0;
  private int valMode = 0;
  private String valInput = new String();

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
        noStroke();
        fill(valMode==1?vCol:bgCol, 200);
        rect(horizontal?x:x-50, horizontal?y-50:y, 40, 24, 12);
        fill(valMode==2?vCol:bgCol, 200);
        rect(horizontal?x:x+50, horizontal?y+50:y, 40, 24, 12);
        rectMode(CORNER);
        textAlign(CENTER, CENTER);
        
        fill(valMode==1?bgCol:vCol);
        text(valMode==1?valInput:Integer.toString(int(horizontal?parent.areas[0].aHeight:parent.areas[0].aWidth)), horizontal?x:x-50, horizontal?y-52:y-2);
        
        fill(valMode==2?bgCol:vCol);
        text(valMode==2?valInput:Integer.toString(int(horizontal?parent.areas[1].aHeight:parent.areas[1].aWidth)), horizontal?x:x+50, horizontal?y+48:y-2);

      
    }
  }

  public void mouseMoved(float mx, float my) {
    if (!mouseOver && sqrt(sq(mx-xPos)+sq(my-yPos)) <= 20/scF) {
      mouseOver = true;
    }
    if (mouseOver && sqrt(sq(mx-xPos)+sq(my-yPos)) > 70/scF) {
      mouseOver = false;
    }
  }

  public void mouseClicked(float mx, float my) {
    if (sqrt(sq(mx-xPos)+sq(my-yPos)) <= 10/scF) {
      parent.rebuild();
      prints.add(parent);
    }
    if (horizontal) {
      if (sqrt(sq(mx-xPos)+sq(my-(yPos-50))) <= 24/scF) {
        if (valMode != 0) {
          valMode = 0;
          if (valInput.length() != 0 && Float.parseFloat(valInput) != parent.areas[0].aHeight) {
            yPos = getDivPos(this, parent.yPos+Float.parseFloat(valInput));
            parent.transform(yPos, horizontal);
          }
        } else {
          valMode = 1;
          valInput = Integer.toString((int)parent.areas[0].aHeight);
        }
      }
      if (sqrt(sq(mx-xPos)+sq(my-(yPos+50))) <= 24/scF) {
        if (valMode != 0) {
          valMode = 0;
          if (valInput.length() != 0 && Float.parseFloat(valInput) != parent.areas[1].aHeight) {
            yPos = getDivPos(this, parent.yPos+parent.aHeight-Float.parseFloat(valInput));
            parent.transform(yPos, horizontal);
          }
        } else {
          valMode = 2;
          valInput = Integer.toString((int)parent.areas[1].aHeight);
        }
      }
    } else {
      if (sqrt(sq(mx-(xPos-50))+sq(my-yPos)) <= 24/scF) {
        if (valMode != 0) {
          valMode = 0;
          if (valInput.length() != 0 && Float.parseFloat(valInput) != parent.areas[0].aWidth) {
            xPos = getDivPos(this, parent.xPos+Float.parseFloat(valInput));
            parent.transform(xPos, horizontal);
          }
        } else {
          valMode = 1;
          valInput = Integer.toString((int)parent.areas[0].aWidth);
        }
      }
      if (sqrt(sq(mx-(xPos+50))+sq(my-yPos)) <= 24/scF) {
        if (valMode != 0) {
          valMode = 0;
          if (valInput.length() != 0 && Float.parseFloat(valInput) != parent.areas[1].aWidth) {
            xPos = getDivPos(this, parent.xPos+parent.aWidth-Float.parseFloat(valInput));
            parent.transform(xPos, horizontal);
          }
        } else {
          valMode = 2;
          valInput = Integer.toString((int)parent.areas[1].aWidth);
        }
      }      
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
  
  public void keyPressed() {
    switch (key) {
      case '0': valInput+="0"; break;
      case '1': valInput+="1"; break;
      case '2': valInput+="2"; break;
      case '3': valInput+="3"; break;
      case '4': valInput+="4"; break;
      case '5': valInput+="5"; break;
      case '6': valInput+="6"; break;
      case '7': valInput+="7"; break;
      case '8': valInput+="8"; break;
      case '9': valInput+="9"; break;
      case BACKSPACE: valInput=valInput.length()>0?valInput.substring(0, valInput.length()-1):""; break;
    }
  }
}