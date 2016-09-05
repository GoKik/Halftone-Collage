public class area {
  
  public float aWidth, aHeight, bWidth, bHeight, xPos, yPos;
  public boolean black = false;
  
  private area[] areas = new area[2];
  private spacer div;
  private renderarea renderframe = new renderarea(this);
  private area parent;
  
  private boolean mouseOver = false;
  private int curvemode = 0;
  
  private Point curve[] = new Point[4];
  private float angle = 0;
  
  private boolean adrag = false;
  
  float s = 20;
  
  public area(float x, float y, float w, float h, area p) {
    aWidth = w;
    aHeight = h;
    xPos = x;
    yPos = y;
    bWidth = 20;
    bHeight = 20;
    parent = p;
    
    curve[0] = new Point(x+(0.4*w), y+(h*0.4));
    curve[1] = new Point(x+(0.45*w), y+(0.05*h));
    curve[2] = new Point(x+(0.55*w), y+(0.95*h));
    curve[3] = new Point(x+(0.6*w), y+(h*0.6));
  }
  
  public void draw() {
    stroke(vCol);
    strokeWeight(1);
    fill(255);
    float midx = xPos*scF+(aWidth/2)*scF;
    float midy = yPos*scF+(aHeight/2)*scF;
    if (curvemode == 1) {
      beginShape();
      vertex(curve[1].x*scF, curve[1].y*scF);
      bezierVertex(curve[0].x*scF,curve[0].y*scF,curve[3].x*scF,curve[3].y*scF,curve[2].x*scF,curve[2].y*scF);
      endShape();
      curve[0].draw(scF);
      curve[1].draw(scF);
      curve[2].draw(scF);
      curve[3].draw(scF);
      ellipse(midx, midy, s, s);
      noFill();
      beginShape();
      vertex(midx, midy-(0.3*s));
      bezierVertex(midx-(0.3*s), midy-(0.1*s), midx+(0.3*s), midy+(0.1*s), midx, midy+(0.3*s));
      endShape();
      arc(midx, midy, s*3, s*3, radians(angle)-QUARTER_PI, radians(angle)+QUARTER_PI);
      fill(255);
      ellipse(midx+(1.5*s)*cos(radians(angle)), midy+(1.5*s)*sin(radians(angle)), s, s);
    } else {
      if (areas[0] != null && areas[1] != null) {
        areas[0].draw();
        areas[1].draw();
        div.draw();
      } else {
        if (mouseOver) {
          ellipse(midx-s, midy, s, s);
          ellipse(midx+s, midy, s, s);
          line(midx-(s*1.5), midy, midx-(s*0.5), midy);
          line(midx+s, midy-(s*0.5), midx+s, midy+(s*0.5));
          ellipse(midx, midy+s, s, s);
          beginShape();
          vertex(midx, midy+(0.7*s));
          bezierVertex(midx-(s/3), midy+(0.9*s), midx+(s/3), midy+(1.1*s), midx, midy+(1.3*s));
          endShape();
          if (curvemode == 0) {
            line(midx+cos(QUARTER_PI)*(s/2), midy+s-cos(QUARTER_PI)*(s/2), midx-cos(QUARTER_PI)*(s/2), midy+s+cos(QUARTER_PI)*(s/2));
          }
          if (black) { fill(255); }
          else { noStroke(); fill(0); }
          ellipse(midx, midy-s, s, s);
          stroke(vCol);
          line(midx+(s*2), midy-(0.5*s), midx+(s*2.5), midy-(0.5*s));
          line(midx+(2.25*s), midy-(0.25*s), midx+(2.25*s), midy-(0.75*s));
          line(midx+(2*s), midy+(0.5*s), midx+(2.5*s), midy+(0.5*s));
          
          line(midx-(0.5*s), midy+(2*s), midx-(0.5*s), midy+(2.5*s));
          line(midx-(0.25*s), midy+(2.25*s), midx-(0.75*s), midy+(s*2.25));
          line(midx+(0.25*s), midy+(2.25*s), midx+(0.75*s), midy+(2.25*s));
        } else {
          ellipse(midx, midy, s/2, s/2);
        }
      }
    }
    fill(255);
    noStroke();
    rect(xPos*scF, yPos*scF,bWidth*scF, aHeight*scF);
    rect(xPos*scF, yPos*scF,aWidth*scF, bHeight*scF);
    rect(xPos*scF+aWidth*scF-bWidth*scF, yPos*scF, bWidth*scF, aHeight*scF);
    rect(xPos*scF, yPos*scF+aHeight*scF-bHeight*scF, aWidth*scF, bHeight*scF);
  }
  
  public Point[] getCurve() {
    if (curvemode != 0 || parent == null) {
      return curve;
    } else {
      return parent.getCurve();
    }
  }
  
  public float getAngle() {
    if (curvemode != 0 || parent == null) {
      return angle;
    } else {
      return parent.getAngle();
    }
  }
  
  public void divide(boolean h) {
    if (h) {
      div = new spacer(xPos+(aWidth/2), yPos+(aHeight/2), h, yPos, yPos+aHeight, this);
      areas[0] = new area(xPos, yPos, aWidth, aHeight/2, this);
      areas[1] = new area(xPos, yPos + (aHeight/2), aWidth, aHeight/2, this);
      if (parent != null) {
        parent.updateDiv1(yPos+(aHeight/2), h, this);
      }
    } else {
      div = new spacer(xPos+(aWidth/2), yPos+(aHeight/2), h, xPos, xPos+aWidth, this);
      areas[0] = new area(xPos, yPos, aWidth/2, aHeight, this);
      areas[1] = new area(xPos+(aWidth/2), yPos, aWidth/2, aHeight, this);
      if (parent != null) {
        parent.updateDiv1(xPos+(aWidth/2), h, this);
      }
    }
  }
  
  
  public void rebuild() {
    div = null;
    if (areas[0] != null) {
      areas[0].rebuild();
    }
    if (areas[1] != null) {
      areas[1].rebuild();
    }
    areas[0] = null;
    areas[1] = null;
  }
  
  public void transform(float n, boolean h) {
     if (h) {
       areas[0].aHeight = n-yPos;
       areas[1].aHeight = yPos+aHeight-n;
       areas[1].yPos = n;
       areas[0].subtransform(n, 'h');
       areas[1].subtransform(n, 'y');
     } else {
       areas[0].aWidth = n-xPos;
       areas[1].aWidth = xPos+aWidth-n;
       areas[1].xPos = n;
       areas[0].subtransform(n, 'w');
       areas[1].subtransform(n, 'x');
     }
     if (parent != null) {
       parent.updateDiv1(n, h, this);
     }
  }
  
  public void subtransform(float n, char b) {
    if (div == null) {
      return;
    }
    switch (b) {
      case 'x':
        if (div.horizontal) {
          div.xPos = xPos+(aWidth/2);
          areas[0].aWidth = aWidth;
          areas[0].xPos = xPos;
          areas[1].aWidth = aWidth;
          areas[1].xPos = xPos;
          areas[0].subtransform(n, b);
          areas[1].subtransform(n, b);
        } else {
          areas[0].aWidth = areas[0].xPos+areas[0].aWidth-xPos;
          areas[0].xPos = xPos;
          areas[0].subtransform(n, b);
        }
        break;
      case 'y':
        if (!div.horizontal) {
          div.yPos = yPos+(aHeight/2);
          areas[0].aHeight = aHeight;
          areas[0].yPos = yPos;
          areas[1].aHeight = aHeight;
          areas[1].yPos = yPos;
          areas[0].subtransform(n, b);
          areas[1].subtransform(n, b);
        } else {
          areas[0].aHeight = areas[0].yPos+areas[0].aHeight-yPos;
          areas[0].yPos = yPos;
          areas[0].subtransform(n, b);
        }
        break;
      case 'w':
        if (div.horizontal) {
          div.xPos = xPos+(aWidth/2);
          areas[0].aWidth = aWidth;
          areas[1].aWidth = aWidth;
          areas[0].subtransform(n, b);
          areas[1].subtransform(n, b);
        } else {
          areas[1].aWidth = xPos+aWidth-areas[1].xPos;
          areas[1].subtransform(n, b);
        }
        break;
      case 'h':
        if (!div.horizontal) {
          div.yPos = yPos+(aHeight/2);
          areas[0].aHeight = aHeight;
          areas[1].aHeight = aHeight;
          areas[0].subtransform(n, b);
          areas[1].subtransform(n, b);
        } else {
          areas[1].aHeight = yPos+aHeight-areas[1].yPos;
          areas[1].subtransform(n, b);
        }
        break;
    }
  }
        
  
  public void render() {
    if (areas[0] != null && areas[1] != null) {
      areas[0].render();
      areas[1].render();
    } else {
      renderframe.render();
    }
  }
  
  public void mouseMoved(float mx, float my) {
    if (areas[0] != null && areas[1] != null) {
      areas[0].mouseMoved(mx, my);
      areas[1].mouseMoved(mx, my);
      div.mouseMoved(mx, my);
    } else {
      if (!mouseOver && sqrt(sq(mx-(xPos+(aWidth/2)))+sq(my-(yPos+(aHeight/2)))) <= s/2/scF) {
        mouseOver = true;
      }
      if (mouseOver && sqrt(sq(mx-(xPos+(aWidth/2)))+sq(my-(yPos+(aHeight/2)))) > s*3/scF) {
        mouseOver = false;
      }
    }
    if (curvemode == 1) {
      curve[0].hover(mx, my);
      curve[1].hover(mx, my);
      curve[2].hover(mx, my);
      curve[3].hover(mx, my);
    }
  }
  
  public void mouseClicked(float mx, float my) {
    if (areas[0] != null && areas[1] != null) {
      areas[0].mouseClicked(mx, my);
      areas[1].mouseClicked(mx, my);
      div.mouseClicked(mx, my);
    } else {
      if (mouseOver) {
        if (sqrt(sq(mx-(xPos+(aWidth/2)-(s/scF)))+sq(my-(yPos+(aHeight/2)))) <= s/2/scF) {
          divide(true);
        }
        if (sqrt(sq(mx-(xPos+(aWidth/2)+(s/scF)))+sq(my-(yPos+(aHeight/2)))) <= s/2/scF) {
          divide(false);
        }
        if (sqrt(sq(mx-(xPos+(aWidth/2)))+sq(my-(yPos+(aHeight/2)-(s/scF)))) <= s/2/scF) {
          black = !black;
        }
        if (sqrt(sq(mx-(xPos+(aWidth/2)))+sq(my-(yPos+(aHeight/2)+(s/scF)))) <= s/2/scF) {
          curvemode = (curvemode+1)%3;
        }
        if (sqrt(sq(mx-(xPos+(aWidth/2)+(2.25*s/scF)))+sq(my-(yPos+(aHeight/2)-(0.5*s/scF)))) <= s/2/scF) {
          bHeight++;
        }
        if (sqrt(sq(mx-(xPos+(aWidth/2)+(2.25*s/scF)))+sq(my-(yPos+(aHeight/2)+(0.5*s/scF)))) <= s/2/scF) {
          bHeight--;
          if (bHeight < 0) { bHeight = 0; }
        }
        if (sqrt(sq(mx-(xPos+(aWidth/2)-(0.5*s/scF)))+sq(my-(yPos+(aHeight/2)+(2.25*s/scF)))) <= s/2/scF) {
          bWidth++;
        }
        if (sqrt(sq(mx-(xPos+(aWidth/2)+(0.5*s/scF)))+sq(my-(yPos+(aHeight/2)+(2.25*s/scF)))) <= s/2/scF) {
          bWidth--;
          if (bWidth < 0) { bWidth = 0; }
        }
      }
      if (curvemode == 1) {
        if (sqrt(sq(mx-(xPos+(aWidth/2)))+sq(my-(yPos+(aHeight/2)))) < s/2/scF) {
          curvemode = 2;
        }
      }
    }
  }
  
  public void mousePressed(float mx, float my) {
    if (areas[0] != null && areas[1] != null) {
      areas[0].mousePressed(mx, my);
      areas[1].mousePressed(mx, my);
      div.mousePressed(mx, my);
    }
    if (curvemode == 1) {
      curve[0].press(mx, my);
      curve[1].press(mx, my);
      curve[2].press(mx, my);
      curve[3].press(mx, my);
      if (sqrt(sq(mx-(xPos+(aWidth/2)+cos(radians(angle))*(1.5*s/scF)))+sq(my-(yPos+(aHeight/2)+sin(radians(angle))*(1.5*s/scF)))) < s/2/scF) {
        adrag = true;
      }
    } 
  }
  
  public void mouseReleased(float mx, float my) {
    if (areas[0] != null && areas[1] != null) {
      areas[0].mouseReleased(mx, my);
      areas[1].mouseReleased(mx, my);
      div.mouseReleased(mx, my);
    }
    adrag = false;
  }
  
  public void mouseDragged(float mx, float my) {
    if (areas[0] != null && areas[1] != null) {
      areas[0].mouseDragged(mx, my);
      areas[1].mouseDragged(mx, my);
      div.mouseDragged(mx, my);
    }
    if (curvemode == 1) {
      curve[0].press(mx, my);
      curve[1].press(mx, my);
      curve[2].press(mx, my);
      curve[3].press(mx, my);
      if (adrag) {
        float r = sqrt(sq(mx - (xPos+(aWidth/2))) + sq(my - (yPos+(aHeight/2))));
        if ((yPos+(aHeight/2)) > my) { 
          angle = degrees(acos((float)((xPos+(aWidth/2)) - mx)/(r))) + 180;
        } else {
          angle = degrees(acos((float)((xPos+(aWidth/2)) - mx)/(-r)));
        }
      }
    } 
  }
}
      
  
  