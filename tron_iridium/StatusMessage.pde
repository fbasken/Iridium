final int STATUS_MESSAGE_LIFETIME = 3000;

/// A temporary status message
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
