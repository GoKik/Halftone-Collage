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
float materialW = 800; // width of material (mm)
float materialH = 800; // height of material (mm)

//set milling-speed
float hOut = 2.0; // offset to material
float sIn = 150; // Feedrate
float sOut = 700; // Seekrate

boolean dotted = false;

color vCol = color(255);
color bgCol = color(30);

ArrayList<area> prints = new ArrayList<area>();
ArrayList<Point[]> errors = new ArrayList<Point[]>();
ArrayList<spacer> hor = new ArrayList<spacer>();
ArrayList<spacer> vert = new ArrayList<spacer>();

PImage image;
String imgfile;
float maxRad = 3.1;
boolean render = false;
boolean print = false;
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
  background(bgCol);
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
  
  
  if (print) {
    textAlign(CENTER, CENTER);
    fill(0);
    for (int i = 0; i < prints.size(); i++) {
      textSize(min(prints.get(i).aWidth*scF, prints.get(i).aHeight*scF)/2);
      text(i+1, prints.get(i).xPos*scF+prints.get(i).aWidth/2*scF, prints.get(i).yPos*scF+prints.get(i).aHeight/2*scF);
    }
  }
  
  noStroke();
  translate(-materialX*scF,-materialY*scF);
  
  fill(bgCol);
  rect(0,0,materialX*scF,height);
  rect(0,0,width,materialY*scF);
  rect(0,height-materialY*scF,width,materialY*scF);
  rect(width-materialX*scF,0,materialX*scF,height);
  
  fill(vCol);
  textSize(10);
  textAlign(LEFT);
  
  text("Max. Radius: " + maxRad, 20, 100);
  text("Min. Free: " + minFree, 20, 120);
  text("Bit Width: " + bitW, 20, 150);
  text("Bit Min: " + bitMin, 20, 170);
  text("Material Width: " + materialW, 20, 200);
  text("Material Height: " + materialH, 20, 220);
  
  if (print) {
    text("Part Count: " + prints.size(), 20, 260);
    float sum = 0;
    for (int i = 0; i < prints.size(); i++) {
      int h = (int)prints.get(i).time()/60;
      int m = (int)prints.get(i).time()-h*60;
      text("Part " + (i+1) + ": "+h+"h "+m+"m", 20, 310+(i*20));
      sum += prints.get(i).time();
    }
    int h = (int)sum/60;
    int m = (int)sum-h*60;
    text("Approx. Milling Time (All): "+h+"h "+m+"m", 20, 280);
  }
}

void registerDiv(spacer d, boolean h) {
  if (h) {
    if (hor.size() == 0 || d.yPos < hor.get(0).yPos) {
      hor.add(0, d);
    } else {
      for (int i=hor.size()-1; i>=0; i--) {
        if (d.yPos>hor.get(i).yPos) {
          hor.add(i+1, d);
          break;
        }
      }
    }
  } else {
    if (vert.size() == 0 || d.xPos < vert.get(0).xPos) {
      vert.add(0, d);
    } else {
      for (int i=vert.size()-1; i>=0; i--) {
        if (d.xPos>vert.get(i).xPos) {
          vert.add(i+1, d);
          break;
        }
      }
    }
  }
}

float getDivPos(spacer d, float p) {
  int c = 30;
  if (d.horizontal) {
    int i = hor.indexOf(d);
    int ia=-1, ib=-1;
    for (int j=i-1; j>=0; j--) {
      if (d.parent.hasChild(hor.get(j).parent) || hor.get(j).parent.hasChild(d.parent)) {
        ia = j;
        break;
      }
    }
    for (int j=i+1; j<hor.size(); j++) {
      if (d.parent.hasChild(hor.get(j).parent) || hor.get(j).parent.hasChild(d.parent)) {
        ib = j;
        break;
      }
    }
    p = min((ib!=-1?hor.get(ib).yPos-c:materialH), max(ia!=-1?hor.get(ia).yPos+c:0, p));
    return p;
  } else {
    int i = vert.indexOf(d);
    int ia=-1, ib=-1;
    for (int j=i-1; j>=0; j--) {
      if (d.parent.hasChild(vert.get(j).parent) || vert.get(j).parent.hasChild(d.parent)) {
        ia = j;
        break;
      }
    }
    for (int j=i+1; j<vert.size(); j++) {
      if (d.parent.hasChild(vert.get(j).parent) || vert.get(j).parent.hasChild(d.parent)) {
        ib = j;
        break;
      }
    }
    p = min((ib!=-1?vert.get(ib).xPos-c:materialW), max(ia!=-1?vert.get(ia).xPos+c:0, p));
    return p;
  }
}

void printGcode(File folder) {
  /*
  if (dotted) {
    hOut = 0.7;
    sIn = 500;
    sOut = 1200;
  }
  */
  if (folder == null) {
    return;
  }
  noLoop();
  main.print(folder);
  ArrayList<String> data = new ArrayList<String>();
  data.add("Project Data");
  data.add("------------");
  data.add("File Path: " + imgfile);
  data.add("Folder Path: " + folder.getAbsolutePath());
  data.add(" ");
  data.add("Full Width: " + materialW + "mm");
  data.add("Full Height: " + materialH + "mm");
  data.add(" ");
  data.add("Bit Width: " + bitW + "mm");
  data.add("Bit Height: " + bitH + "mm");
  data.add("Bit Min.: " + bitMin + "mm");
  data.add(" ");
  data.add("Max. Radius: " + maxRad + "mm");
  data.add("Min. Free: " + minFree + "mm");
  data.add(" ");
  data.add("- - - - - - - - -");
  data.add("Parts Dimensions:");
  data.add("- - - - - - - - -");
  data.add(" ");
  float sum = 0;
  for (int i = 0; i < prints.size(); i++) {
    data.add("Part " + (i+1) + ":");
    data.add("  W: " + (prints.get(i).aWidth-prints.get(i).bWidth*2) + "mm | H: " + (prints.get(i).aHeight-prints.get(i).bHeight*2) + "mm");
    int h = (int)prints.get(i).time()/60;
    int m = (int)prints.get(i).time()-h*60;
    data.add("  Approx. Time: "+h+"h "+m+"m");
    sum += prints.get(i).time();
    data.add("  Color: " + (prints.get(i).black?"Black":"White"));
    data.add(" ");
  }
  int h = (int)sum/60;
  int m = (int)sum-h*60;
  data.add("Approx. Milling Time (All - " + prints.size() + " Parts): "+h+"h "+m+"m");
  data.add("Seekrate: " + sOut + "mm/min");
  data.add("Feedrate: " + sIn + "mm/min");
  print = true;
  redraw();
  delay(2000);
  String[] dims = data.toArray(new String[data.size()]);
  saveStrings(folder.getAbsolutePath()+"/dimens.txt", dims);
  PImage thumbnail = get();
  thumbnail.save(folder.getAbsolutePath()+"/thumbnail.jpg");
  prints.clear();
  print = false;
  loop();
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
    imgfile = file;
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