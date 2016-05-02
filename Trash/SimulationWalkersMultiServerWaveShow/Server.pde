//SERVER
// The serverEvent function is called whenever a new client connects. //Currently does not react!
void serverEvent(Server server, Client client) {
  incomingMessage = "A new client has connected: " + client.ip();
  println(incomingMessage);
}

//SERVER
void server1Recieve() {
  Client client = server1.available();
  if (client != null) {

    incomingMessage = client.readString(); 
    incomingMessage = incomingMessage.trim();

    data = int(split(incomingMessage, " "));

    if (data.length == verticalSteps*horizontalSteps/2) { //This is necessary since the data sometimes is cut off, so not all values are sent
      for (int i = 0; i <verticalSteps*horizontalSteps/2; i++)
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

    if (data.length == verticalSteps*horizontalSteps/2) { //This is necessary since the data sometimes is cut off, so not all values are sent
      for (int i = 0; i <verticalSteps*horizontalSteps/2; i++)
        if (data[i] == 1) {
          buttons[i + verticalSteps*horizontalSteps/2].over = true;
        } else {
          buttons[i + verticalSteps*horizontalSteps/2].over = false;
        }
      println("GOOD data length");
    } else if (data.length >0) {
      println(data.length);
    }
  }
}