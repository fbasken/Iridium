//final float MAX_TARGET_DISTANCE =
class Camera
{

  PVector pos;
  PVector targetPos;
  float zoom;
  float targetZoom;
  float rotation;
  float targetRotation;
  
  Camera()
  {
    pos = new PVector(0, 0);
    targetPos = new PVector();
    rotation = 0;
  }

  void update()
  {
    pos.add(targetPos.copy().sub(pos).mult(.1));
    rotation += (targetRotation - rotation) *.01;
    targetRotation = notEvilMod(targetRotation, TWO_PI);
    zoom += (targetZoom - zoom) * .003;
  }

PVector getCameraWorldPos()
  {
    // Get screen space corner position
    PVector screenPos = new PVector(0, 0);

    // Subtract the camera position to undo the translation
    screenPos.add(_camera.pos.copy());

    // Divide to undo the scaling
    screenPos.div(_camera.zoom);

    return screenPos;
  }
  PVector getCameraCornerPos()
  {
    // Get screen space corner position
    PVector screenCornerPos = new PVector(width, height);

    // Subtract the camera position to undo the translation
    screenCornerPos.add(_camera.pos.copy());

    // Divide to undo the scaling
    screenCornerPos.div(_camera.zoom);

    return screenCornerPos;
  }
}
