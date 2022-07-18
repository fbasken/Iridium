abstract class Ship
{
  PVector pos;
  PVector vel;
  PVector acc;

  float direction;
  float angularVel;
  float angularAcc;

  float blasterDirection;

  PShape shipShape;
  PShape trailShape;
  PShape blasterShape;

  // Ship Constructor
  Ship()
  {
    pos = new PVector();
    vel = new PVector();
    acc = new PVector();

  }

  
}
