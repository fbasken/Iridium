import ddf.minim.*;
Minim minim;

boolean[] pressedKeys = new boolean[1024];
boolean[] prevPressedKeys = new boolean[256];
boolean prevMousePressed;

char leftKey, rightKey;

enum GameState
{
  PAUSED,
  WAITING_TO_START,
  PLAYING,
  RESULTS_SCREEN
}

final int WAIT_TIME_BEFORE_START = 1500;

GameState gameState;


PImage cursor;

int mapStartTimeMS;

Beatmap b;
float CS = 3;
float AR = 9.8;
float OD = 9;

ArrayList<Particle> particleList = new ArrayList<Particle>();

color colorBlue = color(10, 40, 255);
PFont monoFont;

int combo;

void restartMap()
{
  combo = 0;
  mapStartTimeMS = millis() + WAIT_TIME_BEFORE_START;
  statusMessages.add(new StatusMessage("Map restarted."));
  
  b.startFromBeginning();
  
  //gameState = GameState.WAITING_TO_START;
}

void setup()
{
  fullScreen();
  noCursor();
  
  minim = new Minim(this);
  
  cursor = loadImage("cursor@2x.png");
  monoFont = loadFont("Consolas-Bold-18.vlw");

  b = new Beatmap("beatmap/IOSYS - Cirno no Perfect Sansuu Kyoushitsu (alacat) [Perfect Freeze].osu", "beatmap/audio.mp3");

  leftKey = 'S';
  rightKey = 'D';
  
  restartMap();
}

void draw()
{
  if (singleClick())
  {
    particleList.add(new RingParticle(new PVector(mouseX, mouseY), color(255), 70, 350, 500));
  }
  if (keySinglePressed('R'))
  {
    restartMap();
  }

  background(0);

  b.update();
  b.render();

  for (int i = 0; i < particleList.size(); i++)
  {
    Particle p = particleList.get(i);
    p.update();
    p.render();

    if (!p.exists())
    {
      particleList.remove(i);
    }
  }

  drawStatusBar(50, 50);

  drawCursor();

  // Get previous keyboard and mouse state
  prevPressedKeys = pressedKeys.clone();
  prevMousePressed = mousePressed;
}


void drawCursor()
{

  imageMode(CENTER);
  image(cursor, mouseX, mouseY);
}

/// Returns the current number of milliseconds since the map started
int getCurrentMapTime()
{
  return millis() - mapStartTimeMS;
}

boolean keySinglePressed(char k)
{
  return pressedKeys[k] && !prevPressedKeys[k];
}

boolean mouseSinglePressed()
{
  return mousePressed && !prevMousePressed;
}

boolean singleClick()
{
  return mouseSinglePressed() || keySinglePressed(leftKey) || keySinglePressed(rightKey);
}

//void updateCamera()
//{
//  camPos.add(camVel);
//  camVel = new PVector(-playerList.get(0).pos.x + (width/2), -playerList.get(0).pos.y + (height/2));
//}

void keyPressed()
{
  if (keyCode < pressedKeys.length) pressedKeys[keyCode] = true;
}

void keyReleased()
{
  if (keyCode < pressedKeys.length) pressedKeys[keyCode] = false;
}

float osuPixelsToScreenPixels(float osuPixels)
{
  return width / 640 * osuPixels;
}
