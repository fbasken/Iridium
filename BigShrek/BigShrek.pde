/*
BigShrek
 
 TIC SESSION 2 - Freddie (counselor)
 
 
 Here comes shrek
 */

boolean[] pressedKeys = new boolean[256];

PlayerShip player;
Camera _camera;

ArrayList<Ship> shipList = new ArrayList<Ship>();

final color UI_COLOR_WHITE = color(245);
final color UI_COLOR_BLACK = color(10);
final color UI_COLOR_RED = color(245, 0, 0);
final color UI_COLOR_GREEN = color(0, 245, 0);

final int UI_LINE_THICKNESS = 10;


void setup()
{
  player  = new PlayerShip();

  _camera = new Camera();
  _camera.zoom = .03;
  _camera.pos = player.pos.copy().mult(_camera.zoom).sub(new PVector(width/2, height/2));

  fullScreen();
  //noCursor();
  //shipList.add(player);
}

void draw()
{
  background(UI_COLOR_BLACK);

  // UPDATES
  player.update();

  // Update camera
  _camera.targetPos = player.pos.copy().mult(_camera.zoom).sub(new PVector(width/2, height/2));
  _camera.targetZoom = map(player.vel.mag(), 0, 100, .6, .09);
  //_camera.targetRotation = player.direction;
  _camera.update();

  // RENDER GAME
  pushMatrix();
  translate(-_camera.pos.x, -_camera.pos.y);
  scale(_camera.zoom);
  rotate(_camera.rotation);

  drawStars();

  // Draw BG and player
  player.render();

  // DEBUG STUFF
  //pushMatrix();
  //translate(player.pos.x, player.pos.y);
  //rotate(player.direction + HALF_PI); // Correct for the line being drawn facing up, instead of right
  //stroke(UI_COLOR_RED);
  //strokeWeight(UI_LINE_THICKNESS);
  //line(0, 0, 0, -200);
  //popMatrix();

  //pushMatrix();
  //translate(player.pos.x, player.pos.y);
  //rotate(player.directionOfMouseCursor + HALF_PI); // Correct for the line being drawn facing up, instead of right
  //stroke(0, 255, 0);
  //strokeWeight(UI_LINE_THICKNESS);
  //line(0, 0, 0, -200);
  //popMatrix();


  // World mouse cursor
  fill(UI_COLOR_WHITE);
  drawCrosshair(getWorldMouseCursor(), 200);

  drawCrosshair(_camera.pos.copy().div(_camera.zoom), 200);
  drawCrosshair(_camera.pos.copy().add(width, height).div(_camera.zoom), 200);

  //circle(getWorldMouseCursor().x, getWorldMouseCursor().y, 20);

  // Hardcoded unmoving circle
  circle(200, 200, 40);

  circle(-200, 200, 40);

  circle(200, -200, 40);

  circle(-200, -200, 40);

  popMatrix();

  // Debug text
  textSize(20);
  text("CAMERA POS: (" + _camera.pos.x + ", " + _camera.pos.y + ")", width - 500, 30);
  text("CAMERA ZOOM: " + _camera.zoom + "x", width - 500, 55);
  text("CAMERA ROTATION: " + _camera.rotation + " radians", width - 500, 80);
}

void drawStars()
{
  randomSeed(1);
  for (int starX = (int)_camera.pos.copy().div(_camera.zoom).x; starX < _camera.pos.copy().add(width, height).div(_camera.zoom).x; starX+=100)
  {
    for (int starY = (int)_camera.pos.copy().div(_camera.zoom).y; starY < _camera.pos.copy().add(width, height).div(_camera.zoom).y; starY+= 100)
    {

      fill(UI_COLOR_WHITE);
      circle(starX, starY, 20);
    }
  }
}

void drawCrosshair(PVector pos, int size)
{
  rectMode(CENTER);
  fill(UI_COLOR_WHITE);
  noStroke();
  rect(pos.x, pos.y + size * .3, size * .1, size*.3);
  rect(pos.x, pos.y - size * .3, size * .1, size*.3);
  rect(pos.x  +size *.3, pos.y, size * .3, size*.1);
  rect(pos.x  -size *.3, pos.y, size * .3, size*.1);
}

PVector getWorldMouseCursor()
{
  // Get screen space mouse position
  PVector screenMouseCursor = new PVector(mouseX, mouseY);

  // Subtract the camera position to undo the translation
  screenMouseCursor.add(_camera.pos.copy());

  // Divide to undo the scaling
  screenMouseCursor.div(_camera.zoom);

  return screenMouseCursor;
}

void keyPressed()
{
  pressedKeys[keyCode] = true;
}

void keyReleased()
{
  pressedKeys[keyCode] = false;
}

float notEvilMod(float a, float b)
{
  return (a % b + b) % b;
}
