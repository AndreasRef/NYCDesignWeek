//PixelPusher functions

//Clean this up, so you only have the functions you need

void pushStrip(int strip, color c) {
  for (int i = 0; i<strips.size(); i++) {
    for (int stripx = 0; stripx < pixelsPerStrip; stripx++) {
      strips.get(strip).setPixel(c, stripx);
    }
  }
}


void runThroughStrip(int strip, color c) {
  pushPixel(strip*pixelsPerStrip + waveCount[strip], color(c)); //standard
  pushPixel(strip*pixelsPerStrip + waveCount[strip] +1 , color(c)); //Every second strip (needed if you do waveCount[strip] +=2;) 
  //if (strip%2 == 0) pushPixel(strip*pixelsPerStrip + waveCount[strip], color(c));
  //if (strip%2 == 1) pushPixel(strip*pixelsPerStrip + pixelsPerStrip - 1 - waveCount[strip], color(c)); //reverse direction
  waveCount[strip] +=2; 
  if (waveCount[strip] >= pixelsPerStrip) {
    waveCount[strip] = 0;
    vibrationTrigged = false;
  }
}

//void runThroughSide(int strip, int side, color c) {
//  pushPixel(strip*pixelsPerStrip + waveCount[strip], color(c)); //standard
//  pushPixel(strip*pixelsPerStrip + waveCount[strip] +1 , color(c)); //Every second strip (needed if you do waveCount[strip] +=2;) 
//  //if (strip%2 == 0) pushPixel(strip*pixelsPerStrip + waveCount[strip], color(c));
//  //if (strip%2 == 1) pushPixel(strip*pixelsPerStrip + pixelsPerStrip - 1 - waveCount[strip], color(c)); //reverse direction
//  waveCount[strip] +=2; 
//  if (waveCount[strip] >= pixelsPerStrip) {
//    waveCount[strip] = 0;
//    vibrationTrigged = false;
//  }
//}



void pushPixel(int pixel, color c) {
  int strip = floor(pixel/(pixelsPerStrip));
  int pixelNum = pixel % (pixelsPerStrip);

  for (int i = 0; i<strips.size(); i++) {
    strips.get(strip).setPixel(c, pixelNum);
  }
}





void pushSide(int strip, int side, color c) {
 if (strip < stripNumbers && side < sidesPerStrip) {//Attempt to avoid ArrayIndexOutOfBoundsExceptions
   for (int i = 0; i<strips.size(); i++) {
     for (int stripx = side*pixelsPerSide; stripx < (side+1)*pixelsPerSide; stripx++) {
       strips.get(strip).setPixel(c, stripx);
     }
   }
 }
}

//void fadeSide(int strip, int side, color c, boolean inOut, int fadeSpeed, int threshold) {
//  pushStyle();
//  colorMode(HSB, 360);
//  for (int i = 0; i<strips.size(); i++) {
//    for (int stripx = side*pixelsPerSide; stripx < (side+1)*pixelsPerSide; stripx++) {
//      if (inOut == true) {
//        brightness[stripx]+=fadeSpeed;
//        if (brightness[stripx] >= 360) brightness[stripx] = 360;
//      } else if (inOut ==false) {
//        brightness[stripx]-=fadeSpeed;
//        if (brightness[stripx] <= threshold) brightness[stripx] = threshold;
//      }
//      strips.get(strip).setPixel(color(hue(c), 360, brightness[stripx]), stripx);
//    }
//  }
//  popStyle();
//}

//void fadePixel(int pixel, color c, boolean inOut, int fadeSpeed, int threshold) { 
//  int strip = floor(pixel/(pixelsPerStrip));
//  int pixelNum = pixel % (pixelsPerStrip);

//  if (inOut == true) {
//    brightness[pixel]+=fadeSpeed;
//    if (brightness[pixel] >= 360) brightness[pixel] = 360;
//  } else if (inOut ==false) {
//    brightness[pixel]-=fadeSpeed;
//    if (brightness[pixel] <= threshold) brightness[pixel] = threshold;
//  }
//    strips.get(strip).setPixel(color(hue(c), 360, brightness[pixel]), pixelNum);
//}