class StarParticle extends Particle
{
  final int SIZE = 20;
  
  PVector pos;
  
  StarParticle(PVector pos)
  {
    this.pos = pos.copy();
  }
  
  void render()
  {
    circle(pos.x, pos.y, SIZE);
  }
  
}
