public class renderarea {
  
  private area parent;
  private int linesL = 10;
  private int linesR = 10;
  private float distance = 4;
  private int steps = 100; 
  
  private ArrayList<ArrayList<Point>> avgs = new ArrayList<ArrayList<Point>>();
  
  public renderarea(area p) {
    parent = p;
  }
  
  
  public void draw() {
    
  if (render) {
    
    fill(0);
    noStroke();
    for (int i = 0; i < avgs.size(); i++) {
      for (int j = 0; j < avgs.get(i).size(); j++) {
        ellipse(avgs.get(i).get(j).x*scF, avgs.get(i).get(j).y*scF, avgs.get(i).get(j).data*scF, avgs.get(i).get(j).data*scF);
      }
    }
    
    
  }
  }
 
  public void render() {
    imgFilter();
  }
  
void imgFilter() {
  avgs = new ArrayList<ArrayList<Point>>();
  avgs.add(new ArrayList<Point>());
  for (float i = 0; i <= 1; i += (float)1/steps) {
    Point p = getCurvePoint(i);
    avgs.get(0).add(new Point(p.x, p.y, getAVG(p)));
  }
  for (int i = 1; i < linesR; i++) {
    float offsetx = i*distance*cos(radians(parent.getAngle()));
    float offsety = i*distance*(-sin(radians(parent.getAngle())));
    avgs.add(new ArrayList<Point>());
    for (float j = 0; j <= 1; j += (float)1/steps) {
      Point p = getCurvePoint(j);
      Point p1 = new Point(p.x+offsetx, p.y+offsety);
      if (p1.x > 0 && p1.x < width && p1.y > 0 && p1.y < height) {
        avgs.get(avgs.size()-1).add(new Point(p1.x, p1.y, getAVG(p1)));
      }
    }
  }
  for (int i = 1; i < linesL; i++) {
    float offsetx = i*distance*cos(radians(parent.getAngle()));
    float offsety = i*distance*(-sin(radians(parent.getAngle())));
    avgs.add(0, new ArrayList<Point>());
    for (float j = 0; j <= 1; j += (float)1/steps) {
      Point p = getCurvePoint(j);
      Point p2 = new Point(p.x-offsetx, p.y-offsety);
      if (p2.x > 0 && p2.x < width && p2.y > 0 && p2.y < height) {
        avgs.get(0).add(new Point(p2.x, p2.y, getAVG(p2)));
      }
    }
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
  
  float data = (255-(sum / count))/255*maxRad;
  if (data < bitMin) {data = 0;}
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

}