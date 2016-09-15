import java.io.ByteArrayOutputStream;

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
float sInD = 400; // Feedrate Dotted

color vCol = color(255, 255, 255);
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
Point[] minFree = new Point[3];
float imgW;
float imgF = 1;
float imgX = 0;
float imgY = 0;
float[] ms = {0, 0};
float scF;
float materialX;
float materialY;

area main;
int sb = 300;
boolean exportDial = false;
boolean importDial = false;
boolean[] packages = {true, true, true, true, true, true, false};
boolean[] imports = new boolean[7];
String importfile;


void setup() {
  size(1440, 850);
  configDimens();

  main = new area(0, 0, materialW, materialH, null);

  selectInput("Select a file to process:", "fileSelected");
}

void draw() {
  vCol = color(246, 85, 59);
  bgCol = color(16, 16, 16);
  background(bgCol);
  translate(materialX*scF, materialY*scF);

  if (!render && image != null) {
    image(image, imgX*scF, imgY*scF, imgW*scF, imgW*scF*imgF);
  }

  main.draw();

  if (print) {
    textAlign(CENTER, CENTER);
    fill(0);
    for (int i = 0; i < prints.size(); i++) {
      textSize(min(prints.get(i).aWidth*scF, prints.get(i).aHeight*scF)/2);
      text(i+1, prints.get(i).xPos*scF+prints.get(i).aWidth/2*scF, prints.get(i).yPos*scF+prints.get(i).aHeight/2*scF);
    }
  } else {
    if (render) {
      stroke(255, 0, 0);
      for (int i = 0; i < errors.size(); i++) {
        line(errors.get(i)[0].x*scF, errors.get(i)[0].y*scF, errors.get(i)[1].x*scF, errors.get(i)[1].y*scF);
      }
      if (minFree[0] != null) {
        stroke(255, 255, 0);
        noFill();
        ellipse((minFree[1].x+minFree[2].x)/2, (minFree[1].y+minFree[2].y)/2, 10/minFree[0].x, 10/minFree[0].x);
        ellipse((minFree[1].x+minFree[2].x)/2, (minFree[1].y+minFree[2].y)/2, 3/minFree[0].x, 3/minFree[0].x);
      }
    }
  }

  noStroke();
  translate(-materialX*scF, -materialY*scF);

  fill(bgCol);
  rect(0, 0, materialX*scF, height);
  rect(0, 0, width, materialY*scF);
  rect(0, height-materialY*scF, width, materialY*scF);
  rect(materialX*scF+materialW*scF, 0, width-materialX*scF-materialW*scF, height);

  fill(vCol);
  textSize(12);
  textAlign(LEFT, CENTER);

  text("Max. Radius: " + maxRad + "mm", 20, 80);
  text("Min. Free: " + (minFree[0]==null?"/":minFree[0].x) + "mm", 20, 105);
  text("Bit Width: " + bitW + "mm", 20, 140);
  text("Bit Min: " + bitMin + "mm", 20, 165);
  text("Material Width: " + materialW + "mm", 20, 210);
  text("Material Height: " + materialH + "mm", 20, 235);
  text("Seekrate: " + sOut + "mm/min", 20, 280);
  text("Feedrate: " + sIn + "mm/min", 20, 305);
  text("Feedrate (Dot.): " + sInD + "mm/min", 20, 330);
  text("Floating Height: " + hOut + "mm", 20, 355);

  text("Part Count: " + prints.size(), 20, 400);
  float sum = 0;
  for (int i = 0; i < prints.size(); i++) {
    int h = (int)prints.get(i).time()/60;
    int m = (int)prints.get(i).time()-h*60;
    text("Part " + (i+1) + ": "+h+"h "+m+"m  - W: " + prints.get(i).aWidth + "mm, H: " + prints.get(i).aHeight + "mm", 20, 455+(i*25));
    sum += prints.get(i).time();
  }
  int h = (int)sum/60;
  int m = (int)sum-h*60;
  text("Approx. Milling Time (All): "+h+"h "+m+"m", 20, 425);

  if (!print) {
    fill(vCol);
    rect(20, 10, (sb-60)/2, 20, 10);
    rect(40+(sb-60)/2, 10, (sb-60)/2, 20, 10);
    rect(20, 40, (sb-60)/2, 20, 10);
    rect(40+(sb-60)/2, 40, (sb-60)/2, 20, 10);
    rect(sb-80, 95, 45, 20, 10);
    int[] buttons = {80, 280, 305, 330, 355, 210, 235};
    for (int i=0; i<buttons.length; i++) { 
      ellipse(sb-70, buttons[i], 20, 20);
      ellipse(sb-45, buttons[i], 20, 20);
    }
    fill(bgCol);
    textAlign(CENTER, CENTER);
    text("Render", 20+((sb-60)/4), 20-1);
    text("Generate Files", 40+((sb-60)*0.75), 20-1);
    text("Imprort Project", 20+((sb-60)/4), 50-1);
    text("Export Project", 40+((sb-60)*0.75), 50-1);
    text("Go", sb-57.5, 105-1);
    textSize(15);
    for (int i=0; i<buttons.length; i++) { 
      text("-", sb-70, buttons[i]-3);
      text("+", sb-45, buttons[i]-3);
    }
  }
  if (exportDial) {
    translate(width*0.2, height*0.1);
    stroke(vCol);
    strokeWeight(2);
    fill(bgCol);
    rect(0, -20, width*0.6, height*0.8+30, 10);  
    fill(vCol);
    textSize(20);
    textAlign(CENTER, CENTER);
    text("Export Project-Data", width*0.3, 10);
    textAlign(LEFT, CENTER);
    textSize(15);
    text("Bit-Dimensions", 50, 40);
    text("Machine-Settings", 50, 100);
    text("Material-Dimensions", 50, 160);
    text("Main-Renderdata", 50, 220);
    text("Parts-Dimensions", 50, 280);
    text("Parts-Renderdata", 50, 340);
    text("Image", 50, 400);
    stroke(vCol);
    strokeWeight(1);
    for (int i=0; i<packages.length; i++) {
      fill(packages[i]?vCol:bgCol);
      ellipse(30, 40+(i*60), 10, 10);
    }
    textSize(12);
    fill(vCol);
    text("Width: "+bitW+"mm    Height: "+bitH+"mm    Min: "+bitMin+"mm", 30, 65);
    line(20, 80, width*0.6-40, 80);
    text("Seekrate: "+sOut+"mm/min    Feedrate: "+sIn+"mm/min    Feedrate (Dt): "+sInD+"mm/min    Floating Height: "+hOut + "mm", 30, 125);
    line(20, 140, width*0.6-40, 140);
    text("Width: "+materialW+"mm    Height: "+materialH+"mm    Border-W: "+main.bWidth+"mm    Border-H: "+main.bHeight+"mm", 30, 185);
    line(20, 200, width*0.6-40, 200);
    text("Curve: 4 Points    Lines: "+(main.renderframe.linesL + main.renderframe.linesR)+"    Distance: "+main.renderframe.distance+"mm    Steps: "+main.renderframe.steps+"    Max. Radius: "+maxRad+"mm", 30, 245);
    line(20, 260, width*0.6-40, 260);
    text("Parts: " + prints.size(), 30, 305);
    line(20, 320, width*0.6-40, 320);
    text("Parts: " + prints.size(), 30, 365);
    line(20, 380, width*0.6-40, 380);
    text("Width: "+image.width+"px    Height: "+image.height+"    Size: "+((float)round((float)image.width*image.height/100000)/10)+"MB    File: "+imgfile, 30, 425);
    fill(bgCol, 150);
    noStroke();
    if (!packages[2]) {
      rect(5, 205, width*0.6-10, 50);
      rect(5, 265, width*0.6-10, 50);
      rect(5, 325, width*0.6-10, 50);
    } else if (prints.size() < 2) {
      rect(5, 265, width*0.6-10, 50);
      rect(5, 325, width*0.6-10, 50);
    } else if (!packages[4]) {
      rect(5, 325, width*0.6-10, 50);
    }
    fill(vCol);
    rect(width*0.3-110, height*0.8-30, 100, 20, 10);
    rect(width*0.3+10, height*0.8-30, 100, 20, 10);
    fill(bgCol);
    textAlign(CENTER, CENTER);
    int num = 0;
    for (int i=0; i<packages.length; i++) {
      if (packages[i]) {
        num++;
      }
    }
    text("Export (" +num+")", width*0.3-60, height*0.8-20);
    text("Cancel", width*0.3+60, height*0.8-20);
    if (num==0) {
      fill(bgCol, 200);
      rect(width*0.3-115, height*0.8-35, 110, 30);
    }
  }
  if (importDial) {
    translate(width*0.2, height*0.1);
    stroke(vCol);
    strokeWeight(2);
    fill(bgCol);
    rect(0, -20, width*0.6, height*0.8+30, 10);  
    fill(vCol);
    textSize(20);
    textAlign(CENTER, CENTER);
    text("Import Project-Data", width*0.3, 10);
    textAlign(LEFT, CENTER);
    textSize(15);
    text("Bit-Dimensions", 50, 40);
    text("Machine-Settings", 50, 100);
    text("Material-Dimensions", 50, 160);
    text("Main-Renderdata", 50, 220);
    text("Parts-Dimensions", 50, 280);
    text("Parts-Renderdata", 50, 340);
    text("Image", 50, 400);
    stroke(vCol);
    strokeWeight(1);
    for (int i=0; i<packages.length; i++) {
      fill(packages[i]?vCol:bgCol);
      ellipse(30, 40+(i*60), 10, 10);
    }
    textSize(12);
    fill(vCol);
    text("Width, Height, Min", 30, 65);
    line(20, 80, width*0.6-40, 80);
    text("Seekrate, Feedrate, Feedrate (Dt), Floating Height", 30, 125);
    line(20, 140, width*0.6-40, 140);
    text("Width, Height, Border-W, Border-H", 30, 185);
    line(20, 200, width*0.6-40, 200);
    text("Curve, Lines, Distance, Steps, Max. Radius", 30, 245);
    line(20, 260, width*0.6-40, 260);
    text("Parts: Width, Height, Border-W, Border-H", 30, 305);
    line(20, 320, width*0.6-40, 320);
    text("Parts: Curve, Lines, Distance, Steps, Max. Radius" + prints.size(), 30, 365);
    line(20, 380, width*0.6-40, 380);
    text("Width, Height, Image-Data", 30, 425);
    fill(bgCol, 150);
    noStroke();
    for (int i=0; i<imports.length; i++) {
      if (!imports[i] || ((i==3||i==4||i==5)&&!packages[2]) || (i==5&&!packages[4])) {
        rect(5, 25+(i*60), width*0.6-10, 50);
      }
    }
    fill(vCol);
    rect(width*0.3-110, height*0.8-30, 100, 20, 10);
    rect(width*0.3+10, height*0.8-30, 100, 20, 10);
    fill(bgCol);
    textAlign(CENTER, CENTER);
    int num = 0;
    for (int i=0; i<packages.length; i++) {
      if (packages[i]) {
        num++;
      }
    }
    text("Import (" +num+")", width*0.3-60, height*0.8-20);
    text("Cancel", width*0.3+60, height*0.8-20);
    if (num==0) {
      fill(bgCol, 200);
      rect(width*0.3-115, height*0.8-35, 110, 30);
    }
  }
}

void configDimens() {
  if (materialW < 10) { 
    materialW = 10;
  }
  if (materialH < 10) { 
    materialH = 10;
  }
  scF = min((float)(width-sb)/materialW, (float)height/materialH);
  materialX = (((width-sb)/scF)-materialW)/2;
  if (materialX < (sb/scF)) {
    materialX = sb/scF;
  }
  materialY = ((height/scF)-materialH)/2;
  if (main != null) {
    main.rebuild();
    main.aWidth = materialW;
    main.aHeight = materialH;
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
    return round(p);
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
    return round(p);
  }
}

void printGcode(File folder) {
  if (folder == null) {
    return;
  }
  noLoop();
  prints.clear();
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
  data.add("Min. Free: " + (minFree[0]==null?"/":minFree[0].x) + "mm");
  data.add(" ");
  data.add("Seekrate: " + sOut + "mm/min");
  data.add("Feedrate: " + sIn + "mm/min");
  data.add("Feedrate (Dotted): " + sInD + "mm/min");
  data.add("Floating Height: " + hOut + "mm");
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
  print = true;
  redraw();
  delay(2000);
  String[] dims = data.toArray(new String[data.size()]);
  saveStrings(folder.getAbsolutePath()+"/dimens.txt", dims);
  PImage thumbnail = get();
  thumbnail.save(folder.getAbsolutePath()+"/thumbnail.jpg");
  print = false;
  loop();
}

void getErrors() {

  minFree = new Point[3];
  errors.clear();
  main.getErrors();
  minFree[0].x = float(round(minFree[0].x*100))/100;
}

void fileSelected(File file) {
  if (file == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + file.getAbsolutePath());
    if (isImage(file.getAbsolutePath())) {
      image = loadImage(file.getAbsolutePath());
      imgfile = file.getAbsolutePath();
      imgW = materialW;
      imgF = (float)image.height/image.width;
      image.filter(GRAY);
    } else {
      importfile = file.getAbsolutePath();
      byte[] input = loadBytes(importfile);
      for (int i=0; i < 7; i++) {
        imports[i] = input[i]==1;
        packages[i] = input[i]==1;
      }
      importDial = true;
    }
  }
}

void exportProject(File file) {
  if (file == null) {
    println("Window was closed or the user hit cancel.");
    return;
  }
  ByteArrayOutputStream out = new ByteArrayOutputStream();
  for (int i = 0; i < 7; i++) {
    out.write(packages[i]?1:0);
  }
  if (packages[0]) {
    toByte(bitW, out, 1000);
    toByte(bitH, out, 1000);
    toByte(bitMin, out, 1000);
  }
  if (packages[1]) {
    toByte((int)sOut, out);
    toByte((int)sIn, out);
    toByte((int)sInD, out);
    toByte(hOut, out, 10);
  }
  if (packages[2]) {
    toByte((int)materialW, out);
    toByte((int)materialH, out);
    toByte((int)main.bWidth, out);
    toByte((int)main.bHeight, out);
  }
  if (packages[3]) {
    for (int i = 0; i < 4; i++) {
      toByte((int)main.curve[i].x, out);
      toByte((int)main.curve[i].y, out);
    }
    toByte((int)main.angle, out);
    out.write(main.renderframe.linesL>0?1:0);
    toByte((int)abs(main.renderframe.linesL), out);
    out.write(main.renderframe.linesR>0?1:0);
    toByte((int)abs(main.renderframe.linesR), out);
    toByte(main.renderframe.distance, out, 100);
    toByte((int)main.renderframe.steps, out);
    toByte(maxRad, out, 1000);
  }
  if (packages[6]) {
    toByte((int)image.width, out);
    toByte((int)image.height, out);
    toByte((int)imgW, out);
    toByte(imgF, out, 1000);
    toByte((int)imgX, out);
    toByte((int)imgY, out);
    image.loadPixels();
    for (int i=0; i<image.pixels.length; i++) {
      out.write((byte)red(image.pixels[i]));
    }
    image.updatePixels();
  }
  if (packages[4]) {
    main.exportDimens(out);
  }
  if (packages[5]) {
    main.exportRender(out);
  }
  byte[] bytes = out.toByteArray();
  saveBytes(file.getAbsolutePath(), bytes);
  exportDial = false;
}

void toByte(float f, ByteArrayOutputStream list, int n) {
  int i = (int)(f*n);
  int a = i >> 8;
  int b = i - (a<<8);
  list.write(a);
  list.write(b);
}

void toByte(int i, ByteArrayOutputStream list) {
  int a = i>>8;
  int b = i - (a<<8);
  list.write(a);
  list.write(b);
}

boolean isImage(String file) {
  if (file.substring(file.length()-4, file.length()).equals(".jpg")) {
    println("Image found");
    return true;
  }
  if (file.substring(file.length()-4, file.length()).equals(".png")) {
    println("Image found");
    return true; 
  }
  if (file.substring(file.length()-5, file.length()).equals(".jpeg")) {
    println("Image found");
    return true; 
  }
  println("Project-File found");
  return false;
}

void startImport() {
  byte[] input = loadBytes(importfile);
  int pos = 7;
  if (input[0] == 1) {
    if (packages[0]) {
      bitW = toFloat(input[pos], input[pos+1], 1000);
      bitH = toFloat(input[pos+2], input[pos+3], 1000);
      bitMin = toFloat(input[pos+4], input[pos+5], 1000);
    }
    pos+=6;
  }
  if (input[1] == 1) {
    if (packages[1]) {
      sOut = toFloat(input[pos], input[pos+1], 1);
      sIn = toFloat(input[pos+2], input[pos+3], 1);
      sInD = toFloat(input[pos+4], input[pos+5], 1);
      hOut = toFloat(input[pos+6], input[pos+7], 10);
    }
    pos+=8;
  }
  if (input[2] == 1) {
    if (packages[2]) {
      main.rebuild();
      materialW = toFloat(input[pos], input[pos+1], 1);
      materialH = toFloat(input[pos+2], input[pos+3], 1);
      main.aWidth = materialW;
      main.aHeight = materialH;
      main.bWidth = toFloat(input[pos+4], input[pos+5], 1);
      main.bHeight = toFloat(input[pos+6], input[pos+7], 1);
    }
    pos+=8;
  }
  if (input[3] == 1) {
    if (packages[3]) {
      for (int i = 0; i<4; i++) {
        main.curve[i].x = toFloat(input[pos+(i*4)], input[pos+(i*4)+1], 1);
        main.curve[i].y = toFloat(input[pos+(i*4)+2], input[pos+(i*4)+3], 1);
      }
      pos+=16;
      main.angle = toFloat(input[pos], input[pos+1], 1);
      main.renderframe.linesL = (int)toFloat(input[pos+3], input[pos+4], input[pos+2]==0?-1:1);
      main.renderframe.linesL = (int)toFloat(input[pos+6], input[pos+7], input[pos+5]==0?-1:1);
      main.renderframe.distance = toFloat(input[pos+8], input[pos+9], 100);
      main.renderframe.steps = (int)toFloat(input[pos+10], input[pos+11], 1);
      maxRad = toFloat(input[pos+12], input[pos+13], 1000);
    } else {
      pos+=16;
    }
    pos+=14;
  }
  if (input[6] == 1) {
    int px = (int)toFloat(input[pos], input[pos+1], 1)*(int)toFloat(input[pos+2], input[pos+3], 1);
    if (packages[6]) {
      image = createImage((int)toFloat(input[pos], input[pos+1], 1), (int)toFloat(input[pos+2], input[pos+3], 1), RGB);
      imgW = toFloat(input[pos+4], input[pos+5], 1);
      imgF = toFloat(input[pos+6], input[pos+7], 1000);
      imgX = toFloat(input[pos+8], input[pos+9], 1);
      imgY = toFloat(input[pos+10], input[pos+11], 1);
      pos+=12;
      image.loadPixels();
      for (int i=0; i<image.pixels.length; i++) {
        image.pixels[i] = (255<<24)|((input[pos+i]&0xff)<<16)|((input[pos+i]&0xff)<<8)|(input[pos+i]&0xff); 
      }
      image.updatePixels();
    } else {
      pos+=12;
    }
    pos+=px;
  }
  if (input[4] == 1) {
    pos = main.build(input, pos); 
  }
  if (input[5] == 1) {
    pos = main.buildRender(input, pos);
  }
  if (pos == input.length) {
    println("Import successfull!");
  } else {
    println("Failed import");
    println(pos);
    println(input.length);
  }
  importDial = false;
}

float toFloat(byte a, byte b, int f) {
  int i = ((a&0xff)<<8)|(b&0xff);
  return float(i)/f;
}

void mouseMoved() {
  if (exportDial || importDial) {
    return;
  }
  main.mouseMoved(mouseX/scF-materialX, mouseY/scF-materialY);
}

void mouseDragged() {
  if (exportDial || importDial) {
    return;
  }
  main.mouseDragged(mouseX/scF-materialX, mouseY/scF-materialY);
}

void mouseClicked() {
  boolean change = false;
  if (exportDial) {
    mouseX-=width*0.2;
    mouseY-=height*0.1;
    for (int i=0; i<packages.length; i++) {
      if (mouseX > 0 && mouseX < width*0.6 && mouseY > 20+(i*60) && mouseY < 80+(i*60)) {
        packages[i] = !packages[i];
      }
    }
    if (!packages[2]) {
      packages[3] = false;
      packages[4] = false;
      packages[5] = false;
    }
    if (prints.size() < 2) {
      packages[4] = false;
    }
    if (!packages[4]) {
      packages[5] = false;
    }
    if (mouseX > width*0.3-110 && mouseX < width*0.3-10 && mouseY > height*0.8-30 && mouseY < height*0.8-10) {
      selectOutput("Export to: ", "exportProject");
    }
    if (mouseX > width*0.3+10 && mouseX < width*0.3+110 && mouseY > height*0.8-30 && mouseY < height*0.8-10) {
      exportDial = false;
    }
    return;
  } else if (importDial) {
    mouseX-=width*0.2;
    mouseY-=height*0.1;
    for (int i=0; i<packages.length; i++) {
      if (imports[i] && mouseX > 0 && mouseX < width*0.6 && mouseY > 20+(i*60) && mouseY < 80+(i*60)) {
        packages[i] = !packages[i];
      }
    }
    if (!packages[2]) {
      packages[3] = false;
      packages[4] = false;
      packages[5] = false;
    }
    if (!packages[4]) {
      packages[5] = false;
    }
    if (mouseX > width*0.3-110 && mouseX < width*0.3-10 && mouseY > height*0.8-30 && mouseY < height*0.8-10) {
      startImport();
    }
    if (mouseX > width*0.3+10 && mouseX < width*0.3+110 && mouseY > height*0.8-30 && mouseY < height*0.8-10) {
      importDial = false;
    }
    return;
  }
  main.mouseClicked(mouseX/scF-materialX, mouseY/scF-materialY);
  if (mouseX > 20 && mouseX < sb/2-10 && mouseY > 10 && mouseY < 30) {
    render = !render;
    change = true;
  }
  if (mouseX > sb/2+10 && mouseX < sb-20 && mouseY > 10 && mouseY < 30) {
    selectFolder("Select a folder to write to:", "printGcode");
  }
  if (mouseX > 20 && mouseX < sb/2-10 && mouseY > 40 && mouseY < 60) {
    selectInput("Select Project File", "fileSelected");
  }
  if (mouseX > sb/2+10 && mouseX < sb-20 && mouseY > 40 && mouseY < 60) {
    packages[0] = true;
    packages[1] = true;
    packages[2] = true;
    packages[3] = true;
    packages[4] = prints.size() > 1;
    packages[5] = packages[4];
    packages[6] = true;
    exportDial = true;
  }
  if (sqrt(sq(mouseX-(sb-70))+sq(mouseY-80)) < 10) {
    maxRad = float(round((maxRad-0.1)*10))/10;
    if (maxRad < bitMin) {
      maxRad = bitMin;
    }
    change = true;
  }
  if (sqrt(sq(mouseX-(sb-45))+sq(mouseY-80)) < 10) {
    maxRad = float(round((maxRad+0.1)*10))/10;
    if (maxRad > bitW) {
      maxRad = bitW;
    }
    change = true;
  }
  if (sqrt(sq(mouseX-(sb-45))+sq(mouseY-210)) < 10) {
    materialW+=10;
    configDimens();
    change = true;
  }
  if (sqrt(sq(mouseX-(sb-70))+sq(mouseY-210)) < 10) {
    materialW-=10;
    configDimens();
    change = true;
  }
  if (sqrt(sq(mouseX-(sb-45))+sq(mouseY-235)) < 10) {
    materialH+=10;
    configDimens();
    change = true;
  }
  if (sqrt(sq(mouseX-(sb-70))+sq(mouseY-235)) < 10) {
    materialH-=10;
    configDimens();
    change = true;
  }
  if (sqrt(sq(mouseX-(sb-70))+sq(mouseY-280)) < 10) {
    sOut-=10;
    if (sOut < 10) {
      sOut = 10;
    }
    change = true;
  }
  if (sqrt(sq(mouseX-(sb-45))+sq(mouseY-280)) < 10) {
    sOut+=10;
    change = true;
  }
  if (sqrt(sq(mouseX-(sb-70))+sq(mouseY-305)) < 10) {
    sIn-=10;
    if (sIn < 10) {
      sIn = 10;
    }
    change = true;
  }
  if (sqrt(sq(mouseX-(sb-45))+sq(mouseY-305)) < 10) {
    sIn+=10;
    change = true;
  }
  if (sqrt(sq(mouseX-(sb-70))+sq(mouseY-330)) < 10) {
    sInD-=10;
    if (sInD < 10) {
      sInD = 10;
    }
    change = true;
  }
  if (sqrt(sq(mouseX-(sb-45))+sq(mouseY-330)) < 10) {
    sInD+=10;
    change = true;
  }
  if (sqrt(sq(mouseX-(sb-70))+sq(mouseY-355)) < 10) {
    hOut-=0.5;
    if (hOut < 0.5) {
      hOut = 0.5;
    }
    change = true;
  }
  if (sqrt(sq(mouseX-(sb-45))+sq(mouseY-355)) < 10) {
    hOut+=0.5;
    change = true;
  }
  if (mouseX > sb-80 && mouseX < sb-35 && mouseY > 95 && mouseY < 115) {
    getErrors();
  }
  if (change) {
    main.render();
  }
}

void mouseReleased() {
  if (exportDial || importDial) {
    return;
  }
  main.mouseReleased(mouseX/scF-materialX, mouseY/scF-materialY);
}

void mousePressed() {
  if (exportDial || importDial) {
    return;
  }
  main.mousePressed(mouseX/scF-materialX, mouseY/scF-materialY);
}

void keyPressed() {
  if (exportDial || importDial) {
    return;
  }
  if (key == '+') {
    maxRad = float(round((maxRad+0.1)*10))/10;
    if (maxRad > bitW) {
      maxRad = bitW;
    }
  }
  if (key == '-') {
    maxRad = float(round((maxRad-0.1)*10))/10;
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
    exportDial = true;
  }
  if (key == 't') {
    selectInput("Select Project File:", "fileSelected");
  }   
  if (key == ENTER || key == RETURN) {
    render = !render;
  }
  main.keyPressed();
  main.render();
}