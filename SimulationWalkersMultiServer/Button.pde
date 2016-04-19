class Button {
  int index;
  int row;
  int column;
  int x, y;                 // The x- and y-coordinates
  float w;                  // Width
  float h;                  // Height
  color baseGray;           // Default gray value 
  color overGray;           // Color when something is over the button
  boolean over = false;     // State when something is over the button

  Button(int _index, int _row, int _column, int _x, int _y, float _w, float _h, color b, color o) {
    
    index = _index;
    row = _row;
    column = _column; 
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    baseGray = b;
    overGray = o;
  }

  void update(float x, float y) {

    float bX = x;
    float bY = y;

    if ((bX >= this.x) && (bX <= this.x+w) && (bY >= this.y) && (bY <= this.y+h)) {    
      over = true;
    }
  }

  void display() {
    if (over == true) {
      fill(overGray, 100);
    } else {
      fill(baseGray, 100);
    }
    stroke(255);
    rect(x, y, w, h);
  }


  void displayNumbers() {
    pushStyle();
    textAlign(CENTER);
    textSize(10);
    fill(255, 0, 0);
    text(index + " " + row + " " + column + " " + int(over), x+w/2, y+h/2);
    popStyle();
  }
}