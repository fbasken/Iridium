/*

 Tron Iridum by Freddie (counselor)
 mod of Tron_Platinum
 
 (original Tron 2 by Alice and Matisse - TIC Session 1 Seniors 2019)
 
 use a PGraphics to center the scoreboard properly lol
 fade in / out for hud objects
 fade in / out for TRON title
 fix 3-player not tying on all player sizes
 selfkills should not count as frags toggle option
 dash button
 crash particle effects
 
 AUDIO CREDITS:
 * Arsonist - Discovery
 * Kobaryo - Atmospherize
 * Andrew Hulshult - Davoth, the Dark Lord (DOOM Eternal OST) (cut version)
 */

import ddf.minim.*;

// game version
final String _VERSION = "1.21";

Minim minim;
ArrayList<AudioPlayer> musicTracks = new ArrayList<AudioPlayer>();
ArrayList<AudioPlayer> sfxTracks = new ArrayList<AudioPlayer>();
final float CRASHSFX_VOLUME = .17;
ArrayList<AudioPlayer> crashSfxTracks = new ArrayList<AudioPlayer>();

PFont titleFont;
PFont subtitleFont;
PFont textFont;
PFont monoFont;

PGraphics gameBoard;
PGraphics hud;

final int STARTING_EDGE_MARGIN = 90;

final color UI_COLOR_WHITE = color(250);
final color UI_BACKGROUND_COLOR = color(10);
final int UI_MARGIN = 95;
final int TEXT_BOX_ALPHA = 105;

Player[] players;
Player winner;

boolean[] keystatus = new boolean[256];
boolean[] prevKeystatus = new boolean[256];

int deaths = 0;
int rounds = 0;
boolean gameActive = false;
boolean statusBarVisible = false;

int currentPlayers = 4;
int size = 10;
int framesPerMove = 1;
boolean quandaleMode = false; // whether or not players will wrap around the screen or crash into edges

void setup()
{
  // Fonts
  titleFont = loadFont("CenturyGothic-Bold-300.vlw");
  subtitleFont = loadFont("Consolas-Bold-12.vlw");
  textFont = loadFont("CenturyGothic-45.vlw");
  monoFont = loadFont("Consolas-Bold-22.vlw");

  // Audio
  minim = new Minim(this);

  musicTracks.add(minim.loadFile("Arsonist - Discovery.mp3"));
  musicTracks.add(minim.loadFile("Kobaryo - Atmospherize [feat. blaxervant].mp3"));
  musicTracks.add(minim.loadFile("Andrew Hulshult - Davoth, the Dark Lord (DOOM Eternal OST Gamerip).mp3"));
  musicTracks.get(2).loop(); // background music

  sfxTracks.add(minim.loadFile("double knockout.mp3"));
  sfxTracks.add(minim.loadFile("triple knockout.mp3"));
  sfxTracks.add(minim.loadFile("multi knockout with machina effect.mp3"));

  crashSfxTracks.add(minim.loadFile("KO_SFX_Astral_Prison.mp3"));
  crashSfxTracks.add(minim.loadFile("KO_SFX_Digital_Breakdown.mp3"));
  crashSfxTracks.add(minim.loadFile("KO_SFX_Black_Hole.mp3"));
  crashSfxTracks.add(minim.loadFile("KO_SFX_Default.mp3"));

  // Display
  fullScreen();
  noCursor();
  gameBoard = createGraphics(width, height);
  hud = createGraphics(width, height);

  // Create players
  players = new Player[4];
  players[0] = new Player("Blue", color(0, 112, 255), new char[] {'W', 'A', 'S', 'D'});
  players[1] = new Player("Orange", color(255, 102, 0), new char[] {UP, LEFT, DOWN, RIGHT});
  players[2]= new Player("Red", color(255, 9, 0), new char[] {'Y', 'G', 'H', 'J'});
  players[3]= new Player("Green", color(5, 255, 3), new char[] {'P', 'L', ';', 222});
  winner = null;

  reset();
}

void draw()
{
  gameBoard.beginDraw();
  hud.beginDraw();
  hud.clear();

  if (rounds != 0)
  {
    for (int i = 0; i < currentPlayers; i++)
    {
      players[i].drawPlayer();
    }
  }

  // Game is ACTIVE
  if (gameActive)
  {
    for (int i = 0; i < currentPlayers; i++)
    {
      if (players[i].alive)
      {
        players[i].getInputs();

        if (frameCount % framesPerMove == 0)
        {
          players[i].move();
        }
      }
    }

    for (int i = 0; i < currentPlayers; i++)
    {
      if (players[i].alive && frameCount % framesPerMove == 0)
      {

        // Check for collision with another player
        for (int j = 0; j < currentPlayers; j++)
        {
          if (j != i &&
            players[j].alive &&
            players[j].pos.dist(players[i].pos) < 1)
          {
            deaths += 2;

            players[i].colorHit = players[j].c;
            players[j].colorHit = players[i].c;
            players[i].alive = false;
            players[j].alive = false;
            players[i].awardFrag();
            players[j].awardFrag();

            playRandomCrashSound();
          }
        }

        // Otherwise, check for collision with a wall
        if (players[i].collision())
        {
          deaths++;

          // Play sound
          playRandomCrashSound();

          // Get which player they hit
          Player collider = getPlayerByColor(players[i].colorHit);

          // If they exist
          if (collider != null)
          {
            // Award a frag
            collider.awardFrag();

            // DOUBLE KNOCKOUT
            if (collider.frags == 2)
            {
              sfxTracks.get(0).rewind();
              sfxTracks.get(0).play();
            }
            // TRIPLE KNOCKOUT
            else if (collider.frags == 3)
            {
              sfxTracks.get(1).rewind();
              sfxTracks.get(1).play();
            }
            // MULTI KNOCKOUT
            else if (collider.frags == 4)
            {
              sfxTracks.get(0).pause();
              sfxTracks.get(1).pause();
              sfxTracks.get(2).rewind();
              sfxTracks.get(2).play();

              println("multi knockout");
            }
          }

          // DOUBLE KNOCKOUT
          if (players[i].frags == 2)
          {
            sfxTracks.get(0).rewind();
            sfxTracks.get(0).play();
          }
          // TRIPLE KNOCKOUT
          else if (players[i].frags == 3)
          {
            sfxTracks.get(1).rewind();
            sfxTracks.get(1).play();
          }
          // MULTI KNOCKOUT
          else if (players[i].frags == 4)
          {
            sfxTracks.get(0).pause();
            sfxTracks.get(1).pause();
            sfxTracks.get(2).rewind();
            sfxTracks.get(2).play();

            println("multi knockout");
          }
        }
      }
    }


    // If one or fewer players are alive
    if (deaths >= currentPlayers - 1)
    {
      // Get the winner
      winner = getFirstAlivePlayer();

      if (winner != null)
      {
        winner.winCount++;
      }

      // Game is no longer active
      gameActive = false;
    }
  }

  // otherwise, game is INACTIVE
  else
  {
    // If nobody won the previous game, it was either a tie or the title screen
    if (winner == null)
    {
      // If it's the title screen
      if (rounds == 0)
      {
        drawTitleScreen();
      }
      // If it's a tie
      else
      {
        statusBox("Tie Game.", UI_COLOR_WHITE, height/2);
        drawScoreboard();
      }

      // Otherwise, the previous game had a winner
    } else
    {
      statusBox(winner.name + " Wins!", winner.c, height/2);
      drawScoreboard();
    }



    // Press spacebar to start game
    if (keySinglePressed(' '))
    {
      startNewRound();
    }

    // Press brackets to reset stats
    if (keySinglePressed('[') && keySinglePressed(']'))
    {
      for (int i = 0; i < players.length; i++)
      {
        players[i].resetStats();
      }
    }

    // toggle player edge teleporting
    if (keySinglePressed('\\'))
    {
      quandaleMode = !quandaleMode;
      statusBarVisible = true;
    }

    // set players
    if (keySinglePressed('2'))
    {
      currentPlayers = 2;
      statusBarVisible = true;
    }
    if (keySinglePressed('3'))
    {
      currentPlayers = 3;
      statusBarVisible = true;
    }
    if (keySinglePressed('4'))
    {
      currentPlayers = 4;
      statusBarVisible = true;
    }

    // increase size (holding shift will increase frames per move)
    if (keySinglePressed('='))
    {
      if (keystatus[SHIFT])
      {
        if (framesPerMove < 3)
        {
          framesPerMove++;
        }
      } else if (size < 25)
      {
        size += 5;
        statusBarVisible = true;
      }
    }
    // decrease size (holding shift will decrease frames per move)
    if (keySinglePressed('-'))
    {
      if (keystatus[SHIFT])
      {
        if (framesPerMove > 1)
        {
          framesPerMove--;
        }
      } else if (size > 5)
      {
        size -= 5;
        statusBarVisible = true;
      }
    }

    // Draw status bar
    if (statusBarVisible)
    {
      drawSettingsBox();
    }
  }
  
  // End drawing of PGraphics objects
  gameBoard.endDraw();
  hud.endDraw();

  // Draw game board
  image(gameBoard, 0, 0);

  // Draw hud if game isn't active
  if (!gameActive)
  {
    image(hud, 0, 0);
  }

  // Get previous keyboard state
  prevKeystatus = keystatus.clone();
}



void drawTitleScreen()
{
  final int SHOW_START_BUTTON_TIME_MS = 6000;
  final float OSCILLATION_MAX_OFFSET = 20;
  final float SHADOW_OSCILLATION_MAX_OFFSET = 7;
  final float OSCILLATION_RATE = 900.0;
  final float Y_OFFSET_AFTER_START_BUTTON = -height / 12 - subtitleFont.getSize() * 3;

  float startYPos = height / 2 + titleFont.getSize() / 2.5;
  float yPos = startYPos;

  yPos += OSCILLATION_MAX_OFFSET * sin(millis() / OSCILLATION_RATE);

  // After enough time has passed, show a start button and raise up the logo
  if (millis() > SHOW_START_BUTTON_TIME_MS)
  {
    float titleYOffset = (millis() - SHOW_START_BUTTON_TIME_MS) / -3.0;

    if (titleYOffset > Y_OFFSET_AFTER_START_BUTTON)
    {
      yPos += titleYOffset;
    } else
    {
      yPos += Y_OFFSET_AFTER_START_BUTTON;
    }

    //statusBox("Press SPACEBAR", UI_COLOR_WHITE, height / 2 + 100);
    statusBox("Press SPACEBAR", color(255, map(yPos, startYPos, startYPos + Y_OFFSET_AFTER_START_BUTTON - OSCILLATION_MAX_OFFSET, 0, 255)), height / 2 + 100);

    hud.fill(UI_COLOR_WHITE);
    hud.textAlign(LEFT);
    hud.textFont(subtitleFont);
    hud.text("tron_iridium ver " + _VERSION + " by freddie", width/2, yPos + 18);
  }

  // Draw TRON logo
  hud.fill(UI_COLOR_WHITE);
  hud.textAlign(CENTER);
  hud.textFont(titleFont);
  hud.text("TRON", width/2, yPos - 18);
  hud.fill(UI_COLOR_WHITE, 130);
  hud.text("TRON", width/2, yPos - 18 - (SHADOW_OSCILLATION_MAX_OFFSET * sin(millis() / OSCILLATION_RATE)));

  // Used to line things up visually
  //hud.line(0, height/2, width, height/2);
}



void playRandomCrashSound()
{
  int i = round(random(crashSfxTracks.size() - 1));
  crashSfxTracks.get(i).rewind();
  crashSfxTracks.get(i).setGain(CRASHSFX_VOLUME); // doesn't work i dont think

  crashSfxTracks.get(i).play();
}

void drawSettingsBox()
{
  // Upper and lower padding of the status box
  int upperPadding = UI_MARGIN;
  int lowerPadding = UI_MARGIN * 3 ;
  // Available space on the side  of the screen (height of screen, minus the top and bottom padding)
  int paddedSpace = height - (upperPadding + lowerPadding);

  // Size and position
  int boxWidth = (int)(width * .2);
  int boxCenterX = width - UI_MARGIN -  boxWidth / 2;
  int boxCenterY = height / 2;


  // Draw box
  hud.stroke(255);
  hud.strokeWeight(5);
  hud.fill(UI_COLOR_WHITE, TEXT_BOX_ALPHA);
  hud.rectMode(CENTER);
  hud.rect(boxCenterX, boxCenterY, boxWidth, paddedSpace, 10);

  // Margins of the text inside the box
  int textMargin = 30;

  // How far apart each line of text is
  int textVerticalSpacing = 30;

  // Y position of a line of text
  int textY = boxCenterY - paddedSpace / 2 + monoFont.getSize() + textMargin;

  // Settings
  hud.textFont(monoFont);
  hud.fill(UI_COLOR_WHITE);
  hud.textAlign(CENTER);
  hud.text(" - SETTINGS - ", boxCenterX, textY);
  textY += textVerticalSpacing;

  textY += textVerticalSpacing;
  hud.textAlign(LEFT);
  hud.text("Players: ", boxCenterX - boxWidth / 2 + textMargin, textY);
  hud.textAlign(RIGHT);
  hud.text(currentPlayers, boxCenterX + boxWidth / 2 - textMargin, textY);

  textY += textVerticalSpacing;
  hud.textAlign(LEFT);
  hud.text("Player Size: ", boxCenterX - boxWidth / 2 + textMargin, textY);
  hud.textAlign(RIGHT);
  hud.text(size, boxCenterX + boxWidth / 2 - textMargin, textY);

  textY += textVerticalSpacing;
  hud.textAlign(LEFT);
  hud.text("Frames per move: ", boxCenterX - boxWidth / 2 + textMargin, textY);
  hud.textAlign(RIGHT);
  hud.text(framesPerMove, boxCenterX + boxWidth / 2 - textMargin, textY);

  textY += textVerticalSpacing;
  hud.textAlign(LEFT);
  hud.text("Edge-teleporting: ", boxCenterX - boxWidth / 2 + textMargin, textY);
  hud.textAlign(RIGHT);
  hud.text(str(quandaleMode), boxCenterX + boxWidth / 2 - textMargin, textY);

  textY = boxCenterY + monoFont.getSize();

  // Controls
  hud.textFont(monoFont);
  hud.fill(UI_COLOR_WHITE);
  hud.textAlign(CENTER);
  hud.text(" - CONTROLS - ", boxCenterX, textY);
  textY += textVerticalSpacing;

  for (int i = 0; i < players.length; i++)
  {
    textY += textVerticalSpacing;

    hud.textAlign(LEFT);
    hud.fill(players[i].c);
    hud.text(players[i].name, boxCenterX - boxWidth / 2 + textMargin, textY);
    hud.textAlign(RIGHT);
    //hud.fill(UI_COLOR_WHITE);

    // A formatted string listing the control keys for the given player
    String controlsString = "";

    // Check for arrow keys
    if (java.util.Arrays.equals(players[i].controls, new char[] {UP, LEFT, DOWN, RIGHT}))
    {
      controlsString = "Arrow Keys";
    }
    // Otherwise, parse the controls into a formattted string
    else
    {
      for (int controlIndex = 0; controlIndex < players[i].controls.length; controlIndex++)
      {
        String k;
        if (players[i].controls[controlIndex] == LEFT) k = "Left";
        else if (players[i].controls[controlIndex] == RIGHT) k = "Right";
        else if (players[i].controls[controlIndex] == UP) k = "Up";
        else if (players[i].controls[controlIndex] == DOWN) k = "Down";
        else if (players[i].controls[controlIndex] == 222) k = "\'";
        else k = str(players[i].controls[controlIndex]);
        controlsString += "  " + k;
      }
    }
    hud.text(controlsString, boxCenterX + boxWidth / 2 - textMargin, textY);
  }
}

void drawScoreboard()
{
  // Space on each side
  int padding = UI_MARGIN / 2;

  // Available space on the bottom of the screen (width of screen, minus the padding)
  int paddedSpace = width - (padding * 2);

  // Width of each scoreboard entry
  int xWidth = 310;
  int boxHeight = 30;
  float roundCounterSizePercent = .5;

  // Size of a division on the screen -- divide the available space by the number of players, plus an extra partial division for the round counter
  int xSpacing = (int)(paddedSpace / (currentPlayers + roundCounterSizePercent));

  // How far to offset each text piece to center it within its own division
  int paddingToCenter = (xSpacing - xWidth) / 2;

  int yPos = height - padding;

  // Draw box
  hud.stroke(UI_COLOR_WHITE);
  hud.strokeWeight(5);
  //hud.fill(UI_COLOR_WHITE, TEXT_BOX_ALPHA);
  hud.noFill();
  hud.rectMode(CENTER);
  hud.rect(width/2, yPos - (monoFont.getSize() / 3), paddedSpace, boxHeight * 1.5, 10);

  hud.textFont(monoFont);

  int i;
  for (i = 0; i < currentPlayers; i++)
  {
    hud.fill(players[i].c);

    // Draw name
    hud.textAlign(LEFT);
    hud.text(players[i].name, padding + paddingToCenter + (xSpacing * i), yPos);

    // Draw number of wins
    hud.textAlign(RIGHT);
    hud.text(players[i].winCount + " wins (" + players[i].totalFragCount + " frags)", padding + paddingToCenter + (xSpacing * i) + xWidth, yPos);
  }


  // Draw round amount at half size
  hud.fill(UI_COLOR_WHITE);
  hud.textAlign(LEFT);
  hud.text("Rounds:", UI_MARGIN / 2 + paddingToCenter * roundCounterSizePercent + (xSpacing * i), yPos);
  hud.textAlign(RIGHT);
  hud.text(rounds, UI_MARGIN / 2 + paddingToCenter * roundCounterSizePercent + (xSpacing * i) + xWidth * roundCounterSizePercent, yPos);
}


Player getFirstAlivePlayer()
{
  for (int i = 0; i < currentPlayers; i++)
  {
    if (players[i].alive)
    {
      return players[i];
    }
  }

  return null;
}

Player getPlayerByColor(color c)
{
  for (int i = 0; i < currentPlayers; i++)
  {
    if (c == players[i].c)
    {
      return players[i];
    }
  }

  return null;
}

void statusBox(String text, color c, int yPos)
{
  hud.pushMatrix();

  // Draw box
  hud.stroke(c);
  hud.strokeWeight(5);
  hud.noFill();
  hud.rectMode(CENTER);
  hud.rect(width/2, yPos -15, width / 5, height / 12, 10);

  // Draw text
  hud.fill(UI_COLOR_WHITE);
  hud.textFont(textFont);
  hud.textAlign(CENTER);
  hud.text(text, width/2, yPos);

  hud.popMatrix();
}

void keyPressed()
{
  if (keyCode < keystatus.length) keystatus[keyCode] = true;
}

void keyReleased()
{
  if (keyCode < keystatus.length) keystatus[keyCode] = false;
}

boolean keySinglePressed(char k)
{
  return keystatus[k] && !prevKeystatus[k];
}

int roundToGrid(float num)
{
  return floor(num / size) * size;
}

void startNewRound()
{
  reset();
  gameActive = true;
  statusBarVisible = false;
  rounds++;
}

void reset()
{
  gameBoard.beginDraw();
  gameBoard.background(UI_BACKGROUND_COLOR);
  gameBoard.endDraw();

  deaths = 0;

  // 4 Player
  if (currentPlayers == 4)
  {
    players[0].restart(new PVector(roundToGrid(STARTING_EDGE_MARGIN), roundToGrid(STARTING_EDGE_MARGIN)), new PVector(size, 0));
    players[1].restart(new PVector(roundToGrid(width - STARTING_EDGE_MARGIN), roundToGrid(STARTING_EDGE_MARGIN)), new PVector(0, size));
    players[2].restart(new PVector(roundToGrid(STARTING_EDGE_MARGIN), roundToGrid(height - STARTING_EDGE_MARGIN)), new PVector(0, -size));
    players[3].restart(new PVector(roundToGrid(width - STARTING_EDGE_MARGIN), roundToGrid(height - STARTING_EDGE_MARGIN)), new PVector(-size, 0));


    // Should result in a tie game "multi-knockout" if blue self-kills on the same frame green hits blue
    //players[0].restart(new PVector(roundToGrid(STARTING_EDGE_MARGIN), roundToGrid(STARTING_EDGE_MARGIN)), new PVector(size, 0));
    //players[1].restart(new PVector(roundToGrid(width * .3), roundToGrid(STARTING_EDGE_MARGIN)), new PVector(-size, 0));
    //players[2].restart(new PVector(roundToGrid(STARTING_EDGE_MARGIN), roundToGrid(height - STARTING_EDGE_MARGIN)), new PVector(0, -size));
    //players[3].restart(new PVector(roundToGrid(width - STARTING_EDGE_MARGIN), roundToGrid(height - STARTING_EDGE_MARGIN - size)), new PVector(-size, 0));
  }
  // 3 Player
  else if (currentPlayers == 3)
  {
    players[0].restart(new PVector(roundToGrid(STARTING_EDGE_MARGIN), roundToGrid(height - STARTING_EDGE_MARGIN)), new PVector(size, 0));
    players[1].restart(new PVector(roundToGrid(width - STARTING_EDGE_MARGIN), roundToGrid(height - STARTING_EDGE_MARGIN)), new PVector(-size, 0));
    players[2].restart(new PVector(roundToGrid(width / 2), roundToGrid(STARTING_EDGE_MARGIN + size * 3)), new PVector(0, size));
  }
  // 2 Player is default
  else
  {
    players[0].restart(new PVector(roundToGrid(STARTING_EDGE_MARGIN), roundToGrid(height / 2)), new PVector(size, 0));
    players[1].restart(new PVector(roundToGrid(width - STARTING_EDGE_MARGIN), roundToGrid(height / 2)), new PVector(-size, 0));
  }
}
