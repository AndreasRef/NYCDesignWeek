//This sketch is the Server that recieves values from the two client sketches over wifi network about the position of people
//It can also simulates people walking around in the tunnel using the walker class
//The sketch uses it inputs to determine which commands to send to the light animation and Max4Live

//Update April 19th: Integrated with Arduino, so touching the tubes triggers chime sound and lights up the tubes (in the simulation)
////Note that pins 0, 1 and 13 are not accessible from the Arduino, so you need to recalculate the values comming from the Arduino!

//Still to do: Integration with the Pixel Pusher

//Update April 20th: Cleanup, flush MIDI notes

//Libraries
import controlP5.*;
import netP5.*;
import oscP5.*;
import processing.net.*;
import processing.serial.*;


//Arduino Serial
Serial myPort;
int serialCounter = 0;
int lastSerialCounter =0;
int triggerValue = -1;
String incomingMessage = "";
int data[];
int[] cMinor = {72, 74, 75, 77, 79, 80, 82, 84, 86, 87, 89, 91, 92, 94, 96, 98, 99, 101, 103, 104, 106, 108, 110, 11, 113, 115, 116, 118};
boolean vibrationTrigged = false;
long vibrationTimer = 0;

//Button
int horizontalSteps = 16;
int verticalSteps = 7;
int count;
Button[] buttons;
int beatVal1 = 0;


//ControlP5
ControlP5 cp5;

boolean displayNumbers = true;
boolean displayButtons = true;
boolean whiteLights = true;
boolean walkerSimulation = false;

color gradientStart;
color gradientEnd;
color currentBeatC;
color triggerC;

int speed = 50;

//Light
Light[] lights = new Light[horizontalSteps];


//OscP5
OscP5 oscP5;
NetAddress myRemoteLocation;


//Server
Server server1;
Server server2;


//Walker
ArrayList<Walker> walkers;
float walkerSteps = 2;



//Global variables
int programHeight = 480;
int yOffset = 100;



void setup() {
  size(1280, 800);
  
  //Arduino Serial
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[1], 9600);
  myPort.bufferUntil('\n');
  
  
  //Button
  setupButtons();
  
  
  //ControlP5
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
  
  
  //Light
  for (int i=0; i<lights.length; i++) {
    lights[i] = new Light(i, 255, 255, 255, color(#FC03C3)); //Pink
  }
  
  
  //OscP5
  oscP5 = new OscP5(this, 5002); // Listen for incoming messages at port 5002
  oscP5.plug(this, "beatPlug", "/beat");
  myRemoteLocation = new NetAddress("127.0.0.1", 5001); // set the remote location to be the localhost on port 5001
  
  OscMessage bangMessage = new OscMessage("/bang"); //Start the metro
  bangMessage.add(1);
  oscP5.send(bangMessage, myRemoteLocation);
  
  
  //Server
  server1 = new Server(this, 5204);
  server2 = new Server(this, 5205);


  //Walker
  walkers = new ArrayList<Walker>();
   
}

void draw() {
  background(50);
  
  //Button & Walker
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
  
  //Button & Osc 
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
  
  //Walker
  for (int i = 0; i < walkers.size(); i++) {
    Walker w = walkers.get(i);
    w.walk();
    w.display();
  }
  
  //Show beat line
  strokeWeight(25);
  stroke(255, 0, 0);
  //line(beatVal1*width/horizontalSteps + 0.5*width/horizontalSteps, yOffset, beatVal1*width/horizontalSteps + 0.5*width/horizontalSteps, programHeight+yOffset);
  strokeWeight(1);

  //Light
  pushStyle();
  colorMode(HSB, 255); //OBS!
  drawLights();
  popStyle();


  //Arduino Serial
  if (lastSerialCounter == serialCounter) {
    // Do nothing
  } else {
    trigFunction();
  }
  lastSerialCounter = serialCounter;

  if (vibrationTimer < 5000) {
    vibrationTimer++;
  }

  if (vibrationTimer > 100) {
    vibrationTrigged = false;

  } 
  
  //Server
  server1Recieve(); 
  server2Recieve(); 
}

//Server
void server1Recieve() {
  Client client = server1.available();
  if (client != null) {

    incomingMessage = client.readString(); 
    incomingMessage = incomingMessage.trim();

    data = int(split(incomingMessage, " "));

    if (data.length == 7*8) { //This is necessary since the data sometimes is cut off, so not all values are sent
      for (int i = 0; i <7*8; i++)
        if (data[i] == 1) {
          buttons[i].over = true;
        } else {
          buttons[i].over = false;
        }
      println("GOOD data length");
    } else if (data.length >0) {
      println(data.length);
    }
  }
}


void server2Recieve() {
  Client client = server2.available();
  if (client != null) {

    incomingMessage = client.readString(); 
    incomingMessage = incomingMessage.trim();

    data = int(split(incomingMessage, " "));

    if (data.length == 7*8) { //This is necessary since the data sometimes gets cut off, so not all values are sent
      for (int i = 0; i <7*8; i++)
        if (data[i] == 1) {
          buttons[i + 56].over = true;
        } else {
          buttons[i + 56].over = false;
        }
      //println("GOOD data length");
    } else if (data.length >0) {
      //println(data.length);
    }
  }
}

//Light
void drawLights() {

  noStroke();
  for (int i = 0; i<lights.length; i++) {
    lights[i].fillC = color(hue(lerpColor(gradientStart, gradientEnd, abs(200 - (frameCount % 400))*0.005)), 75, 75);

    if (beatVal1 == i) {  
      lights[i].fillC = currentBeatC; //current beat position color
    }

    for (Button button : buttons) {
      if (button.row == i && button.over) { //color of rows/columns with people inside
        if (whiteLights) {
          lights[i].fillC = color (#FFFFFF, 120); //grey
        } else {
          lights[i].fillC = color (hue(lerpColor(gradientStart, gradientEnd, abs(200 - (frameCount % 400))*0.005)), 255, 255); //Lerp color full on
        }
        if (beatVal1 == i) {
          lights[i].fillC = triggerC; //color of lights when they are trigged
        }
      }
    }

    //Arduino inputs
    if (triggerValue > -1 && vibrationTrigged == true) { //Small hack to avoid arrayOutOfBounds error when starting up
      lights[triggerValue-2].fillC = color (hue(lerpColor(gradientStart, gradientEnd, abs(200 - (frameCount % 400))*0.005)), 255, 255); //Lerp color full on
    }
    lights[i].display();
  }
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(cp5.getController("horizontalSteps")) || theEvent.isFrom(cp5.getController("verticalSteps"))) {
    setupButtons();
  }
}


//Walker
void keyPressed() {
  if (key == 'a') walkers.add(new Walker((int)random(width), (int)random(programHeight)+yOffset)); 
  if (key == 'd' && walkers.size() > 0)  walkers.remove(0);
}

//Button
void setupButtons () {
  count = horizontalSteps * verticalSteps;
  buttons = new Button[count];

  int index = 0;
  for (int i = 0; i < horizontalSteps; i++) { 
    for (int j = 0; j < verticalSteps; j++) {
      buttons[index] = new Button(index, i, j, i*1280/horizontalSteps, j*programHeight/verticalSteps+yOffset, 1280/horizontalSteps, 480/verticalSteps, color(122), color(255));
      index++;
    }
  }
}


void mousePressed() {
  if (mouseY > yOffset && mouseY < yOffset + programHeight) {
    walkers.add(new Walker(mouseX, mouseY));
  }
}

public void beatPlug(int _beatVal1) {
  beatVal1 = _beatVal1;
}

// The serverEvent function is called whenever a new client connects. //Currently does not react!
void serverEvent(Server server, Client client) {
  incomingMessage = "A new client has connected: " + client.ip();
  println(incomingMessage);
}


void serialEvent(Serial thisPort) {
  String inputString = thisPort.readStringUntil('\n');
  inputString = trim(inputString);
  triggerValue = int(inputString);

  serialCounter++;

  vibrationTrigged = true;
  vibrationTimer = 0;
}

void trigFunction() {

  println("New trig revieced from input " + triggerValue);
  println("Total trigs recieved " + serialCounter);
  println();

  int midiNote = cMinor[triggerValue-2]; 

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