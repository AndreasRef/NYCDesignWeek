class Walker {
  PVector location;
  Walker(int x, int y) {
    location = new PVector(x, y);
  }

  void display() {
    strokeWeight(2);
    fill(127);
    stroke(0);
    ellipse(location.x, location.y, 48, 48);
  }


  void walk() {
    if (frameCount % 60 == 0) {
      location.x += random(-speed, speed);
      location.y += random(-speed, speed);
    }  
    int offSet = 10;    
    location.x = constrain(location.x, offSet, width-offSet);
    location.y = constrain(location.y, yOffset + offSet, programHeight + yOffset-offSet);
  }
}



//ADD WALKERS --- NOT PART OF WALKER CLASS!!
void keyPressed() {
  if (key == 'a') walkers.add(new Walker((int)random(width), (int)random(programHeight)+yOffset)); 
  if (key == 'd' && walkers.size() > 0)  walkers.remove(0);
}

void mousePressed() {
  if (mouseY > yOffset && mouseY < yOffset + programHeight) {
    walkers.add(new Walker(mouseX, mouseY));
  }
  
  //Experiment with waveShow
  if (mouseY < SCREENHEIGHT) {
    if (mouseButton == LEFT) {
      SPEEDUP = (int) random(1, 2);
      GRADIENTLEN = 1000 + (int) random (1, 500);
      makeGradient(GRADIENTLEN);
    }
  }
  
}