/*
gameing01
 
 */
boolean[] pressedKey = new boolean[256];

final float GLOBAL_FRICTION = 0.8;

int[][] inputMethods = { //scheme is UP , LEFT , DOWN , RIGHT , FIRE
  {'W', 'A', 'S', 'D', ' '}, 
  {UP, LEFT, DOWN, RIGHT, ENTER}
};

Tank shrek, shrek2;

void setup() {
  //size(500, 500,P2D);
  fullScreen(P2D);
  background(253);

  shrek = new Tank(new PVector(200, 200), color(140, 50, 240), 0, 40, inputMethods[0]);
  shrek.enableTrails(true);

  shrek2 = new Tank(new PVector(800, 200), color(40, 150, 240), 0, 40, inputMethods[1]);
  shrek2.enableTrails(true);
}

void draw() {
  background(253);

  shrek.update();

  shrek2.update();

  shrek.render();

  shrek2.render();
}


// input handling

void keyPressed() {
  pressedKey[keyCode] = true;
}
void keyReleased() {
  pressedKey[keyCode] = false;
}


//custom color modification functions

color setAlpha(color mainColor, int alpha) {
  return color(red(mainColor), green(mainColor), blue(mainColor), alpha);
}
