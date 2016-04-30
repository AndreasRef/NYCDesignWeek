
int stride = 240;

int SCREENWIDTH  = 480;
int SCREENHEIGHT = 32;

int GRADIENTLEN = 3000;
// use this factor to make things faster, esp. for high resolutions
int SPEEDUP = 1;

int c = 0;
// swing/wave function parameters
int SWINGLEN = GRADIENTLEN*3;
int SWINGMAX = GRADIENTLEN / 2 - 1;

// gradient & swing curve arrays
private int[] colorGrad;
private int[] swingCurve;

//ControlP5 vars
int masterBri = 255;
int masterSat = 255;

boolean first_scrape = true;

void scrape() {
  // scrape for the strips
  loadPixels();
  if (testObserver.hasStrips) {
    registry.startPushing();
    List<Strip> strips = registry.getStrips();
    boolean phase = false;
     // for every strip:
       int currenty = 0;
       int stripy = 0;
       for(Strip strip : strips) {
         int strides_per_strip = strip.getLength() / stride;

        //println("Strides per strip = "+strides_per_strip);

         int xscale = 480 / stride;
         //int yscale = height / (int)(strides_per_strip * strips.size()+1); //MEGAHACK!!!
         int yscale = SCREENHEIGHT / (int)(72 * strips.size()); //yscale does not seem to make a big difference
         
         // for every pixel in the physical strip
         for (int stripx = 0; stripx < strip.getLength(); stripx++) {
             int xpixel = stripx % stride;
             int stridenumber = stripx / stride; 
             int xpos,ypos; 
             
             if ((stridenumber & 1) == 0) { // we are going left to right
               xpos = xpixel * xscale; 
               ypos = (((int)(stripy*strides_per_strip)) + stridenumber) * yscale;
            } else { // we are going right to left
               xpos = ((stride - 1)-xpixel) * xscale;
               ypos = ((stripy*strides_per_strip) + stridenumber) * yscale;               
            }
            
            color c = get(xpos, ypos);
            //strip.setPixel(c, stripx);
            
            pushStyle();
            colorMode(HSB, 255);
            strip.setPixel(color(hue(c), masterSat, masterBri), stripx);
            popStyle(); 
          }
         stripy++;
       }
  }
}


// fill the given array with a nice swingin' curve
// three cos waves are layered together for that
// the wave "wraps" smoothly around, uh, if you know what i mean ;-)
void makeSwingCurve(int arrlen, int maxval) {
  // default values will be used upon first call
  int factor1=2;
  int factor2=3;
  int factor3=6;

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
}

// create a smooth, colorful gradient by cosinus curves in the RGB channels
private void makeGradient(int arrlen) {
  // default values will be used upon first call
  int rf = 3;
  int gf = 2;
  int bf = 4;
  int rd = 3;
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
    println("Gradient factors("+rf+","+gf+","+bf+"), displacement("+rd+","+gd+","+bd+")");
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

void waveShowSetup() {
    makeGradient(GRADIENTLEN);
  makeSwingCurve(SWINGLEN, SWINGMAX);
}

void waveShowDraw() {
  loadPixels();
  int i = 0;
  int t = frameCount*SPEEDUP;
  int swingT = swing(t); // swingT/-Y/-YT variables are used for a little tuning ...

  for (int y = 0; y < SCREENHEIGHT; y++) {
    int swingY  = swing(y);
    int swingYT = swing(y + t);
    for (int x = 0; x < SCREENWIDTH; x++) {
      // this is where the magic happens: map x, y, t around
      // the swing curves and lookup a color from the gradient
      // the "formula" was found by a lot of experimentation
      pixels[i++] = gradient(
        swing(swing(x + swingT) + swingYT) +
        swing(swing(x + t     ) + swingY ));
    }
  }
  updatePixels();
  scrape();
}