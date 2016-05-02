// pixelpusher syphon sketch.
// takes pixels from syphon, puts 'em on the pixelpusher array.
// jas strong, 6th Dec 2013.

import codeanticode.syphon.*;

import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;

import processing.core.*;
import java.util.*;

DeviceRegistry registry;

SyphonClient client;
PGraphics canvas;

boolean ready_to_go = true;
int lastPosition;
int canvasW = 288;
//int canvasH = 432 ;
int canvasH = 8;
TestObserver testObserver;

void settings() {
 size(288, 8, P2D);
  PJOGL.profile = 1;
}

void setup() {
  
  registry = new DeviceRegistry();
  testObserver = new TestObserver();
  registry.addObserver(testObserver);
  background(0);
  client = new SyphonClient(this, "Arena", "LED");
  //client = new SyphonClient(this);
}

void draw() {
  background(0);
  if (client.newFrame()) {
    canvas = client.getGraphics(canvas);
    image(canvas, 0, 0, width, height);
  }  
  scrape();
}

void stop()
{
  super.stop();
}