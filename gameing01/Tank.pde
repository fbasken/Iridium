class Tank {

  //graffics
  PGraphics tankBody;
  PGraphics tankArm;

  //tank body
  PVector pos;
  PVector vel;
  float velMag = 0; ///////////////
  float accMag = 0; ///////////////
  float tankDir; // 0 is RIGHT
  int engineHeat  = 0;


  int tankSize;
  color tankColor;

  //tank arm
  float armDir; // 0 is RIGHT
  color armColor;

  //tank trail
  ArrayList<PVector[]> trailPoints;
  color trailColor;
  boolean trailsEnabled;

  //tank inputs
  int[] inputMethod;
  //  int[] inputMethod   is the array of keyCodes that this tank recognizes.
  //comes from a global array of such arrays (aka 2d array) in the main class of preset input structures.
  //each tank should use a different one, thus each different tank has a different control scheme (aka input method)




  //CONSTANTS
  final int maxTrailLength = 200;
  float tankSizeRatio = 0.7;
  float maxSpeed = 9;
  int wheelWidth  = 10;
  float friction = 0.8;



  void enableTrails(boolean value) {
    trailsEnabled = value;
  }

  void update() {
    //Assume we are not accelerating (actively being propelled by the engine.)
    accMag = 0;
    friction = .8;
    //input
    if (pressedKey[inputMethod[0]]) { // FORWARD
      //If we are accelerating
      accMag= 0.02;
      friction = .999;
    }
    if (pressedKey[inputMethod[1]]) { // LEFT
      tankDir+=0.1;
    }
    if (pressedKey[inputMethod[3]]) { // RIGHT
      tankDir-=0.1;
    }
    if (pressedKey[inputMethod[2]]) { // DOWN
    
      accMag= -0.002;
      friction = 1;
    }
    if (pressedKey[inputMethod[4]]) { // FIRE
      //TODO
    }

    //Speed changes by Acceleration
    velMag+=accMag;
    //Friction reduces speed
    velMag*=friction;
    //Cap the speed
    if (velMag > maxSpeed) {
      velMag = maxSpeed;
    }
    //Finally, change our position based on our current speed multiplied by a unit vector representing our direction
    vel = (PVector.fromAngle(tankDir).mult(velMag)).copy();
    pos.add(vel);


    drawDebugText();


    if (trailsEnabled) {
      updateTrail();
    }
  }

  void drawDebugText() {
    fill(0);
    textSize(25);
    text(vel.x, 20, 20);
    text(vel.y, 20, 40);
    text(vel.mag(), 20, 70);
  }

  void render() {
    if (trailsEnabled) {
      renderTrail();
    }

    //BODY
    tankBody.beginDraw();
    tankBody.clear();

    tankBody.translate(tankBody.width/2, tankBody.height/2);
    tankBody.rotate(tankDir);
    //draw tank body
    tankBody.fill(tankColor);
    tankBody.stroke(0);
    tankBody.strokeWeight(2);
    tankBody.rectMode(CENTER);
    tankBody.rect(0, 0, tankSize, tankSize* tankSizeRatio);
    tankBody.endDraw();

    //ARM
    tankArm.beginDraw();
    tankArm.clear();
    tankArm.translate(tankArm.width/2, tankArm.height/2);
    tankArm.rotate(armDir);
    //draw tank arm
    tankArm.fill(tankColor);
    tankArm.stroke(0);
    tankArm.strokeWeight(2);
    tankArm.rectMode(CENTER);
    float armLength = tankSize * tankSizeRatio;
    float armWidth =  tankSize / 3.0;
    tankArm.rect(armLength - 1.5*armWidth, 0, armLength, armWidth);
    tankArm.point(0, 0);
    tankArm.endDraw();

    imageMode(CENTER);
    image(tankBody, pos.x, pos.y);
    image(tankArm, pos.x, pos.y);

    //rect(pos.x, pos.y, 40, 40);
  }



  void updateTrail() {
    int trailLength = trailPoints.size();
    //  IGNORE : //this code uses short circuiting. the statement before the && ensures no crash should there be no trail
    if (trailPoints.get(trailLength-1)[0].dist(pos) > (tankSize/10)) { // the change in position required to draw a new line segment for the trail

      PVector tankDirL = PVector.fromAngle(tankDir + HALF_PI);
      PVector tankDirR = PVector.fromAngle(tankDir - HALF_PI);

      PVector wheelPosL = pos.copy().add(tankDirL.mult(tankSize*tankSizeRatio/2));
      PVector wheelPosR = pos.copy().add(tankDirR.mult(tankSize*tankSizeRatio/2));

      trailPoints.add(new PVector[]{wheelPosL, wheelPosR});
      if (trailLength > maxTrailLength)
        trailPoints.remove(0);
    }
  }

  void renderTrail() {

    //reset trail color to be based off tank color
    trailColor = setAlpha(tankColor, 0);

    noFill();
    strokeWeight(wheelWidth);
    strokeCap(PROJECT);
    strokeJoin(ROUND);

    //left wheel trail
    beginShape();
    for (PVector[] p : trailPoints) {
      trailColor = setAlpha(trailColor, int(alpha(trailColor)+1)); //increase trail color alpha channel
      stroke(trailColor);
      vertex(p[0].x, p[0].y);
    }
    endShape();

    //reset trail color to be based off tank color
    trailColor = setAlpha(tankColor, 0);

    //right wheel trail
    beginShape();
    for (PVector[] p : trailPoints) {
      trailColor = setAlpha(trailColor, int(alpha(trailColor)+1)); //increase trail color alpha channel
      stroke(trailColor);
      vertex(p[1].x, p[1].y);
    }
    endShape();
  }

  // locomotive commands
  void goTo(PVector newTankPos) {
    pos = newTankPos.copy();
  }



  // C O N S T R U C T O R

  Tank(PVector pos, color tankColor, float tankDir, int tankSize, int[] inputMethod) {

    //create canvases
    tankBody = createGraphics(tankSize*2, tankSize*2, P2D);
    tankArm = createGraphics(tankSize*2, tankSize*2, P2D);

    //get constructor values
    this.pos = pos;
    this.tankColor = tankColor;
    this.tankDir = tankDir;    
    this.inputMethod = inputMethod;
    this.tankSize = tankSize;

    //other initialization
    vel = new PVector(0, 0);

    armDir = tankDir;

    trailPoints = new ArrayList<PVector[]>();
    trailsEnabled = true;

    //colors
    armColor = setAlpha(tankColor, 200);
    trailColor = setAlpha(tankColor, 0);


    // REMOVE  DEBUG  CODE  (ensures there is at least 1 point in the trail)
    PVector tankDirL = PVector.fromAngle(tankDir + HALF_PI);
    PVector tankDirR = PVector.fromAngle(tankDir - HALF_PI);

    PVector wheelPosL = pos.copy().add(tankDirL.mult(tankSize / 2));
    PVector wheelPosR = pos.copy().add(tankDirR.mult(tankSize / 2));

    trailPoints.add(new PVector[]{wheelPosL, wheelPosR});
    //
  }
}
