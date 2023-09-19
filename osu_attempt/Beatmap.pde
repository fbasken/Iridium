class Beatmap
{
  ArrayList<Circle> circleList;
  ArrayList<Integer> comboColors = new ArrayList<Integer>();

  int hitWindow50;
  int hitWindow100;
  int hitWindow300;

  AudioPlayer audio;

  Beatmap(String osuFile, String audioFile)
  {
    circleList = new ArrayList<Circle>();
    loadObjectsFromFile(osuFile);
    audio = minim.loadFile(audioFile);
  }

  void startFromBeginning()
  {
    audio.rewind();
    audio.pause();
  }



  void loadObjectsFromFile(String filename)
  {
    String[] lines = loadStrings(filename);

    OsuFileSection currentSection = OsuFileSection.GENERAL;


    int number = 1;
    int comboColorIndex = 0;

    // Parse file line-by-line
    for (int i = 0; i < lines.length; i++)
    {
      // If there is no object on this line, skip to next loine
      if (lines[i].length() == 0) continue;

      // Check if we are in a new section of the .osu file
      if (lines[i].equals("[Colours]"))
      {
        currentSection = OsuFileSection.COLOURS;
      } else if (lines[i].equals("[HitObjects]"))
      {
        currentSection = OsuFileSection.HITOBJECTS;
      }

      // Otherwise, we are in an existing section:
      else {

        // Create hit objects
        if (currentSection == OsuFileSection.HITOBJECTS)
        {
          // Split into string array
          String[] object = lines[i].split(",");

          // Parse into an object
          float x = osuPixelsToScreenPixels(float(object[0]));
          float y = osuPixelsToScreenPixels(float(object[1]));

          int hitTime = int(object[2]);

          int type = int(object[3]);


          // Circle
          if ((type & 1) != 0)
          {
            circleList.add(new Circle(new PVector(x, y), number, comboColors.get(comboColorIndex), hitTime));
          }

          // Slider
          else if ((type & 00000010) != 0)
          {
          }

          // Spinner
          else if ((type & 00001000) != 0)
          {
          }

          // NEW COMBO
          if ((type & 4) != 0)
          {
            number = 1;
            comboColorIndex++;
            comboColorIndex %= comboColors.size();
          } else
          {
            number++;
          }
        }
        // Create combo colors
        else if (currentSection == OsuFileSection.COLOURS)
        {
          println(lines[i]);
          // Split into string array
          String[] object = lines[i].split(":");

          // Split into RGB values
          String[] rgb = object[1].strip().split(",");

          comboColors.add(color(int(rgb[0]), int(rgb[1]), int(rgb[2])));
        }
      }
    }

    hitWindow50 = int(200 - 10 * OD);
    hitWindow100 = int(140 - 8 * OD);
    hitWindow300 = int(80 - 6 * OD);
  }

  void update()
  {
    if (getCurrentMapTime() > 0 && !audio.isPlaying())
    {
      audio.play();
      audio.cue(getCurrentMapTime());
    }

    for (Circle c : circleList)
    {
      c.update();
      if (c.checkClick() && abs(c.getRelativeTimeToHit()) < HIT_WINDOW_MS)
      {
        int scoreOnHit = calculateHitScore(getCurrentMapTime(), c.hitTime);
        particleList.add(new ScoreParticle(new PVector(mouseX, mouseY), scoreOnHit));
      }
    }
  }

  int calculateHitScore(int clickedTime, int hitTime)
  {
    int diff = hitTime - clickedTime;
    int score;
    
    if (abs(diff) > hitWindow50)
    {
      score = 0;
    }
    else if (abs(diff) > hitWindow100)
    {
      score = 50;
    }
    else if (abs(diff) > hitWindow300)
    {
      score = 100;
    }
    else
    {
      score = 300;
    }

    return score;
  }

  void render()
  {
    for (Circle c : circleList)
    {
      if (c.visible)
      {
        c.render();
      }
    }
  }
}

enum OsuFileSection
{
  GENERAL,
    EDITOR,
    METADATA,
    DIFFICULTY,
    EVENTS,
    TIMINGPOINTS,
    COLOURS,
    HITOBJECTS
}
