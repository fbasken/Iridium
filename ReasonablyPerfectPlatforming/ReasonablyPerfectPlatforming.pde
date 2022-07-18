/*
Perfect Platforming
 by Freddie (counselor)
 
 DEMO PROJECT -- demonstrates how to make really good (dareisay perfect) rectangle-rectangle collisions
 
 TIC Session 1 2022
 
 
 TODO:
 Use a single RectPlatform collision function with params
 Moving platforms
 Player collision
 */

// A list of type boolean (true/false) corresponding to each possible key code
// This list will track what key codes are being pressed (true means it's pressed, false means it's released)
boolean[] pressedKeys = new boolean[256];

// A list of platforms that make up the level
ArrayList<RectPlatform> levelPlatforms = new ArrayList<RectPlatform>();

Player player1, player2;

PVector camPos;
PVector camVel;

void setup()
{
  fullScreen();

  player1 = new Player(new PVector(200, 200), 40, 55, color(249, 160, 180), new char[]{'W', 'S', 'A', 'D'});
  player2 = new Player(new PVector(width - 200, 200), 40, 55, color(180, 160, 249), new char[]{UP, DOWN, LEFT, RIGHT});

  // FLOOR
  //levelPlatforms.add(new RectPlatform(-50, height * .9, width + 100, height * .2));
  levelPlatforms.add(new RectPlatform(0, height * .9, width, height * .1));

  // WALLS AND CEILING
  levelPlatforms.add(new RectPlatform(-100, -100, 100, height));
  levelPlatforms.add(new RectPlatform(width, -100, 100, height));

  levelPlatforms.add(new RectPlatform(0, -100, width, 100));


  levelPlatforms.add(new RectPlatform(200, height * .9 - 100, 200, 100));

  levelPlatforms.add(new RectPlatform(400, height * .9 - 200, 100, 40));

  levelPlatforms.add(new RectPlatform(570, height * .9 - 250, 100, 40));

  levelPlatforms.add(new RectPlatform(width - 400, height * .9 - 100, 200, 100));

  levelPlatforms.add(new RectPlatform(800, height * .6 - 200, 100, 40));

  levelPlatforms.add(new RectPlatform(970, height * .6 - 250, 100, 40));

  levelPlatforms.add(new RectPlatform(200, height * .4 - 100, 200, 100));
}

void draw()
{
  background(1);

  // Scrolling !
  //translate(-player1.pos.x + (width/2), -player1.pos.y + (height/2));

  for (int i = 0; i < levelPlatforms.size(); i++)
  {
    fill(100, 120, 254);
    noStroke();
    levelPlatforms.get(i).render();
  }

  player1.update();
  player2.update();
  player1.checkAndResolveCollisions(levelPlatforms);
  player2.checkAndResolveCollisions(levelPlatforms);

  player1.render();
  player2.render();
}

void updateCamera()
{
  camPos.add(camVel);
  camVel = new PVector(-player1.pos.x + (width/2), -player1.pos.y + (height/2));
}

void keyPressed()
{
  pressedKeys[keyCode] = true;
}

void keyReleased()
{
  pressedKeys[keyCode] = false;
}
