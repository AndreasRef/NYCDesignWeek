void setupControlP5() {

  cp5 = new ControlP5(this);

  cp5.addFrameRate().setPosition(10, 10);

  cp5.addSlider("speed", 0, 50).setPosition(10, height-15);

  cp5.addToggle("displayNumbers").setPosition(10, height-55).setSize(50, 10);
  cp5.addToggle("displayButtons").setPosition(85, height-55).setSize(50, 10);

  cp5.addToggle("emptyWhite").setPosition(300, height-85).setSize(50, 10);
  cp5.addToggle("silentMode").setPosition(300, height-55).setSize(50, 10);
  cp5.addToggle("walkerSimulation").setPosition(300, height-25).setSize(50, 10);

  cp5.addColorWheel("gradientStart", 400, height - 115, 100 ).setRGB(color(#71FFD6));
  cp5.addColorWheel("gradientEnd", 520, height - 115, 100 ).setRGB(color(#FA0DFF));

  cp5.addSlider("maxSat", 100, 255).setPosition(650, height-15);
  cp5.addSlider("maxBri", 100, 255).setPosition(650, height-35);
  cp5.addSlider("fadeSpeed", 2, 20).setPosition(650, height-55);
  cp5.addSlider("fadeThresLo", 0, 100).setPosition(650, height-75).listen(true);

  cp5.addSlider("tintA", 0, 255).setPosition(850, height-15);
  cp5.addSlider("tintC", 0, 255).setPosition(850, height-35);
  cp5.addSlider("horizontalGradient", 0, 5).setPosition(850, height-55);
  cp5.addSlider("verticalGradient", 0, 5).setPosition(850, height-75);

  int tintC = 0;
  int tintA = 150;
}