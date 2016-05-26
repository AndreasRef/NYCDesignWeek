//SERVER
// The serverEvent function is (/ought to be) called whenever a new client connects. //Doesn't always 
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

    if (data.length == 8*7) { //This is necessary since the data sometimes is cut off, so not all values are sent
      for (int i = 0; i <8*7; i++)
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

    if (data.length == 4*7) { //This is necessary since the data sometimes is cut off, so not all values are sent
      for (int i = 0; i <4*7; i++)
        if (data[i] == 1) {
          buttons[i + 8*7].over = true;
        } else {
          buttons[i + 8*7].over = false;
        }
      println("GOOD data length");
    } else if (data.length >0) {
      println(data.length);
    }
  }
}