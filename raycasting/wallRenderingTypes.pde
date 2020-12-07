float distanceProjectionPlane = 0;        //Distance til projektionsplan/skærm
float correctDistance = 0;                //Rettet længde af stråle
float wallStripHeight = 0;                //Højden på den lodrette pixellinje der udgør væggen
float colorIntensity = 0;                 //Farven på en væg
float colorFade = 0;                      //Mørklægning af væg
float picHeightRatio = 0;                 //Forholdet mellem texturefilens højde og væggenshøjde



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//Beregner væghøjde for alle rays uden at påføre textures når spilskærmen ikke fylder hele skærmen
void renderNoFullScreenNoTexture() {
  for (int i = rays.size() / 4; i < rays.size() / 4 * 3; i++) {
    correctDistance = rays.get(i).distance * cos(rays.get(i).rayAngle - player.rotationAngle);
    wallStripHeight = map.tileSize * wallScale / (2 * correctDistance) * 2 * distanceProjectionPlane;
    colorIntensity = rays.get(i).wasHitVertical ? 255 : 145;
    colorFade = map(correctDistance, 0, (map.yTiles - 2) * map.tileSize, 255, 35);

    rectMode(CORNER);
    fill(51);
    rect(width/2 + (i - rays.size() / 4) * wallStripWidth, height/2 - wallStripHeight/2 - player.mouseYPos, wallStripWidth, wallStripHeight);
    fill(colorIntensity, colorIntensity, colorIntensity, colorFade);
    noStroke();
    rect(width/2 + (i - rays.size() / 4) * wallStripWidth, height/2 - wallStripHeight/2 - player.mouseYPos, wallStripWidth, wallStripHeight);
  }
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Beregner væghøjde for alle rays uden at påføre textures når spilskærmen fylder hele skærmen
void renderFullScreenNoTexture() {
  for (int i = 0; i < rays.size(); i++) {
    correctDistance = rays.get(i).distance * cos(rays.get(i).rayAngle - player.rotationAngle);
    wallStripHeight = map.tileSize * wallScale / (2 * correctDistance) * 2 * distanceProjectionPlane;
    colorIntensity = rays.get(i).wasHitVertical ? 255 : 145;
    colorFade = map(correctDistance, 0, (map.yTiles - 2) * map.tileSize, 255, 35);

    rectMode(CORNER);
    fill(51);
    rect(i * wallStripWidth, height/2 - wallStripHeight/2 - player.mouseYPos, wallStripWidth, wallStripHeight);
    fill(colorIntensity, colorIntensity, colorIntensity, colorFade);
    noStroke();
    rect(i * wallStripWidth, height/2 - wallStripHeight/2 - player.mouseYPos, wallStripWidth, wallStripHeight);
  }
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//Beregner væghøjde for alle rays og påfører textures når spilskærmen ikke fylder hele skærmen
void renderNoFullScreenTexture() {
  for (int i = rays.size() / 4; i < rays.size() / 4 * 3; i++) {
    correctDistance = rays.get(i).distance * cos(rays.get(i).rayAngle - player.rotationAngle);
    wallStripHeight = map.tileSize * wallScale / (2 * correctDistance) * 2 * distanceProjectionPlane;
    colorIntensity = rays.get(i).wasHitVertical ? 255 : 145;
    colorFade = map(correctDistance, 0, (map.yTiles - 2) * map.tileSize, 255, 35);

    int col = round(map(rays.get(i).colHit, 0, map.tileSize, 0, wallTexture.width - 1));
    float picHeight = wallStripHeight * picHeightRatio;
    int totalNumPicsInCol = ceil(wallStripHeight / picHeight);

    for (int j = 0; j < wallTexture.width; j++) {
      tempTextCol.pixels[j] = wallTexture.pixels[col + j * wallTexture.width];
    } 

    tempTextCol.updatePixels();
    rectMode(CORNER);
    fill(51);
    rect(width/2 + (i - rays.size() / 4) * wallStripWidth, height/2 - wallStripHeight/2 - player.mouseYPos, wallStripWidth, wallStripHeight);
    tint(colorIntensity, colorFade);

    float ypos = height/2 - wallStripHeight/2  - player.mouseYPos;

    for (int k = 0; k < totalNumPicsInCol; k++) {
      if (k == totalNumPicsInCol - 1) {
        arrayCopy(tempTextCol.pixels, 0, tempTextCol2.pixels, 0, round(wallStripHeight % picHeight / picHeight * wallTexture.width));
        tempTextCol2.updatePixels();
        image(tempTextCol2, width/2 + (i - rays.size() / 4) * wallStripWidth, ypos, wallStripWidth, picHeight);
        break;
      }
      image(tempTextCol, width/2 + (i - rays.size() / 4) * wallStripWidth, ypos, wallStripWidth, picHeight);
      ypos += picHeight;
    }
  }
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//Beregner væghøjde for alle rays og påfører textures når spilskærmen fylder hele skærmen
void renderFullScreenTexture() {
  for (int i = 0; i < rays.size(); i++) {
    correctDistance = rays.get(i).distance * cos(rays.get(i).rayAngle - player.rotationAngle);
    wallStripHeight = map.tileSize * wallScale / (2 * correctDistance) * 2 * distanceProjectionPlane;
    colorIntensity = rays.get(i).wasHitVertical ? 255 : 145;
    colorFade = map(correctDistance, 0, (map.yTiles - 2) * map.tileSize, 255, 35);

    int col = round(map(rays.get(i).colHit, 0, map.tileSize, 0, wallTexture.width - 1));
    float picHeight = wallStripHeight * picHeightRatio;
    int totalNumPicsInCol = ceil(wallStripHeight / picHeight);

    for (int j = 0; j < wallTexture.width; j++) {
      tempTextCol.pixels[j] = wallTexture.pixels[col + j * wallTexture.width];
    } 

    tempTextCol.updatePixels();
    rectMode(CORNER);
    fill(51);
    rect(i * wallStripWidth, height/2 - wallStripHeight/2 - player.mouseYPos, wallStripWidth, wallStripHeight);
    tint(colorIntensity, colorFade);

    float ypos = height/2 - wallStripHeight/2  - player.mouseYPos;

    for (int k = 0; k < totalNumPicsInCol; k++) {
      if (k == totalNumPicsInCol - 1) {
        arrayCopy(tempTextCol.pixels, 0, tempTextCol2.pixels, 0, round(wallStripHeight % picHeight / picHeight * wallTexture.width));
        tempTextCol2.updatePixels();
        image(tempTextCol2, i * wallStripWidth, ypos, wallStripWidth, picHeight);
        break;
      }
      image(tempTextCol, i * wallStripWidth, ypos, wallStripWidth, picHeight);
      ypos += picHeight;
    }
  }
}



/////////////////////////////////////////////////////////////Render vægge i det valgte mode


void render3dWallProjections() {
  if (!loadedTextureHeights) {
    loadTextures();
  }

  //********************************************************* Laver den blå firkant der ligner himmel

  fill(180, 180, 255);
  rectMode(CORNER);
  rect(0, 0, width, height/2 - player.mouseYPos);


  //********************************************************* Renderer vægge efter det valgt mode
 
  if (fullScreen && textureMode) {
    renderFullScreenTexture();
  } else if (!fullScreen && textureMode) {
    renderNoFullScreenTexture();
  } else if (fullScreen && !textureMode) {
    renderFullScreenNoTexture();
  } else if (!fullScreen && !textureMode) {
    renderNoFullScreenNoTexture();
  }
}



/////////////////////////////////////////////////////////////Beregner hvad størrelsesforholdet mellem væghøjde og visningen af en texturefil skal være

void loadTextures() {
  Ray tempRay = new Ray(PI/2 * 3);
  tempRay.cast();
  int tileIndexX = floor((width / 4 + map.tileSize / 2) / map.tileSize);
  int picHeightDirect = map.numHitsHorz[tileIndexX] * wallStripWidth;

  distanceProjectionPlane = (width / 2) / tan(fovAngle / 2);
  correctDistance = tempRay.distance * cos(tempRay.rayAngle - player.rotationAngle);
  wallStripHeight = (map.tileSize * wallScale / correctDistance) * distanceProjectionPlane;

  picHeightRatio = picHeightDirect / wallStripHeight;
  loadedTextureHeights = true;

  player.pos = map.searchForTileCoordinates("Start").copy();
  player.newPlayerPos = player.pos.copy();
}
