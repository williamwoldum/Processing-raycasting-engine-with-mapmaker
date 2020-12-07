ArrayList <Ray> rays = new ArrayList <Ray> ();      //Array der holder stråle objekterne
float deltaRayAngle = 0;                            //Vinkel mellem strålerne

class Ray {
  float rayAngle;                      //Vinkel på den specifikke stråle
  float distance;                      //Længden af det specifikke stråle fra spiller til mur
  boolean isRayFacingDown;             //Peger strålen nedad
  boolean isRayFacingRight;            //Peger strålen mod højre
  boolean wasHitVertical = false;      //Rammer strålen en mur vertikalt eller horisontalt
  PVector wallHit = new PVector();     //Koordinatet på punktet hvor strålen rammer muren
  int colHit = 0;                      //Kollonnen i texturefilen strålen rammer

  //********************************************************* Laver en stråle i given retning

  Ray(float angle) {
    rayAngle = normalizeAngle(angle, "Radians");
    isRayFacingDown = rayAngle < PI;
    isRayFacingRight = rayAngle > PI/2 * 3 || rayAngle < PI/2;
  }

  //********************************************************* Beregner koordinatet hvor strålen rammer væggen

  void cast() {
    PVector intercept = new PVector();       //Koordinatet hvor strålen skærere gitteret
    PVector step = new PVector();            //Vektoren mellem vandrette kollisioner med gitteret
    
    
    //////////Beregner strålens vandrette kollision med væggen/////////////
    PVector horzWallHit = new PVector(400*width, 400*height);

    intercept.y = floor(player.pos.y / map.tileSize) * map.tileSize;
    intercept.y += isRayFacingDown ? map.tileSize : 0;
    intercept.x = player.pos.x + (intercept.y - player.pos.y) / tan(rayAngle);

    step.y = map.tileSize;
    step.y *= isRayFacingDown ? 1 : -1;
    step.x = map.tileSize / tan(rayAngle);
    step.x *= isRayFacingRight && step.x < 0 ? -1 : 1;
    step.x *= !isRayFacingRight && step.x > 0 ? -1 : 1;

    PVector nextHorzTouch = new PVector(intercept.x, intercept.y);

    while (nextHorzTouch.x > 0 && nextHorzTouch.x < width/2 && nextHorzTouch.y > 0 && nextHorzTouch.y < height) {
      if (map.hasObjectAtCoordinate(nextHorzTouch.x, nextHorzTouch.y - (!isRayFacingDown ? 1 : 0), "Wall")) {
        horzWallHit = nextHorzTouch.copy();        
        break;
      } else {
        nextHorzTouch.x += step.x;
        nextHorzTouch.y += step.y;
      }
    }



    //////////Beregner strålens lodrette kollision med væggen/////////////
    PVector vertWallHit = new PVector(400*width, 400*height);
    
    //Beregner strålens første lodrette kollision med gitteret
    intercept.x = floor(player.pos.x / map.tileSize) * map.tileSize;
    intercept.x += isRayFacingRight ? map.tileSize : 0;
    intercept.y = player.pos.y + (intercept.x - player.pos.x) * tan(rayAngle);
    
    //Beregner step vektoren mellem de lodrette skæreinger
    step.x = map.tileSize;
    step.x *= isRayFacingRight ? 1 : -1;
    step.y = map.tileSize * tan(rayAngle);
    step.y *= isRayFacingDown && step.y < 0 ? -1 : 1;
    step.y *= !isRayFacingDown && step.y > 0 ? -1 : 1;
    
    //Laver vektor ved første lodretteskæring
    PVector nextVertTouch = new PVector(intercept.x, intercept.y);
  
    //Tilføjer stepvekotren til første lodrette skæring indtil strålen rammer en mur eller er uden for canvas
    while (nextVertTouch.x > 0 && nextVertTouch.x < width/2 && nextVertTouch.y > 0 && nextVertTouch.y < height) {
      if (map.hasObjectAtCoordinate(nextVertTouch.x - (!isRayFacingRight ? 1 : 0), nextVertTouch.y, "Wall")) {
        vertWallHit = nextVertTouch.copy();
        break;
      } else {
        nextVertTouch.x += step.x;
        nextVertTouch.y += step.y;
      }
    }


    //////////Tjekker om den lodrette eller vandrette kollision er kortest/////////////
    float horzHitDist = 0;
    float vertHitDist = 0;

    horzHitDist = abs(horzWallHit.sub(player.pos).mag());
    vertHitDist = abs(vertWallHit.sub(player.pos).mag());

    wallHit = horzHitDist < vertHitDist ? horzWallHit.copy() : vertWallHit.copy();
    distance = horzHitDist < vertHitDist ? horzHitDist : vertHitDist;
    wasHitVertical = horzHitDist > vertHitDist;



    //////////Hvis ikke textures er loaded gem hvilken celle strålen ramte på øverste væg/////////////
    if (!loadedTextureHeights) {
      //println(player.pos.x + wallHit.x);
      int tileIndexX = floor((player.pos.x + wallHit.x - map.xOffSet) / map.tileSize);

      map.numHitsHorz[tileIndexX] += !wasHitVertical ? 1 : 0;
    }


    //////////Beregn hvilke kolonne strålen ville svarer til at ramm i texture filen/////////////
    if (textureMode) {
      if (wasHitVertical) {
        colHit = round((player.pos.y + wallHit.y) % map.tileSize);
        if (!isRayFacingRight) {
          colHit = map.tileSize - colHit;
        }
      } else {
        colHit = round((player.pos.x + wallHit.x) % map.tileSize);
        if (isRayFacingDown) {
          colHit = map.tileSize - colHit;
        }
      }
    }
  }

  //********************************************************* Viser en stråle som en linje (kræver meget computerkræft)

  void display() {
    strokeWeight(1);
    stroke(255, 50, 50);
    line(player.pos.x, player.pos.y, wallHit.x +player.pos.x, wallHit.y + player.pos.y);
  }
}

///////////////////////////////////////////////////////////// Skyder all stråler ud i spillerens retning

void castAllRays() {
  float rayAngle = player.rotationAngle - (fovAngle / 2);

  rays.clear();
  for (int i = 0; i < numRays; i++) {
    Ray ray = new Ray(rayAngle);
    ray.cast();
    rays.add(ray);
    rayAngle += deltaRayAngle;
  }
}

///////////////////////////////////////////////////////////// Viser alle strålerne som et felt istedet for linjer (sparer meget computerkræft)

void displayRays() {
  noStroke();
  beginShape();

  if (fullScreen) {
    vertex(
      map.scalingConstant * player.pos.x, 
      map.scalingConstant * player.pos.y
      );
    for (Ray ray : rays) {
      vertex(
        map.scalingConstant * (ray.wallHit.x + player.pos.x), 
        map.scalingConstant * (ray.wallHit.y + player.pos.y)
        );
    }
  } else {
    vertex(
      player.pos.x + map.xOffSet, 
      player.pos.y + map.yOffSet
      );
    for (int i = rays.size() / 4; i < rays.size() / 4 * 3; i++) {
      vertex(
        rays.get(i).wallHit.x + player.pos.x + map.xOffSet, 
        rays.get(i).wallHit.y + player.pos.y + map.yOffSet
        );
    }
  }
  endShape(CLOSE);
}
