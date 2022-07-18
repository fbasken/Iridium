final char KEY_ACCELERATE = 'W';
final float ACCELERATION_MAG = 1;
final float SPEED_MAX = 100;

class PlayerShip extends Ship
{
  float directionOfMouseCursor;
  float directionDifference;

  PlayerShip()
  {
    super();


    // Create ship shape
    shipShape = createShape();
    shipShape.beginShape();
    shipShape.fill(UI_COLOR_BLACK);
    //shipShape.noStroke();
    shipShape.stroke(UI_COLOR_WHITE);
    shipShape.strokeWeight(10);
    shipShape.vertex(0, 0);
    shipShape.vertex(-130, 200);
    shipShape.vertex(0, 120);
    shipShape.vertex(130, 200);
    shipShape.endShape(CLOSE);


    // Create blaster shape
    blasterShape = createShape();
    blasterShape.beginShape();
    blasterShape.fill(245);
    blasterShape.stroke(UI_COLOR_WHITE);
    blasterShape.strokeWeight(UI_LINE_THICKNESS);
    blasterShape.vertex(-45, 15);
    blasterShape.vertex(15, 15);
    blasterShape.vertex(15, -15);
    blasterShape.vertex(-45, -15);
    blasterShape.endShape(CLOSE);


    // Create trail shape
    trailShape = createShape();
    trailShape.beginShape();
    trailShape.noFill();
    trailShape.strokeWeight(UI_LINE_THICKNESS);
    trailShape.strokeCap(PROJECT);
    trailShape.vertex(-130, 200);
    trailShape.vertex(0, 120);
    trailShape.vertex(130, 200);
    trailShape.endShape();
  }

  void render()
  {

    pushMatrix();
    translate(pos.x, pos.y);
    rotate(direction + HALF_PI); // Correct for the ship being drawn facing up, instead of right
    
    //drawBlasters();

    shape(shipShape, 0, 0);

    drawEmblem();

    drawTrail();

    popMatrix();
  }

  private void drawEmblem()
  {
    int size = 30;
    
    pushMatrix();
    translate(29, 101);
    rotate(1);
    rectMode(CENTER);
    fill(UI_COLOR_WHITE);
    rect(0, 0, size * sqrt(2) -10, size * sqrt(2) -10);
    rotate(HALF_PI / 2);
    fill(UI_COLOR_BLACK);

    for (int i = 0; i < 4; i++)
    {
      rotate(HALF_PI);
      bezier(0, size, 0, size/3, size/3, 0, size, 0);
    }
    popMatrix();
  }

  private void drawBlasters()
  {
    pushMatrix();
    translate(-50, 100);
    rotate(blasterDirection+ HALF_PI); // Correct for the blasters being drawn facing up, instead of right
    shape(blasterShape, 0, 0);

    popMatrix();

    pushMatrix();
    translate(50, 100);
    rotate(blasterDirection+ HALF_PI); // Correct for the blasters being drawn facing up, instead of right
    shape(blasterShape, 0, 0);

    popMatrix();
  }

  private void drawTrail()
  {
    int numLines = 5;
    float distance = 30 * map(vel.mag(), 0, 100, 1, 2.5);
    //float speed = map(acc.mag(), 0, 1000, .5, 1);

    float currentTrailFrame = (frameCount * 1.5) % distance;

    for (int i = 0; i < numLines; i++)
    {
      //scale(map(currentTrailFrame * i, 0, distance * (numLines - 1), 1, 0.4));
      //translate(0, map(currentTrailFrame * i, 0, distance * (numLines - 1), 0, 300));

      trailShape.setStroke(color(255, 0, 0, map(currentTrailFrame + i * distance, 0, distance + distance * (numLines - 1), 255, 0)));
      if (acc.mag() < 0.9)
      {
        trailShape.setStroke(color(255, 0, 0, 10));
      }
      shape(trailShape, 0, 20 + currentTrailFrame + i * distance);
    }
  }

  void update()
  {
    angularAcc = angularVel * -0.1;

    acc = vel.copy().mult(-0.01);


    // input
    getInputs();

    // physics
    vel.add(acc);
    pos.add(vel);

    angularVel += angularAcc;
    direction += angularVel;

    // Put direction between -PI and PI
    direction = notEvilMod(direction + PI, TWO_PI) - PI;

    // Constrain velocity to max allowed velocity
    vel.setMag(constrain(vel.mag(), -SPEED_MAX, SPEED_MAX));
  }

  private void getInputs()
  {
    // Get direction of mouse cursor
    directionOfMouseCursor = getWorldMouseCursor().sub(pos).heading();
    directionDifference = directionOfMouseCursor - direction;

    // Correct direction difference if it's out of range
    if (directionDifference > Math.PI || directionDifference < -Math.PI)
    {
      directionDifference = -directionDifference;
    }

    // Point blasters
    blasterDirection = directionOfMouseCursor;

    if (pressedKeys[KEY_ACCELERATE])
    {
      angularAcc = constrain(directionDifference, -0.001, 0.001);

      if (direction > PI)  direction -= TWO_PI;
      if (direction < -PI) direction += TWO_PI;

      acc = PVector.fromAngle(direction);
      acc.setMag(ACCELERATION_MAG);
    }

    // DEBUG TEXT
    textSize(20);
    text("POS: (" + round(pos.x) + ", " + round(pos.y) + ") VEL: (" + round(vel.x) + ", " + round(vel.y) + ") ACC: (" + round(acc.x) + ", " + round(acc.y) + ")", 10, 35);
    text("DIRECTION TO MOUSE: " + directionOfMouseCursor + " (" + degrees(directionOfMouseCursor) + " degrees)", 10, 60);
    text("DIRECTION: " + direction + " (" + degrees(direction) + " degrees)", 10, 85);
    text("delta: " + directionDifference + " (" + degrees(directionDifference) + " degrees)", 10, 110);
  }
}
