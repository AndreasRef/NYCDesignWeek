void syphonDraw() {

  pg.beginDraw();
  pg.background(0);
  pg.noStroke();

  //Each light has a pixel size of 4 (width = 12*4 = 48)
  for (int i = 0; i<lights.length; i++) {
    pg.stroke(lights[i].fillC);
    pg.line(i*4, 0, i*4, pg.height);
    pg.line(i*4+1, 0, i*4+1, pg.height);
    pg.line(i*4+2, 0, i*4+2, pg.height);
    pg.line(i*4+3, 0, i*4+3, pg.height);
  }
  
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