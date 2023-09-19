/// A particle effect that appears whenever a Player crashes
class CrashEffect
{
  final float GROW_PERCENTAGE = 7;
  final float GROW_RATE = .08;
  final int STROKE_WEIGHT = 5;
  
  PVector pos;
  float currentSize;
  float startSize;
  float endSize;
  
  color c;
  
  CrashEffect(PVector pos, float startSize, color c, boolean isSuper)
  {
    this.pos = pos.copy();
    this.startSize = startSize;
    currentSize = startSize;
    endSize = startSize * GROW_PERCENTAGE;
    
    if (isSuper)
    {
      endSize *= 3;
    }
    
    this.c = c;
  }
  
  boolean isOver()
  {
    return endSize - currentSize < 0.001;
  }
  
  void drawEffect(PGraphics pg)
  {
    pg.strokeWeight(STROKE_WEIGHT);
    pg.stroke(red(c), green(c), blue(c), map(currentSize, startSize, endSize, 255, 0));
    pg.noFill();
    pg.circle(pos.x, pos.y, currentSize);
  }
  
  void update()
  {
    // the magic equation
    currentSize += (endSize - currentSize) * GROW_RATE;
  }
}
