float xpos=90;
float ypos=10;
float xvel=0;
float yvel=3.5;
final int pwidth = 10;
final int pheight = 10;
float xoffset=0;
int level = 1;
boolean onMovingPlatform = false;
int toKill = 0;
ArrayList<Platform> q = new ArrayList<Platform>(); //q contains all the platforms of each level
float[] endZone = {
  0, 120, //level 1
  0, 900, //level 2
  0, 900, //level 3
  0, 900, //level 4
  0, 900, //level 5
  0, 900, //level 6
  0, 900, //level 7
  0, 900, //level 8

};
ArrayList<RectParticle> particles = new ArrayList<RectParticle>();
Level l1, l2, l3, l4, l5, l6, l7, l8;
/* to create a new level
 -add endzone
 -add platforms
 -clearList q
 -create new Level
 -add level number into getLevel()
 */
boolean gameActive=true;
boolean switching = false;
PGraphics pg;
float r=0;
boolean jump=false;
PFont LeelawadeeFONT;
void setup() {
  //fullScreen();
  size(1600, 900);
  LeelawadeeFONT=createFont("LeelawadeeUI-Semilight-75.vlw", 75);
  pg=createGraphics(40, 40);
  q.add(new Platform(60, 400, 60, 20));
  q.add(new Platform(185, 330, 60, 20));
  q.add(new Platform(390, 800, 60, 20));
  q.add(new Platform(500, 780, 60, 20));
  q.add(new Platform(610, 800, 60, 20));
  q.add(new Platform(720, 780, 60, 20));
  q.add(new Platform(830, 800, 60, 20));
  q.add(new Platform(940, 780, 60, 20));
  q.add(new Platform(1050, 800, 60, 20));
  q.add(new Platform(1160, 780, 60, 20));
  q.add(new Platform(1270, 800, 60, 20));
  q.add(new Platform(1380, 780, 60, 20));
  q.add(new Platform(1510, 720, 60, 20));
  q.add(new Platform(1400, 640, 60, 20));
  q.add(new Platform(1300, 600, 60, 20));
  q.add(new Platform(1170, 570, 60, 20));
  q.add(new Platform(1050, 540, 60, 20));
  q.add(new Platform(940, 500, 60, 20));
  q.add(new Platform(830, 470, 60, 20));
  q.add(new Platform(770, 400, 60, 20));
  q.add(new Platform(830, 330, 60, 20));
  q.add(new Platform(770, 260, 60, 20));
  q.add(new Platform(830, 190, 60, 20));
  q.add(new Platform(770, 120, 60, 20));
  q.add(new Platform(900, 60, 60, 20));
  q.add(new Platform(1060, 120, 60, 20));
  q.add(new Platform(1200, 100, 60, 20));
  q.add(new Platform(1360, 90, 250, 20));
  l1 = new Level(#FFA7EB, q);
  clearList(q);

  //level 2
  q.add(new Platform(0, 90, 150, 20));
  q.add(new Platform(200, 600, 60, 20));
  q.add(new Platform(200, 500, 60, 20));
  q.add(new Platform(200, 300, 60, 20));
  q.add(new Platform(200, 200, 60, 20));
  q.add(new Platform(200, 400, 60, 20));
  q.add(new Platform(330, 0, 20, 500));
  q.add(new Platform(420, 800, 60, 20));
  q.add(new Platform(570, 850, 60, 20));
  q.add(new Platform(700, 800, 60, 20));
  q.add(new Platform(810, 710, 60, 20));
  q.add(new Platform(690, 660, 60, 20));

  q.add(new Platform(600, 610, 60, 20));
  q.add(new Platform(600, 530, 60, 20));
  q.add(new Platform(600, 450, 60, 20));
  q.add(new Platform(600, 290, 60, 20));
  q.add(new Platform(600, 210, 60, 20));
  q.add(new Platform(600, 370, 60, 20));


  q.add(new Platform(750, 170, 60, 20));
  q.add(new Platform(860, 85, 60, 20));

  //final staircase
  q.add(new Platform(1180, 850, 60, 20));
  q.add(new Platform(1250, 770, 60, 20)); 
  q.add(new Platform(1320, 690, 60, 20)); 
  q.add(new Platform(1390, 610, 60, 20));
  q.add(new Platform(1460, 530, 60, 20));
  q.add(new Platform(1530, 450, 80, 20));
  l2= new Level (#F54545, q);

  clearList(q);

  //level 3
  q.add(new Platform(0, 450, 120, 20));
  q.add(new Platform(235, 550, 60, 20));
  q.add(new Platform(380, 550, 60, 20));
  q.add(new Platform(480, 480, 60, 20));
  q.add(new Platform(360, 400, 60, 20));
  q.add(new Platform(480, 320, 60, 20));
  q.add(new Platform(360, 260, 60, 20));
  q.add(new Platform(480, 180, 60, 20));
  q.add(new Platform(480, 100, 60, 20));
  q.add(new MovingPlatform(600, 100, 60, 20, 2, 2, 100, true));
  //q.add(new MovingPlatform(1100, 350, 60, 20, 1, 1,100,false));

  q.add(new Platform(1000, 780, 60, 20));
  q.add(new Platform(1000, 700, 60, 20));

  q.add(new Platform(1200, 880, 60, 20));
  q.add(new Platform(1300, 800, 60, 20));
  q.add(new Platform(1300, 720, 60, 20));
  q.add(new Platform(1300, 640, 60, 20));
  q.add(new Platform(1300, 560, 60, 20));
  q.add(new Platform(1230, 470, 60, 20));
  q.add(new Platform(1090, 390, 60, 20));
  q.add(new Platform(1230, 310, 60, 20));
  q.add(new Platform(1160, 220, 60, 20));
  q.add(new Platform(1300, 165, 60, 20));


  q.add(new Platform(1440, 110, 160, 20));


  l3= new Level (#FFA600, q);
  clearList(q);

  //level 4
  q.add(new Platform(-10, 110, 140, 20));
  q.add(new MovingPlatform(180, 110, 60, 20, 0, 3, 150, true));
  q.add(new MovingPlatform(200, 550, 60, 20, 3, 0, 150, true));

  q.add(new MovingPlatform(700, 550, 60, 20, 0, 2, 150, true));
  q.add(new MovingPlatform(700, 500, 60, 20, 0, 2, 150, false));

  q.add(new MovingPlatform(800, 110, 60, 20, 3, 2, 75, true));
  q.add(new MovingPlatform(1330, 110, 60, 20, -3, 2, 75, true));

  l4= new Level (#EBF002, q);


  l5= new Level (#8EFF6C, q);
  l6= new Level (#3506C6, q);
  l7= new Level (#7C06C6, q);
  l8= new Level (#740693, q);
}
void draw() {
  //draw background and level

  noStroke();
  rectMode(CORNER);

  getLevel(level).render();

  //game active
  if (gameActive) {
    fill(255);
    textFont(LeelawadeeFONT);
    textSize(75);
    text(level, 1500, 75);


    //change position based on velocities
    while (getLevel(level).lvlcollide()) {
      if (yvel<0)
      {
        yvel=-1;

        ypos--;
        println("ypos--, still colliding?: "+l1.lvlcollide());
      } else { 
        yvel=1;

        while (getLevel(level).lvlcollide()) {
          ypos++;
          println("ypos--, still colliding?: "+l1.lvlcollide());
        }
        println("collided, yvel = "+yvel);
      }
    }

    xpos=xpos+xvel;
    ypos=ypos-yvel;

    //friction

    xvel=xvel*0.2;

    //test collisions


    //gravity
    yvel--;
    if (yvel < -19) {
      yvel = -19;
    }
    println(yvel);

    //Death
    if (ypos >height) {
      reset();
    }
    //if a level endzone even exists, then check to find out what that endzone is
    if (endZone.length>=level*2) {
      println("end zone is between "+endZone[(level*2)-2]+" and " + endZone [level*2-1]);

      if (xpos > width && (ypos > endZone[(level*2)-2]) && (ypos < endZone [level*2-1])) {
        switching=true;
      }
    }

    //input
    if (isw && (getLevel(level).lvlcollide())) {
      yvel=13; 
      jump=true;
    }

    if (isd) xvel=4.5;
    if (isa && xpos>0 +pwidth) xvel=-4.5;
  }

  //jump rotation
  if (jump) {
    r+=.09;
    if (r>HALF_PI) { //|| getLevel(level).lvlcollide()) {
      r=0;
      jump=false;
    }
  }

  //draw particles
  if (gameActive) {
    if (!onMovingPlatform) {
      particles.add(new RectParticle(xpos, ypos));
    }
    for (RectParticle p : particles) {
      p.display();
      if (p.life<0) {
        toKill++;
      }
    }
  }

  //kill particles
  for (int i = 0; i < toKill; i++) {
    particles.remove(0);
  }
  toKill = 0;



  //character
  pg.beginDraw();
  pg.clear();
  pg.fill(255);
  pg.translate(pwidth * 2, pheight * 2);
  pg.rotate(r);
  pg.rectMode(CENTER);
  pg.noStroke();
  pg.rect(0, 0, pwidth, pheight);
  pg.endDraw();
  image(pg, xpos-(pwidth * 2), ypos-(pwidth * 2.3));
  fill(255, 0, 0);
  ellipseMode(CENTER);
  // ellipse(xpos, ypos, 2, 2);

  if (switching) {
    switchLevel();
  }
}
boolean isw, isa, isd;
void keyPressed() {
  if (key=='w') {
    isw=true;
  }
  if (key=='d') {
    isd=true;
  }
  if (key=='a') {
    isa=true;
  }
  if (key==' ') {
    xpos = mouseX;
    ypos = mouseY;
    //gameActive=!gameActive;
  }
  if (key=='x') {
    switching = true;
  }
}

void keyReleased() {
  if (key=='w') {
    isw=false;
  }
  if (key=='d') {
    isd=false;
  }
  if (key=='a') {
    isa=false;
  }
}

void reset() {
  xpos=90;
  ypos=10;
  xvel=0;
  yvel=3.5;
}

void clearList(ArrayList list) {
  while (list.size()>0) {
    list.remove(0);
  }
}
Level getLevel(int l) {
  if (l==1) return l1;
  else if (l==2) return l2;
  else if (l==3) return l3;
  else if (l==4) return l4;
  else if (l==5) return l5;
  else if (l==6) return l6;
  else if (l==7) return l7;
  else if (l==8) return l8;

  else {
    //level = (level % (endZone.length/2));
    return l1;//getLevel(level);
  } //if level doesnt exist, use l1
}

int t = 0;
void switchLevel() {
  if (xoffset > width*-1) {
    gameActive=false;
    getLevel(level).render();
    getLevel(level+1).renderOffset();
    t+=20;
    xoffset = -1*((pow((t+800), 4))/(pow(800, 4)/20))+20;
    xpos = xoffset+(width+pwidth);
    image(pg, xpos-(pwidth * 2), ypos-(pwidth * 2.3));
  } else {
    xoffset =0;
    t=0;
    level++;
    gameActive=true;
    switching = false;
  }
}

class MovingPlatform extends Platform {
  float x1;
  float y1;

  float x2;
  float y2;

  float dx; // x speed
  float dy; // y speed
  float tempd;
  int range;
  int i;
  boolean dir;

  MovingPlatform(int tempx, int tempy, int tempw, int temph, float dx, float dy, int range, boolean dir) {
    super(tempx, tempy, tempw, temph);
    x1=x;
    y1=y;
    this.dx= dx;
    this.dy= dy;  //((x2-x1)/(y2-y1))*(dx);
    this.range = range;

    this.dir = dir;
    if (!dir) i = range-1;
    //this.xend=(int)(tempx+sqrt(pow(distance, 2)/(1+pow((dy/dx), 2))));
    //this.yend=(int)(tempy+sqrt(pow(distance, 2)/(1+pow((dx/dy), 2))));
  }

  void display() {
    fill(255);
    rect(x+xoffset, y, w, h);

    if (i >= range || i < 0) {
      dir = !dir;
    }
    if (dir) {
      x+=dx;
      y+=dy;
      i++;
    }
    if (!dir) {
      x-=dx;
      y-=dy;
      i--;
    }
  }

  void displayOffset() {
    fill(255);
    rect(x+xoffset+width, y, w, h);

    if (i >= range || i < 0) {
      dir = !dir;
    }
    if (dir) {
      x+=dx;
      y+=dy;
      i++;
    }
    if (!dir) {
      x-=dx;
      y-=dy;
      i--;
    }
  }

  boolean collideMoving() {
    if ( xpos + xvel + pwidth > x && xpos + xvel < x + w && ypos - yvel + pheight > y && ypos - yvel < y + h ) {

      //yvel = -1*dy;
      //xvel = dx;
      //ypos--;
      if (dir) {

        xpos += dx;
      } else {
        xpos-= dx;
      }

      onMovingPlatform = true;
      return true;
    } else {

      onMovingPlatform = false;
      return false;
    }
  }
}




class Platform {
  float x;
  float y;
  float w;
  float h;
  float osciSpeed = 10;
  float xOsci;
  float osciSize = 4;
  Platform(float tempx, float tempy, float tempw, float temph) {
    x=tempx;
    y=tempy;
    w=tempw;
    h=temph;
  }

  void display() {
    xOsci = map(x, 0, height, 0, 100);
    fill(255);
    rect(x+xoffset-(osciSize/2)*sin(frameCount/osciSpeed+xOsci), y-(osciSize/2)*sin(frameCount/osciSpeed+xOsci), w+osciSize*sin(frameCount/osciSpeed+xOsci), h+osciSize*sin(frameCount/osciSpeed+xOsci));
  }

  void displayOffset() {
    fill(255);
    rect(x+xoffset+width, y, w, h);
  }

  boolean collideMoving() {
    return false;
  }

  boolean collide() {
    if (xpos+xvel>x && xpos+xvel<x+w && ypos-yvel>y && ypos-yvel<y+h) {
      if (ypos>y+h+1) {
        xvel=0;
        return false;
      }
      return true;
    } else {
      return false;
    }
  }
} 


class Level {
  ArrayList<Platform> lvl = new ArrayList<Platform>(); //contains the levels platforms
  color bg;


  Level(color tempbg, ArrayList<Platform> templvl) {
    bg=tempbg;
    for (Platform p : templvl) {
      lvl.add(p); //receive a list of platforms
    }
  }
  void render() {
    fill(bg);
    rectMode(CORNER);
    rect(xoffset, 0, width, height);
    for (Platform p : lvl) {
      p.display();
    }
  }

  void renderOffset() {
    fill(bg);
    rectMode(CORNER);
    rect(xoffset+width, 0, width, height);
    for (Platform p : lvl) {
      p.displayOffset();
    }
  }

  boolean lvlcollide() {
    for (Platform p : lvl) {

      if (p.collide()) {
        return true;
      }
      p.collideMoving();
    }
    return false;
  }
}

class Particle {
  float x, y; //position of the particle
  color c; //color of the particle
  int size; //dimensions of the particle
  int life;
  Particle(float x, float y) {
    this.x=x;
    this.y=y;
  }
}

class RectParticle extends Particle {

  RectParticle (float x, float y) {
    super(x, y);
    c=color(255);
    size=10;
    life=10;
  }

  void display() {
    rectMode(CENTER);
    fill(255, 100);
    rect(x, y-5, size, size);
    life--;
  }
} 
