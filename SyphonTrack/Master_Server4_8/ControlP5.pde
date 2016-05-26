void setupControlP5() {

  cp5 = new ControlP5(this);

  cp5.addFrameRate().setPosition(10, 10);

  cp5.addToggle("walkerSimulation").setPosition(10, height-115).setSize(50, 10);
  cp5.addToggle("displayButtons").setPosition(10, height-85).setSize(50, 10);
  cp5.addToggle("displayNumbers").setPosition(10, height-55).setSize(50, 10);
  cp5.addSlider("speed", 0, 50).setPosition(10, height-15);
  
  cp5.addToggle("silentMode").setPosition(155, height-95).setSize(50, 10);
  cp5.addToggle("emptyWhite").setPosition(155, height-65).setSize(50, 10);
  cp5.addSlider("fadeSpeed", 2, 20).setPosition(155, height-35);
  cp5.addSlider("fadeThresLo", 0, 100).setPosition(155, height-15);
  
  cp5.addColorWheel("gradientStart", 400, height - 115, 100 ).setRGB(color(#71FFD6));
  cp5.addColorWheel("gradientEnd", 520, height - 115, 100 ).setRGB(color(#FA0DFF));

  cp5.addSlider("noiseScale", 0.0, 0.03).setPosition(690, height-75);
  cp5.addSlider("noiseSmooth", 0.0, 0.1).setPosition(690, height-55);
  cp5.addSlider("maxBri", 100, 255).setPosition(690, height-35);
  cp5.addSlider("maxSat", 100, 255).setPosition(690, height-15);  
  
  cp5.addToggle("noiseGradient").setPosition(810, height-115).setSize(50, 10);
  
  cp5.addSlider("trigHighlight", 0, 255).setPosition(880, height-115);
  cp5.addSlider("gradientPeriod", 100, 1000).setPosition(880, height-95);
  cp5.addSlider("verticalGradient", 0, 2).setPosition(880, height-75);
  cp5.addSlider("horizontalGradient", 0, 5).setPosition(880, height-55);
  cp5.addSlider("tintC", 0, 255).setPosition(880, height-35);
  cp5.addSlider("tintA", 0, 255).setPosition(880, height-15);  

}