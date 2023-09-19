class RingParticle extends Particle
{
  color c;
  float startSize;
  float endSize;
  int endTime;
  int spawnTime;

  RingParticle(PVector pos, color c, float startSize, float endSize, int fadeTime)
  {
    super(pos);
    spawnTime = millis();
    endTime = millis() + fadeTime;
    this.startSize = startSize;
    this.endSize = endSize;
    this.c = c;
  }

  boolean exists()
  {
    return millis() < endTime;
  }

  void update()
  {
  }

  void render()
  {
    pushStyle();
    stroke(c, map(millis(), spawnTime, endTime, 255, 0));
    noFill();
    circle(pos.x, pos.y, map(millis(), spawnTime, endTime, startSize, endSize));
    popStyle();
  }
}
