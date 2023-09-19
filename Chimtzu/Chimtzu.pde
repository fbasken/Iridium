/*
Chimtzu
 by Freddie (counselor)
 
 TIC Session 3 2022
 
 
 TODO:
 Moving platforms
 Player-player collision
 
 */


// A list of type boolean (true/false) corresponding to each possible key code
// This list will track what key codes are being pressed (true means it's pressed, false means it's released)
boolean[] pressedKeys = new boolean[256];
boolean[] prevPressedKeys = new boolean[256];
boolean prevMousePressed;

// A list of platforms that make up the level
ArrayList<RectPlatform> levelPlatforms = new ArrayList<RectPlatform>();
ArrayList<Player> playerList = new ArrayList<Player>();

final float GRAVITY = 1;

PFont monoFont;

Camera _camera;

boolean editingMode = true;
boolean drawing = false;
PVector startingCorner;
PVector endingCorner;
SelectionOperation currentOperation = SelectionOperation.NONE;
final int gridSize = 32;

ArrayList<StatusMessage> statusMessages = new ArrayList<StatusMessage>();

PImage icon;

void setup()
{
  monoFont = loadFont("Consolas-Bold-18.vlw");

  icon = loadImage("melon.png");

  _camera = new Camera();

  fullScreen();
  //frameRate(10);
  //size(1600, 900);
  surface.setIcon(icon);

  playerList.add(new Player(new PVector(200, 200), 40, 55, color(249, 160, 180), new char[]{'W', 'S', 'A', 'D'}));
  //playerList.add(new Player(new PVector(width - 200, 200), 40, 55, color(180, 160, 249), new char[]{UP, DOWN, LEFT, RIGHT}));

  // FLOOR
  color floorColor = color(100, 120, 254);

  //levelPlatforms.add(new RectPlatform(-50, height * .9, width + 100, height * .2));
  levelPlatforms.add(new RectPlatform(0, height * .9, width, height * .1, floorColor));

  // WALLS AND CEILING
  levelPlatforms.add(new RectPlatform(-100, -100, 100, height, floorColor));
  levelPlatforms.add(new RectPlatform(width, -100, 100, height, floorColor));

  levelPlatforms.add(new RectPlatform(0, -100, width, 100, floorColor));


  levelPlatforms.add(new RectPlatform(200, height * .9 - 100, 200, 100, floorColor));

  levelPlatforms.add(new RectPlatform(400, height * .9 - 200, 100, 40, floorColor));

  levelPlatforms.add(new RectPlatform(570, height * .9 - 250, 100, 40, floorColor));

  levelPlatforms.add(new RectPlatform(width - 400, height * .9 - 100, 200, 100, floorColor));

  levelPlatforms.add(new RectPlatform(800, height * .6 - 200, 100, 40, floorColor));

  levelPlatforms.add(new RectPlatform(970, height * .6 - 250, 100, 40, floorColor));

  levelPlatforms.add(new RectPlatform(200, height * .4 - 100, 200, 100, floorColor));
}

void draw()
{
  if (keySinglePressed('1'))
  {
    editingMode = !editingMode;
  }

  if (keySinglePressed('='))
  {
    _camera.targetZoom *= 1.1;
  }
  if (keySinglePressed('-'))
  {
    _camera.targetZoom *= .9;
  }

  background(1);

  _camera.targetPos = playerList.get(0).pos.copy().mult(_camera.zoom).sub(width/2, height/2);
  _camera.update();

  // Scrolling !
  pushMatrix();
  translate(-_camera.pos.x, -_camera.pos.y);
  scale(_camera.zoom);

  for (int i = 0; i < levelPlatforms.size(); i++)
  {
    levelPlatforms.get(i).render();
  }

  for (int i = 0; i < playerList.size(); i++)
  {
    playerList.get(i).update();
    playerList.get(i).checkAndResolveCollisions(levelPlatforms);
    playerList.get(i).render();
  }

  if (editingMode)
  {

    if (keySinglePressed(ENTER))
    {
      saveLevelToFile();
    }
    if (keySinglePressed('L'))
    {
      selectInput("Select a level file:", "loadLevelFromFile");
    }
    // Delete platforms
    if (keySinglePressed((char)127) || keySinglePressed((char)8)) // delete key and backspace
    {
      int numDeleted = 0;
      for (int i = 0; i < levelPlatforms.size(); i++)
      {
        if (levelPlatforms.get(i).selected)
        {
          levelPlatforms.remove(i);
          i--;

          numDeleted++;
        }
      }

      statusMessages.add(new StatusMessage("Deleted " + numDeleted + " platforms"));
    }

    // Clear selection
    if (keySinglePressed('C')) {
      for (int i = 0; i < levelPlatforms.size(); i++)
      {
        levelPlatforms.get(i).selected = false;
      }
    }

    // If mouse is pressed
    if (mousePressed)
    {
      // Left click
      if (mouseButton == LEFT)
      {
        currentOperation = SelectionOperation.CREATE;

        if (startingCorner == null)
        {
          startingCorner = roundVectorToGrid(getWorldMousePos(), gridSize);
        }
        endingCorner = roundVectorToGrid(getWorldMousePos(), gridSize);

        // Calculate the selection area
        float newX = min(startingCorner.x, endingCorner.x);
        float newY = min(startingCorner.y, endingCorner.y);
        float newW = abs(startingCorner.x - endingCorner.x);
        float newH = abs(startingCorner.y - endingCorner.y);

        if (newW >= gridSize && newH >= gridSize)
        {

          fill(0, 255, 0, 160);
          drawCrosshair(roundVectorToGrid(getWorldMousePos(), gridSize), 16);

          rectMode(CORNER);
          fill(255, sin(millis() / 160.0) * 75 + 200);
          rect(newX, newY, newW, newH);
        } else
        {

          fill(255, 0, 0, 160);
          drawCrosshair(roundVectorToGrid(getWorldMousePos(), gridSize), 16);
        }
      } else if (mouseButton == RIGHT)
      {
        // Set the current position as the starting point if none has been selected yet
        if (startingCorner == null)
        {
          startingCorner = getWorldMousePos();
        }
        endingCorner = getWorldMousePos();

        // Calculate the selection area
        float newX = min(startingCorner.x, endingCorner.x);
        float newY = min(startingCorner.y, endingCorner.y);
        float newW = abs(startingCorner.x - endingCorner.x);
        float newH = abs(startingCorner.y - endingCorner.y);

        // If the selection region is larger than 5 pixels, it's a multi-selection
        if (startingCorner.dist(endingCorner) > 5)
        {
          currentOperation = SelectionOperation.SELECTMULTI;
          fill(200, 220, 255, 160);
          drawCrosshair(getWorldMousePos(), 16);
          stroke(200, 220, 255, sin(millis() / 160.0) * 100 + 155);
          rectMode(CORNER);
          strokeWeight(3);
          noFill();
          rect(newX, newY, newW, newH);
        }
        // Otherwise, the selection region is small-- it's a single-selection
        else
        {
          currentOperation = SelectionOperation.SELECTSINGLE;
          fill(200, 220, 255, 160);
          drawCrosshair(getWorldMousePos(), 16);
        }
      }
    } else
    {
      // If a selection exists
      if (startingCorner != null && endingCorner != null)
      {
        // Calculate the selection area
        float newX = min(startingCorner.x, endingCorner.x);
        float newY = min(startingCorner.y, endingCorner.y);
        float newW = abs(startingCorner.x - endingCorner.x);
        float newH = abs(startingCorner.y - endingCorner.y);

        // If in Create mode
        if (currentOperation == SelectionOperation.CREATE)
        {
          // If the selection is a large enough size
          if (newW >= gridSize && newH >= gridSize)
          {
            // Create a new RectPlatform
            levelPlatforms.add(new RectPlatform(newX, newY, newW, newH, color(170, 190, 255)));

            statusMessages.add(new StatusMessage("Created new platform {" + newX + ", " + newY + ", " + newW + ", " + newH + "}"));
          }
        } else
        {
          // If multi-selecting
          if (currentOperation == SelectionOperation.SELECTMULTI)
          {
            // Loop through all platforms, starting from the newest
            for (int i = levelPlatforms.size() - 1; i >= 0; i--)
            {
              // Find all platforms that intersect the selection
              if (levelPlatforms.get(i).rectCollision(newX, newY, newW, newH))
              {
                // Set them to all be selected
                levelPlatforms.get(i).selected = true;
              }
            }
          }
          // If single-selecting
          else if (currentOperation == SelectionOperation.SELECTSINGLE)
          {
            // Loop through all platforms, starting from the newest
            for (int i = levelPlatforms.size() - 1; i >= 0; i--)
            {
              // Find the newest platform that touches the mouse
              if (levelPlatforms.get(i).rectCollision(getWorldMousePos().x, getWorldMousePos().y, 0, 0))
              {
                // Toggle its selection state
                levelPlatforms.get(i).selected = !levelPlatforms.get(i).selected;
                break;
              }


              // If nothing was selected
              if (i == 0)
              {
                for (i = 0; i < levelPlatforms.size(); i++)
                {
                  levelPlatforms.get(i).selected = false;
                }

                break;
              }
            }
          }
        }
      }

      currentOperation = SelectionOperation.NONE;

      fill(255, 160);
      drawCrosshair(getWorldMousePos(), 24);

      startingCorner = null;
      endingCorner = null;
    }
  }

  popMatrix();

  if (editingMode)
  {
    drawVignette();


    fill(255);
    textAlign(LEFT);
    textFont(monoFont);
    text("Number of Platforms: " + levelPlatforms.size(), 50, 50);
    text("Current operation: " + currentOperation, 50, 100);
    text("Zoom Level: " + _camera.zoom + "x", 50, 150);
    drawStatusBar(50, 200);
  }

  // Get previous keyboard and mouse state
  prevPressedKeys = pressedKeys.clone();
  prevMousePressed = mousePressed;
}

void loadLevelFromFile(File selection)
{
  if (selection != null)
  {
    //JSONArray p = loadJSONArray("../saves/" + filename);
    JSONArray p = loadJSONArray(selection);

    levelPlatforms.clear();

    for (int i = 0; i < p.size(); i++)
    {
      JSONObject job = p.getJSONObject(i);

      levelPlatforms.add(new RectPlatform(job.getFloat("x"), job.getFloat("y"), job.getFloat("w"), job.getFloat("h"), (color)job.getInt("c")));
    }

    statusMessages.add(new StatusMessage("Loaded level from file: " + selection.getAbsolutePath()));
  }
}

void saveLevelToFile()
{
  JSONArray p = new JSONArray();

  for (int i = 0; i < levelPlatforms.size(); i++)
  {
    p.setJSONObject(i, levelPlatforms.get(i).toJSONObject());
  }

  String filename = "saves/" + "level-" + levelPlatforms.hashCode() + ".json";
  saveJSONArray(p, filename);

  statusMessages.add(new StatusMessage("Saved level to file: " + filename));
}


PVector roundVectorToGrid(PVector v, int factor)
{
  int x =  round(v.x / factor) * factor;
  int y =  round(v.y / factor) * factor;

  return new PVector(x, y);
}

void drawGrid()
{
  for (int i = 0; i < 0; i++)
  {
  }
}

void drawVignette()
{
  final int thickness = 20;

  for (int i = 0; i < thickness; i++)
  {
    rectMode(CENTER);
    noFill();
    strokeWeight(2);
    stroke(255, map(i, 0, thickness, 50, 0));
    rect(width/2, height/2, width - i, height - i);
  }
}

void drawCrosshair(PVector pos, int size)
{
  size /= _camera.zoom;
  rectMode(CENTER);
  noStroke();
  rect(pos.x, pos.y + size * .4, size * .1, size*.4);
  rect(pos.x, pos.y - size * .4, size * .1, size*.4);
  rect(pos.x  +size *.4, pos.y, size * .4, size*.1);
  rect(pos.x  -size *.4, pos.y, size * .4, size*.1);
}

boolean keySinglePressed(char k)
{
  return pressedKeys[k] && !prevPressedKeys[k];
}

boolean mouseSinglePressed()
{
  return mousePressed && !prevMousePressed;
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

PVector getWorldMousePos()
{
  return _camera.pos.copy().add(mouseX, mouseY).div(_camera.zoom);
}

void drawStatusBar(int x, int y)
{
  final int MAX_MESSAGES = 10;

  if (statusMessages.size() > MAX_MESSAGES)
  {
    statusMessages.remove(0);
  }

  for (int i = 0; i < statusMessages.size(); i++)
  {

    fill(255, map(millis() - statusMessages.get(i).timeCreated, 0, STATUS_MESSAGE_LIFETIME, 255, 40));
    textAlign(LEFT);
    textFont(monoFont);
    text(statusMessages.get(i).message, x, y + i * 30);

    if (millis() > statusMessages.get(i).timeCreated + STATUS_MESSAGE_LIFETIME)
    {
      statusMessages.remove(i);
    }
  }
}

enum SelectionOperation
{
  NONE,
    CREATE,
    SELECTSINGLE,
    SELECTMULTI
}

final int STATUS_MESSAGE_LIFETIME = 3000;

class StatusMessage
{
  String message;
  int timeCreated;

  StatusMessage(String message)
  {
    this.message = message;
    timeCreated = millis();
  }
}
