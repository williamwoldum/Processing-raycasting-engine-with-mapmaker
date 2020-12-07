ArrayList <Button> buttons = new ArrayList <Button>();

class Button {

  int x, y, w, h;
  color c;
  String label;
  float rimScale = 0.8;

  Button(int x_, int y_, int w_, int h_, color c_, String label_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    c = c_;
    label = label_;
  }

  void display() {
    rectMode(CORNER);
    strokeWeight(width/320);
    stroke(51);
    fill(c);
    rect(x, y, w, h, 0, width/128, width/128, 0);
    rectMode(CENTER);
    noStroke();
    fill(51);
    rect(x + w/2, y + h/2, w * rimScale, h * (rimScale - 0.1), width/512, width/512, width/512, width/512);
    fill(230);
    textAlign(CENTER, CENTER);
    textSize(w/4.5 * rimScale);
    text(label, x + w/2, y + h/2);
  }

  boolean checkIfHoveringOver() {
    if (mouseX < x + w && mouseX > x && mouseY < y + h && mouseY > y) {
      return true;
    } else {
      return false;
    }
  }
}

//////////////////////////////////////////////////////////////////////////////

void makeButtons() {
  buttons.add(new Button(width/2, height/18 * 13, width/20, height/18, color(255, 50, 50), "Reset"));
  buttons.add(new Button(width/2, height/18 * 5, width/20, height/18, color(90, 200, 90), "Start"));
  buttons.add(new Button(width/2, height/18 * 6, width/20, height/18, color(255, 255, 90), "Goal"));
  buttons.add(new Button(width/2, height/18 * 7, width/20, height/18, color(150), "Wall"));
  buttons.add(new Button(width/2, height/18 * 8, width/20, height/18, color(255, 90, 50), "Enemy"));
  buttons.add(new Button(width/2, height/18 * 10, width/20, height/18, color(90, 90, 255), "Open"));
  buttons.add(new Button(width/2, height/18 * 11, width/20, height/18, color(230, 160, 230), "Export"));
}


void handleButtons() {
  for (int i = 0; i < buttons.size(); i++) {
    if (buttons.get(i).checkIfHoveringOver() || buttons.get(i).label.equals(currentObject)) {
      buttons.get(i).rimScale = 0.6;
    } else if (!buttons.get(i).label.equals(currentObject)) {
      buttons.get(i).rimScale = 0.8;
    }
    buttons.get(i).display();
  }
}

void fileSelected(File selection) {
  if (selection != null) {
    String [] loadedMap = loadStrings(selection.getAbsolutePath());
    scale = (int) sqrt(loadedMap.length/(8*9));
    xTiles = scale * 8;
    yTiles = scale * 9;
    squareSize = height/yTiles;
    xOffSet = (width / 2 - xTiles * squareSize) / 2;
    yOffSet = (height - yTiles * squareSize) / 2;
    cp5.getController("Scale").setValue(scale);
    int iteration = 1;
    while (round(cp5.getController("Scale").getValue()) != scale) {
      if (round(cp5.getController("Scale").getValue()) > scale) {
        cp5.getController("Scale").setValue(scale - iteration);
      } 
      if (round(cp5.getController("Scale").getValue()) < scale) {
        cp5.getController("Scale").setValue(scale + iteration);
      }
      iteration++;
    }



    content = new String[yTiles][xTiles];
    for (int y = 0; y < yTiles; y++) {
      for (int x = 0; x < xTiles; x++) {
        content[y][x] = loadedMap[y * xTiles + x];
      }
    }
  } 
  loop();
}

void placeSelected(File selection) {
  if (selection != null) {
    String [] map = new String [yTiles*xTiles];
    for (int y = 0; y < yTiles; y++) {
      for (int x = 0; x < xTiles; x++) {
        map[y * xTiles + x] = content[y][x];
      }
    }
    saveStrings(selection.getAbsolutePath() + ".txt", map);
  }
}


void checkForSliderAction() {
  if (round(cp5.getController("Scale").getValue()) != scale) {
    noLoop();
    scale = round(cp5.getController("Scale").getValue());
    xTiles = scale * 8;
    yTiles = scale * 9;
    squareSize = height/yTiles;
    xOffSet = (width / 2 - xTiles * squareSize) / 2;
    yOffSet = (height - yTiles * squareSize) / 2; 
    resetMap();
    loop();
  }
}
