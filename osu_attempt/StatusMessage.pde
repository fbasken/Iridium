final int STATUS_MESSAGE_LIFETIME = 3000;

class StatusMessage
{
  String message;
  int timeCreated;

  StatusMessage(String message)
  {
    this.message = message;
    timeCreated = millis();
  }
}

ArrayList<StatusMessage> statusMessages = new ArrayList<StatusMessage>();

void drawStatusBar(int x, int y)
{
  final int MAX_MESSAGES = 10;

  if (statusMessages.size() > MAX_MESSAGES)
  {
    statusMessages.remove(0);
  }

  for (int i = 0; i < statusMessages.size(); i++)
  {
    pushStyle();
    fill(255, map(millis() - statusMessages.get(i).timeCreated, 0, STATUS_MESSAGE_LIFETIME, 255, 40));
    textAlign(LEFT);
    textFont(monoFont);
    text(statusMessages.get(i).message, x, y + i * 30);
    popStyle();
    
    if (millis() > statusMessages.get(i).timeCreated + STATUS_MESSAGE_LIFETIME)
    {
      statusMessages.remove(i);
    }
  }
}
