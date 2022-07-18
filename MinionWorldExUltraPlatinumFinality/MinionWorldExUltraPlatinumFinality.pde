/*
Minion World
 by Freddie (counselor)
 
 DEMO PROJECT -- demonstrates how you can use Processing to make cool patterns!
 
 TIC Session 1 2022
 */

ArrayList<Minion> minions = new ArrayList<Minion>();

void setup()
{
  // Put the game in full screen, and hide the mouse cursor
  fullScreen();
  noCursor();
}

void draw()
{
  // Nothing happens until 10 ms
  if (millis() > 1000) {

    // Black background
    background(0);

    // Repeat 50 times and add a new minion where the mouse is
    // Set the speed, and point in a random direction
    float BASE_SPEED = 10;
    for (int i = 0; i < 50; i++)
    {
      minions.add(new Minion(new PVector(mouseX, mouseY), BASE_SPEED, random(0, TWO_PI)));
    }

    // Go through the list of minions and update all of them, and render them to the screen
    for (int i = 0; i < minions.size(); i++)
    {
      if (mousePressed)
      {
        minions.get(i).update(1.2);
      }
      else
      {
        minions.get(i).update(1);
      }
      minions.get(i).render();

      // If this minion is offscreen, remove them from the list (otherwise we will have infinite minions and run out of computer memory!)
      if (minions.get(i).isOffScreen())
      {
        minions.remove(i);
        i++;
      }
    }
  }
}
