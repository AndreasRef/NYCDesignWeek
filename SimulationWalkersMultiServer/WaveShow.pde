
void waveShowDraw() {
  ws.beginDraw();
  ws.loadPixels();
  int i = 0;
  int t = frameCount*SPEEDUP;
  int swingT = swing(t); // swingT/-Y/-YT variables are used for a little tuning ...

  for (int y = 0; y <waveShowHeight; y++) {
    int swingY  = swing(y);
    int swingYT = swing(y + t);
    for (int x = 0; x < waveShowWidth; x++) {
      // this is where the magic happens: map x, y, t around
      // the swing curves and lookup a color from the gradient
      // the "formula" was found by a lot of experimentation
      ws.pixels[i++] = gradient(
        swing(swing(x + swingT) + swingYT) +
        swing(swing(x + t     ) + swingY ));
    }
  }

  ws.updatePixels();
  
  ws.endDraw();
  
  image(ws, width-100, height-100); 
  
  if (waveShow) scrape(); 
  
}

void scrape() {
  // scrape for the strips
  ws.loadPixels();
  if (testObserver.hasStrips) {
        registry.startPushing();
        registry.setAutoThrottle(true);
        registry.setAntiLog(true);
        int stripy = 0;
        strips = registry.getStrips();
        
        if (strips.size() > 0) {
          int yscale = ws.height / strips.size();
          for(Strip strip : strips) {
            int xscale = ws.width / strip.getLength();
            for (int stripx = 0; stripx < strip.getLength(); stripx++) {
                color c = get(stripx*xscale + width-100, stripy*yscale + height-100);
            
                strip.setPixel(c, stripx);
             }
            stripy++;
          }
        }
    }
}


// create a new random gradient when mouse is pressed
//void mousePressed() {
//  if (mouseY < waveShowHeight) {
//    if (mouseButton == LEFT) {
//      SPEEDUP = (int) random(1, 2);
//      GRADIENTLEN = 1000 + (int) random (1, 500);
//      makeGradient(GRADIENTLEN);
//    } else if (mouseButton == RIGHT) {
//      makeSwingCurve(SWINGLEN, SWINGMAX);
//    }
//  }
//}


void newWaveGradient() {
  //SPEEDUP = (int) random(1, 2);
  //GRADIENTLEN = 1000 + (int) random (1, 500);
  makeSwingCurve(SWINGLEN, SWINGMAX);
}

// fill the given array with a nice swingin' curve
// three cos waves are layered together for that
// the wave "wraps" smoothly around, uh, if you know what i mean ;-)
void makeSwingCurve(int arrlen, int maxval) {
  // default values will be used upon first call
  int factor1=1;
  int factor2=5;
  int factor3=1;

  if (swingCurve == null) {
    swingCurve = new int[SWINGLEN];
  } else {
    factor1=(int) random(1, 7);
    factor2=(int) random(1, 7);
    factor3=(int) random(1, 7);
  }

  int halfmax = maxval/factor1;

  for ( int i=0; i<arrlen; i++ ) {
    float ni = i*TWO_PI/arrlen; // ni goes [0..TWO_PI] -> one complete cos wave
    swingCurve[i]=(int)(
      cos( ni*factor1 ) *
      cos( ni*factor2 ) *
      cos( ni*factor3 ) *
      halfmax + halfmax );
  }
  
  println("factor1: " + factor1 + "factor2: " + factor2 + "factor3: " + factor3);
}

// create a smooth, colorful gradient by cosinus curves in the RGB channels
private void makeGradient(int arrlen) {
  // default values will be used upon first call
  int rf = 4;
  int gf = 2;
  int bf = 1;
  int rd = 0;
  int gd = arrlen / gf;
  int bd = arrlen / bf / 2;

  if (colorGrad == null) {
    // first call
    colorGrad = new int[GRADIENTLEN];
  } else {
    // we are called again: random gradient
    rf = (int) random(1, 5);
    gf = (int) random(1, 5);
    bf = (int) random(1, 5);
    rd = (int) random(0, arrlen);
    gd = (int) random(0, arrlen);
    bd = (int) random(0, arrlen);
    System.out.println("Gradient factors("+rf+","+gf+","+bf+"), displacement("+rd+","+gd+","+bd+")");
  }

  // fill gradient array
  for (int i = 0; i < arrlen; i++) {
    int r = cos256(arrlen / rf, i + rd);
    int g = cos256(arrlen / gf, i + gd);
    int b = cos256(arrlen / bf, i + bd);
    colorGrad[i] = color(r, g, b);
  }
}

// helper: get cosinus sample normalized to 0..255
private int cos256(final int amplitude, final int x) {
  return (int) (cos(x * TWO_PI / amplitude) * 127 + 127);
}

// helper: get a swing curve sample
private int swing(final int i) {
  return swingCurve[i % SWINGLEN];
}

// helper: get a gradient sample
private int gradient(final int i) {
  return colorGrad[i % GRADIENTLEN];
}