void setupControlP5() {

  cp5 = new ControlP5(this);
  cp5.addSlider("horizontalSteps", 0, 16).setPosition(10, height-55);
  cp5.addSlider("verticalSteps", 0, 8).setPosition(10, height-35);
  cp5.addSlider("speed", 0, 50).setPosition(10, height-15);

  cp5.addToggle("displayNumbers").setPosition(200, height-55).setSize(50, 10);
  cp5.addToggle("displayButtons").setPosition(200, height-25).setSize(50, 10);
  cp5.addToggle("whiteLights").setPosition(300, height-55).setSize(50, 10);
  cp5.addToggle("walkerSimulation").setPosition(300, height-25).setSize(50, 10);

  cp5.addColorWheel("gradientStart", 400, height - 115, 100 ).setRGB(color(#71FFD6));
  cp5.addColorWheel("gradientEnd", 520, height - 115, 100 ).setRGB(color(#FA0DFF));

  cp5.addColorWheel("currentBeatC", 650, height - 115, 100 ).setRGB(color(#08FFEC));
  cp5.addColorWheel("triggerC", 770, height - 115, 100 ).setRGB(color(#FFFFFF));
  cp5.addFrameRate().setPosition(width-100, height-50);

  cp5.addSlider("passiveSat", 0, 255).setPosition(880, height-35);
  cp5.addSlider("passiveBri", 0, 255).setPosition(880, height-15);
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(cp5.getController("horizontalSteps")) || theEvent.isFrom(cp5.getController("verticalSteps"))) {
    setupButtons();
  }
}