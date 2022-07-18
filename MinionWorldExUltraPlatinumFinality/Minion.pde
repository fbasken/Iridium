/// A minion. Likes bananas
class Minion
{
  PVector pos;
  PVector vel;
  float speed;
  
  color c;
  int hue;
  
  int size = 10;
  
  /// Creates a new minion
  Minion(PVector pos, float speed, float dir)
  {
    this.pos = pos.copy();
    vel = PVector.fromAngle(dir).mult(speed);
    
  }
  
  /// Draws this minion to the screen
  void render()
  {
    // Use Hue/Saturation/Brightness mode-- this makes rainbow colors easier!
    colorMode(HSB, 360);
    
    // Draw the minion with the correct color, at the right position and size
    //stroke(c);
    //strokeWeight(size);
    //strokeCap(ROUND);
    //line(pos.x, pos.y, pos.x + vel.x / 7, pos.y + vel.y / 7);
    
    fill(c);
    noStroke();
    ellipseMode(CENTER);
    circle(pos.x, pos.y, size);
    
    
    
  }
  
  /// Updates this minion's position, velocity, and color
  void update(float speedMultiplier)
  {
    
    // Controls for the oscillation of the minion's speed
    float velOscillationSpeed = 500.0;
    float velOscillationAmplitudePercentage = .05;
    
    // Uses a sin function to smoothly oscillate between a fast and slow speed multiplier
    float currentVelMultiplier = 1 + (sin(millis() * ( 1 / velOscillationSpeed)) * velOscillationAmplitudePercentage);
    
    // Change the minion speed by the above multiplier
    vel.mult(currentVelMultiplier * speedMultiplier);
    
    // Rotate the minion very slightly, based on the above multiplier
    vel.rotate(0.01 * currentVelMultiplier);
    
    // How fast the colors change
    float colorOscillationSpeed = 100.0;
    
    // Set the minion's color based on their speed
    c = color((millis() / colorOscillationSpeed) % 360, 360, 360, map(vel.mag(), 9.95, 10.5, 100,255));
    
    // Change the minion's position
    pos.add(vel);
  }
  
  /// Returns true if this minion is located entirely off the edges of the screen
  boolean isOffScreen()
  {
    return (pos.x > width + size || pos.x < 0 - size || pos.y > height + size || pos.y < 0 - size);
  }
}
