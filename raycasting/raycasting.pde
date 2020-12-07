/*
Raycasting af William Woldum 3.x
Eksamensprojekt programmering B
11 maj. 2020

Dette projekt har til formål at generere 3d-grafik
ved brug af teknikken raycasting, en simpel og effektiv metode.
Der er funktionsbeskrivelse i tilhørende rapport.
Ellers står alle keybindings beksrevet hvis man klikker på 'm'.
Der er indbygget knapper og sliders i programmet til at justere variabler.
Ellers kan man kigge under fanen "functionality" for mere specifikke ændringer
*/

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

import java.awt.Robot;          //Bibliotek af Oracle der giver mig adgang til Robot klassen der kan bruges til at styre inputs fra mus og tastatur    https://docs.oracle.com/javase/7/docs/api/java/awt/Robot.html 
import java.awt.Window;         //Bibliotek af Oracle der giver mig adgang til at hente informationer om vinduet programmmet kører i                   https://docs.oracle.com/javase/7/docs/api/java/awt/Window.html
import controlP5.*;             //Bibliotek af Andreas Schlegel der giver adgang til controllers til programmets GUI                                   http://www.sojamo.de/libraries/controlP5/#about


//Initialiserer objekter
ControlP5 cp5;
Robot robot;
Player player;
Map map;
Menu menu;

/////////////////////////////////////////////////////////////

//Sætter vinduet til en 16/9 resolution hvis ikke skærmen har denne opløsning
void settings() {
  if (float(displayWidth)/float(displayHeight) != 16.0/9.0) {
    size(round(float(displayWidth) * 0.75), round(float(displayWidth) * 0.75 * (9.0 / 16.0)));
  } else {
    fullScreen();
  }
}

/////////////////////////////////////////////////////////////

void setup() {
  setupExtra();                  //Loader billeder og fonts
  map = new Map();
  player = new Player();
  setupUI();                     //Laver sliders
  try { 
    robot = new Robot();         //For at lave en robot klasse er det nødvendigt med en exeption. 
  } 
  catch (Throwable e) {
  }
  noCursor();
  frameRate(144);
}

/////////////////////////////////////////////////////////////

void update() {
  loc = getWindowLocation();                //Henter positionen af vinduet
  lastTime = timer;                         //Timers der bruges til at bestemme hvor meget spilleres skal flytte sig på baggrund af fps
  timer = millis();
  deltaTime = timer - lastTime;
  player.update();                          //Flyt spilleren
  castAllRays();                            //Kast strålerne
}

/////////////////////////////////////////////////////////////

void draw() {
  background(51);
  update();
  render3dWallProjections();        //Beregner væghøjde, vægfarve og tegner vægge
  map.display();                    //Tegner mappet
  player.display();                 //Tegner spilleren
  displayRays();                    //Tegner synesfeltet
  displayPermText();                //Tegner permanent text "Raycasting by William" mm.
  if (menuOpen) {                   //Hvis menuen er åben
    menu.update();                  //Ændrer farver på knapper og håndterer hvis der flyttes på sliders
    menu.display();                 //Viser menuen samt knapper og sliders deri
  }
}

/////////////////////////////////////////////////////////////

void keyPressed() {
  if (keyCode == UP || key == 'w' || key == 'W') {                          //Gå forlæns
    player.walkDirection = 1;
  } else if (keyCode == DOWN || key == 's' || key == 'S') {                 //Gå baglæns
    player.walkDirection = -1;
  } else if (keyCode == LEFT || key == 'a' || key == 'A') {                 //Gå mod venstre
    player.sideWaysDirection = -1;
  } else if (keyCode == RIGHT || key == 'd' || key == 'D') {                //Gå mod højre
    player.sideWaysDirection = 1;
  } else if (key == 'f' || key == 'F') {                                    //forstør/minimer spiller vindue
    fullScreen = !fullScreen;
    map.scalingConstant = fullScreen ? 0.2 : 1;
  } else if (key == 't' || key == 'T') {                                    //Slå textures til fra
    textureMode = !textureMode;
  } else if (key == 'p' || key == 'P') {                                    //Slå tts til fra
    ttsMode = !ttsMode;
      cp5.getController("fov").setValue(round(startFovAngle *  (PI / 180)));
      fovAngle = startFovAngle;
      reloadMapAndTextures();       
  }else if (key == 'm' || key == 'M') {                                     //Åben luk menu
    menuOpen = !menuOpen;
    if (!menuOpen) {
      menu.closeMenu();
    } else {
      cursor();
    }
  }
}

/////////////////////////////////////////////////////////////

void keyReleased() {
  if (keyCode == UP || key == 'w' || key == 'W') {                  //Stop forlæns bevægelse
    player.walkDirection = 0;
  } else if (keyCode == DOWN || key == 's' || key == 'S') {         //Stop baglæns bevægelse
    player.walkDirection = 0;
  } else if (keyCode == LEFT || key == 'a' || key == 'A') {         //Stop sidelæns bevægelse mod venstre
    player.sideWaysDirection = 0;
  } else if (keyCode == RIGHT || key == 'd' || key == 'D') {        //Stop sidelæns bevægelse mod højre
    player.sideWaysDirection = 0;
  }
}

/////////////////////////////////////////////////////////////

void mousePressed() {
  if (menu.selectMapButton.hovering) {                //Åben file selector til at vælge map
    noLoop();
    selectInput("Select a map", "mapSelected");
  }
  
   if (menu.selectTextureButton.hovering) {           //Åben file selector til at vælge map
    noLoop();
    selectInput("Select a square texture tile", "textureSelected");
  }

  if (menu.closeMenuButton.hovering) {                //Luk menu hvis der trykkes på close
    menuOpen = false;
    menu.closeMenu();
  }
}
