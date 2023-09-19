/**
 Tron Iridum by Freddie (counselor)
 mod/continuation of Tron_Platinum (also by Freddie)
 
 (original Tron 2 by Alice and Matisse - TIC Session 1 Seniors 2019)
 
 MUSIC CREDITS:
 * Arsonist - Discovery
 * Kobaryo - Atmospherize
 * Andrew Hulshult - Davoth, the Dark Lord (DOOM Eternal OST) (cut version)
 * Fractal Dreamers - Paradigm Shift
 * penoreri - Reverenced Flower
 
 SOUND EFFECT CREDITS:
 * Universal UI/Menu Soundpack by Nathan Gibson
 
 
 -- TODO --
 use a PGraphics to center the scoreboard properly lol
 fix 3-player not tying on all player sizes
 dash button
 camera shake
 rebind controls to work with 6 players
 fix edge outline being ugly
 fix frames per move allowing self crash (store prev vel)
 
 */

import ddf.minim.*;

// game version
final String _VERSION = "1.5";

boolean[] keystatus = new boolean[256];
boolean[] prevKeystatus = new boolean[256];

Minim minim;
ArrayList<AudioPlayer> musicTracks = new ArrayList<AudioPlayer>();
ArrayList<AudioPlayer> sfxTracks = new ArrayList<AudioPlayer>();
final float CRASHSFX_VOLUME = 0;
ArrayList<AudioPlayer> crashSfxTracks = new ArrayList<AudioPlayer>();
AudioPlayer buttonConfirmTone;
AudioPlayer buttonSelectTone;

int currentMusic = 0;
String[] musicFilenames = new String[]
  {
  "Andrew Hulshult - Davoth, the Dark Lord (DOOM Eternal OST Gamerip).mp3",
  "Arsonist - Discovery.mp3",
  "Kobaryo - Atmospherize [feat. blaxervant].mp3",
  "Fractal Dreamers - Paradigm Shift.mp3",
  "penoreri - Reverenced Flower.mp3"
};

PFont subtitleFont;
PFont textFont;
PFont monoFont;

PImage logoImage;
PImage icon;

PGraphics gameBoard;
PGraphics effectLayer;
PGraphics hud;

ArrayList<CrashEffect> effectList = new ArrayList<CrashEffect>();

ArrayList<StatusMessage> statusMessages = new ArrayList<StatusMessage>();

PVector cameraOffset;
float hudScale;
float hudAlpha;

final color UI_COLOR_WHITE = color(250);
final color UI_BACKGROUND_COLOR = color(10);
final int UI_MARGIN = 95;
final int TEXT_BOX_ALPHA = 0;

ArrayList<Player> players;
Player winner;

int deaths = 0;
int rounds = 0;
boolean gameActive = false;
boolean settingsBoxVisible = false;

final int STARTING_EDGE_MARGIN = 90;

int currentPlayers = 2;
int size = 10;
int framesPerMove = 1;
boolean quandaleMode = true; // whether or not players will wrap around the screen or crash into edges
boolean enableSelfKO = true;
boolean enableFancyTrails = false;

void settings()
{
  fullScreen(P2D);
  PJOGL.setIcon("Icon.png");
}

void setup()
{
  // Fonts
  subtitleFont = loadFont("Consolas-Bold-12.vlw");
  textFont = loadFont("CenturyGothic-Bold-45.vlw");
  monoFont = loadFont("Consolas-Bold-22.vlw");

  logoImage = loadImage("TRON logo.png");

  // Display
  surface.setTitle("Tron " + _VERSION);

  noCursor();
  gameBoard = createGraphics(width, height);
  effectLayer = createGraphics(width, height);
  hud = createGraphics(width, height);
  cameraOffset = new PVector(0, 0);

  // Draw loading screen
  drawLoadingScreen();

  // Audio
  minim = new Minim(this);
  for (String filename : musicFilenames)
  {
    musicTracks.add(minim.loadFile(filename));
  }

  sfxTracks.add(minim.loadFile("double knockout.mp3"));
  sfxTracks.add(minim.loadFile("triple knockout.mp3"));
  sfxTracks.add(minim.loadFile("multi knockout with machina effect.mp3"));

  buttonConfirmTone = minim.loadFile("Modern7.mp3");
  buttonConfirmTone.setGain(2);

  buttonSelectTone = minim.loadFile("Abstract2.mp3");
  //buttonSelectTone = minim.loadFile("Modern7.mp3");
  buttonSelectTone.setGain(20);

  crashSfxTracks.add(minim.loadFile("KO_SFX_Astral_Prison.mp3"));
  crashSfxTracks.add(minim.loadFile("KO_SFX_Digital_Breakdown.mp3"));
  crashSfxTracks.add(minim.loadFile("KO_SFX_Black_Hole.mp3"));
  crashSfxTracks.add(minim.loadFile("KO_SFX_Default.mp3"));
  crashSfxTracks.get(0).setGain(CRASHSFX_VOLUME);
  crashSfxTracks.get(1).setGain(CRASHSFX_VOLUME);
  crashSfxTracks.get(2).setGain(CRASHSFX_VOLUME);
  crashSfxTracks.get(3).setGain(CRASHSFX_VOLUME);

  // Create players
  players = new ArrayList<Player>();
  players.add(new Player("Blue", color(0, 112, 255), new char[] {'W', 'A', 'S', 'D'}));
  players.add(new Player("Orange", color(255, 102, 0), new char[] {UP, LEFT, DOWN, RIGHT}));
  players.add(new Player("Red", color(255, 9, 0), new char[] {'Y', 'G', 'H', 'J'}));
  players.add(new Player("Green", color(5, 255, 3), new char[] {'O', 'K', 'L', ';'}));
  // Extended
  players.add(new Player("Pink", color(255, 8, 181), new char[] {'F', 'C', 'V', 'B'}));
  players.add(new Player("Yellow", color(255, 235, 8), new char[] {'=', '[', ']', '\\'}));

  winner = null;

  reset();
  startHudFX();

  // Pick a random track
  currentMusic = floor(random(musicTracks.size()));
  musicTracks.get(currentMusic).loop(); // background music

  println(roundToGrid(size));
}

void draw()
{
  gameBoard.beginDraw();
  effectLayer.beginDraw();
  effectLayer.clear();
  hud.beginDraw();
  hud.clear();

  if (rounds != 0)
  {
    for (int i = 0; i < currentPlayers; i++)
    {
      players.get(i).drawPlayer();
    }
  }

  // Game is ACTIVE
  if (gameActive)
  {
    for (int i = 0; i < currentPlayers; i++)
    {
      if (players.get(i).alive)
      {
        players.get(i).getInputs();

        if (frameCount % framesPerMove == 0)
        {
          players.get(i).move();
        }
      }
    }

    for (int i = 0; i < currentPlayers; i++)
    {
      if (players.get(i).alive && frameCount % framesPerMove == 0)
      {

        // Check for collision with another player
        for (int j = 0; j < currentPlayers; j++)
        {
          if (j != i &&
            players.get(j).alive &&
            players.get(j).pos.dist(players.get(i).pos) < 1)
          {
            deaths += 2;

            players.get(i).colorHit = players.get(j).c;
            players.get(j).colorHit = players.get(i).c;
            players.get(i).knockOut();
            players.get(j).knockOut();
            players.get(i).awardFrag();
            players.get(j).awardFrag();

            effectList.add(new CrashEffect(players.get(i).pos, size, color(255), true));

            playRandomCrashSound();
          }
        }

        // Otherwise, check for collision with a wall
        if (players.get(i).collision())
        {
          deaths++;

          // Play sound
          playRandomCrashSound();

          // Get which player they hit
          Player collider = getPlayerByColor(players.get(i).colorHit);

          // If they hit a player (instead of a wall)
          if (collider != null)
          {
            // If self-KO is enabled, OR they didn't hit themself
            if (enableSelfKO || collider != players.get(i))
            {
              // Award a frag
              collider.awardFrag();

              // DOUBLE KNOCKOUT
              if (collider.frags == 2)
              {
                playFromBeginning(sfxTracks.get(0));
              }
              // TRIPLE KNOCKOUT
              else if (collider.frags == 3)
              {
                playFromBeginning(sfxTracks.get(1));
              }
              // MULTI KNOCKOUT
              else if (collider.frags == 4)
              {
                sfxTracks.get(0).pause();
                sfxTracks.get(1).pause();
                playFromBeginning(sfxTracks.get(2));

                println("multi knockout");
              }
            }
          }

          // DOUBLE KNOCKOUT
          if (players.get(i).frags == 2)
          {
            playFromBeginning(sfxTracks.get(0));
          }
          // TRIPLE KNOCKOUT
          else if (players.get(i).frags == 3)
          {
            playFromBeginning(sfxTracks.get(1));
          }
          // MULTI KNOCKOUT
          else if (players.get(i).frags == 4)
          {
            sfxTracks.get(0).pause();
            sfxTracks.get(1).pause();
            playFromBeginning(sfxTracks.get(2));

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
      startHudFX();
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
    if (keySinglePressed(' ') || keySinglePressed(ENTER))
    {
      startNewRound();

      playFromBeginning(buttonConfirmTone);
    }

    // Next song
    if (keySinglePressed('.') && keystatus[SHIFT])
    {
      musicTracks.get(currentMusic).pause();
      musicTracks.get(currentMusic).rewind();

      currentMusic++;
      currentMusic = (int)notEvilMod(currentMusic, musicTracks.size());

      musicTracks.get(currentMusic).loop();

      statusMessages.add(new StatusMessage("Now playing: " + musicFilenames[currentMusic]));

      playFromBeginning(buttonSelectTone);
    }
    // Prev song
    if (keySinglePressed(',') && keystatus[SHIFT])
    {
      musicTracks.get(currentMusic).pause();
      musicTracks.get(currentMusic).rewind();

      currentMusic--;
      currentMusic = (int)notEvilMod(currentMusic, musicTracks.size());

      musicTracks.get(currentMusic).loop();

      statusMessages.add(new StatusMessage("Now playing: " + musicFilenames[currentMusic]));

      playFromBeginning(buttonSelectTone);
    }

    // Press brackets to reset stats
    if (keystatus['['] && keystatus[']'])
    {
      for (int i = 0; i < players.size(); i++)
      {
        players.get(i).resetStats();
      }
      rounds = 0;
      winner = null;

      playFromBeginning(buttonSelectTone);
      //reset();
    }

    // toggle player edge teleporting (holding shift will toggle self-KO)
    if (keySinglePressed('\\'))
    {
      if (keystatus[SHIFT])
      {
        enableSelfKO = !enableSelfKO;
      } else
      {
        quandaleMode = !quandaleMode;
      }
      settingsBoxVisible = true;

      playFromBeginning(buttonSelectTone);
    }

    // toggle effects (holding shift will toggle fancy trails)
    if (keySinglePressed('`'))
    {
      if (keystatus[SHIFT])
      {
        enableFancyTrails = !enableFancyTrails;
      } else
      {
      }
      settingsBoxVisible = true;

      playFromBeginning(buttonSelectTone);
    }

    // set players
    if (keySinglePressed('2'))
    {
      currentPlayers = 2;
      settingsBoxVisible = true;

      playFromBeginning(buttonSelectTone);
    }
    if (keySinglePressed('3'))
    {
      currentPlayers = 3;
      settingsBoxVisible = true;
      reset();

      playFromBeginning(buttonSelectTone);
    }
    if (keySinglePressed('4'))
    {
      currentPlayers = 4;
      settingsBoxVisible = true;
      reset();

      playFromBeginning(buttonSelectTone);
    }
    if (keySinglePressed('6'))
    {
      currentPlayers = 6;
      settingsBoxVisible = true;
      reset();

      playFromBeginning(buttonSelectTone);
    }

    // increase size (holding shift will increase frames per move)
    if (keySinglePressed('='))
    {
      if (keystatus[SHIFT])
      {
        if (framesPerMove < 3)
        {
          framesPerMove++;
          settingsBoxVisible = true;

          playFromBeginning(buttonSelectTone);
        }
      } else if (size < 25)
      {
        size += 5;
        settingsBoxVisible = true;

        playFromBeginning(buttonSelectTone);
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
          settingsBoxVisible = true;

          playFromBeginning(buttonSelectTone);
        }
      } else if (size > 5)
      {
        size -= 5;
        settingsBoxVisible = true;

        playFromBeginning(buttonSelectTone);
      }
    }

    // Draw settings box
    if (settingsBoxVisible)
    {
      drawSettingsBox();
    }

    // Draw status messages
    drawAndUpdateStatusMessages();
  }

  // Draw and process effects
  for (int i = 0; i < effectList.size(); i++)
  {
    effectList.get(i).update();
    effectList.get(i).drawEffect(effectLayer);

    if (effectList.get(i).isOver())
    {
      effectList.remove(i);
      i++;
    }
  }

  // Don't draw the border on title screen
  if (rounds != 0)
  {
    drawBorderLine();
  }

  // End drawing of PGraphics objects
  gameBoard.endDraw();
  //effectLayer.textSize(24);
  //effectLayer.text("num effects being processed: " + effectList.size(), 50, 50);
  effectLayer.endDraw();
  hud.endDraw();

  //background(UI_BACKGROUND_COLOR);

  // Draw game board
  pushMatrix();
  tint(255, 255); // undo tint??
  image(gameBoard, 0, 0);
  image(effectLayer, 0, 0);
  popMatrix();

  //updateGameBoardShakeFX();
  //pushMatrix();
  //translate(width / 2 + cameraOffset.x, height / 2 + cameraOffset.y);
  //image(gameBoard, -width / 2, -height / 2);
  //popMatrix();

  // Draw hud if game isn't active
  if (!gameActive)
  {
    updateHudFX();
    pushMatrix();
    translate(width / 2, height / 2);
    scale(hudScale);
    tint(255, hudAlpha);
    image(hud, -width / 2, -height / 2);
    popMatrix();
  }

  // Get previous keyboard state
  prevKeystatus = keystatus.clone();
}

void drawBorderLine()
{
  effectLayer.pushStyle();

  effectLayer.strokeWeight(size);
  if (quandaleMode)
  {
    // Draw more transparent, slowly strobing
    effectLayer.stroke(UI_COLOR_WHITE, sin(millis() / 450.0) * 40 + 90);
  } else
  {
    // Draw nearly opaque, slightly faster strobing
    effectLayer.stroke(UI_COLOR_WHITE, sin(millis() / 350.0) * 20 + 235);
  }
  effectLayer.strokeCap(PROJECT);

  // Left and right
  effectLayer.line(roundToGrid(0), roundToGrid(0), roundToGrid(0), roundToGrid(height));
  effectLayer.line(roundToGrid(width + size/2), roundToGrid(0), roundToGrid(width + size/2), roundToGrid(height));

  // Top and bottom
  effectLayer.line(roundToGrid(size), roundToGrid(0), width - roundToGrid(size), roundToGrid(0));
  effectLayer.line(roundToGrid(size), roundToGrid(height), width - roundToGrid(size), roundToGrid(height));

  effectLayer.popStyle();
}

void drawAndUpdateStatusMessages()
{
  final int XPOS = 50;
  final int YPOS = 150;
  final int MAX_MESSAGES = 10;

  if (statusMessages.size() > MAX_MESSAGES)
  {
    statusMessages.remove(0);
  }

  for (int i = 0; i < statusMessages.size(); i++)
  {

    hud.fill(255, map(millis() - statusMessages.get(i).timeCreated, 0, STATUS_MESSAGE_LIFETIME, 255, 40));
    hud.textAlign(LEFT);
    hud.textFont(monoFont);
    hud.text(statusMessages.get(i).message, XPOS, YPOS + i * 30);

    if (millis() > statusMessages.get(i).timeCreated + STATUS_MESSAGE_LIFETIME)
    {
      statusMessages.remove(i);
    }
  }
}


void startHudFX()
{
  // Starting values for hud effects
  hudAlpha = -100;
  hudScale = 2;
}

void updateHudFX()
{
  final int TARGET_ALPHA = 255;
  final float ALPHA_CHANGE_PERCENT = 0.07;
  final int TARGET_SCALE = 1;
  final float SCALE_CHANGE_PERCENT = 0.08;

  final float INTERPOLATION_THRESHOLD = 0.001;

  if (TARGET_ALPHA - hudAlpha > INTERPOLATION_THRESHOLD)
  {
    hudAlpha += (TARGET_ALPHA - hudAlpha) * ALPHA_CHANGE_PERCENT;
  } else
  {
    hudAlpha = TARGET_ALPHA;
  }

  if (hudScale - TARGET_SCALE > INTERPOLATION_THRESHOLD)
  {
    hudScale -= (hudScale - TARGET_SCALE) * SCALE_CHANGE_PERCENT;
  } else
  {
    hudScale = TARGET_SCALE;
  }
}


void drawTitleScreen()
{
  final int SHOW_START_BUTTON_TIME_MS = 25000;
  final float OSCILLATION_MAX_OFFSET = 20;
  final float OSCILLATION_RATE = 900.0;
  final float Y_OFFSET_AFTER_START_BUTTON = -height / 12 - subtitleFont.getSize() * 3;

  final float SHADOW_OSCILLATION_MAX_OFFSET = 10;
  final int NUM_SHADOWS = 3;
  final float SHADOW_ALPHA_DECREASE = 40;
  final int SHADOW_STARTING_ALPHA = 200;

  final int PADDING_FROM_YPOS = 18;

  float startYPos = height / 2 - subtitleFont.getSize() * 3;
  float yPos = startYPos;

  yPos += OSCILLATION_MAX_OFFSET * sin(millis() / OSCILLATION_RATE);

  // After enough time has passed, show a start button and raise up the logo
  if (millis() > SHOW_START_BUTTON_TIME_MS)
  {
    float titleYOffset = (millis() - SHOW_START_BUTTON_TIME_MS) / -9.0;

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
    hud.text("tron_iridium ver " + _VERSION + " by freddie", width/2, yPos + PADDING_FROM_YPOS + 150);
  }

  // Draw TRON logo
  hud.tint(UI_COLOR_WHITE);
  hud.imageMode(CENTER);
  hud.image(logoImage, width/2, yPos - PADDING_FROM_YPOS);

  // Draw shadows under logo
  for (int i = 0; i < NUM_SHADOWS; i++)
  {
    hud.tint(UI_COLOR_WHITE, SHADOW_STARTING_ALPHA - SHADOW_ALPHA_DECREASE * (i + 1));
    hud.image(logoImage, width/2, yPos - PADDING_FROM_YPOS - ((SHADOW_OSCILLATION_MAX_OFFSET / NUM_SHADOWS) * (i + 1) * sin(millis() / OSCILLATION_RATE)));
  }
  // Used to line things up visually
  //hud.line(0, height/2, width, height/2);
}



void playRandomCrashSound()
{
  int i = round(random(crashSfxTracks.size() - 1));
  playFromBeginning(crashSfxTracks.get(i));
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
  hud.text("Player size: ", boxCenterX - boxWidth / 2 + textMargin, textY);
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

  textY += textVerticalSpacing;
  hud.textAlign(LEFT);
  hud.text("Enable self-KO: ", boxCenterX - boxWidth / 2 + textMargin, textY);
  hud.textAlign(RIGHT);
  hud.text(str(enableSelfKO), boxCenterX + boxWidth / 2 - textMargin, textY);

  textY += textVerticalSpacing;
  hud.textAlign(LEFT);
  hud.text("Enable fancy trail: ", boxCenterX - boxWidth / 2 + textMargin, textY);
  hud.textAlign(RIGHT);
  hud.text(str(enableFancyTrails), boxCenterX + boxWidth / 2 - textMargin, textY);


  // Controls
  textY = boxCenterY + monoFont.getSize();

  hud.textFont(monoFont);
  hud.fill(UI_COLOR_WHITE);
  hud.textAlign(CENTER);
  hud.text(" - CONTROLS - ", boxCenterX, textY);
  textY += textVerticalSpacing;

  // Draw the control scheme for each of the current players
  for (int i = 0; i < currentPlayers; i++)
  {
    textY += textVerticalSpacing;

    hud.textAlign(LEFT);
    hud.fill(players.get(i).c);
    hud.text(players.get(i).name, boxCenterX - boxWidth / 2 + textMargin, textY);
    hud.textAlign(RIGHT);
    //hud.fill(UI_COLOR_WHITE);

    // A formatted string listing the control keys for the given player
    String controlsString = "";

    // Check for arrow keys
    if (java.util.Arrays.equals(players.get(i).controls, new char[] {UP, LEFT, DOWN, RIGHT}))
    {
      controlsString = "Arrow Keys";
    }
    // Otherwise, parse the controls into a formattted string
    else
    {
      for (int controlIndex = 0; controlIndex < players.get(i).controls.length; controlIndex++)
      {
        String k;
        if (players.get(i).controls[controlIndex] == LEFT) k = "Left";
        else if (players.get(i).controls[controlIndex] == '\'') k = "\'";
        //else if (players.get(i).controls[controlIndex] == RIGHT) k = "Right";
        else if (players.get(i).controls[controlIndex] == UP) k = "Up";
        else if (players.get(i).controls[controlIndex] == DOWN) k = "Down";
        else if (players.get(i).controls[controlIndex] == 222) k = "\'";
        else k = str(players.get(i).controls[controlIndex]);
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
  int xWidth = (int)map(currentPlayers, 2, 6, 310, 250);
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
  hud.fill(UI_COLOR_WHITE, TEXT_BOX_ALPHA);
  hud.rectMode(CENTER);
  hud.rect(width/2, yPos - (monoFont.getSize() / 3), paddedSpace, boxHeight * 1.5, 10);

  hud.textFont(monoFont);

  int i;
  for (i = 0; i < currentPlayers; i++)
  {
    hud.fill(players.get(i).c);

    // Draw name
    hud.textAlign(LEFT);
    hud.text(players.get(i).name, padding + paddingToCenter + (xSpacing * i), yPos);

    // Draw number of wins
    hud.textAlign(RIGHT);
    hud.text(players.get(i).winCount + " wins (" + players.get(i).totalFragCount + " KOs)", padding + paddingToCenter + (xSpacing * i) + xWidth, yPos);
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
    if (players.get(i).alive)
    {
      return players.get(i);
    }
  }

  return null;
}

Player getPlayerByColor(color c)
{
  for (int i = 0; i < currentPlayers; i++)
  {
    if (c == players.get(i).c)
    {
      return players.get(i);
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
  settingsBoxVisible = false;
  rounds++;
}

void reset()
{
  gameBoard.beginDraw();
  gameBoard.background(UI_BACKGROUND_COLOR);
  gameBoard.endDraw();

  deaths = 0;
  // 6 Player
  if (currentPlayers == 6)
  {
    players.get(0).restart(new PVector(roundToGrid(STARTING_EDGE_MARGIN), roundToGrid(STARTING_EDGE_MARGIN)), new PVector(0, size));
    players.get(1).restart(new PVector(roundToGrid(width - STARTING_EDGE_MARGIN), roundToGrid(STARTING_EDGE_MARGIN)), new PVector(0, size));
    players.get(2).restart(new PVector(roundToGrid(STARTING_EDGE_MARGIN), roundToGrid(height - STARTING_EDGE_MARGIN)), new PVector(0, -size));
    players.get(3).restart(new PVector(roundToGrid(width - STARTING_EDGE_MARGIN), roundToGrid(height - STARTING_EDGE_MARGIN)), new PVector(0, -size));
    players.get(4).restart(new PVector(roundToGrid(width / 2), roundToGrid(STARTING_EDGE_MARGIN)), new PVector(0, size));
    players.get(5).restart(new PVector(roundToGrid(width / 2), roundToGrid(height - STARTING_EDGE_MARGIN)), new PVector(0, -size));
  }
  // 4 Player
  else if (currentPlayers == 4)
  {
    players.get(0).restart(new PVector(roundToGrid(STARTING_EDGE_MARGIN), roundToGrid(STARTING_EDGE_MARGIN)), new PVector(size, 0));
    players.get(1).restart(new PVector(roundToGrid(width - STARTING_EDGE_MARGIN), roundToGrid(STARTING_EDGE_MARGIN)), new PVector(0, size));
    players.get(2).restart(new PVector(roundToGrid(STARTING_EDGE_MARGIN), roundToGrid(height - STARTING_EDGE_MARGIN)), new PVector(0, -size));
    players.get(3).restart(new PVector(roundToGrid(width - STARTING_EDGE_MARGIN), roundToGrid(height - STARTING_EDGE_MARGIN)), new PVector(-size, 0));


    // Should result in a tie game "multi-knockout" if blue self-kills on the same frame green hits blue
    //players.get(0).restart(new PVector(roundToGrid(STARTING_EDGE_MARGIN), roundToGrid(STARTING_EDGE_MARGIN)), new PVector(size, 0));
    //players.get(1).restart(new PVector(roundToGrid(width * .3), roundToGrid(STARTING_EDGE_MARGIN)), new PVector(-size, 0));
    //players.get(2).restart(new PVector(roundToGrid(STARTING_EDGE_MARGIN), roundToGrid(height - STARTING_EDGE_MARGIN)), new PVector(0, -size));
    //players.get(3).restart(new PVector(roundToGrid(width - STARTING_EDGE_MARGIN), roundToGrid(height - STARTING_EDGE_MARGIN - size)), new PVector(-size, 0));
  }
  // 3 Player
  else if (currentPlayers == 3)
  {
    players.get(0).restart(new PVector(roundToGrid(STARTING_EDGE_MARGIN), roundToGrid(height - STARTING_EDGE_MARGIN)), new PVector(size, 0));
    players.get(1).restart(new PVector(roundToGrid(width - STARTING_EDGE_MARGIN), roundToGrid(height - STARTING_EDGE_MARGIN)), new PVector(-size, 0));
    players.get(2).restart(new PVector(roundToGrid(width / 2), roundToGrid(STARTING_EDGE_MARGIN + size * 3)), new PVector(0, size));
  }
  // 2 Player is default
  else
  {
    players.get(0).restart(new PVector(roundToGrid(STARTING_EDGE_MARGIN), roundToGrid(height / 2)), new PVector(size, 0));
    players.get(1).restart(new PVector(roundToGrid(width - STARTING_EDGE_MARGIN), roundToGrid(height / 2)), new PVector(-size, 0));
  }
}

void drawLoadingScreen()
{
  background(0);
  fill(255);
  textFont(subtitleFont);
  textAlign(CENTER);
  text("loading . . . ", width / 2, height / 2);
  textAlign(LEFT);
  text("ver " + _VERSION, subtitleFont.getSize(), height - subtitleFont.getSize());
  textAlign(RIGHT);
  fill(255, 50);
  text(":)", width - subtitleFont.getSize(), height - subtitleFont.getSize());
}

void playFromBeginning(AudioPlayer ap)
{
  ap.rewind();
  ap.play();
}

float notEvilMod(float a, float b)
{
  return (a % b + b) % b;
}

/*
void startGameBoardShakeFX()
 {
 cameraOffset = new PVector(500, 500);
 }
 
 void updateGameBoardShakeFX()
 {
 final PVector TARGET_OFFSET = new PVector(0, 0);
 final float OFFSET_CHANGE_PERCENT = 0.9;
 
 final float INTERPOLATION_THRESHOLD = 1;
 
 if (cameraOffset.dist(TARGET_OFFSET) > INTERPOLATION_THRESHOLD)
 {
 cameraOffset.add((TARGET_OFFSET.sub(cameraOffset)).mult(1 + OFFSET_CHANGE_PERCENT));
 } else
 {
 cameraOffset.set(TARGET_OFFSET);
 }
 }
 */
