/// Length of time during which a circle can be clicked
final float HIT_WINDOW_MS = 700;

class Circle
{
  PVector pos;
  int alpha;
  float approachCircleDiameter;

  int number;
  color c;

  int hitTime;
  int clickedTime;

  boolean successfullyHit;
  boolean visible;

  float CIRCLE_DIAMETER = osuPixelsToScreenPixels(54.4 - 4.48 * CS);
  final float APPROACH_CIRCLE_DIAMETER = CIRCLE_DIAMETER * 3;


  /// How early to start drawing this circle
  final float APPEAR_TIME_MS = -450;
  /// How late to stop drawing this circle
  final float DISAPPEAR_TIME_MS = 300;

  final color COLOR_EDGE = color(255);


  Circle(PVector pos, int number, color c, int hitTime)
  {
    this.pos = pos.copy();
    this.hitTime = hitTime;
    approachCircleDiameter = APPROACH_CIRCLE_DIAMETER;
    successfullyHit = false;

    this.number = number;
    this.c = c;

    alpha = 0;
    visible = false;
  }

  /// True if this circle is currently clickable
  boolean isClickable()
  {
    return abs(getRelativeTimeToHit()) < HIT_WINDOW_MS / 2;
  }

  /// The difference in time between the circle's hit time and the time in the map
  /// Negative values are early, 0 means that the hit time is NOW, positive values are late
  int getRelativeTimeToHit()
  {
    return getCurrentMapTime() - hitTime;
  }

  /// If this circle was clicked this frame
  boolean checkClick()
  {
    if (successfullyHit) return false;

    boolean clicked = dist(mouseX, mouseY, pos.x, pos.y) < CIRCLE_DIAMETER / 2 && singleClick();
    
    if (clicked)
    {
      successfullyHit = true;
      clickedTime = getCurrentMapTime();
    }
    
    return clicked;
  }

  void update()
  {
    visible = true;

    // If it's too early to hit
    if (getRelativeTimeToHit() >= APPEAR_TIME_MS && getRelativeTimeToHit() < -HIT_WINDOW_MS / 2)
    {
      // Increase opacity from 0
      alpha = round(map(getRelativeTimeToHit(), APPEAR_TIME_MS, -HIT_WINDOW_MS / 2, 0, 255));
    }

    // If it's on the early side of the hit window
    else if (getRelativeTimeToHit() >= -HIT_WINDOW_MS / 2 && getRelativeTimeToHit() < 0)
    {
      alpha = 255;

      // Decrease approach circle diameter
      approachCircleDiameter = map(getRelativeTimeToHit(), -HIT_WINDOW_MS / 2, 0, APPROACH_CIRCLE_DIAMETER, CIRCLE_DIAMETER);
    }

    // If it's on the late side of the hit window
    else if (getRelativeTimeToHit() >= 0 && getRelativeTimeToHit() < HIT_WINDOW_MS / 2)
    {
      approachCircleDiameter = CIRCLE_DIAMETER;

      // Decrease opacity from 255
      alpha = round(map(getRelativeTimeToHit(), 0, HIT_WINDOW_MS / 2, 255, 0));
    } else
    {
      visible = false;
    }
  }

  void render()
  {
    final int EDGE_THICKNESS = 5;

    pushStyle();
    stroke(COLOR_EDGE, alpha);
    strokeWeight(EDGE_THICKNESS);


    fill(c, alpha);
    circle(pos.x, pos.y, CIRCLE_DIAMETER);

    textSize(CIRCLE_DIAMETER / 2);
    textAlign(CENTER);
    fill(COLOR_EDGE, alpha);
    text(number, pos.x, pos.y + CIRCLE_DIAMETER / 7);


    // If it's too early to hit
    if (getRelativeTimeToHit() >= APPEAR_TIME_MS && getRelativeTimeToHit() < -HIT_WINDOW_MS / 2)
    {
    }

    // If it's on the early side of the hit window
    else if (getRelativeTimeToHit() >= -HIT_WINDOW_MS / 2 && getRelativeTimeToHit() < 0)
    {
      noFill();
      stroke(COLOR_EDGE);
      circle(pos.x, pos.y, approachCircleDiameter);
    }

    // If it's on the late side of the hit window
    else if (getRelativeTimeToHit() >= 0 && getRelativeTimeToHit() < HIT_WINDOW_MS / 2)
    {
    }

    popStyle();
  }
}
