public class renderarea {

  private area parent;
  public float distance = 4;
  public int linesL;
  public int linesR;
  public int steps = (int)(materialH / distance); 
  public boolean linked = true;
  public boolean dotted = false;

  public float time = 0;
  private float[] pos = new float[3];

  private ArrayList<ArrayList<Point>> avgs = new ArrayList<ArrayList<Point>>();

  private boolean mouseOver;

  public renderarea(area p) {
    parent = p;
    linesL = (int)(parent.aWidth / distance / 2);
    linesR = linesL;
    listeners.put(this.toString()+"distance", new OnChangeListener() {
      boolean wait = false;
      float save = distance;
      public void saveForRender() {
        wait = true;
        save = distance;
      }
      public void onChangeBy(int i) {
        if (!wait) {
          save = distance;
        }
        distance = float(round((distance+(0.1*i))*10))/10;
      }
      public void onChange(Object o) {
        if (!wait) {
          save = distance;
        }
        distance = (float)o;
      }
      public void onRender(boolean h) {
        if (h) {
          history.add(new Action(save, distance, "Changed Distance to "+distance+" mm", this));
        }
        wait = false;
      }
    });
    listeners.put(this.toString()+"linesL", new OnChangeListener() {
      boolean wait = false;
      int save = linesL;
      public void saveForRender() {
        wait = true;
        save = linesL;
      }
      public void onChangeBy(int i) {
        if (!wait) {
          save = linesL;
        }
        linesL+=i;
        if (linesL+linesR < 1) { 
          linesL=1-linesR;
        }
      }
      public void onChange(Object o) {
        if (!wait) {
          save = linesL;
        }
        linesL = (int)o;
      }
      public void onRender(boolean h) {
        if (h) {
          history.add(new Action(save, linesL, "Changed Line-Count to "+(linesL+linesR), this));
        }
        wait = false;
      }
    });
    listeners.put(this.toString()+"linesR", new OnChangeListener() {
      boolean wait = false;
      int save = linesR;
      public void saveForRender() {
        wait = true;
        save = linesR;
      }
      public void onChangeBy(int i) {
        if (!wait) {
          save = linesR;
        }
        linesR+=i;
        if (linesL+linesR < 1) { 
          linesR=1-linesL;
        }
      }
      public void onChange(Object o) {
        if (!wait) {
          save = linesR;
        }
        linesR = (int)o;
      }
      public void onRender(boolean h) {
        if (h) {
          history.add(new Action(save, linesR, "Changed Line-Count to "+(linesL+linesR), this));
        }
        wait = false;
      }
    });
    listeners.put(this.toString()+"steps", new OnChangeListener() {
      boolean wait = false;
      int save = steps;
      public void saveForRender() {
        wait = true;
        save = steps;
      }
      public void onChangeBy(int i) {
        if (!wait) {
          save = steps;
        }
        steps+=i;
        if (steps < 1) { 
          steps = 1;
        }
      }
      public void onChange(Object o) {
        if (!wait) {
          save = steps;
        }
        steps = (int)o;
      }
      public void onRender(boolean h) {
        if (h) {
          history.add(new Action(save, steps, "Changed Steps to "+steps, this));
        }
        wait = false;
      }
    });
    listeners.put(this.toString()+"linked", new OnChangeListener() {
      public void saveForRender() {}
      public void onChangeBy(int i) {}
      public void onChange(Object o) {
        linked = (boolean)o;
      }
      public void onRender(boolean h) {
        if (h) {
          history.add(new Action(!linked, linked, (linked?"Linked":"Unlinked")+" Renderdata", this));
        }
      }
    });
    listeners.put(this.toString()+"dotted", new OnChangeListener() {
      public void saveForRender() {}
      public void onChangeBy(int i) {}
      public void onChange(Object o) {
        dotted = (boolean)o;
      }
      public void onRender(boolean h) {
        if (h) {
          history.add(new Action(!dotted, dotted, "Set Rendering to "+(dotted?"Dotted":"Connected"), this));
        }
      }
    });
  }


  public void draw() {
    if (render) {
      noStroke();
      fill(parent.black?0:255);
      rect(parent.xPos*scF+parent.bWidth*scF, parent.yPos*scF+parent.bHeight*scF, parent.aWidth*scF-parent.bWidth*scF*2, parent.aHeight*scF-parent.bHeight*scF*2);
      fill(parent.black?255:0);
      noStroke();
      for (int i = 0; i < avgs.size(); i++) {
        for (int j = 0; j < avgs.get(i).size(); j++) {
          ellipse(avgs.get(i).get(j).x*scF, avgs.get(i).get(j).y*scF, avgs.get(i).get(j).data*scF, avgs.get(i).get(j).data*scF);
        }
      }
      float midx = parent.xPos*scF+(parent.aWidth/2)*scF;
      float midy = parent.yPos*scF+(parent.aHeight/2)*scF;
      float s = parent.s;
      if (!print) {
        if (mouseOver) {
          fill(parent.black?vCol:bgCol);
          ellipse(midx-(1.7*s), midy-(0.6*s), s, s);
          ellipse(midx-(0.6*s), midy-(0.6*s), s, s);
          ellipse(midx+(0.6*s), midy-(0.6*s), s, s);
          ellipse(midx+(1.7*s), midy-(0.6*s), s, s);
          ellipse(midx-(1.7*s), midy+(0.6*s), s, s);
          ellipse(midx-(0.6*s), midy+(0.6*s), s, s);
          ellipse(midx+(0.6*s), midy+(0.6*s), s, s);
          ellipse(midx+(1.7*s), midy+(0.6*s), s, s);
          ellipse(midx+(0.6*s), midy-(1.7*s), s, s);
          fill(parent.black?bgCol:vCol);
          textSize(s*0.9);
          textAlign(CENTER, CENTER);
          text("+", midx-(1.7*s), midy-(0.8*s));
          text("-", midx-(0.6*s), midy-(0.8*s));
          text("-", midx+(0.6*s), midy-(0.8*s));
          text("+", midx+(1.7*s), midy-(0.8*s));
          textSize(s*0.6);
          text("◄", midx-(1.8*s), midy+(0.5*s));
          text("►", midx-(0.6*s), midy+(0.5*s));
          text("▲", midx+(0.6*s), midy+(0.5*s));
          text("▼", midx+(1.7*s), midy+(0.6*s));
          if (dotted) {
            ellipse(midx+(0.8*s), midy-(1.7*s), 0.3*s, 0.3*s);
            ellipse(midx+(0.4*s), midy-(1.7*s), 0.3*s, 0.3*s);
          } else {
            rect(midx+(0.25*s), midy-(1.85*s), 0.7*s, 0.3*s, 0.15*s);
          }
          if (!parent.ownC()) {
            fill(parent.black?vCol:bgCol);
            ellipse(midx-(0.6*s), midy-(1.7*s), s, s);
            noFill();
            stroke(parent.black?bgCol:vCol);
            if (linked) {
              ellipse(midx-0.7*s, midy-(1.7*s), 0.3*s, 0.3*s);
              ellipse(midx-0.5*s, midy-(1.7*s), 0.3*s, 0.3*s);
            } else {
              ellipse(midx-0.8*s, midy-(1.7*s), 0.3*s, 0.3*s);
              ellipse(midx-0.4*s, midy-(1.7*s), 0.3*s, 0.3*s);
            }
          }
        } else {
          ellipse(midx, midy, s/2, s/2);
        }
      }
    }
  }

  public void render() {
    parent.getRenderData(this, linked);
    imgFilter();
  }

  void imgFilter() {
    avgs = new ArrayList<ArrayList<Point>>();
    avgs.add(new ArrayList<Point>());
    if (linesL>=0&&linesR>=0) {
      for (float i = 0; i <= 1; i += (float)1/steps) {
        Point p = getCurvePoint(i);
        addPoint(0, new Point(p.x, p.y, getAVG(p)));
      }
      for (int i = 1; i < linesR; i++) {
        float offsetx = i*distance*cos(radians(parent.getAngle()));
        float offsety = i*distance*(-sin(radians(parent.getAngle())));
        avgs.add(new ArrayList<Point>());
        for (float j = 0; j <= 1; j += (float)1/steps) {
          Point p = getCurvePoint(j);
          Point p1 = new Point(p.x+offsetx, p.y+offsety);
          addPoint(avgs.size()-1, new Point(p1.x, p1.y, getAVG(p1)));
        }
      }
      for (int i = 1; i < linesL; i++) {
        float offsetx = i*distance*cos(radians(parent.getAngle()));
        float offsety = i*distance*(-sin(radians(parent.getAngle())));
        avgs.add(0, new ArrayList<Point>());
        for (float j = 0; j <= 1; j += (float)1/steps) {
          Point p = getCurvePoint(j);
          Point p2 = new Point(p.x-offsetx, p.y-offsety);
          addPoint(0, new Point(p2.x, p2.y, getAVG(p2)));
        }
      }
    } else {
      for (int i = abs(min(linesL, linesR)); i<max(linesL, linesR); i++) {
        float offsetx = i*distance*cos(radians(parent.getAngle()));
        float offsety = i*distance*(-sin(radians(parent.getAngle())));
        avgs.add(0, new ArrayList<Point>());
        for (float j = 0; j <= 1; j += (float)1/steps) {
          Point p = getCurvePoint(j);
          Point p2 = new Point(p.x+(linesL<linesR?offsetx:-offsetx), p.y+(linesL<linesR?offsety:-offsety));
          addPoint(0, new Point(p2.x, p2.y, getAVG(p2)));
        }
      }
    }
  }

  void addPoint(int i, Point p) {
    if (p.x > parent.xPos+parent.bWidth && p.x < parent.xPos+parent.aWidth-parent.bWidth && p.y > parent.yPos+parent.bHeight && p.y < parent.yPos+parent.aHeight-parent.bHeight) {
      avgs.get(i).add(p);
    }
  }

  float getAVG(Point p) {
    float sum = 0;
    float count = 0;
    float rad = maxRad/2;
    float factor = image.width/imgW;
    image.loadPixels();
    for (int x = (int)(p.x*factor - rad*factor - imgX*factor); x < p.x*factor + rad*factor - imgX*factor; x += 1) {
      if (x < 0 || x >= image.width) { 
        continue;
      }
      for (int y = (int)(p.y*factor -rad*factor -imgY*factor); y<p.y*factor +rad*factor -imgY*factor; y += 1) {
        if (y < 0 || y >= image.height) { 
          continue;
        }
        sum += red(image.pixels[y*image.width+x]);
        count+=1;
      }
    }
    image.updatePixels();

    float data = (!parent.black?(255-(sum/count))/255*maxRad:(sum/count)/255*maxRad);
    if (data < bitMin) {
      data = bitMin;
    }
    return data;
  }


  Point getCurvePoint(float f) {  

    Point[] curve = parent.getCurve();

    float xa = curve[1].x + (f * (curve[0].x - curve[1].x));
    float ya = curve[1].y + (f * (curve[0].y - curve[1].y));
    float xb = curve[0].x + (f * (curve[3].x - curve[0].x));
    float yb = curve[0].y + (f * (curve[3].y - curve[0].y));
    float xc = curve[3].x + (f * (curve[2].x - curve[3].x));
    float yc = curve[3].y + (f * (curve[2].y - curve[3].y));

    float xab = xa + (f * (xb - xa));
    float yab = ya + (f * (yb - ya));
    float xbc = xb + (f * (xc - xb));
    float ybc = yb + (f * (yc - yb));

    float xabc = xab + (f * (xbc - xab));
    float yabc = yab + (f * (ybc - yab));

    return new Point(xabc, yabc);
  }

  public void getErrors() {
    for (int i = 0; i < avgs.size(); i++) {
      for (int i2 = 0; i2 < avgs.get(i).size(); i2++) {
        for (int j = 0; j < avgs.size(); j++) {
          for (int j2 = 0; j2 < avgs.get(j).size(); j2++) {
            float r = sqrt(sq(avgs.get(i).get(i2).x - avgs.get(j).get(j2).x) + sq(avgs.get(i).get(i2).y - avgs.get(j).get(j2).y));
            if ((dotted && (i != j || i2 != j2)) || (!dotted && i != j)) {
              if (r <= (avgs.get(i).get(i2).data/2) + (avgs.get(j).get(j2).data/2)) {
                errors.add(new Point[]{avgs.get(i).get(i2), avgs.get(j).get(j2)});
              }
              float free = r - ((avgs.get(i).get(i2).data/2) + (avgs.get(j).get(j2).data/2));
              if (minFree[0] == null || free < minFree[0].x) {
                minFree[0] = new Point(free, 0);
                minFree[1] = avgs.get(i).get(i2);
                minFree[2] = avgs.get(j).get(j2);
              }
            }
          }
        }
      }
    }
  }

  public String[] generateGCode() {
    ArrayList<String> output = new ArrayList<String>();
    boolean in = false;
    time = 0;
    pos[0] = 0;
    pos[1] = 0;
    pos[2] = 0;
    output.add("G92 X0 Y0 Z0");
    output.add("G21");
    output.add("G90");
    output.add("G1 Z5.0 F"+sOut);
    go(null, null, (float)5, sOut);
    output.add("G1 X"+(parent.aWidth-parent.bWidth*2)+" F"+sOut);
    go((parent.aWidth-parent.bWidth*2), null, null, sOut);
    output.add("G1 Y"+(parent.aHeight-parent.bHeight*2)+" F"+sOut);
    go(null, (parent.aHeight-parent.bHeight*2), null, sOut);
    output.add("G1 X0 F"+sOut);
    go((float)0, null, null, sOut);
    output.add("G1 Y0 F"+sOut);
    go(null, (float)0, null, sOut);
    for (int i = 0; i < avgs.size(); i++) {
      for (int j = (i%2==0?0:avgs.get(i).size()-1); (i%2==0?j<avgs.get(i).size():j>=0); j+=(i%2==0?1:-1)) {
        Point p = new Point(avgs.get(i).get(j).x, avgs.get(i).get(j).y, avgs.get(i).get(j).data);
        p.y = parent.aHeight-parent.bHeight*2-p.y;
        if (dotted) {
          if (p.data > 0) {
            output.add("G0 X"+p.x+" Y"+p.y+" F"+sOut);
            go(p.x, p.y, null, sOut);
            output.add("G1 Z"+(-(p.data/bitW)*bitH)+" F"+sInD);
            go(null, null, (-(p.data/bitW)*bitH), sInD);
            output.add("G1 Z"+hOut+" F"+sInD);
            go(null, null, hOut, sInD);
          }
        } else {
          if (in) {
            if (p.data > 0) {
              output.add("G1 X"+p.x+" Y"+p.y+" Z"+(-(p.data/bitW)*bitH)+" F"+sIn);
              go(p.x, p.y, (-(p.data/bitW)*bitH), sIn);
            } else {
              output.add("G1 Z"+hOut+" F"+sIn);
              go(null, null, hOut, sIn);
              in = false;
            }
          } else {
            if (p.data > 0) {
              output.add("G0 X"+p.x+" Y"+p.y+" F"+sOut);
              go(p.x, p.y, null, sOut);
              output.add("G1 Z"+(-(p.data/bitW)*bitH)+" F"+sIn);
              go(null, null, (-(p.data/bitW)*bitH), sIn);
              in = true;
            }
          }
        }
      }
      if (in) {
        output.add("G1 Z"+hOut+" F"+(dotted?sInD:sIn));
        go(null, null, hOut, (dotted?sInD:sIn));
        in = false;
      }
    }
    if (in) {
      output.add("G1 Z"+hOut+" F"+(dotted?sInD:sIn));
      go(null, null, hOut, (dotted?sInD:sIn));
      in = false;
    }
    output.add("G0 X0.000 Y0.000 F"+sOut);
    go((float)0, (float)0, null, sOut);
    String[] gcode = output.toArray(new String[output.size()]);
    return gcode;
  }

  void go(Float x, Float y, Float z, float sp) {
    if (x==null) { 
      x = pos[0];
    };
    if (y==null) { 
      y = pos[1];
    };
    if (z==null) { 
      z = pos[2];
    };
    time += sqrt(sq(sqrt(sq(pos[0]-x)+sq(pos[1]-y)))+sq(pos[2]-z))/sp;
    pos[0] = x;
    pos[1] = y;
    pos[2] = z;
  }

  void mouseMoved(float mx, float my) {
    if (sqrt(sq(mx-(parent.xPos+(parent.aWidth/2)))+sq(my-(parent.yPos+(parent.aHeight/2)))) < parent.s/2/scF) {
      mouseOver = true;
    }
    if (sqrt(sq(mx-(parent.xPos+(parent.aWidth/2)))+sq(my-(parent.yPos+(parent.aHeight/2)))) > parent.s*3/scF) {
      mouseOver = false;
    }
  }

  void mouseClicked(float mx, float my) {
    float midx = parent.xPos+(parent.aWidth/2);
    float midy = parent.yPos+(parent.aHeight/2);
    float s = parent.s/scF;
    float r = parent.s/2/scF;
    boolean click = false;
    if (mouseOver && sqrt(sq(mx-(midx-1.7*s))+sq(my-(midy-0.6*s))) < r) {
      listeners.get(this.toString()+"linesL").onChangeBy(1);
      listeners.get(this.toString()+"linesL").onRender(true);
      click = true;
    }
    if (mouseOver && sqrt(sq(mx-(midx-0.6*s))+sq(my-(midy-0.6*s))) < r) {
      listeners.get(this.toString()+"linesL").onChangeBy(-1);
      listeners.get(this.toString()+"linesL").onRender(true);
      click = true;
    }
    if (mouseOver && sqrt(sq(mx-(midx+0.6*s))+sq(my-(midy-0.6*s))) < r) {
      listeners.get(this.toString()+"linesR").onChangeBy(-1);
      listeners.get(this.toString()+"linesR").onRender(true);
      click = true;
    }
    if (mouseOver && sqrt(sq(mx-(midx+1.7*s))+sq(my-(midy-0.6*s))) < r) {
      listeners.get(this.toString()+"linesR").onChangeBy(1);
      listeners.get(this.toString()+"linesR").onRender(true);
      click = true;
    }
    if (mouseOver && sqrt(sq(mx-(midx-1.7*s))+sq(my-(midy+0.6*s))) < r) {
      listeners.get(this.toString()+"distance").onChangeBy(1);
      listeners.get(this.toString()+"distance").onRender(true);
      click = true;
    }
    if (mouseOver && sqrt(sq(mx-(midx-0.6*s))+sq(my-(midy+0.6*s))) < r) {
      listeners.get(this.toString()+"distance").onChangeBy(-1);
      listeners.get(this.toString()+"distance").onRender(true);
      click = true;
    }
    if (mouseOver && sqrt(sq(mx-(midx+0.6*s))+sq(my-(midy+0.6*s))) < r) {
      listeners.get(this.toString()+"steps").onChangeBy(1);
      listeners.get(this.toString()+"steps").onRender(true);
      click = true;
    }
    if (mouseOver && sqrt(sq(mx-(midx+1.7*s))+sq(my-(midy+0.6*s))) < r) {
      listeners.get(this.toString()+"steps").onChangeBy(-1);
      listeners.get(this.toString()+"steps").onRender(true);
      click = true;
    }
    if (mouseOver && !parent.ownC() && sqrt(sq(mx-(midx-0.6*s))+sq(my-(midy-1.7*s))) < r) {
      listeners.get(this.toString()+"linked").onChange(!linked);
      listeners.get(this.toString()+"linked").onRender(true);
      click = true;
    }
    if (mouseOver && sqrt(sq(mx-(midx+0.6*s))+sq(my-(midy-1.7*s))) < r) {
      listeners.get(this.toString()+"dotted").onChange(!dotted);
      listeners.get(this.toString()+"dotted").onRender(true);
      click = true;
    }

    if (render && click) {
      parent.setRenderData(this, linked);
    }
  }

}