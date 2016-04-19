//Communication from the Arduino vibration sensors to Processing

int vibrationPins[] = { //Note that 0, 1 and 13 are not accessible!
  2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40
};

int pinCount = 38;

int LED = 13;

int counter = 0;

void setup() {

  //Start serial
  Serial.begin(9600);

  // Define pin #13 as output, for the LED
  pinMode(LED, OUTPUT);

  // Define all pins in the vibrationPins array as inputs and activate the internal pull-up resistor
  for (int thisPin = 0; thisPin < pinCount; thisPin++) {
    pinMode(vibrationPins[thisPin], INPUT_PULLUP);
  }
}

void loop() {

  //Go through all the input pins
  for (int thisPin = 0; thisPin < pinCount; thisPin++) {

    // Read the value of the input. It can either be 1 or 0
    int sensorValue = digitalRead(vibrationPins[thisPin]);

    if (sensorValue == LOW) { // If vibration trigger is down

      Serial.println(vibrationPins[thisPin]); //Send the number of the specific pin to the serial
      digitalWrite(LED, HIGH); //Turn on the built in Arduino on the board
      delay(100); //Pause everything for 100 ms 

    } else { // Otherwise, turn the LED off
      digitalWrite(LED, LOW);
    }
  }
}
