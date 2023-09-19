abstract class Particle
{
  PVector pos;

  Particle(PVector pos)
  {
    this.pos = pos.copy();
  }

  abstract void update();

  abstract void render();

  abstract boolean exists();
}
