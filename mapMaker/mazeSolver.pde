String [][] tempContent;
PVector start;
PVector exit;

boolean runSolvabillityTest() {
  tempContent = new String [yTiles][xTiles];
  for (int y = 0; y < yTiles; y++) {
    for (int x = 0; x < xTiles; x++) {
      tempContent[y][x] = content[y][x];
    }
  }
  noStroke();
  return navigate((int)start.x, (int)start.y);
}

boolean navigate(int x, int y) {        
  if (x == exit.x && y == exit.y) {                      
    return true;                                          
  } else if (tempContent[y][x].equals("Wall") || tempContent[y][x].equals("Been")) {  
    return false;                                        
  } else {                                                
    tempContent[y][x] = "Been";   
    if (x+1 <= tempContent[0].length && navigate(x+1, y)) {                            
      return true;                                      
    } else if (y+1 <= tempContent.length && navigate(x, y+1)) {
      return true;
    } else if (x-1 >= 0 && navigate(x-1, y)) {
      return true;
    } else if (y-1 >= 0 && navigate(x, y-1)) {
      return true;
    } else {                                             
      tempContent[y][x] = "Been"; 
      return false;
    }
  }
}
