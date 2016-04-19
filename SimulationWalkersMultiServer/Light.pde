class Light {
  int row;
  int h;
  int s;
  int b;
  float xPos;
  color fillC;

  int size = 25;


  Light(int _row, int _h, int _s, int _b, color _fillC) {

    row = _row;
    h = _h;
    s = _s;
    b = _b;
    fillC = _fillC;

    xPos = (row+0.5) * width/horizontalSteps;
  }

  void display() {
    fill(fillC);
    ellipse(xPos, 25, size, size);
    ellipse(xPos, 75, size, size);
    ellipse(xPos, programHeight + yOffset + 25, size, size);
    ellipse(xPos, programHeight + yOffset + 75, size, size);
  }
}