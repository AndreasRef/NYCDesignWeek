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