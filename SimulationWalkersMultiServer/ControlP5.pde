void setupControlP5() {

  cp5 = new ControlP5(this);
  cp5.addSlider("horizontalSteps", 0, 16).setPosition(10, height-55);
  cp5.addSlider("verticalSteps", 0, 8).setPosition(10, height-35);
  cp5.addSlider("speed", 0, 50).setPosition(10, height-15);

  cp5.addToggle("waveShow").setPosition(200, height-85).setSize(50, 10);
  cp5.addToggle("displayNumbers").setPosition(200, height-55).setSize(50, 10);
  cp5.addToggle("displayButtons").setPosition(200, height-25).setSize(50, 10);
  
  cp5.addToggle("silentMode").setPosition(300, height-85).setSize(50, 10);
  cp5.addToggle("whiteLights").setPosition(300, height-55).setSize(50, 10);
  cp5.addToggle("walkerSimulation").setPosition(300, height-25).setSize(50, 10);

  cp5.addColorWheel("gradientStart", 400, height - 115, 100 ).setRGB(color(#71FFD6));
  cp5.addColorWheel("gradientEnd", 520, height - 115, 100 ).setRGB(color(#FA0DFF));

  cp5.addColorWheel("currentBeatC", 650, height - 115, 100 ).setRGB(color(#08FFEC));
  cp5.addColorWheel("triggerC", 770, height - 115, 100 ).setRGB(color(#FFFFFF));
  cp5.addFrameRate().setPosition(10, 10);


  //cp5.addSlider("GRADIENTLEN", 500, 3000).setPosition(880, height-75);
  cp5.addSlider("SPEEDUP", 0, 10).setPosition(880, height-95);
  cp5.addSlider("waveShowSpeed", 0.0, 5.0).setPosition(880, height-55);
  cp5.addSlider("fadeSpeed", 2, 20).setPosition(880, height-35);
  cp5.addSlider("fadeThresLo", 0, 150).setPosition(880, height-15);
  
  

  
  //int GRADIENTLEN = 1500;
  //int SPEEDUP = 1;
  
  
  cp5.addBang("bang").setPosition(width-50, height-50).setSize(40, 40);
  
  
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(cp5.getController("horizontalSteps")) || theEvent.isFrom(cp5.getController("verticalSteps"))) {
    setupButtons();
    }
  if (theEvent.isFrom(cp5.getController("bang"))) {
   newWaveGradient();
  }
}