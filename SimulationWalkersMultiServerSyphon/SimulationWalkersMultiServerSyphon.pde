//This sketch is the Server that recieves values from the two client sketches over wifi network about the position of people
//It can also simulates people walking around in the tunnel using the walker class
//The sketch uses its inputs to determine which commands to send to the light animation and Max4Live

//Update April 22nd: Vibration wave and fade made quicker. Follow Sequencer by showing three small pixels light (in a dominant color) for each step
//SilentMode added (fading lights), but not implemented to follow buttons yet

//Update April 25th: Fading lights implemented
//Changed to 12 beats and rows instead of 16
//Integrated gradient mode in master sketch

//Update April 26th: Proof of concept for Syphon
//Integrated a version of JoesWaveShow as a PGraphics that can be selected as the syphon output

//Syphon
import codeanticode.syphon.*;
SyphonServer server;
PGraphics pg;

//Waveshow
PGraphics ws;

int stride = 240;

int waveShowWidth = 6;
int waveShowHeight = 72;
int syphonRunThroughCounter = 0;


int GRADIENTLEN = 1500;
// use this factor to make things faster, esp. for high resolutions
int SPEEDUP = 1;

int c = 0;
// swing/wave function parameters
int SWINGLEN = GRADIENTLEN*3;
int SWINGMAX = GRADIENTLEN / 2 - 1;

// gradient & swing curve arrays
private int[] colorGrad;
private int[] swingCurve;



//LIBRARIES
import controlP5.*;
import netP5.*;
import oscP5.*;
import processing.net.*;
import processing.serial.*;

import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;
import java.util.*;

//PIXELPUSHER
DeviceRegistry registry;

class TestObserver implements Observer {
  public boolean hasStrips = false;
  public void update(Observable registry, Object updatedDevice) {
    //println("Registry changed!");
    if (updatedDevice != null) {
      //println("Device change: " + updatedDevice);
    }
    this.hasStrips = true;
  }
}

TestObserver testObserver;
List<Strip> strips;

int sidesPerStrip = 3;
int stripNumbers = 6;
int pixelsPerStrip = 72;
int pixelsPerSide = 24;

float hue[] = new float[stripNumbers*pixelsPerStrip];
int saturation[] = new int[stripNumbers*pixelsPerStrip];
int brightness[] = new int[stripNumbers*pixelsPerStrip];

int fadeSpeed = 4;
int fadeThresLo = 20;

color[] colorOptions = { #003D43, #38001F, #8F7D00};

int[] waveCount = {0, 0, 0, 0, 0, 0};

//ARDUINO SERIAL
Serial myPort;
int serialCounter = 0;
int lastSerialCounter =0;
int triggerValue = -1;
String incomingMessage = "";
int data[];
int[] cMinor = {72, 74, 75, 77, 79, 80, 82, 84, 86, 87, 89, 91, 92, 94, 96, 98, 99, 101, 103, 104, 106, 108, 110, 11, 113, 115, 116, 118};
boolean vibrationTrigged = false;
long vibrationTimer = 0;

long fadingTimer = 0;
boolean fadingTrigged = false;

int vibrationThres = 80;


//BUTTON
int horizontalSteps = 12;
int verticalSteps = 7;
int count;
Button[] buttons;
int beatVal1 = 0;

//CONTROLP5
ControlP5 cp5;

boolean displayNumbers = true;
boolean displayButtons = true;
boolean whiteLights = false;
boolean walkerSimulation = true;
boolean silentMode = true;
boolean waveShow = false;

color gradientStart;
color gradientEnd;
color currentBeatC;
color triggerC;

int speed = 50;
float waveShowSpeed = 0.1;

//LIGHT
Light[] lights = new Light[horizontalSteps];

//OSCP5
OscP5 oscP5;
NetAddress myRemoteLocation;

//SERVER
Server server1;
Server server2;

//WALKER
ArrayList<Walker> walkers;
float walkerSteps = 2;

//GLOBAL VARIABLES
int programHeight = 480;
int yOffset = 100;

void settings() {
  size(1280, 800, P2D);
  PJOGL.profile=1;
}

void setup() {
  setupWaveshow();
  
  // Create syhpon server to send frames out.
  server = new SyphonServer(this, "Processing Syphon");
  pg = createGraphics(48, 192);

  //Arduino Serial
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[1], 9600);
  myPort.bufferUntil('\n');

  //PixelPusher
  registry = new DeviceRegistry();
  testObserver = new TestObserver();
  registry.addObserver(testObserver);

  //BUTTON
  setupButtons();

  //CONTROLP5
  setupControlP5();

  //LIGHT
  for (int i=0; i<lights.length; i++) {
    lights[i] = new Light(i, 100, 100, 100, color(#FC03C3)); //Pink
  }

  //OSCP5
  oscP5 = new OscP5(this, 5002); // Listen for incoming messages at port 5002
  oscP5.plug(this, "beatPlug", "/beat");
  myRemoteLocation = new NetAddress("127.0.0.1", 5001); // set the remote location to be the localhost on port 5001

  OscMessage bangMessage = new OscMessage("/bang"); //Start the metro
  bangMessage.add(1);
  oscP5.send(bangMessage, myRemoteLocation);

  //SERVER
  server1 = new Server(this, 5204);
  server2 = new Server(this, 5205);

  //WALKER
  walkers = new ArrayList<Walker>();


  //WAVESHOW
  for (int i = 0; i <72*6; i++) {
    hue[i] = i/10;
    saturation[i] = 0;
    brightness[i]= 0;
  }
}

void draw() {
  background(50);
  
  syphonDraw();
  drawWaveshow();
 
  
  
  

  //BUTTON & WALKER
  for (Button button : buttons) {

    if (walkerSimulation == true) { //Update using random walkers
      button.over=false;
      for (int i = 0; i < walkers.size(); i++) { 
        Walker w = walkers.get(i);
        button.update(w.location.x, w.location.y);
      }
    } else {
      //Kill all walkers 
      for (int i = 0; i < walkers.size(); i++) {
        walkers.remove(i);
      }
    }
    if (displayButtons) button.display();
    if (displayNumbers) button.displayNumbers();
  }

  //BUTTON & OSC 
  OscMessage myMessage = new OscMessage("/sequencer");
  for (Button button : buttons) {
    myMessage.add(button.row);
    myMessage.add(button.column);
    if (button.over) {
      myMessage.add(1);
    } else {
      myMessage.add(0);
    }
  }
  oscP5.send(myMessage, myRemoteLocation);

  //WALKER
  for (int i = 0; i < walkers.size(); i++) {
    Walker w = walkers.get(i);
    w.walk();
    w.display();
  }

  //BEAT LINE
  strokeWeight(25);
  stroke(255, 0, 0);
  line(beatVal1*width/horizontalSteps + 0.5*width/horizontalSteps, yOffset, beatVal1*width/horizontalSteps + 0.5*width/horizontalSteps, programHeight+yOffset);
  strokeWeight(1);


  // PIXELPUSHER
  if (testObserver.hasStrips) {
    registry.startPushing();
    registry.setAutoThrottle(true);
    registry.setAntiLog(true);
    strips = registry.getStrips();

    if (waveShow == false) {
      for (int i = 0; i<stripNumbers; i++) {
        if (triggerValue == i && vibrationTrigged) { //If a light vibration sensor has recently been trigged
          //runThroughStrip(triggerValue, color(#FFFFFF)); //White lights run through the strip
          syphonRunThroughStrip(triggerValue);
        } else if (triggerValue == i && fadingTrigged) { //Fading function - starts a bit later
          //pushStrip(i, lerpColor(#FFFFFF, lights[i].fillC, (fadingTimer-vibrationThres/2)/(vibrationThres/2.0)));
          //println("Hello: " + fadingTimer + " " + (fadingTimer-100)/100);
        } else { //If light vibration sensor has not recently been trigged
          //pushStrip(i, color(lights[i].fillC)); //Strip has the color of the lights
        }
      }

      //Follow Sequencer by showing three small pixels in the bottom for each step
      for (int i = 0; i<lights.length; i++) {
        if (beatVal1 == i && silentMode == false) {  
          //if (i < stripNumbers) pushPixel(i*72, currentBeatC);
        }
      }
    } else if (waveShow == true) {//Push multiple pixels (changing colors rainbowstyle)
      pushStyle(); 
      for (int i = 0; i<pixelsPerStrip*strips.size(); i++) {
        colorMode(HSB, 255);
        float currentHue =  hue[i];
        //pushPixel(i, color(currentHue, 255, 255));
        hue[i]+=waveShowSpeed;
        if (hue[i] >255) hue[i] = 0;
      }
      popStyle();
    }
    
  }
  //LIGHT
  fillLights();

  //ARDUINO SERIAL
  if (lastSerialCounter == serialCounter) {
    // Do nothing
  } else {
    trigFunction();
  }
  lastSerialCounter = serialCounter;


  //VibrationTimer
  if (vibrationTimer < 5000) { 
    vibrationTimer++;
  }

  if (vibrationTimer > vibrationThres/2) {
    vibrationTrigged = false;
  } 

  //FadingTimer
  if (fadingTimer < 5000) { 
    fadingTimer ++;
  }

  if (fadingTimer > vibrationThres) {
    fadingTrigged = false;
  }

  if (fadingTimer < vibrationThres) {
    fadingTrigged = true;
  }

  //SERVER
  server1Recieve(); 
  server2Recieve();
}


//LIGHT
void fillLights() {

  pushStyle();
  colorMode(HSB, 255); //OBS!

  float lerpVal = abs(200 - (frameCount % (200*2)))*(1.0/200);

  noStroke();
  for (int i = 0; i<lights.length; i++) {
    lights[i].fillC = color(hue(lerpColor(gradientStart, gradientEnd, lerpVal)), 255, lights[i].b);
    lights[i].fadeDown(fadeSpeed/2, fadeThresLo);

    for (Button button : buttons) {
      if (button.row == i && button.over) { //color of rows/columns with people inside
        lights[i].fadeUp(fadeSpeed, 255);
        if (whiteLights) {
          lights[i].fillC = color (#FFFFFF, 120); //grey
        } else {
          lights[i].fillC = color (hue(lerpColor(gradientStart, gradientEnd, lerpVal)), 255, lights[i].b); //Lerp color full on
        }
        if (beatVal1 == i && silentMode == false) {
          lights[i].fillC = triggerC; //color of lights when they are trigged
        }
      }
    }

    //ARDUINO INPUTS
    if (triggerValue > -1 && vibrationTrigged == true) { //Small hack to avoid arrayOutOfBounds error when starting up
      //lights[triggerValue].fillC = color (#FFFFFF); //White color to indicate a hit - only on screen, because it gets overwritten
    }
    lights[i].display();
  }
  popStyle();
}

//ARDUINO SERIAL
void serialEvent(Serial thisPort) {
  String inputString = thisPort.readStringUntil('\n');
  inputString = trim(inputString);

  triggerValue = int(inputString);
  

  //Compensating for Input 0, 1 and 13 being blocked on the Arduino
  if (triggerValue == 50) triggerValue = 0;
  if (triggerValue == 51) triggerValue = 1;
  if (triggerValue == 53) triggerValue = 13; 
  syphonRunThroughStrip(triggerValue);
  serialCounter++;

  vibrationTrigged = true;
  vibrationTimer = 0;

  fadingTimer = 0;
}

//ARDUINO & OSC
void trigFunction() {

  println("New trig revieced from input " + triggerValue);
  println("Total trigs recieved " + serialCounter);
  println();

  int midiNote = cMinor[triggerValue]; 

  OscMessage myMessage = new OscMessage("/note");
  myMessage.add(midiNote); 
  myMessage.add(122); 
  oscP5.send(myMessage, myRemoteLocation); 

  OscMessage myMessageOff = new OscMessage("/note");
  myMessageOff.add(midiNote); 
  myMessageOff.add(0); 
  oscP5.send(myMessageOff, myRemoteLocation);

  //Flush out previous notes
  OscMessage myMessageFlush = new OscMessage("/flush");
  myMessageFlush.add(1);
  oscP5.send(myMessageFlush, myRemoteLocation);
}

//OSC
public void beatPlug(int _beatVal1) {
  beatVal1 = _beatVal1;
}