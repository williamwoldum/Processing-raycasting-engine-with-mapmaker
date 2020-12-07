class Player {
  PVector pos;                              //Spillerens position på canvas
  PVector newPlayerPos;                     //Spillerens næste position i canvas efter bruger input
  int radius = map.tileSize / 2;            //Spillerens radius
  int walkDirection = 0;                    //Spillerens bevægelsesretning  frem og tilbage (-1 = baglæns, 0 = stilstand, 1 = forlæns)
  int sideWaysDirection = 0;                //Spillerens bevægelsesretning  fra side til side (-1 = venstre, 0 = stilstand, 1 = højre)
  float rotationAngle = PI/2 * 3;           //Vinklen spiller peger
  float moveSpeedStart = 0.7;
  float moveSpeed = 0;                      //Spillerens hastighed efter fps og map dimensions justering
  int mouseXPos = 0;                        //Variabel der holder afstands værdi, stiger når musen går mod højre falder når musen går mod venstre
  int mouseYPos = 0;                        //Variabel der holder afstands værdi, stiger når musen går nedad falder når musen går opad


  //********************************************************* Skaber spilleren så tæt på bunden af mappet som muligt bruges til at beregne texture højde

  Player() {
    float dist = round(float(map.xTiles/8) * float(map.tileSize) / 2.0 / tan(fovAngle/2.0) + map.tileSize + map.yOffSet);
    pos = new PVector(width / 4 + map.xOffSet + map.tileSize / 2, dist);
  }

  //*********************************************************Viser spilleren

  void display() {
    fill(180, 180, 255);
    noStroke();
    if (fullScreen) {
      circle(
        map.scalingConstant * pos.x, 
        map.scalingConstant * pos.y, 
        map.scalingConstant * radius
        );
    } else {
      circle(
        pos.x + map.xOffSet, 
        pos.y + map.yOffSet, 
        radius
        );
    }
  }

  //********************************************************* Opdaterer spiller position og musse inputs

  void update() {
    if (!menuOpen) {

      if (map.hasObjectAtCoordinate(pos.x, pos.y, "Goal")) {                //Hvis spilleren er på mål cellen åben file selector
        noLoop();
        selectInput("Select a map", "mapSelected");
      }

      moveSpeed = (moveSpeedStart * deltaTime) / map.scale;                 //Beregner spillerens hastighed på baggrund af fps

      if (!loadedTextureHeights) {
        return;
      }  


      //Opdaterer musens bevægelse
      mouseXPos += rotationAngle == 0 ? -mouseXPos + (mouseX - width/2) : (mouseX - width/2);
      mouseYPos += (mouseY - height/2) * 4;
      mouseYPos = constrain(mouseYPos, -height/2, height/2);
      rotationAngle = normalizeAngle(mouseXPos, "Degrees") * (PI/180);



      //Centrerer musen i midten af canvas på trods af vindue størrelse
      if (width != displayWidth) {
        int windowCenterX = (int)loc.x + width/2 + 3;
        int windowCenterY = (int)loc.y + height/2 + 26;
        robot.mouseMove(windowCenterX, windowCenterY);
      } else {
        robot.mouseMove(width/2, height/2);
      }


      //Beregner spillerens næste position      
      newPlayerPos = pos.copy();

      if (walkDirection != 0) {
        newPlayerPos.x += walkDirection * cos(rotationAngle) * moveSpeed;
        newPlayerPos.y += walkDirection * sin(rotationAngle) * moveSpeed;
      }  
      if (sideWaysDirection != 0) {
        newPlayerPos.x += sideWaysDirection * cos(rotationAngle + PI / 2) * moveSpeed;
        newPlayerPos.y += sideWaysDirection * sin(rotationAngle + PI / 2) * moveSpeed;
      }

      if (walkDirection != 0 && sideWaysDirection != 0) {
        newPlayerPos.add((PVector.sub(pos, newPlayerPos).setMag(PVector.sub(pos, newPlayerPos).mag()-moveSpeed)));
      }

      if (!map.hasObjectAtCoordinate(newPlayerPos.x, newPlayerPos.y, "Wall")) {
        pos = newPlayerPos.copy();
      }
    }
  }
}
