void syphonDraw() {

  pg.beginDraw();
  pg.background(0);
  pg.noStroke();


  for (int i = 0; i<lights.length; i++) {
    pg.fill(lights[i].fillC);
    int s = lights[i].s;
    for (int j = 0; j<4; j++) {
          
      for (int h = 0; h <pg.height; h++) {
      
      float hVal = hue(lights[i].fillC)+h*verticalGradient;
        
      if (hVal<255) { 
      pg.fill(color(hVal, min(s,min(masterSat,maxSat)), min(lights[i].b, maxBri)));
      } 
      else if (hVal>255) {
      pg.fill(color(hVal-255, min(s,min(masterSat,maxSat)), min(lights[i].b, maxBri)));
      }
      pg.rect(i*4+j, h, 1, 1);  
      }
    }
  }


  pg.tint(tintC, tintA);
  pg.image(transGradient, 0, 0);


  for (int i = 0; i<innerLights; i++) {
    pg.fill(255, swushAlpha[i]);
    pg.noStroke();
    pg.rect(i*2, 0, 1, map(swushHeight[i], 0, 255, 64, 0));
  }

  for (int i = 0; i < swushAlpha.length; i++) {
    swushAlpha[i]-=2; 
    if (swushAlpha[i] <0) swushAlpha[i] =0;
  }

  for (int i = 0; i < swushHeight.length; i++) {
    swushHeight[i]-=10; 
    if (swushHeight[i] <0) swushHeight[i] =0;
  }




  pg.endDraw();
  //image(pg, width-pg.width, height-pg.height); //Original

  //Make image bigger so you see what is going on 
  image(pg, width-pg.width*4, height-pg.height*4, pg.width*4, pg.height*4);

  server.sendImage(pg);
}