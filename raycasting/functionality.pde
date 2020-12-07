boolean fullScreen = false;                       //Er mappet minimeret aka er spilskærmen fullscreen
boolean textureMode = false;                      //Er textures slået til
boolean ttsMode = false;                          //Er tts slået til  
boolean loadedTextureHeights = false;             //Er textures sat op til at kunne anvendes
float wallScale = 3;                              //Ratio der justerer murens højde bredde forhold større = højere og smallere
int wallStripWidth = 1;                           //Pixel bredde på kolonnerne der udgør væggene
int numRays;                                      //Mængden af rays der kastes aka mængden af kolonner 
float fovAngle = 60 * (PI / 180);                 //Synsvinklen for spilleren
float startFovAngle = fovAngle;                   //Variabel til at holde en tidligerer synsvinkel
long timer = 0;                                   //Tid siden programstart
long lastTime = 0;                                //Tid ved sidste opdatering af tid
float deltaTime = 0;                              //Tid siden sidste opdatering af programstart (tid for en frame)

PVector loc;                                      //Vinduets koordinat på skærm
String [] loadedMap;                              //Array der holder information fra loaded map
PImage wallTexture;                               //Texturefil
PImage tempTextCol;                               //Gennemsigtig kolonne ligeså høj som texturefil
PImage tempTextCol2;                              //Gennemsigtig kolonne ligeså høj som texturefil
PFont blockPix;                                   // https://www.1001fonts.com/blocky-fonts.html?page=7&items=10
PFont zap;                                        //https://www.fontspace.com/zap-cannon-font-f30565


/////////////////////////////////////////////////////////////Loader billeder og fonts og inintialiserer variabler

void setupExtra() {
  loadedMap = loadStrings("assets/Maps/8.txt");
  wallTexture = loadImage("assets/Textures/2tile64.jpg");
  tempTextCol = createImage(1, wallTexture.width, ARGB);
  for (int i = 0; i < wallTexture.width; i++) {
    tempTextCol.pixels[i] = color(0, 0, 0, 0);
  }
  tempTextCol.updatePixels();
  tempTextCol2 = tempTextCol.get();

  blockPix = createFont("assets/Fonts/BULKYPIX.TTF", height / 60);
  zap = createFont("assets/Fonts/zap.ttf", height / 60);
  numRays = width / wallStripWidth + 5;
  deltaRayAngle = fovAngle / numRays;
}

/////////////////////////////////////////////////////////////Oversætter en given værdi til en vinkel mellem 0 og 360 grader eller 0 og 2PI

float normalizeAngle(float angle, String mode) {
  if (mode.equals("Degrees")) {
    angle = angle % 360;
    if (angle < 0) {
      angle = 360 + angle;
    }
  } else if (mode.equals("Radians")) {
    angle = angle % (2 * PI);
    if (angle < 0) {
      angle = (2 * PI) + angle;
    }
  }
  return angle;
}


/////////////////////////////////////////////////////////////

//Opdaterer map efter filinput
void mapSelected(File selection) {
  if (selection != null) {
    loadedMap = loadStrings(selection.getAbsolutePath());
    map.scale = (int) sqrt(loadedMap.length/(8*9));
    map.xTiles = map.scale * 8;
    map.yTiles = map.scale * 9;
    map.tileSize = ceil(float(height) / float(map.yTiles));
    map.xOffSet = (width / 2 - map.xTiles * map.tileSize) / 2;
    map.yOffSet = (height - map.yTiles * map.tileSize) / 2;
    map.content = new String[map.yTiles][map.xTiles];
    for (int y = 0; y < map.yTiles; y++) {
      for (int x = 0; x < map.xTiles; x++) {
        map.content[y][x] = loadedMap[y * map.xTiles + x];
      }
    }
    player = new Player();
    player.pos = map.searchForTileCoordinates("Start").copy();
    player.newPlayerPos = player.pos.copy();
  } 
  loop();
}

/////////////////////////////////////////////////////////////

//Opdaterer texture efter filinput
void textureSelected(File selection) {
  if (selection != null) {
    wallTexture = loadImage(selection.getAbsolutePath());
    tempTextCol = createImage(1, wallTexture.width, ARGB);
    for (int i = 0; i < wallTexture.width; i++) {
      tempTextCol.pixels[i] = color(0, 0, 0, 0);
    }
    tempTextCol.updatePixels();
    tempTextCol2 = tempTextCol.get();
  } 
  loop();
}


/////////////////////////////////////////////////////////////
//Finder positionen af vinduet

PVector getWindowLocation() {
  PVector l = new PVector();
  java.awt.Frame f =  (java.awt.Frame) ((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame();
  l.x = f.getX();
  l.y = f.getY();
  return l;
}

/////////////////////////////////////////////////////////////
//Beregner nye højder på textures ved ændring på sliders

void reloadMapAndTextures() {
  numRays = width / wallStripWidth + 5;
  deltaRayAngle = fovAngle / numRays;
  map.emptyMap();
  for (int y = 0; y < map.yTiles; y++) {
    for (int x = 0; x < map.xTiles; x++) {
      map.content[y][x] = map.emptyMap[y][x];
    }
  }

  PVector pPlayerPos = player.pos.copy();
  float pPlayerRotationAngle = player.rotationAngle;

  player = new Player();
  map.numHitsHorz = new int [map.xTiles];
  loadedTextureHeights = false;
  castAllRays();
  for (int y = 0; y < map.yTiles; y++) {
    for (int x = 0; x < map.xTiles; x++) {
      map.content[y][x] = loadedMap[y * map.xTiles + x];
    }
  }
  tempTextCol = createImage(1, wallTexture.width, ARGB);
  for (int i = 0; i < wallTexture.width; i++) {
    tempTextCol.pixels[i] = color(0, 0, 0, 0);
  }
  tempTextCol.updatePixels();
  tempTextCol2 = tempTextCol.get();

  loadTextures();
  player.pos = pPlayerPos.copy(); 
  player.newPlayerPos = player.pos.copy();
  player.rotationAngle = pPlayerRotationAngle;
}
