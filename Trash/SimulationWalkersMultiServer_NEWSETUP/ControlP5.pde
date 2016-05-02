void setupControlP5() {

  cp5 = new ControlP5(this);
  cp5.addSlider("horizontalSteps", 0, 16).setPosition(10, height-55);
  cp5.addSlider("verticalSteps", 0, 8).setPosition(10, height-35);
  cp5.addSlider("speed", 0, 50).setPosition(10, height-15);

  
  cp5.addToggle("displayNumbers").setPosition(10, height-105).setSize(50, 10);
  cp5.addToggle("displayButtons").setPosition(100, height-105).setSize(50, 10);
  
  cp5.addToggle("silentMode").setPosition(200, height-85).setSize(50, 10);
  cp5.addToggle("waveShow").setPosition(200, height-55).setSize(50, 10);
  cp5.addToggle("walkerSimulation").setPosition(200, height-25).setSize(50, 10);

  cp5.addColorWheel("gradientStart", 400, height - 115, 100 ).setRGB(color(#71FFD6));
  cp5.addColorWheel("gradientEnd", 520, height - 115, 100 ).setRGB(color(#FA0DFF));

  cp5.addFrameRate().setPosition(10, 10);
  
  
  cp5.addSlider("emptyFadeFactor", 1, 50).setPosition(880, height-55);
  cp5.addSlider("fadeSpeed", 2, 20).setPosition(880, height-35).listen(true);
  cp5.addSlider("fadeThresLo", 0, 150).setPosition(880, height-15).listen(true);
  
  cp5.addSlider("waveSat", 1, 255).setPosition(1070, height-115);
  cp5.addSlider("waveBri", 1, 255).setPosition(1070, height-95);
  
  cp5.addSlider("waveShowSpeed", 1, 250).setPosition(1070, height-75);
  cp5.addSlider("wsHueMid", 50, 200).setPosition(1070, height-55);
  
  cp5.addSlider("wsHueVariance", 10, 100).setPosition(1070, height-35);
  cp5.addSlider("wsPixelVariance", 1, 300).setPosition(1070, height-15);
  
  
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(cp5.getController("horizontalSteps")) || theEvent.isFrom(cp5.getController("verticalSteps"))) {
    setupButtons();
    }
}