/*

 Tron Iridum by Freddie (counselor)
 mod of Tron_Platinum
 
 (original Tron 2 by Alice and Matisse - TIC Session 1 Seniors 2019)
 
 
 
 leaderboard
 settings menu
 dash button
 
 AUDIO CREDITS:
 * Arsonist - Discovery
 * Kobaryo - Atmospherize
 */

import ddf.minim.*;

Minim minim;
ArrayList<AudioPlayer> musicTracks = new ArrayList<AudioPlayer>();
ArrayList<AudioPlayer> sfxTracks = new ArrayList<AudioPlayer>();

PFont titleFont;
PFont textFont;
PFont monoFont;

final int STARTING_EDGE_MARGIN = 90;

final color UI_COLOR_WHITE = color(250);
final color UI_BACKGROUND_COLOR = color(10);

int textBoxDraws = 0;
final int TEXT_BOX_MAX_DRAWS = 16;
final int TEXT_BOX_ALPHA = 30;

Player[] players;
Player winner;

boolean[] keystatus = new boolean[256];
boolean[] prevKeystatus = new boolean[256];

int deaths = 0;
int rounds = 0;
boolean gameActive = false;

int currentPlayers = 4;
int size = 10;
int framesPerMove = 1;

void setup()
{
  // Fonts
  titleFont = loadFont("CenturyGothic-Bold-300.vlw");
  textFont = loadFont("CenturyGothic-45.vlw");
  monoFont = loadFont("Consolas-Bold-30.vlw");

  // Audio
  minim = new Minim(this);

  musicTracks.add(minim.loadFile("Arsonist - Discovery.mp3"));
  musicTracks.add(minim.loadFile("Kobaryo - Atmospherize [feat. blaxervant].mp3"));

  musicTracks.get(1).loop(); // background music

  sfxTracks.add(minim.loadFile("double knockout.mp3"));
  sfxTracks.add(minim.loadFile("triple knockout.mp3"));
  sfxTracks.add(minim.loadFile("multi knockout.mp3"));

  // Display
  fullScreen();
  background(UI_BACKGROUND_COLOR);

  // Create players
  players = new Player[4];
  players[0] = new Player("Blue", color(0, 112, 255), new char[] {'W', 'A', 'S', 'D'});
  players[1] = new Player("Orange", color(255, 102, 0), new char[] {UP, LEFT, DOWN, RIGHT});
  players[2]= new Player("Red", color(255, 9, 0), new char[] {'Y', 'G', 'H', 'J'});
  players[3]= new Player("Green", color(5, 255, 3), new char[] {'P', 'L', ';', 222});
  winner = null;

  //restart(); // immediately start, skipping title screen
}

void draw()
{
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
            players[i].frags++;
            players[j].frags++;
          }
        }

        // Otherwise, check for collision with a wall
        if (players[i].collision())
        {
          deaths++;

          // Get which player they hit
          Player collider = getPlayerByColor(players[i].colorHit);

          // If they exist
          if (collider != null)
          {
            // Award a frag
            collider.frags++;

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
              sfxTracks.get(2).rewind();
              sfxTracks.get(2).play();
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
            sfxTracks.get(2).rewind();
            sfxTracks.get(2).play();
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

      // Text box hasn't been drawn yet
      textBoxDraws = 0;
    }
  }

  // otherwise, game is INACTIVE
  else
  {

    // Only allow the text box to be drawn so many times
    if (textBoxDraws < TEXT_BOX_MAX_DRAWS)
    {
      if (winner == null)
      {
        // If it's the title screen
        if (rounds == 0)
        {
          fill(UI_COLOR_WHITE);
          textAlign(CENTER);
          textFont(titleFont, 300);
          text("TRON", width/2, height / 2 - 100);

          statusBox("Press SPACEBAR.", UI_COLOR_WHITE);
          textBoxDraws = 0;
        }
        // If it's not the title screen
        else
        {

          statusBox("Tie Game.", UI_COLOR_WHITE);
        }
      } else
      {
        statusBox(winner.name + " Wins!", winner.c);
      }

      textBoxDraws++;
    }

    // start game
    if (keySinglePressed(' '))
    {
      restart();
    }

    // set players
    if (keySinglePressed('2'))
    {
      currentPlayers = 2;
    }
    if (keySinglePressed('3'))
    {
      currentPlayers = 3;
    }
    if (keySinglePressed('4'))
    {
      currentPlayers = 4;
    }

    // set size
    if (keySinglePressed('=') && size < 25)
    {
      size += 5;
    }
    if (keySinglePressed('-') && size > 5)
    {
      size -= 5;
    }
  }

  // Get previous keyboard state
  prevKeystatus = keystatus.clone();
}

void statusScreen()
{
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

void statusBox(String text, color c)
{
  pushMatrix();

  // Draw box
  stroke(c, TEXT_BOX_ALPHA);
  strokeWeight(5);
  noFill();
  rectMode(CENTER);
  rect(width/2, height/2 - 15, width / 5, height / 12, 10);

  // Draw text
  fill(UI_COLOR_WHITE);
  textFont(textFont, 45);
  textAlign(CENTER);
  text(text, width/2, height/2);

  popMatrix();
}

void keyPressed()
{
  keystatus[keyCode] = true;
}

void keyReleased()
{
  keystatus[keyCode] = false;
}

boolean keySinglePressed(char k)
{
  return keystatus[k] && !prevKeystatus[k];
}

int roundToGrid(float num)
{
  return floor(num / size) * size;
}

void restart()
{
  background(UI_BACKGROUND_COLOR);

  gameActive = true;
  deaths = 0;
  rounds++;

  // 4 Player
  if (currentPlayers == 4)
  {
    players[0].restart(new PVector(roundToGrid(STARTING_EDGE_MARGIN), roundToGrid(STARTING_EDGE_MARGIN)), new PVector(size, 0));
    players[1].restart(new PVector(roundToGrid(width - STARTING_EDGE_MARGIN), roundToGrid(STARTING_EDGE_MARGIN)), new PVector(0, size));
    players[2].restart(new PVector(roundToGrid(STARTING_EDGE_MARGIN), roundToGrid(height - STARTING_EDGE_MARGIN)), new PVector(0, -size));
    players[3].restart(new PVector(roundToGrid(width - STARTING_EDGE_MARGIN), roundToGrid(height - STARTING_EDGE_MARGIN)), new PVector(-size, 0));


    // Should result in a tie game "multi-knockout" if no inputs are pressed
    //players[0].restart(new PVector(STARTING_EDGE_MARGIN, STARTING_EDGE_MARGIN), new PVector(size, 0));
    //players[1].restart(new PVector(width - STARTING_EDGE_MARGIN, STARTING_EDGE_MARGIN), new PVector(-size, 0));
    //players[2].restart(new PVector(STARTING_EDGE_MARGIN, height - STARTING_EDGE_MARGIN), new PVector(0, -size));
    //players[3].restart(new PVector(width- STARTING_EDGE_MARGIN, height - STARTING_EDGE_MARGIN), new PVector(0, size));
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
