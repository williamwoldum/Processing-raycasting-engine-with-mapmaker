class Map {
  String [][] content;             //Array med der holder styr på tilesobjekterne i mappet
  String [][] emptyMap;            //Tomt map der kun har ramme. Bruges til at beregne texture højder
  int [] numHitsHorz;              //Array der holder styr på hvor mange gange et væg-tilsene i en række er blevet ramt. Bruges til at beregne texture højder
  int tileSize;                    //Størrelsen på cellerne
  int xTiles, yTiles;              //Mængden af celler i given retning
  int scale;                       //Skaleringsfaktor til mængden af celler
  float scalingConstant = 1;       //Skaleringsfaktor til mappets dimensioner
  int xOffSet, yOffSet;            //Offsets der placerer mappet centreret i venstre halvdel af skærmen

  //*********************************************************

  Map() {
    scale = (int) sqrt(loadedMap.length/(8*9));
    xTiles = scale * 8;
    yTiles = scale * 9;
    tileSize = ceil(float(height) / float(yTiles));
    xOffSet = (width / 2 - xTiles * tileSize) / 2;
    yOffSet = (height - yTiles * tileSize) / 2;
    content = new String [yTiles][xTiles];
    numHitsHorz = new int [xTiles];
    emptyMap();                                        //Laver et tomt map i samme størrelse
    for (int y = 0; y < yTiles; y++) {                 //Fylder den loadede bane i et 2d array
      for (int x = 0; x < xTiles; x++) {
        content[y][x] = loadedMap[y * xTiles + x];
      }
    }
  }

  //********************************************************* Tegner mappet

  void display() {
    strokeWeight(1);
    rectMode(CORNER);
    fill(130);
    rect((xOffSet + tileSize) * scalingConstant, (yOffSet + tileSize) * scalingConstant, (xTiles - 2) * tileSize * scalingConstant, (yTiles - 2) * tileSize * scalingConstant);        //Laver baggrund bag kort rectsene laver mellemrum i visse opløsninger
    
    for (int y = 0; y < yTiles; y++) {
      for (int x = 0; x < xTiles; x++) {
        if (!loadedTextureHeights) {
          switch(emptyMap[y][x]) { 
          case "Wall":
            fill(51);
            stroke(51);
            break;

          case "Enemy":
            stroke(255, 90, 50);
            fill(255, 90, 50);
            break;
          }
        } else {
          switch(content[y][x]) {
          case "Start":
            stroke(90, 200, 90);
            fill(90, 200, 90);
            break;

          case "Goal":
            stroke(255, 255, 90);
            fill(255, 255, 90);
            break;

          case "Wall":
            fill(51);
            stroke(51);
            break;

          case "Enemy":
            stroke(255, 90, 50);
            fill(255, 90, 50);
            break;

          case "Empty":
            noStroke();
            fill(130);
            break;
          }
        }
        if (fullScreen){
        square(
          scalingConstant * x * tileSize, 
          scalingConstant * y * tileSize, 
          scalingConstant * tileSize
          );
        } else {
          square(
          x * tileSize + xOffSet, 
          y * tileSize + yOffSet, 
          tileSize
          );
        }
      }
    }
  }

  ///////////////////////////////////////////////////////////// Bruges til at tjekke om der er en bestemt type celle ved en given position

  boolean hasObjectAtCoordinate(float x, float y, String type) {
    int tileIndexX = floor(x / tileSize);
    int tileIndexY = floor(y / tileSize);
    return content[tileIndexY][tileIndexX].equals(type);
  }

  ///////////////////////////////////////////////////////////// Returnerer center positionen af en given celle type (virker kun med celler der én af)

  PVector searchForTileCoordinates(String type) {
    PVector tilePos = new PVector(-1, -1);

    for (int y = 0; y < yTiles; y++) {
      for (int x = 0; x < xTiles; x++) {
        if (content[y][x].equals(type)) {
          
          tilePos = new PVector(x * tileSize + tileSize / 2 + xOffSet, y * tileSize + tileSize / 2 + yOffSet);
          return tilePos;
        }
      }
    } 
    println("map not valid");
    return tilePos;
  }


  /////////////////////////////////////////////////////////////Danner et tomt map kun med ramme
  void emptyMap() {
    emptyMap = new String [yTiles][xTiles];
    for (int y = 0; y < yTiles; y++) {
      for (int x = 0; x < xTiles; x++) {
        if (y == 0 || y == yTiles - 1 || x == 0 || x == xTiles -1) {
          emptyMap[y][x] = "Wall";
        } else {
          emptyMap[y][x] = "Empty";
        }
      }
    }
  }
}
