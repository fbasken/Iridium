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
  int totalFragCount;

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

    resetStats();
  }

  void awardFrag()
  {
    frags++;
    totalFragCount++;
  }

  void resetStats()
  {
    frags = 0;
    totalFragCount = 0;
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
    gameBoard.noStroke();
    gameBoard.rectMode(CENTER);
    if (alive)
    {
      gameBoard.fill(c);
      gameBoard.rect(pos.x, pos.y, size, size, 1 + (int)abs(sin(millis() / 100.0) * 5));
    } else
    {
      gameBoard.fill(lerpColor(c, color(UI_COLOR_WHITE), (sin(millis() / 100.0) *.5) + .5), 20);
      gameBoard.rect(pos.x, pos.y, size, size, 1);
    }
  }

  /// Returns true if there is a collision (and also records what color was hit)
  boolean collision()
  {
    // Check if we hit a wall (and store the opposing edge in case we are going to teleport)
    PVector opposingEdgeLocation = getOpposingEdgeLocation();

    // If there is an opposing edge location, then we hit a wall
    if (opposingEdgeLocation != null)
    {
      // If edge teleporting is on, then teleport
      if (quandaleMode)
      {
        pos.set(opposingEdgeLocation);
        return false;
      }
      // Otherwise, this is a crash
      else
      {
        alive = false;
        colorHit = color(UI_BACKGROUND_COLOR);
        return true;
      }
    } else if (gameBoard.get((int)pos.x, (int)pos.y) != color(UI_BACKGROUND_COLOR))
    {
      alive = false;
      colorHit = gameBoard.get((int)pos.x, (int)pos.y);
      return true;
    }
    return false;
  }

  PVector getOpposingEdgeLocation()
  {
    if (pos.x + size/2 > width) return new PVector(roundToGrid(size), pos.y);
    if (pos.x - size/2 < 0) return new PVector(roundToGrid(width - size), pos.y);
    if (pos.y + size/2 > height) return new PVector(pos.x, roundToGrid(size));
    if (pos.y - size/2 < 0) return new PVector(pos.x, roundToGrid(height - size));
    return null;
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
