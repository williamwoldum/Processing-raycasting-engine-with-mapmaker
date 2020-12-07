import controlP5.*;
ControlP5 cp5; 

//Banestørrelse skal have forholdet x/y = 8/9 ændrer derfor på scale
int scale;
int xTiles;     
int yTiles;
int squareSize;
int xOffSet;
int yOffSet;

String [][] content;
String currentObject = "Wall";

PFont font;

void settings() {
  if (float(displayWidth)/float(displayHeight) != 16.0/9.0) {
    size(round(float(displayWidth) * 0.75), round(float(displayWidth) * 0.75 * (9.0 / 16.0)));
  } else {
    fullScreen();
  }
}


void setup() {

  cp5 = new ControlP5(this); 
  cp5.addSlider("Scale")
    .setPosition(width/2 + 4, height/18 * 3 - 1)
    .setColorBackground(color(51))
    .setRange(1, 8)
    .setFont(createFont("assets/Kayak Sans Bold.otf", 28))
    .setColorActive(color(230))
    .setColorBackground(color(73, 100, 170))
    .setColorForeground(color(51))
    .setColorValue(color(180, 180, 180, 0))
    .setColorLabel(color(230, 0, 0, 0))
    .setSize(width/20-10, height/18)
    .setValue(7)
    .setNumberOfTickMarks(8)
    .setSliderMode(Slider.FLEXIBLE)
    ;

  scale = round(cp5.getController("Scale").getValue());
  xTiles = scale * 8;     
  yTiles = scale * 9;
  squareSize = height/yTiles;
  content = new String[yTiles][xTiles];
  xOffSet = (width / 2 - xTiles * squareSize) / 2;
  yOffSet = (height - yTiles * squareSize) / 2; 
  resetMap();
  makeButtons();
  background(130);
  smooth();
  font = createFont("assets/Kayak Sans Bold.otf", 32);  //Downloadet font fra https://befonts.com/kayak-sans-typeface.html
  textFont(font);
  makeTextBox();
}


void draw() {

  fill(51);
  rectMode(CORNER);
  noStroke();
  rect(0, 0, width/2, height);

  checkForSliderAction();
  drawTiles();
  handleButtons();

  rectMode(CORNER);
  strokeWeight(width/100);
  stroke(51);
  rect(width/2, height/18 * 3 - 1, width/20 - 3, height/18, width/512, width/512, width/512, width/512);
}

void drawTiles() {
  stroke(51);
  strokeWeight(1);
  rectMode(CORNER);
  for (int y = 0; y < yTiles; y++) {
    for (int x = 0; x < xTiles; x++) {
      switch(content[y][x]) {
      case "Start":
        fill(90, 200, 90);
        break;

      case "Goal":
        fill(255, 255, 90);
        break;

      case "Wall":
        fill(51);
        break;

      case "Enemy":
        fill(255, 90, 50);
        break;

      case "Empty":
        fill(230);
        break;
      }
      square(x * squareSize + xOffSet, y * squareSize + yOffSet, squareSize);
    }
  }
}

void resetMap() {
  content = null;
  content = new String[yTiles][xTiles];
  for (int y = 0; y < yTiles; y++) {
    for (int x = 0; x < xTiles; x++) {
      if (boundary(x, y)) {
        content[y][x] = "Wall";
      } else {
        content[y][x] = "Empty";
      }
    }
  }
}

boolean boundary(int x, int y) {
  if (x == 0 || x == xTiles - 1 || y == 0 || y == yTiles -1) {
    return true;
  } else {
    return false;
  }
}

void placeObject() {

  if (mouseX >= width/2 - xOffSet - squareSize || mouseX <= xOffSet + squareSize || mouseY >= height - yOffSet - squareSize || mouseY <= yOffSet + squareSize) {
    return;
  }

  int currentXtile = floor(mouseX - xOffSet) / squareSize;
  int currentYtile = floor(mouseY - yOffSet) / squareSize;

  if (boundary(currentXtile, currentYtile)) {
    return;
  } 

  if (mouseButton == LEFT) {
    if (currentObject.equals("Start")) {
      lookAndDelete("Start");
    } else if (currentObject.equals("Goal")) {
      lookAndDelete("Goal");
    }
    content[currentYtile][currentXtile] = currentObject;
  } else if (mouseButton == RIGHT) {
    content[currentYtile][currentXtile] = "Empty";
  }
}

void lookAndDelete(String object) {
  for (int y = 0; y < yTiles; y++) {
    for (int x = 0; x < xTiles; x++) {
      if (content[y][x].equals(object)) {
        content[y][x] = "Empty";
      }
    }
  }
}

void makeTextBox() {
  noStroke();
  textAlign(CENTER, CENTER);
  textSize(width/24);
  rectMode(CENTER);
  fill(230);
  rect(width/4 * 3 + buttons.get(0).w/2, height/9, width * 0.4, width/14, width/85, width/85, width/85, width/85);
  fill(51);
  text("Raycasting mapmaker", width/4 * 3 + buttons.get(0).w/2, height/10);
  pushMatrix();
  translate(width/4 * 3 + buttons.get(0).w/2, height/18 * 6);
  rect(0, height/18, width * 0.35, height/18 * 5, width/128, width/128, width/128, width/128);
  textAlign(LEFT, TOP);
  textSize(width/100);
  fill(230);
  String [] text = {"Use the blue slider to scale the grid on the left", 
    "Notice that the grid will reset when scaling", 
    "Pick an object by clicking on of the buttons", 
    "Click or drag with the left mousebutton on the grid to place an object", 
    "Click or drag with the right mousebutton on the grid to delete an object", 
    "Every map must contain one 'start' tile and one 'goal' tile in order to export it", 
    "Every map must be solveable in order to export it", 
    "You can by pressin 'open' open a saved map to edit it", 
    "Play your map in the dedicated raycasting game"};
  for (int i = 0; i < text.length; i++) {
    text(text[i], - width * 0.35 * 0.5 + width/34, i * width/64 - height/18 * 2 + width/38);
    ellipse(- width * 0.35 * 0.5 + width/60, i * width/64 - height/18 * 2 + width/32, width/130, width/130);
  }
  popMatrix();
}


void mousePressed() {
  for (int i = 0; i < buttons.size(); i++) {
    if (buttons.get(i).checkIfHoveringOver()) {
      switch (buttons.get(i).label) {
      case "Reset":
        resetMap();
        break;

      case "Start":
        currentObject = buttons.get(i).label;
        break;

      case "Goal":
        currentObject = buttons.get(i).label;
        break;

      case "Wall":
        currentObject = buttons.get(i).label;
        break;

      case "Enemy":
        currentObject = buttons.get(i).label;
        break;

      case "Open":
        noLoop();
        selectInput("Select a map .txt file to edit:", "fileSelected");
        break;

      case "Export":
        boolean startFound = false;
        boolean goalFound = false;
        for (int y = 0; y < yTiles; y++) {
          for (int x = 0; x < xTiles; x++) {
            if (content[y][x].equals("Start")) {
              startFound = true;
              start = new PVector(x, y);
            } else if (content[y][x].equals("Goal")) {
              goalFound = true;
              exit = new PVector(x, y);
            }
          }
        }
        if (startFound && goalFound && runSolvabillityTest()) {
          selectOutput("Choose an export destination:", "placeSelected");
        }

        break;
      }
      return;
    }
  }
  placeObject();
}

void mouseDragged() {
  placeObject();
}
