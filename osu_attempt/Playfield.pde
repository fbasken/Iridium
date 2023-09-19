class Playfield
{
  PGraphics canvas;
  
  
  PVector getMousePosition()
  {
    return new PVector(mouseX * width / canvas.width, mouseY * height / canvas.height);
  }
}
