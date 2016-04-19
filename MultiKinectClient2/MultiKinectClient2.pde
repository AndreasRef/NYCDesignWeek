//This sketch is the Client of the Server-Client relationship.  //<>//
//Its purpose is ONLY to send information about which buttons 
//in the second half of the installation where "over == true"

//Therefore it DOES NOT NEED ANY COMMUNICATION WITH THE PIXELPUSHER OR MAX4LIVE
//And all of that stuff is deleted

//This sketch has two Kinect inputs and sends the button/blob information to the server

import org.openkinect.freenect.*;
import org.openkinect.processing.*;

import blobDetection.*;

import controlP5.*;

// Import the net libraries
import processing.net.*;
// Declare a client
Client client;

ControlP5 cp5;

//Kinect
ArrayList<Kinect> multiKinect;

int numDevices = 0;

PGraphics pg;

//DepthThreshold
PImage depthImg;

//Blob
BlobDetection theBlobDetection;
PImage img;
boolean newFrame=false;

int programHeight = 480; 

//ControlP5
int minDepth =  60;
int maxDepth = 914;

boolean positiveNegative = true;
boolean showBlobs = false;
boolean showEdges = true;
boolean showInfo = false;
float luminosityThreshold = 0.7;
float minimumBlobSize = 100;
int blurFactor = 6;
boolean mirror = true;
boolean rgbView = false;
boolean switchOrder = false;

int cropAmount = 9;

int kinect0X, kinect0Y, kinect1X, kinect1Y;

//Buttons
int startX = 0;
int startY = 0;
int endX = 1280;
int endY = 480;

int horizontalSteps = 8;
int verticalSteps = 7;
int count;
Button[] buttons;
boolean displayNumbers = true;
boolean autoPress = false;
boolean mouseControl = true;
boolean showButtons = true;

PVector bCenterLerp; 

void setup() {
  size(1280, 640);
  
  frameRate(10); //Attempt to avoid jumpyness and communication errors... 

  pg = createGraphics(1280, 480); 
  
  client = new Client(this, "192.168.10.120", 5205); //The ip address is subject to change, so make sure you have it right every time you start up the program.

  numDevices = Kinect.countDevices();
  println("number of Kinect v1 devices  "+numDevices);

  multiKinect = new ArrayList<Kinect>();

  //iterate through all the devices and activate them
  for (int i  = 0; i < numDevices; i++) {
    Kinect tmpKinect = new Kinect(this);
    tmpKinect.enableMirror(mirror);
    tmpKinect.activateDevice(i);
    tmpKinect.initDepth();
    tmpKinect.initVideo();
    multiKinect.add(tmpKinect);
  }
  depthImg = new PImage(640, 480);

  // BlobDetection
  // img which will be sent to detection 
  img = new PImage(1280/4, 480/4); //a smaller copy of the frame is faster, but less accurate. Between 2 and 4 is normally fine
  theBlobDetection = new BlobDetection(img.width, img.height);
  theBlobDetection.setPosDiscrimination(true);
  theBlobDetection.setThreshold(luminosityThreshold); // will detect bright areas whose luminosity > luminosityThreshold (reverse if setPosDiscrimination(false);

  //ControlP5
  cp5 = new ControlP5(this);
  controlP5setup();

  //Button
  setupButtons();
  
  bCenterLerp = new PVector(0.0,0.0);
}

void draw() {
  background(0);

  pg.beginDraw();
  pg.background(0);
  for (int i  = 0; i < multiKinect.size(); i++) {
    multiKinect.get(i).enableMirror(mirror);

    //Threshold 
    int[] rawDepth = multiKinect.get(i).getRawDepth();
    for (int j=0; j < rawDepth.length; j++) {
      if (rawDepth[j] >= minDepth && rawDepth[j] <= maxDepth) {
        depthImg.pixels[j] = color(255);
      } else {
        depthImg.pixels[j] = color(0);
      }
    }
    depthImg.updatePixels();

    //Small hack for removing strange black bars in the left side of the depth images (might not be necessary for other setups)...
    //int cropAmount = 9;
    PImage croppedDepthImage = depthImg.get(cropAmount, 0, depthImg.width-cropAmount, depthImg.height);

    if (switchOrder) {
      if (i==0) {
        pg.image(croppedDepthImage, croppedDepthImage.width*(1-i)+kinect0X, kinect0Y, croppedDepthImage.width, 480);
      } else if (i==1) {
        pg.image(croppedDepthImage, croppedDepthImage.width*(1-i)+kinect1X, kinect1Y, croppedDepthImage.width, 480);
      }
    } else if (switchOrder == false) {
      if (i==0) {
        pg.image(croppedDepthImage, croppedDepthImage.width*i+kinect0X, kinect0Y, croppedDepthImage.width, 480);
      } else if (i==1) {
        pg.image(croppedDepthImage, croppedDepthImage.width*i+kinect1X, kinect1Y, croppedDepthImage.width, 480);
      }
      //pg.image(depthImg, 640*i, 0); //Full image without crop
    }
  }
  pg.endDraw();
  image(pg, 0, 0);


  img.copy(pg, 0, 0, pg.width, pg.height, 0, 0, img.width, img.height);
  fastblur(img, blurFactor);
  theBlobDetection.computeBlobs(img.pixels);
  drawBlobsAndEdges(showBlobs, showEdges, showInfo);
  theBlobDetection.setThreshold(luminosityThreshold); 
  theBlobDetection.activeCustomFilter(this);

  if (rgbView) {
    for (int i  = 0; i < multiKinect.size(); i++) {
      pushStyle();
      tint(255, 150);
      Kinect tmpKinect = (Kinect)multiKinect.get(i);

      if (switchOrder) {
        image(tmpKinect.getVideoImage(), 640*(1-i), 0);
      } else {
        image(tmpKinect.getVideoImage(), 640*i, 0);
      }
      popStyle();
    }
  }  

  //Buttons
  pushStyle();
  for (Button button : buttons) {
    button.over=false;

    if (mouseControl) {
      button.update(mouseX, mouseY); 
    } else {

      Blob b;
      for (int n=0; n<theBlobDetection.getBlobNb(); n++)
      {
        b=theBlobDetection.getBlob(n);
        
        //Make a vector for the center of the blob
        PVector bCenter = new PVector (b.xMin*width/1 + b.w*width/2, b.yMin*programHeight + b.h*programHeight/2);
        
        //Perhaps make a lerp function to smooth out values and avoid jumpiness?
        button.update(bCenter.x, bCenter.y);
        
      }
    }
    if (showButtons) { 
      button.display();
      if (displayNumbers) button.displayNumbers();
    }
  }
  popStyle();
  
  
  //Send information about each button to the server
  for (int i = 0; i<horizontalSteps*verticalSteps; i++) {
  client.write(str(int(buttons[i].over)) + " ");
  }

  pushStyle();
  fill(255);
  textSize(16);
  textAlign(LEFT);
  text("BLOBS: " + theBlobDetection.getBlobNb(), 152, height-5);

  popStyle();
}