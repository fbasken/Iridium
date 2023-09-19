class Camera
{
  PVector pos;
  PVector targetPos;
  float zoom;
  float targetZoom;
  
  Camera()
  {
    pos = new PVector(0, 0);
    targetPos = new PVector();
    zoom = 1;
    targetZoom = 1;
  }

  void update()
  {
    pos.add(targetPos.copy().sub(pos).mult(.1));
    zoom += (targetZoom - zoom) * .03;
  }

PVector getCameraWorldPos()
  {
    // Get screen space corner position
    PVector screenPos = new PVector(0, 0);

    // Subtract the camera position to undo the translation
    screenPos.add(pos.copy());

    // Divide to undo the scaling
    screenPos.div(zoom);

    return screenPos;
  }
  PVector getCameraCornerPos()
  {
    // Get screen space corner position
    PVector screenCornerPos = new PVector(width, height);

    // Subtract the camera position to undo the translation
    screenCornerPos.add(pos.copy());

    // Divide to undo the scaling
    screenCornerPos.div(zoom);

    return screenCornerPos;
  }
}
