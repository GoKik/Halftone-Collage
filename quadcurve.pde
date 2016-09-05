/* KEYS
enter: prerender image
w,a,s,d: move image
q,e: scale image
y, x, c, v: num of lines
left, right: distance between lines
+, -: size of milling-bit
l, j, i, k: size of border
up, down: steps per line (for dotted images choose a low number and set "dotted = true"
p: print gcode
f: show overlap of lines
z: export settings
t: inport settings
*/

//set dimensions of your milling-bit
//use a cone-shaped bit
float bitW = 3.125; //widest diameter (mm)
float bitH = 4.9; //height between apex of the cone and place of widest diameter (mm)
float bitMin = 0.15; //diameter at apex of the cone (mm)

//set dimensions of your material
float materialW = 1500; // width of material (mm)
float materialH = 1500; // height of material (mm)

//set milling-speed
float hOut = 2.0; // offset to material
float sIn = 150; // Feedrate
float sOut = 700; // Seekrate



color vCol = color(0);


ArrayList<Point[]> errors = new ArrayList<Point[]>();

PImage image;
float maxRad = 3.1;
boolean render = false;
float minFree = 0;
float imgW;
float imgF = 1;
float imgX = 0;
float imgY = 0;
float[] ms = {0,0};
float scF;
float materialX;
float materialY;

area main;


void setup() {
  size(1440, 850);
  
  scF = min((float)width/materialW, (float)height/materialH);
  materialX = ((width/scF)-materialW)/2;
  materialY = ((height/scF)-materialH)/2;
  
  main = new area(0, 0, materialW, materialH, null);
  
  selectInput("Select a file to process:", "fileSelected");
}

void draw() {
  background(255);
  translate(materialX*scF,materialY*scF);
  
  if (!render && image != null) {
    image(image, imgX*scF, imgY*scF, imgW*scF, imgW*scF*imgF);
  }
  
  main.draw();
   
  if (render) {
    stroke(255,0,0);
    for (int i = 0; i < errors.size(); i++) {
      line(errors.get(i)[0].x*scF, errors.get(i)[0].y*scF, errors.get(i)[1].x*scF, errors.get(i)[1].y*scF);
    }
  }
  
  translate(-materialX*scF,-materialY*scF);
  fill(30);
  rect(0,0,materialX*scF,height);
  rect(0,0,width,materialY*scF);
  rect(0,height-materialY*scF,width,materialY*scF);
  rect(width-materialX*scF,0,materialX*scF,height);

}

void printGcode(File folder) {
  /*
  if (dotted) {
    hOut = 0.7;
    sIn = 500;
    sOut = 1200;
  }
  
  if (folder == null) {
    return;
  }
  ArrayList<String> output = new ArrayList<String>();
  boolean in = false;
  output.add("G92 X0 Y0 Z0");
  output.add("G21");
  output.add("G90");
  output.add("G1 Z5.0 F180.0");
  for (int i = 0; i < avgs.size(); i++) {
    for (int j = 0; j < avgs.get(i).size(); j++) {
      Point p = new Point(avgs.get(i).get(j).x, avgs.get(i).get(j).y, avgs.get(i).get(j).data);
      p.y = materialH-p.y;
      if (p.x < borderW/2 || p.x > materialW-(borderW/2) || p.y < borderH/2 || p.y > materialH-(borderH/2)) {
        if (in) {
          output.add("G1 Z"+hOut+" F"+sIn);
          in = false;
        }
        continue;
      }
      if (dotted) {
        if (p.data > 0) {
          output.add("G0 X"+p.x+" Y"+p.y+" F"+sOut);
          output.add("G1 Z"+(-(p.data/bitW)*bitH)+" F"+sIn);
          output.add("G1 Z"+hOut+" F"+sIn);
        }
      } else {
        if (in) {
          if (p.data > 0) {
            output.add("G1 X"+p.x+" Y"+p.y+" Z"+(-(p.data/bitW)*bitH)+" F"+sIn);
          } else {
            output.add("G1 Z"+hOut+" F"+sIn);
            in = false;
          }
        } else {
          if (p.data > 0) {
            output.add("G0 X"+p.x+" Y"+p.y+" F"+sOut);
            output.add("G1 Z"+(-(p.data/bitW)*bitH)+" F"+sIn);
            in = true;
          }
        }
      }
    }
    if (in) {
      output.add("G1 Z"+hOut+" F"+sIn);
      in = false;
    }
  }
  if (in) {
    output.add("G1 Z"+hOut+" F"+sIn);
    in = false;
  }
  output.add("G0 X0.000 Y0.000 F"+sOut);
  String[] gcode = output.toArray(new String[output.size()]);
  saveStrings(selection.getAbsolutePath(), gcode);
  */
}

void getErrors() {
  /*
  minFree = 0;
  errors = new ArrayList<Point[]>();
  for (int i = 0; i < avgs.size(); i++) {
    for (int i2 = 0; i2 < avgs.get(i).size(); i2++) {
      for (int j = 0; j < avgs.size(); j++) {
        for (int j2 = 0; j2 < avgs.get(j).size(); j2++) {
          float r = sqrt(sq(avgs.get(i).get(i2).x - avgs.get(j).get(j2).x) + sq(avgs.get(i).get(i2).y - avgs.get(j).get(j2).y));
          if ((dotted && (i != j || i2 != j2)) || (!dotted && (i != j && i2 != j2))) {
            if (r <= (avgs.get(i).get(i2).data/2) + (avgs.get(j).get(j2).data/2)) {
              errors.add(new Point[]{avgs.get(i).get(i2), avgs.get(j).get(j2)});
            }
            float free = r - ((avgs.get(i).get(i2).data/2) + (avgs.get(j).get(j2).data/2));
            if (minFree == 0 || free < minFree) {
              minFree = free;
            }
          }
        }
      }
    }
  }
  */
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    String file = selection.getAbsolutePath();
    image = loadImage(file);
    imgW = materialW;
    imgF = (float)image.height/image.width;
    image.filter(GRAY);
  }
}

void exportSettings(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    return;
  }
  /*
  ArrayList<String> output = new ArrayList<String>();
  output.add(str(linesL));
  output.add(str(linesR));
  output.add(str(distance));
  output.add(str(steps));
  output.add(str(maxRad));
  output.add(str(angle));
  output.add(str(dotted));
  output.add(str(materialW));
  output.add(str(materialH));
  output.add(str(bitW));
  output.add(str(bitH));
  output.add(str(bitMin));
  output.add(str(borderW));
  output.add(str(borderH));
  output.add(str(hOut));
  output.add(str(sIn));
  output.add(str(sOut));
  output.add(str(curve[0].x));
  output.add(str(curve[0].y));
  output.add(str(curve[1].x));
  output.add(str(curve[1].y));
  output.add(str(curve[2].x));
  output.add(str(curve[2].y));
  output.add(str(curve[3].x));
  output.add(str(curve[3].y));  
  String[] settings = output.toArray(new String[output.size()]);
  saveStrings(selection.getAbsolutePath(), settings);
  */
}

void importSettings(File selection) {
  /*
  String[] settings = loadStrings(selection.getAbsolutePath());
  linesL = Integer.parseInt(settings[0]);
  linesR = Integer.parseInt(settings[1]);
  distance = Float.parseFloat(settings[2]);
  steps = Integer.parseInt(settings[3]);
  maxRad = Float.parseFloat(settings[4]);
  angle = Float.parseFloat(settings[5]);
  dotted = Boolean.parseBoolean(settings[6]);
  materialW = Float.parseFloat(settings[7]);
  materialH = Float.parseFloat(settings[8]);
  bitW = Float.parseFloat(settings[9]);
  bitH = Float.parseFloat(settings[10]);
  bitMin = Float.parseFloat(settings[11]);
  borderW = Float.parseFloat(settings[12]);
  borderH = Float.parseFloat(settings[13]);
  hOut = Float.parseFloat(settings[14]);
  sIn = Float.parseFloat(settings[15]);
  sOut = Float.parseFloat(settings[16]);
  curve[0].x = Float.parseFloat(settings[17]);
  curve[0].y = Float.parseFloat(settings[18]);
  curve[1].x = Float.parseFloat(settings[19]);
  curve[1].y = Float.parseFloat(settings[20]);
  curve[2].x = Float.parseFloat(settings[21]);
  curve[2].y = Float.parseFloat(settings[22]);
  curve[3].x = Float.parseFloat(settings[23]);
  curve[3].y = Float.parseFloat(settings[24]);
  
  surface.setSize((int)materialW, (int)materialH);
  if (render) {
    imgFilter();
  }
  */
}

void mouseMoved() {
  main.mouseMoved(mouseX/scF-materialX, mouseY/scF-materialY);
}

void mouseDragged() {
  main.mouseDragged(mouseX/scF-materialX, mouseY/scF-materialY);
}

void mouseClicked() {
  main.mouseClicked(mouseX/scF-materialX, mouseY/scF-materialY);
}

void mouseReleased() {
  main.mouseReleased(mouseX/scF-materialX, mouseY/scF-materialY);
}

void mousePressed() {
  main.mousePressed(mouseX/scF-materialX, mouseY/scF-materialY);
}

void keyPressed() {
  if (key == '+') {
    maxRad += 0.1;
    if (maxRad > bitW) {
      maxRad = bitW;
    }
  }
  if (key == '-') {
    maxRad -= 0.1;
    if (maxRad < bitMin) {
      maxRad = bitMin;
    }
  }
  if (key == 'w') {
    imgY--;
  }
  if (key == 's') {
    imgY++;
  }
  if (key == 'a') {
    imgX--;
  }
  if (key == 'd') {
    imgX++;
  }
  if (key == 'q') {
    imgW-=5;
  }
  if (key == 'e') {
    imgW+=5;
  }
  if (key == 'p') {
    selectFolder("Select a folder to write to:", "printGcode");
  }
  if (key == 'f') {
    getErrors();
  }
  if (key == 'z') {
    selectOutput("Select a file to write to:", "exportSettings");
  }
  if (key == 't') {
    selectInput("Select a file to import:", "importSettings");
  }   
  if (key == ENTER) {
    render = !render;
  }    
  main.render();    

}