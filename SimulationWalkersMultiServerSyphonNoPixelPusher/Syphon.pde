void syphonDraw() {

  //Syphon PGraphics
  pg.beginDraw();
  pg.background(0);
  pg.noStroke();

  //Single Size pixels (width = 12)
  //for (int i = 0; i<lights.length; i++) {
  //  pg.stroke(lights[i].fillC);
  //  pg.line(i,0,i, pg.height);
  //}

  //Each light has a pixel size of 4 (width = 12*4 = 48)
  for (int i = 0; i<lights.length; i++) {
    pg.stroke(lights[i].fillC);
    pg.line(i*4, 0, i*4, pg.height);
    pg.line(i*4+1, 0, i*4+1, pg.height);
    pg.line(i*4+2, 0, i*4+2, pg.height);
    pg.line(i*4+3, 0, i*4+3, pg.height);
  }

  if (keyPressed) {

    if (int(key)-48 > -1 && int(key)-48 < lights.length) {
      syphonRunThroughStrip(int(key)-48); //Subtract 48 since the char '0' has a ASCII value of 48, '1' is 49 etc...
      triggerValue = (int(key)-48);
      serialCounter++;
      //trigFunction();

      if (syphonRunThroughCounter <500) syphonRunThroughCounter+=5;

      vibrationTrigged = true;
      vibrationTimer = 0;
    
      fadingTimer = 0;
    }
  } 
  
  if (vibrationTrigged) {
    syphonRunThroughStrip(triggerValue);
    if (syphonRunThroughCounter <500) syphonRunThroughCounter+=5;
    
  } else if (fadingTrigged && triggerValue > -1) { // triggerValue > -1 condiction avoids start up errors from the Arduino
    syphonRunThroughStrip(triggerValue);
    if (syphonRunThroughCounter <500) syphonRunThroughCounter+=5;
  }
  else if (vibrationTrigged == false && fadingTrigged == false) {
      syphonRunThroughCounter = 0;
  }

  
  pg.endDraw();
  image(pg, width-pg.width, height-pg.height); 

  if (waveShow) {
    server.sendImage(ws);
  } else {
    server.sendImage(pg);
  }
}



void syphonRunThroughStrip(int strip) {

  int thres = 300;

  if (syphonRunThroughCounter > thres) {
    syphonRunThroughCounter = thres;
  }
  
  
  
  pg.stroke(lerpColor(#FFFFFF, lights[strip].fillC, map(syphonRunThroughCounter, 0, thres, 0, 1)));
  //pg.stroke(lerpColor(#FFFFFF, lights[strip].fillC, (fadingTimer-vibrationThres/2)/(vibrationThres/2.0)));
  pg.line(strip*4, 0, strip*4, syphonRunThroughCounter);
  pg.line(strip*4+1, 0, strip*4+1, syphonRunThroughCounter);
  pg.line(strip*4+2, 0, strip*4+2, syphonRunThroughCounter);
  pg.line(strip*4+3, 0, strip*4+3, syphonRunThroughCounter);



  //println("syphonRunThroughStrip" + strip);
}


//lerpColor(#FFFFFF, lights[i].fillC, (fadingTimer-vibrationThres/2)/(vibrationThres/2.0)));