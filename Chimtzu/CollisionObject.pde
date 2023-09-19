/// An object that detects rectangular collisions
class CollisionObject
{
  PVector pos;
  float w;
  float h;

  CollisionObject(PVector pos, float w, float h)
  {
    this.pos = pos;
    this.w = w;
    this.h = h;
  }
  
  /// Returns true if the provided rectangle intersects this object
  boolean rectCollision(float rx, float ry, float rw, float rh)
  {
    return rx < pos.x + w &&
      rx + rw > pos.x &&
      ry < pos.y + h &&
      ry + rh > pos.y;
  }
}
