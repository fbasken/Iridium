/// A rectangular platform
class RectPlatform
{
  float x;
  float y;
  float w;
  float h;
  color c;

  boolean selected;

  /// Creates a RectPlatform
  RectPlatform(float x, float y, float w, float h, color c)
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;

    this.c = c;

    selected = false;
  }

  /// Draws a rectangle at this platform's location
  void render()
  {
    rectMode(CENTER);
    fill(c);
    if (selected && editingMode)
    {
      strokeWeight(10);
      stroke(255);
    } else
    {
      noStroke();
    }
    rect(x + w/2.0, y + h/2.0, w, h, 5); // why did i do this
  }

  /// Returns true if the provided rectangle intersects this platform
  boolean rectCollision(float rx, float ry, float rw, float rh)
  {
    return rx < x + w &&
      rx + rw > x &&
      ry < y + h &&
      ry + rh > y;
  }

  JSONObject toJSONObject()
  {
    JSONObject job = new JSONObject();

    job.setFloat("x", x);
    job.setFloat("y", y);
    job.setFloat("w", w);
    job.setFloat("h", h);
    job.setInt("c", c);

    return job;
  }
}
