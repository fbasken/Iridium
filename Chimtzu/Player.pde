/// A controllable, physics-simulated player who collides with platforms
class Player
{
  final float JUMP_VEL = -15;
  final float BASE_WALK_SPEED = 10;
  final float MAX_XVEL = 30;
  final float MAX_YVEL = 100;

  final int ALLOWED_MIDAIR_JUMPS = 3; // Double jump = 1, since its a single midair jump

  PVector pos;
  PVector vel;
  PVector acc;
  float w;
  float h;
  float STANDING_HEIGHT;
  float CROUCHING_HEIGHT;
  float walkSpeedMultiplier;
  float jumpHeightMultiplier;

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
    acc = new PVector();

    falling = true;

    this.w = w;
    this.h = h;

    STANDING_HEIGHT = h;
    CROUCHING_HEIGHT = 0;
    walkSpeedMultiplier = 1;
    jumpHeightMultiplier = 1;

    this.c = c;

    this.controlScheme = controlScheme;

    numJumps = 0;
  }

  /// Updates the player
  void update()
  {
    // Update velocity based on acceleration, and position based on velocity
    vel.add(acc);
    pos.add(vel);

    // Friction
    //acc.x = vel.x * -.9;
    vel.x *= .5;
    // Gravity
    vel.y += GRAVITY;


    // Reset jumps upon landing on the ground
    if (!falling)
    {
      numJumps = 0;
    }

    // Prevent velocity from going above the maximum
    vel.x = constrain(vel.x, -MAX_XVEL, MAX_XVEL);
    vel.y = constrain(vel.y, -MAX_YVEL, MAX_YVEL);

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
          vel.y = JUMP_VEL * .8 * jumpHeightMultiplier;

          // Use up a jump
          numJumps++;
        }
        // Jump since we are on the ground
        else if (!falling)
        {
          vel.y = JUMP_VEL * jumpHeightMultiplier;
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
      vel.x = -BASE_WALK_SPEED * walkSpeedMultiplier;
    }
    // Right
    if (pressedKeys[controlScheme[3]])
    {
      vel.x = BASE_WALK_SPEED * walkSpeedMultiplier;
    }
    // Down
    if (pressedKeys[controlScheme[1]])
    {
      h = CROUCHING_HEIGHT;
      walkSpeedMultiplier = .5;
      jumpHeightMultiplier = .7;
    } else
    {
      h = STANDING_HEIGHT;
      walkSpeedMultiplier = 1;
      jumpHeightMultiplier = 1;
    }
  }



  /// Draws this player to the screen
  void render()
  {
    rectMode(CORNER);
    noStroke();
    fill(c, map(constrain(vel.y, 0, JUMP_VEL), 0, JUMP_VEL, 250, 200));
    rect(pos.x, pos.y, w, h, h/10);
    fill(255);
    textFont(monoFont);
    textAlign(CENTER);
    text(ALLOWED_MIDAIR_JUMPS - numJumps, pos.x + w/2, pos.y + h/2);
  }

  /// Detects and resolves collisions with the provided level
  void checkAndResolveCollisions(ArrayList<RectPlatform> levelPlatforms)
  {
    // Assume we are falling
    falling = true;

    for (int i = 0; i < levelPlatforms.size(); i++)
    {
      // Check y-collisions
      if (levelPlatforms.get(i).rectCollision(pos.x, pos.y + vel.y, w, h))
      {
        // If moving down
        if (vel.y >= 0)
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

      // Check x-collisions
      if (levelPlatforms.get(i).rectCollision(pos.x + vel.x, pos.y, w, h))
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
    }
  }
}
