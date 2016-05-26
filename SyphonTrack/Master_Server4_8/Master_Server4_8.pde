//This master version recives information from:
//The two Client sketches ("MultiKinectClient1" (8x7 cells) & "SingKinectClient2" (4x7 cells) via wifi
//The Arduino (when the vibration sensors are trigged)
//Ableton (the current beatvalue)

//It sends information to:
//Ableton 
//Resolume via Syphon

//It does not send anything to the PixelPusher - that is a job of the "Syphon_To_PixelPusher" sketch
//This sketch sends out a Syphon stream of 48x64 (number of tubes x pixels per tube) 

//The sketch uses a new Swush function to enable multiple trigs on the vibration sensors at the same time
//New feature is also the alpha gradient, the horizontalGradient and the vertical gradient

//LIBRARIES
import controlP5.*;
import netP5.*;
import oscP5.*;
import processing.net.*;
import processing.serial.*;
import codeanticode.syphon.*;

import java.util.*;

int fadeSpeed = 4;
int fadeThresLo = 0;

int[] waveCount = {0, 0, 0, 0, 0, 0};

//ARDUINO SERIAL
Serial myPort;
int serialCounter = 0;
int lastSerialCounter =0;
int triggerValue = -1;
String incomingMessage = "";
int data[];
//int[] cMinor = {48, 50, 51, 53, 55, 56, 58, 60, 62, 63, 65, 67, 68, 70, 72, 74, 75, 77, 79, 80, 82, 84, 86, 87, 89, 91, 92, 94, 96, 98, 99, 101, 103, 104, 106, 108, 110, 11, 113, 115, 116, 118};
int[] cMinor = {82, 80, 79, 77, 75, 74, 72, 70, 68, 67, 65, 63, 65, 67, 68, 70, 72, 74, 75, 77, 79, 80, 82, 84, 86, 87, 89, 91, 92, 94, 96, 98, 99, 101, 103, 104, 106, 108, 110, 11, 113, 115, 116, 118};

//BUTTON
int horizontalSteps = 12;
int verticalSteps = 7;
int count;
Button[] buttons;
int beatVal1 = 0;

//CONTROLP5
ControlP5 cp5;

boolean displayNumbers = false;
boolean displayButtons = true;
boolean walkerSimulation = true;
boolean silentMode = false;
boolean emptyWhite = true;

color gradientStart;
color gradientEnd;

int emptyFadeFactor = 1;

int maxBri = 255;
int maxSat = 255;

int speed = 50;

int tintC = 0;
int tintA = 0;

float horizontalGradient = 0;
float verticalGradient = 1;

int gradientPeriod = 200;

int trigHighlight = 255;

float noiseSmooth = 0.03;
float noiseScale = 0.02;
boolean noiseGradient = true;


//LIGHT
Light[] lights = new Light[horizontalSteps];

//OSCP5
OscP5 oscP5;
NetAddress myRemoteLocation;

//SERVER
Server server1;
Server server2;

//SYPHON
SyphonServer server;
int syphonRunThroughCounter = 0;
PGraphics pg;

//WALKER
ArrayList<Walker> walkers;

//GLOBAL VARIABLES
int programHeight = 480;
int yOffset = 100;

int masterSat = 255;
boolean empty = true;

//SWUSH
int innerLights = 24; 
int[] swushAlpha = new int [innerLights];
int[] swushHeight = new int[innerLights];

//GRADIENT ALPHA IMAGE
PImage transGradient;

//NOISE GRADIENT
float xoff = 0.0;
float lerpVal = 0.5;

void settings() {
  size(1280, 800, P2D);
  PJOGL.profile=1;
}

void setup() {

  colorMode(HSB, 255);

  // Create syhpon server to send frames out.
  server = new SyphonServer(this, "Processing Syphon");
  pg = createGraphics(12*4, 64);

  //Arduino Serial
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[1], 9600);
  myPort.bufferUntil('\n');

  //BUTTON
  setupButtons();

  //CONTROLP5
  setupControlP5();

  //GRADIENT ALPHA IMAGE
  transGradient = loadImage("transGradient.png");

  //LIGHT
  for (int i=0; i<lights.length; i++) {
    lights[i] = new Light(i, 100, 100, 100, color(#FFFFFF));
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

  //SWUSH
  for (int i=0; i < innerLights; i++) {         
    swushAlpha[i] =255;
    swushHeight[i] = 255;
  }

  //WALKER
  walkers = new ArrayList<Walker>();
}

void draw() {
  background(50);

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


  //Cp5 Color indicators
  pushStyle();
  fill(#FFFFFF);
  text("hue: " + round(hue(gradientStart)), 400, height - 125);
  int maxHue = round((hue(gradientEnd)) + (verticalGradient*64 + horizontalGradient* 12));
  if (maxHue > 255) maxHue = maxHue - 255; 
  text("hue: " + round(hue(gradientEnd)), 520, height - 125); 
  text("maxhue: " + maxHue, 690, height-105);

  fill(maxHue, maxBri, maxSat);
  rect(690, height-95, 100, 10);
  popStyle();

  //LIGHT
  fillLights();

  //ARDUINO SERIAL
  if (lastSerialCounter == serialCounter) {
    // Do nothing
  } else {
    trigFunction();
  }
  lastSerialCounter = serialCounter;

  syphonDraw();

  //SERVER
  server1Recieve(); 
  server2Recieve();
}


//LIGHT
void fillLights() {

  empty = true; //Empty true if no people are inside

  //NOISE & GRADIENT
  xoff += noiseScale;
  float noiseVal = noise(xoff);

  if (noiseGradient) {
    lerpVal = lerp(lerpVal, noiseVal, noiseSmooth);
  } else {
    lerpVal = abs(gradientPeriod - (frameCount % (gradientPeriod*2)))*(1.0/gradientPeriod);
  }

  noStroke();
  for (int i = 0; i<lights.length; i++) {
    lights[i].fillC = color(hue(lerpColor(gradientStart, gradientEnd, lerpVal))+i*horizontalGradient, min(masterSat, maxSat), min(lights[i].b, maxBri));
    lights[i].fadeDown(fadeSpeed/2, fadeThresLo);
    lights[i].s = maxSat;

    for (Button button : buttons) {
      if (button.row == i && button.over) { //color of rows/columns with people inside
        empty = false;
        lights[i].fadeUp(fadeSpeed, 255);
        //lights[i].fillC = color (hue(lerpColor(gradientStart, gradientEnd, lerpVal)), masterSat, lights[i].b); //Lerp color full on

        if (beatVal1 == i && silentMode == false) {
          lights[i].fillC = color(hue(lights[i].fillC), maxSat - trigHighlight, min(lights[i].b, maxBri));

          lights[i].s = maxSat - trigHighlight;
        }
      }
    }
    lights[i].display();
  }

  if (empty == true) {
    fadeSpeed = 10;
    if (emptyWhite) {
      masterSat -=3;
    } else {
      masterSat +=3;
      if (masterSat > 255) masterSat =255;
    }
    if (masterSat <= 0) masterSat=0;

    for (int i = 0; i<lights.length; i++) {
      
      //make fadeThresLo fade towards 10
      //fadeThresLo--;
      //if (fadeThresLo <= 10) fadeThresLo=10;

      if (beatVal1 == i || beatVal1 == i-1 || beatVal1 == i+1 || beatVal1 - 11 == i ||  beatVal1 == i-2 || beatVal1 == i+2 || beatVal1 - 10 == i) {
        lights[i].fadeUp(fadeSpeed*emptyFadeFactor, 255);
      } else {
        lights[i].fadeDown(fadeSpeed/2, 0);
      }
      lights[i].display();
    }
  } else if (empty == false) {


    masterSat +=3;
    if (masterSat >= 255) masterSat=255;

    //make fadeThresLo fade towards 50;
    //fadeThresLo++;
    //if (fadeThresLo >= 50) fadeThresLo=50;
  }
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
  serialCounter++;

  swushFunction(triggerValue);
}

void swushFunction(int t) {

  if (swushHeight[t] > 0) {
    swushAlpha[t] = 255;
  } else {
    swushHeight[t] = 255;
    swushAlpha[t] = 255;
  }
}


void keyReleased() { //Swush 
  if (int(key)-48 > -1 && int(key)-48 < innerLights) {
    swushFunction(int(key)-48); //Subtract 48 since the char '0' has a ASCII value of 48, '1' is 49 etc...
    triggerValue = (int(key)-48);
    serialCounter++;
  }
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