/// Player in a Tron game
class Player
{
  String name;
  color c;

  PVector pos;
  PVector vel;

  boolean alive;
  int frags;
  color colorHit;
  int winCount;

  char[] controls;
  
  Player(String name, color c, char[] controls)
  {
    this.name = name;
    this.c = c;
    this.controls = controls;

    pos = new PVector();
    vel = new PVector();

    alive = true;
    colorHit = color(0);
    frags = 0;
    winCount = 0;
  }

  void restart(PVector startingPos, PVector startingVel)
  {
    pos.set(startingPos);
    vel.set(startingVel);

    alive = true;
    frags = 0;
  }

  void move()
  {
    if (alive)
    {
      pos.add(vel);
    }
  }

  /// Draws a rectangle at the player's position
  void drawPlayer()
  {
    noStroke();
    rectMode(CENTER);
    if (alive)
    {
      fill(c);
      rect(pos.x, pos.y, size, size, 1 + (int)abs(sin(millis() / 100.0) * 5));
    } else
    {
      fill(lerpColor(c, color(UI_COLOR_WHITE), (sin(millis() / 100.0) *.5) + .5), 20);
      rect(pos.x, pos.y, size, size, 1);
    }
  }

  /// Returns true if there is a collision (and also records what color was hit)
  boolean collision()
  {
    // If offscreen
    if (pos.x + size/2 > width ||
      pos.x - size/2 < 0 ||
      pos.y + size/2 > height ||
      pos.y - size/2 < 0)
    {
      alive = false;
      colorHit = color(UI_BACKGROUND_COLOR);
      return true;
    }
    
    else if (get((int)pos.x, (int)pos.y) != color(UI_BACKGROUND_COLOR))
    {
      alive = false;
      colorHit = get((int)pos.x, (int)pos.y);
      return true;
    }
    return false;
  }

  /// Processes player inputs
  void getInputs()
  {
    // If player is moving horizonally, allow up/down to be pressed
    if (vel.x != 0)
    {
      // UP
      if (keySinglePressed(controls[0]))
      {
        vel.set(0, -size);
      }

      // DOWN
      if (keySinglePressed(controls[2]))
      {
        vel.set(0, size);
      }
    }

    // Otherwise, if player is moving vertically, allow left/right to be pressed
    else
    {
      // LEFT
      if (keySinglePressed(controls[1]))
      {
        vel.set(-size, 0);
      }

      // RIGHT
      if (keySinglePressed(controls[3]))
      {
        vel.set(size, 0);
      }
    }
  }
}
