/// A controllable, physics-simulated player who collides with platforms
class Player
{
  final float JUMP_VEL = -15;
  final float BASE_WALK_SPEED = 10;
  final float MAX_VEL = 100;
  final float GRAVITY = 1;
  final float FRICTION = .6;
  // Double jump = 1, since its a single midair jump
  final int ALLOWED_MIDAIR_JUMPS = 9999999;

  PVector pos;
  PVector vel;
  float w;
  float h;
  color c;
  char[] controlScheme;
  boolean falling;
  boolean jumpPressed;
  int numJumps;

  /// Creates a Player
  Player(PVector startingPos, float w, float h, color c, char[] controlScheme)
  {
    pos = startingPos.copy();
    vel = new PVector();

    falling = true;

    this.w = w;
    this.h = h;

    this.c = c;

    this.controlScheme = controlScheme;

    numJumps = 0;
  }

  /// Updates the player
  void update()
  {
    // Update position based on velocity
    pos.add(vel);

    // Update velocity based on gravity and friction forces
    vel.y += GRAVITY;
    vel.x *= FRICTION;

    // Reset jumps upon landing on the ground
    if (!falling)
    {
      numJumps = 0;
    }

    // Prevent velocity from going above the maximum
    vel.x = constrain(vel.x, -MAX_VEL, MAX_VEL);
    vel.y = constrain(vel.y, -MAX_VEL, MAX_VEL);

    // Get user inputs
    processInputs();
  }

  /// Checks for inputs
  private void processInputs()
  {
    // Jump -- if we have jumps remaining
    if (pressedKeys[controlScheme[0]])
    {
      if (!jumpPressed)
      {
        // If falling and we have midair jumps left, use up a jump
        if (falling && numJumps < ALLOWED_MIDAIR_JUMPS)
        {
          // Jump (but not as hard)
          vel.y = JUMP_VEL * .8;
          
          // Use up a jump
          numJumps++;
        }
        // Jump since we are on the ground
        else if (!falling)
        {
          vel.y = JUMP_VEL;
        }
      }
      
      // Mark that jump key is being pressed still
      jumpPressed = true;
    } else
    {
      // Jump key has been released
      jumpPressed = false;
    }
    // Left
    if (pressedKeys[controlScheme[2]])
    {
      vel.x = -BASE_WALK_SPEED;
    }
    // Right
    if (pressedKeys[controlScheme[3]])
    {
      vel.x = BASE_WALK_SPEED;
    }
  }



  /// Draws this player to the screen
  void render()
  {
    rectMode(CORNER);
    noStroke();
    fill(c, map(constrain(vel.y, 0, JUMP_VEL), 0, JUMP_VEL, 250, 200));
    rect(pos.x, pos.y, w, h, h/10);
  }

  /// Detects and resolves collisions with the provided level
  void checkAndResolveCollisions(ArrayList<RectPlatform> levelPlatforms)
  {
    // Assume we are falling
    falling = true;

    for (int i = 0; i < levelPlatforms.size(); i++)
    {
      // Check x-collisions
      if
        (
        pos.x + vel.x < levelPlatforms.get(i).x + levelPlatforms.get(i).w &&
        pos.x + vel.x + w > levelPlatforms.get(i).x &&
        pos.y < levelPlatforms.get(i).y + levelPlatforms.get(i).h &&
        pos.y + h > levelPlatforms.get(i).y
        )
      {
        // If moving right
        if (vel.x > 0)
        {
          pos.x = levelPlatforms.get(i).x - w;
        }
        // If moving left
        else
        {
          pos.x = levelPlatforms.get(i).x + levelPlatforms.get(i).w;
        }

        // Stop our velocity
        vel.x = 0;
      }

      // Check y-collisions
      if
        (
        pos.x < levelPlatforms.get(i).x + levelPlatforms.get(i).w &&
        pos.x + w > levelPlatforms.get(i).x &&
        pos.y + vel.y < levelPlatforms.get(i).y + levelPlatforms.get(i).h &&
        pos.y + vel.y + h > levelPlatforms.get(i).y
        )
      {
        // If moving down
        if (vel.y > 0)
        {
          pos.y = levelPlatforms.get(i).y - h;

          // We have hit the floor so we are no longer falling
          falling = false;
        }
        // If moving up
        else
        {
          pos.y = levelPlatforms.get(i).y + levelPlatforms.get(i).h;
        }

        // Stop our velocity
        vel.y = 0;
      }
    }
  }
}
