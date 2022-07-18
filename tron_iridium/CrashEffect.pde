class CrashEffect
{
  final float GROW_PERCENTAGE = 3;
  final float GROW_RATE = .02;
  final int STROKE_WEIGHT = 5;
  
  PVector pos;
  float currentSize;
  float startSize;
  float endSize;
  
  color c;
  
  CrashEffect(PVector pos, float startSize, color c)
  {
    this.pos.set(pos);
    this.startSize = startSize;
    currentSize = startSize;
    endSize = startSize * GROW_PERCENTAGE;
    
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
