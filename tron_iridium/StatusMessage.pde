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
