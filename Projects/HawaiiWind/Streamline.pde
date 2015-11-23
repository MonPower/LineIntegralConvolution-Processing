import de.fhpotsdam.unfolding.mapdisplay.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.tiles.*;
import de.fhpotsdam.unfolding.interactions.*;
import de.fhpotsdam.unfolding.ui.*;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.core.*;
import de.fhpotsdam.unfolding.mapdisplay.shaders.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.texture.*;
import de.fhpotsdam.unfolding.events.*;
import de.fhpotsdam.utils.*;
import de.fhpotsdam.unfolding.providers.*;

import g4p_controls.*;

int SQUARE_FLOW_FIELD_SZ = 193;
int WINDOWSIZE = SQUARE_FLOW_FIELD_SZ*3;
int n_xres = SQUARE_FLOW_FIELD_SZ;
int n_yres = SQUARE_FLOW_FIELD_SZ;
int MAXPARTICLE = n_xres*n_yres;
int numParticle = 0;
int generate = 0;
int windday = 1;
int [] pass = new int[n_xres*n_yres];

ArrayList particle = new ArrayList();
float[] pVectr = new float[2*n_xres*n_yres];
boolean windowNotExist = true;
boolean change = false;
GWindow newWindow;
GCustomSlider slider;
PImage map;
PImage wind;
PImage streamline;
PImage googlemap;
float opacity = 0.8;
double lat = 21.3115;
double lon = -157.7964;
int zoom_size = 7;
String map_type = "satellite";
PGraphics tintLayer;
UnfoldingMap unmap;

void setup() {
  background(0);
  map = loadImage("./image/hawaii.jpg");
  wind = loadImage("./image/wind.jpg");
  streamline = loadImage("./image/streamline.jpg");
  size(WINDOWSIZE,WINDOWSIZE);
  createSlider();
  readVector(n_xres, n_yres, pVectr);
  NormalizVectrs(n_xres, n_yres, pVectr);
  for (int i = 1; i <= n_xres; i++)
    for (int j = 1; j <= n_yres; j++)
    {
      Particle p = new Particle();
      p.x = i*3-1.5;
      p.y = j*3-1.5;
      if (i % 2 ==0 || j % 2 == 0 || i % 3 == 0 || j % 3 == 0)
        p.life = 0;
      particle.add(p);
      numParticle++;
    }
  for (int i = 0; i < pass.length; i++)
    pass[i] = 0;
  
  unmap = new UnfoldingMap(this);
  unmap.zoomAndPanTo(new Location(52.5f, 13.4f), 10);
  MapUtils.createDefaultEventDispatcher(this, unmap);
  googlemap = loadImage("http://maps.google.com/maps/api/staticmap?center=" + lat + "," + lon+ "&zoom=" + zoom_size + "&key=AIzaSyBq9EAjubBJETt31qL5o0uf5f4DszoVHcY&size=600x600&maptype=" + map_type + "&sensor=false","jpg");
  tintLayer = createGraphics(width, height, JAVA2D);
  tintLayer.beginDraw();
  tintLayer.background(0,180);
  tintLayer.endDraw();
}

void createSlider() {
  slider = new GCustomSlider(this, 0, 10, 150, 10, null);
  slider.setValue(0.8);
}

void readVector(int n_xres, int n_yres, float pVectr[]) {
  float vx, vy;
  int index;
  int line = 0;
  String data[] = null;
  switch(windday) {
    case 1: data = loadStrings("wind.txt"); break;
    case 2: data = loadStrings("wind1.txt"); break;
    default: data = loadStrings("wind.txt"); break;
    //case 3: String data[] = loadStrings("wind2.txt"); break;
    //case 4: String data[] = loadStrings("wind3.txt"); break;
    //case 5: String data[] = loadStrings("wind4.txt"); break;
  }
  println(windday);
  
  for (int i = n_xres-1; i >= 0; i--)
    for (int j = 0; j < n_yres; j++)
    {
      String number[] = split(data[line], ' ');
      vx = float(number[0]);
      vy = float(number[1]);
      index = (i * n_yres + j) << 1;
      pVectr[index] = vx;
      pVectr[index+1] = -vy;
      line++;
    }
}

void NormalizVectrs(int n_xres, int n_yres, float pVectr[]) {
  for(int i = 0; i < n_xres; i ++)
    for(int j = 0; j < n_yres; j ++)
      {
        int index = (i * n_yres + j) << 1;
        float vcMag = sqrt(pVectr[index] * pVectr[index] + pVectr[index + 1] * pVectr[index + 1]);
        float scale = (vcMag == 0.0f) ? 0.0f : 1.0f / vcMag;
        pVectr[index] *= scale;
        pVectr[index+1] *= scale;
      }
}


void draw() {
  if (keyPressed) {
    if ((key == 'm' || key == 'M') && windowNotExist) {
      createWindow();
      windowNotExist = false;
      keyPressed = false;
    }
    //else if (key == CODED) {
      else if (key == 'q') {
        windday++;
        readVector(n_xres, n_yres, pVectr);
        NormalizVectrs(n_xres, n_yres, pVectr);
        println(windday);
      }
      else if (key == 'w') {
        windday--;
        readVector(n_xres, n_yres, pVectr);
        NormalizVectrs(n_xres, n_yres, pVectr);
      }
    //}
    
  }
  //background(155);
  tint(255, 20);
  image(googlemap, 0, 0, width, height);
  //image(tintLayer, 0, 0);
  //unmap.draw();
  opacity = slider.getValueF();
  // fill(0,15);
  // rect(0,0,width,height);
  for (int i = 0; i < particle.size(); i++)
  {
    Particle p = (Particle)particle.get(i);
    int posx = (int)(p.x / 3);
    int posy = (int)(p.y / 3);
    //print(posx + " " + posy);
    if (p.x >= 193*3 || p.y >= 193*3 || p.x <= 0 || p.y <= 0)
    {
      p.life = 0;
      numParticle--;
    }
    if (p.life != 0) {
      int index = (posy * n_xres + posx) << 1;
      p.vx = pVectr[index];
      p.vy = pVectr[index+1];
      p.update();
      p.paint();
    }
    else if (numParticle < MAXPARTICLE){
      particle.remove(i);
      int m,n;
      if (generate % 2 == 0)
      {
        m = (int)random(0,5);
        n = (int)random(0,n_yres);
        generate++;
      }
      else {
        m = (int)random(0,n_xres);
        n = (int)random(0,5);
        generate++;
      }
      Particle q = new Particle();
      q.x = m*3-1.5;
      q.y = n*3-1.5;
      particle.add(q);
      numParticle++;
    }
  }
}

void streamline() {
  stroke(255);
  noFill();
  strokeJoin(ROUND);
  strokeCap(ROUND);
  strokeWeight(4);
  streamline();
  ArrayList<Float> xCoord = new ArrayList<Float>();
  ArrayList<Float> yCoord = new ArrayList<Float>();
  float x1, y1, x2, y2;
  float vx = 0;
  float vy = 0;
  float smin;
  int index;
  int index1;
  int m, n;
  for (int i = 0; i < n_xres; i+=20)
    for (int j = 0; j < n_yres; j+=20) {
      index = i*n_yres+j;
      if (pass[index] == 0) {
        pass[index] = 1;
        x1 = i*3 + 1.5;
        y1 = j*3 + 1.5;
        m = i;
        n = j;
        xCoord.add(x1);
        yCoord.add(y1);
        do{
          index1 = (n*n_yres+m) << 1;
          vx = pVectr[index1];
          vy = pVectr[index1+1];
          //println(vx + " " + vy);
          //println(x1 + " " + y1);
          smin = calcSmin(x1, y1, vx, vy);
          x2 = vx * smin + x1;
          y2 = vy * smin + y1;
         // println(x2 + " " + y2);
          if (x2 < 0 || x2 > width || y2 < 0 || y2 > height) {
            break;
          }
          else {
            xCoord.add(x2);
            yCoord.add(y2);
            x1 = x2;
            y1 = y2;
            m = (int)(x1 / 3);
            n = (int)(y1 / 3);
          }
          }
        while (true);
        beginShape();
        for (int k = 0; k < xCoord.size(); k++) {
          curveVertex(xCoord.get(k), yCoord.get(k));
        }
        endShape();
        xCoord.clear();
        yCoord.clear();
      }
    }
}

float calcSmin(float x1, float y1, float vx, float vy) {
  float stop, sleft, sright, sbottom, smin;
  smin = 1000;
  if (Math.abs(vy - 0) >= 0.0001) {
    stop = (3 * (int)(y1/3) - y1) * (1.0 / vy);
    sbottom = (3 * ((int)(y1/3)+1) - y1) * (1.0 / vy);
  }
  else {
    stop = sbottom = 1000;
  }
  
  if (Math.abs(vx - 0) >= 0.0001) {
    sleft = (3*(int)(x1/3) - x1) * (1.0 / vx);
    sright = ((3*((int)(x1/3)+1)) - x1) * (1.0 / vx);
  }
  else {
    sleft = sright = 1000;
  }
  if (stop < 0)
    stop = 1000;
  if (sbottom < 0)
    sbottom = 1000;
  if (sleft < 0)
    sleft = 1000;
  if (sright < 0)
    sright = 1000; 
  //println("Sright: " + sright); 
  //println("Sleft: " + sleft); 
  //println("Stop: " + stop); 
  //println("Sbottom: " + sbottom); 
  smin = Math.min(stop, sleft);
  smin = Math.min(smin, sright);
  smin = Math.min(smin, sbottom);
  //println("Smin: " + smin);
  smin += 0.004;
  return smin;
}
void createWindow() {
   newWindow = new GWindow(this, "Streamline-LIC", WINDOWSIZE+50, 0, WINDOWSIZE, WINDOWSIZE, false, JAVA2D);
   newWindow.addOnCloseHandler(this, "closeWindow");
   newWindow.addDrawHandler(this, "drawWindow");
   newWindow.addMouseHandler(this, "clickWindow");
   newWindow.setActionOnClose(GWindow.CLOSE_WINDOW);
}

void closeWindow(GWindow window) {
  windowNotExist = true;
}

void drawWindow(GWinApplet appc, GWinData data){
  appc.image(map,0,0);
  appc.tint(255,opacity*255);
  if (change == false)
    appc.image(wind,0,0);
  else if (change == true)
    appc.image(streamline,0,0);
  appc.noTint();
}

void clickWindow(GWinApplet appc, GWinData data, MouseEvent event) {
  if (event.getAction() == MouseEvent.PRESS)
    change = !change;
}

class Particle {
  float x, y;
  float vx, vy;
  int life;

  Particle() {
    life = 1;
  }

  void update() {
    x += vx;
    y += vy;
  }

  void paint() {
      noStroke();
      fill(255);
      ellipse(x,y,1.2,1.2);
  }
}
