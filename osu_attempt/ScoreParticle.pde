class ScoreParticle extends Particle
{
  float startSize = 50;
  float endSize = 60;
  int endTime;
  int spawnTime;
  int fadeTime = 500;

  int type;

  ScoreParticle(PVector pos, int type)
  {
    super(pos);
    spawnTime = millis();
    endTime = millis() + fadeTime;

    this.type = type;
  }

  boolean exists()
  {
    return millis() < endTime;
  }

  void update()
  {
    pos.y--;
  }

  void render()
  {
    pushStyle();
    if (type == 50)
    {
      fill(color(240, 240, 10), map(millis(), spawnTime, endTime, 255, 0));
      textSize(map(millis(), spawnTime, endTime, startSize, endSize));
      text("50", pos.x, pos.y);
    }
    else if (type == 100)
    {
      fill(color(10, 255, 10), map(millis(), spawnTime, endTime, 255, 0));
      textSize(map(millis(), spawnTime, endTime, startSize, endSize));
      text("100", pos.x, pos.y);
    }
    else if (type == 300)
    {
      fill(color(10, 10, 255), map(millis(), spawnTime, endTime, 255, 0));
      textSize(map(millis(), spawnTime, endTime, startSize, endSize));
      text("300", pos.x, pos.y);
    }
    else if (type == 0)
    {
      fill(color(240, 15, 10), map(millis(), spawnTime, endTime, 255, 0));
      textSize(map(millis(), spawnTime, endTime, startSize, endSize));
      text("X", pos.x, pos.y);
    }

    popStyle();
  }
}
