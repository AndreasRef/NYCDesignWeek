//This experimental version is without the Pixel Pusher, and tries to do all the light animations in the PGraphics
//Integrated a version of JoesWaveShow as a PGraphics that can be selected as the syphon output. 
//Optimized the "empty" mode, so it now works the same way as the PixelPusher version


//LIBRARIES
import controlP5.*;
import netP5.*;
import oscP5.*;
import processing.net.*;
import processing.serial.*;
import codeanticode.syphon.*;

import java.util.*;

int stripNumbers = 6;

int fadeSpeed = 4;
int fadeThresLo = 20;

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

int vibrationThres = 40;


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
boolean waveShow = false;

color gradientStart;
color gradientEnd;

int emptyFadeFactor = 1;

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


//SYPHON
SyphonServer server;
PGraphics pg;

//Waveshow
PGraphics ws;

int stride = 240;

int waveShowWidth = 12*4; 
int waveShowHeight = 64*4;
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

//WALKER
ArrayList<Walker> walkers;
float walkerSteps = 2;

//GLOBAL VARIABLES
int programHeight = 480;
int yOffset = 100;

//Test
int masterSat = 255;

void settings() {
  size(1280, 800, P2D);
  PJOGL.profile=1;
}

void setup() {
  setupWaveshow();
  
  colorMode(HSB,255);

  // Create syhpon server to send frames out.
  server = new SyphonServer(this, "Processing Syphon");
  //pg = createGraphics(48, 192);
  pg = createGraphics(12*4, 64*4); //Suitable for Option 1 simple

  //Arduino Serial
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[1], 9600);
  myPort.bufferUntil('\n');

  //BUTTON
  setupButtons();

  //CONTROLP5
  setupControlP5();

  //LIGHT
  for (int i=0; i<lights.length; i++) {
    lights[i] = new Light(i, 100, 100, 100, color(#FFFFFF)); //Pink
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

}

void draw() {
  background(50);

  syphonDraw();
  //drawWaveshow();

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

  if (waveShow == false) {
    for (int i = 0; i<stripNumbers; i++) {
      if (triggerValue == i && vibrationTrigged) { //If a light vibration sensor has recently been trigged
      } else if (triggerValue == i && fadingTrigged) { //Fading function - starts a bit later
      } else { //If light vibration sensor has not recently been trigged
      }
    }

    //Follow Sequencer by showing three small pixels in the bottom for each step
    for (int i = 0; i<lights.length; i++) {
      if (beatVal1 == i && silentMode == false) {  
        //if (i < stripNumbers) pushPixel(i*72, currentBeatC);
      }
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

  boolean empty = true; //Boolean that is true if no people are inside

  float lerpVal = abs(200 - (frameCount % (200*2)))*(1.0/200);

  noStroke();
  for (int i = 0; i<lights.length; i++) {
    lights[i].fillC = color(hue(lerpColor(gradientStart, gradientEnd, lerpVal)), masterSat, lights[i].b);
    lights[i].fadeDown(fadeSpeed/2, fadeThresLo);

    for (Button button : buttons) {
      if (button.row == i && button.over) { //color of rows/columns with people inside
        empty = false;
        lights[i].fadeUp(fadeSpeed, 255);
        lights[i].fillC = color (hue(lerpColor(gradientStart, gradientEnd, lerpVal)), masterSat, lights[i].b); //Lerp color full on

        if (beatVal1 == i && silentMode == false) {
          lights[i].fillC = color(hue(lights[i].fillC), 175, brightness(lights[i].fillC));
        }
      } 
    }
    lights[i].display();
  }
 
  if (empty == true) {
    fadeSpeed = 10;
    masterSat -=3;
    if (masterSat <= 0) masterSat=0;
    
    for (int i = 0; i<lights.length; i++) {
      //make fadeThresLo fade towards 10
      fadeThresLo--;
      if (fadeThresLo <= 10) fadeThresLo=10;
      
      lights[i].fillC = color(hue(lights[i].fillC), masterSat, brightness(lights[i].fillC));
     
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
    fadeThresLo++;
    if (fadeThresLo >= 50) fadeThresLo=50;
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