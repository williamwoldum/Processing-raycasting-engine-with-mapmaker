boolean menuOpen = false;       //Tjekker om menuen er åben

//Laver menu og slideres
void setupUI() {
  menu = new Menu();
  cp5 = new ControlP5(this);


  //Slider til at kontrollere stripWidth
  cp5.addSlider("stripWidth")
    .setRange(1, 20)
    .setFont(createFont("assets/Fonts/BULKYPIX.TTF", height/55))
    .setColorActive(color(130))
    .setColorBackground(color(180))
    .setColorForeground(color(130))
    .setColorLabel(color(180))
    .setColorValueLabel(color(51))
    .setSize(round(menu.buttonWidth), menu.buttonHeight)
    .setValue(wallStripWidth)
    .hide()
    .setNumberOfTickMarks(20)
    .showTickMarks(false)
    .setSliderMode(Slider.FLEXIBLE)
    .setPosition(width/2 - cp5.getController("stripWidth").getWidth()/2, menu.startPos + menu.buttonSpacing * 6 - menu.buttonHeight/2)
    ;

  cp5.getController("stripWidth").getValueLabel().align(ControlP5.RIGHT, CENTER).setPaddingX(height/144);
  cp5.getController("stripWidth").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);


  //Slider til at kontrollere vinklen af synsfeltet
  cp5.addSlider("fov")
    .setRange(60, 140)
    .setFont(createFont("assets/Fonts/BULKYPIX.TTF", height/55))
    .setColorActive(color(130))
    .setColorBackground(color(180))
    .setColorForeground(color(130))
    .setColorLabel(color(180))
    .setColorValueLabel(color(51))
    .setSize(round(menu.buttonWidth), menu.buttonHeight)
    .setValue(round(fovAngle * (180 / PI)))
    .hide()
    .setNumberOfTickMarks(81)
    .showTickMarks(false)
    .setSliderMode(Slider.FLEXIBLE)
    .setPosition(width/2 - cp5.getController("stripWidth").getWidth()/2, menu.startPos + menu.buttonSpacing * 9 - menu.buttonHeight/2)
    ;

  cp5.getController("fov").getValueLabel().align(ControlP5.RIGHT, CENTER).setPaddingX(height/144);
  cp5.getController("fov").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);

  //Slider til at kontrollere væggenes højde bredde forhold
  cp5.addSlider("wallScaler")
    .setRange(0.5, 5.5)
    .setFont(createFont("assets/Fonts/BULKYPIX.TTF", height/55))
    .setColorActive(color(130))
    .setColorBackground(color(180))
    .setColorForeground(color(130))
    .setColorLabel(color(180))
    .setColorValueLabel(color(51))
    .setSize(round(menu.buttonWidth), menu.buttonHeight)
    .setValue(wallScale)
    .hide()
    .setNumberOfTickMarks(11)
    .showTickMarks(false)
    .setSliderMode(Slider.FLEXIBLE)
    .setPosition(width/2 - cp5.getController("stripWidth").getWidth()/2, menu.startPos + menu.buttonSpacing * 12 - menu.buttonHeight/2)
    ;

  cp5.getController("wallScaler").getValueLabel().align(ControlP5.RIGHT, CENTER).setPaddingX(height/144);
  cp5.getController("wallScaler").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);



  //Sliderne placerer ikke sig selv ved de initialierede værdier og må derfor sættes på plads hver for sig
  int iteration = 1;
  while (round(cp5.getController("fov").getValue()) != round(fovAngle * 180/PI)) {
    if (round(cp5.getController("fov").getValue()) > round(fovAngle * 180/PI)) {
      cp5.getController("fov").setValue(round(fovAngle * 180/PI) - iteration);
    } 
    if (round(cp5.getController("fov").getValue()) < round(fovAngle * 180/PI)) {
      cp5.getController("fov").setValue(round(fovAngle * 180/PI) + iteration);
    }
    iteration++;
  }

  iteration = 1;
  while (round(cp5.getController("stripWidth").getValue()) != wallStripWidth) {
    if (round(cp5.getController("stripWidth").getValue()) > wallStripWidth) {
      cp5.getController("stripWidth").setValue(wallStripWidth - iteration);
    } 
    if (round(cp5.getController("stripWidth").getValue()) < wallStripWidth) {
      cp5.getController("stripWidth").setValue(wallStripWidth + iteration);
    }
    iteration++;
  }

  iteration = 1;
  while (cp5.getController("wallScaler").getValue() != wallScale) {
    if (cp5.getController("wallScaler").getValue() > wallScale) {
      cp5.getController("wallScaler").setValue(wallScale - iteration);
    } 
    if (cp5.getController("wallScaler").getValue() < wallScale) {
      cp5.getController("wallScaler").setValue(wallScale + iteration);
    }
    iteration+= 0.01;
  }
}

//////////////////////////////////////////////////////////////////////////

//Viser permanent tekst
void displayPermText() {
  textFont(zap);
  fill(51);
  textAlign(RIGHT, TOP);
  textSize(height / 60);
  text("Ray casting", width - height / 36, height / 36);
  textSize(height / 80);
  text("By William", width - height / 36, height / 20);

  textAlign(LEFT, TOP);
  textSize(height / 60);
  if (fullScreen) {
    text("Press 'm' for menu", map.xTiles * map.tileSize * map.scalingConstant + height / 36, height / 36);
  } else {
    text("Press 'm' for menu", width/2 + height / 36, height / 36);
  }
}

//*********************************************************

class Menu {
  int w, h;                            //Bredde højde på menu
  Button selectMapButton;              
  Button selectTextureButton;
  Button closeMenuButton;
  int buttonWidth;                                //Bredde på knapper
  int buttonHeight;                               //Højde på knapper
  int startPos = round(height / 2 - height/6);    //y koordinat for første knap
  int buttonSpacing = height/33;                  //Mellemrum mellem knapper

  //*********************************************************

  Menu() {
    w = width/4;
    h = round(height * 0.7);
    buttonWidth = round(w * 0.54);
    buttonHeight = h/15;
    selectMapButton = new Button(width/2, startPos, buttonWidth, buttonHeight, "Select map");
    selectTextureButton = new Button(width/2, startPos + buttonSpacing * 3, buttonWidth, buttonHeight, "Select texture");
    closeMenuButton = new Button(width/2, startPos + buttonSpacing * 15, buttonWidth / 2, buttonHeight, "Close");
  }

  //********************************************************* Ændrer farver på knapper og håndterer hvis der flyttes på sliders

  void update() {
    selectMapButton.update();
    selectTextureButton.update();
    closeMenuButton.update();

    if (cp5.getController("fov").isMouseOver()) {
      cp5.getController("fov").setColorBackground(color(130));
      cp5.getController("fov").setColorForeground(color(180, 180, 255));
      cp5.getController("fov").setColorActive(color(180, 180, 255));
    } else if (cp5.getController("stripWidth").isMouseOver()) {
      cp5.getController("stripWidth").setColorBackground(color(130));
      cp5.getController("stripWidth").setColorForeground(color(180, 180, 255));
      cp5.getController("stripWidth").setColorActive(color(180, 180, 255));
    } else {
      cp5.getController("fov").setColorBackground(color(180));
      cp5.getController("fov").setColorForeground(color(130));
      cp5.getController("fov").setColorActive(color(130));
      cp5.getController("stripWidth").setColorBackground(color(180));
      cp5.getController("stripWidth").setColorForeground(color(130));
      cp5.getController("stripWidth").setColorActive(color(130));
    }

    checkForFovSliderAction();
    checkForScaleSliderAction();
    checkForStripSliderAction();
  }

  //********************************************************* Viser menuen samt knapper og sliders deri

  void display() {
    cp5.getController("stripWidth").show();
    cp5.getController("fov").show();
    cp5.getController("wallScaler").show();
    pushMatrix();
    translate(width/2 - w/2, height/2 - h/2);

    rectMode(CORNER);
    fill(180);
    rect(-height/72, -height/72, w + height/72*2, h + height/72*2);
    fill(51);
    rect(0, 0, w, h);

    textFont(blockPix);
    textAlign(CENTER, TOP);
    textSize(height / 15);
    fill(180);
    text("Menu", w/2, height / 17);

    rectMode(CORNER);
    fill(180);
    rect(width / 3 - height/72, -height/72, w + height/72*2, h/2.2+ height/72*2);
    fill(51);
    rect(width / 3, 0, w, h/2.2);

    textFont(blockPix);
    textAlign(LEFT, TOP);
    textSize(height / 40);
    fill(180);
    text("Keybindings", width/3 + height/ 20, height / 17);
    textSize(height / 60);
    text("w,a,s,d : move", width/3 + height/ 20, height / 17 + height/40 * 2);
    text("t : enable/disable textures", width/3 + height/ 20, height / 17 + height/40 * 3);
    text("f : enable/disable fullscreen", width/3 + height/ 20, height / 17 + height/40 * 4);
    text("P : enable/disable tts scaling", width/3 + height/ 20, height / 17 + height/40 * 5);
    text("esc : quit", width/3 + height/ 20, height / 17 + height/40 * 6);

    popMatrix();
    selectMapButton.display();
    selectTextureButton.display();
    closeMenuButton.display();
  }

  //********************************************************* Skjuler slideres når menuen lukkes

  void closeMenu() {
    cp5.getController("stripWidth").hide();
    cp5.getController("wallScaler").hide();
    cp5.getController("fov").hide();
    noCursor();
  }
}

/////////////////////////////////////////////////////////////////

class Button {
  int x, y;                        //Koordinat
  int w, h;                        //Bredde højde
  String label;                    //Tekst på knap            
  boolean hovering = false;        //Er musen over knappen
  color buttonColour;              //Knappens farve
  color textColour;                //Tekstens farve

  //*********************************************************

  Button(int x_, int y_, int w_, int h_, String label_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    label = label_;
  }

  //********************************************************* Opdater knappens farver afhængigt af om musen er over den
  
  void update() {
    hovering = checkIfHoveringOver();
    if (hovering) {
      textColour = color(180, 180, 255);
      buttonColour = color(130);
    } else {
      textColour = color(51);
      buttonColour = color(180);
    }
  }
  
  //********************************************************* Viser knappen
  
  void display() {
    rectMode(CENTER);
    fill(buttonColour);
    rect(x, y, w, h);

    textFont(blockPix);
    textAlign(CENTER, CENTER);
    fill(textColour);
    textSize(height/50);
    text(label, x, y);
  }
  
  //********************************************************* Chekker om musen er over knappen

  boolean checkIfHoveringOver() {
    if (mouseX < x + w / 2 && mouseX > x - w / 2 && mouseY < y + h / 2 && mouseY > y - h / 2) {
      return true;
    } else {
      return false;
    }
  }
}

////////////////////////////////////////////////////////////////////////
 
//Sørger for at ændre fov hvis slideren ændres i
void checkForFovSliderAction() {
  if (round(cp5.getController("fov").getValue()) != round(fovAngle * 180 / PI)) {
    fovAngle = cp5.getController("fov").getValue() * PI / 180;
    if (!ttsMode) {
      reloadMapAndTextures();
    } else {
      numRays = width / wallStripWidth + 5;
      deltaRayAngle = fovAngle / numRays;
    }
  }
}

////////////////////////////////////////////////////////////////////////

//Sørger for at ændre stripWidth hvis slideren ændres i
void checkForStripSliderAction() {
  if (round(cp5.getController("stripWidth").getValue()) != wallStripWidth) {
    wallStripWidth = round(cp5.getController("stripWidth").getValue());
    numRays = width / wallStripWidth + 5;
    deltaRayAngle = fovAngle / numRays;
  }
}

////////////////////////////////////////////////////////////////////////

//Sørger for at ændre væggenes højde bredde forhold hvis slideren ændres i
void checkForScaleSliderAction() {
  if (cp5.getController("wallScaler").getValue() != wallScale) {
    wallScale = cp5.getController("wallScaler").getValue();
    fovAngle = startFovAngle;
    cp5.getController("fov").setValue(round(startFovAngle *  (PI / 180)));
    reloadMapAndTextures();
  }
}
