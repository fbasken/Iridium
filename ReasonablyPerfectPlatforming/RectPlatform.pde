/// A rectangular platform
class RectPlatform
{
  float x;
  float y;
  float w;
  float h;
  
  /// Creates a RectPlatform
  RectPlatform(float x, float y, float w, float h)
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  /// Draws a rectangle at this platform's location
  void render()
  {
    rectMode(CENTER);
    rect(x + w/2.0, y + h/2.0, w, h, 5);
  }
}
