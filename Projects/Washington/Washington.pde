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
import java.awt.*;


int worldStart = 0;
int worldDay = 1;
int speed = 1;

float lat = 38.5f;
float lon = -79.5f;
float mapResult;

Table startTable;
Table endTable;
Table events;

int zoom_size = 6;
int[] changeState = new int[23];
int[] colorTable = new int[6];
int[] colorTable1 = new int[6];
int[] colorTable2 = new int[6];
int[] tempcolorTable = new int[6];
int[] month = new int[12];

String map_type = "roadmap";

ArrayList<Person> person;

GWindow newWindow;
GCustomSlider sliderStart;
GCustomSlider sliderDay;
GCustomSlider sliderSpeed;
GCheckbox unknow;
GCheckbox uninfected;
GCheckbox exposed;
GCheckbox asymptomatic;
GCheckbox symptomatic;
GCheckbox chronic;
GButton plus;
GButton minus;
GButton stop;

Location[] zoomLocation = new Location[9];
PImage[] zoomImage = new PImage[9];
boolean[] showState = new boolean[6];
boolean windowNotExist = true;
boolean firststop = true;
boolean controlPress = false;

UnfoldingMap map;
PImage showmap;

  
void setup() {
  size(1000, 700, OPENGL);
  startTable = loadTable("./data/startt2.csv", "header");
  endTable = loadTable("/data/endt2.csv", "header");
  events = loadTable("/data/eventst2.csv", "header");
  map = new UnfoldingMap(this);
  map.zoomAndPanTo(new Location(39f, -77.3f), 6);
  map.setZoomRange(4, 12);
  initiateStatus();
  createSlider();
  createCheckbox();
  createButton();
  person = new ArrayList<Person>();
    int d1, d2;
    int n;
    float d3, d4, d5, d6;
    TableRow row;
    int flag;
    int index = 0;
    for (int i = 0; i < startTable.getRowCount(); i++) {
      flag = 0;
      row = startTable.getRow(i);
      n = row.getInt("person");
      d1 = calcSecond(row.getString("start_time"));
      d2 = calcSecond(row.getString("end_time"));
      d3 = row.getFloat("latitude");
      d4 = row.getFloat("longitude");
      if (i-1 >= 0) {
        if (n == startTable.getRow(i-1).getInt("person")) {
          flag = 1;
          index = person.size() - 1;
        }
      }
      row = endTable.getRow(i);
      d5 = row.getFloat("latitude");
      d6 = row.getFloat("longitude");
      PLocation l = new PLocation(d1, d2, d3, d4, d5, d6);
      if (flag == 1) {
        person.get(index).location.add(l);
      }
      else {
        Person p = new Person(n);
        p.location.add(l);
        person.add(p);
      }
    }

    index = 0;
    int n1;
    String temptime;
    int time, dayfloat, oldi, newi;
    for (int i = 0; i < person.size(); i++) { 
      n = person.get(i).id;
out:
      for (int j = index; j < events.getRowCount(); j++) {
        row = events.getRow(j);
        n1 = row.getInt("recipient_id");
        if (n1 == n) {
          dayfloat = (int)(row.getFloat("dayfloat"));
          temptime = row.getString("time");
          time = calcSecond(temptime) - 86400 * dayfloat;
          oldi = row.getInt("oldifcode");
          oldi = changeState[oldi];
          newi = row.getInt("newifcode");
          newi = changeState[newi];
          Event e = new Event(time, dayfloat, oldi, newi);
          person.get(i).event.add(e);
          for (int k = j+1; k < events.getRowCount(); k++) {
            row = events.getRow(k);
            n1 = row.getInt("recipient_id");
            if (n1 != n) {
              index = k;
              break out;
            }
            else {
              dayfloat = (int)(row.getFloat("dayfloat"));
              temptime = row.getString("time");
              time = calcSecond(temptime) - 86400 * dayfloat;
              oldi = row.getInt("oldifcode");
              oldi = changeState[oldi];
              newi = row.getInt("newifcode");
              newi = changeState[newi];
              e = new Event(time, dayfloat, oldi, newi);
              person.get(i).event.add(e);
            }
          }
        }
      }
    }
    for (int i = 0; i < person.size(); i++) {
      person.get(i).initiate(-1);
    }

    strokeWeight(1.5);
}

void draw() {
  if (worldStart >= 86400) {
    worldStart = 86400;
  }
  mapResult = maptime(worldStart);
  showmap = zoomImage[map.getZoomLevel()-4];
  //map.draw();
  tint(mapResult, 20);
  image(showmap, 0, 0, width, height);
  noTint();
  //copy(showmap, 0, 0, 140, 35, 0, 0, 140, 35);
  drawClock();
  //fill(0, 0, 0, 150);
  //rect(0, 0, width, height);
  //rect(0, 0, 140, 35);
  if (mapResult >= 60 && mapResult <= 110) {
    tempcolorTable = colorTable2;
  }
  else if (mapResult > 110 && mapResult <= 160) {
    tempcolorTable = colorTable1;
  }
  else {
    tempcolorTable = colorTable;
  }
  noStroke();
  fill(tempcolorTable[0]);
  // line(865, 365, 895, 365);
  // ellipse(895, 365, 2.5, 2.5);
  rect(880, 358, 14, 14);
  fill(tempcolorTable[1]);
  // line(865, 415, 895, 415);
  // ellipse(895, 415, 2.5, 2.5);
  rect(880, 408, 14, 14);
  fill(tempcolorTable[2]);
  // line(865, 465, 895, 465);
  // ellipse(895, 465, 2.5, 2.5);
  rect(880, 458, 14, 14);
  fill(tempcolorTable[3]);
  // line(865, 515, 895, 515);
  // ellipse(895, 515, 2.5, 2.5);
  rect(880, 508, 14, 14);
  fill(tempcolorTable[4]);
  // line(865, 565, 895, 565);
  // ellipse(895, 565, 2.5, 2.5);
  rect(880, 558, 14, 14);
  fill(tempcolorTable[5]);
  // line(865, 615, 895, 615);
  // ellipse(895, 615, 2.5, 2.5);
  rect(880, 608, 14, 14);
  noStroke();
  //fill(mapResult, 220);
  //rect(0, 0, 140, 35);
  textSize(15);
  fill(255);
  text(calcDay(worldDay), 9, 15);
  //text(calcTime(worldStart), 45, 35);
  if (controlPress == true) {
    controlPress = false;
    tint(mapResult, 20);
    image(zoomImage[map.getZoomLevel()-4], 0, 0, width, height);
    noTint();
    for (int i = 0; i < person.size(); i++) {
      person.get(i).initiate(-1);
    }
  }
  for (int i = 0; i < person.size(); i++) {
    person.get(i).drawPerson();
    person.get(i).update();
  }
  worldStart+=speed;
  //sliderStart.setValue(1.0 * worldStart / 86400);
}


void createSlider() {
  sliderStart = new GCustomSlider(this, 800, 680, 200, 8, null);
  sliderStart.setValue(0);
  sliderDay = new GCustomSlider(this, 800, 660, 200, 8, null);
  sliderDay.setValue(0);
  sliderSpeed = new GCustomSlider(this, 800, 640, 200, 8, null);
  sliderSpeed.setValue(0.1);
}

void createButton() {
  plus = new GButton(this, 805, 570, 50, 20, "+");
  minus = new GButton(this, 805, 600, 50, 20, "-");
  stop = new GButton(this, 805, 540, 50, 20, "stop");
}

void closeWindow(GWindow window) {
  windowNotExist = true;
}

void drawWindow(GWinApplet appc, GWinData data){
}

void clickWindow(GWinApplet appc, GWinData data, MouseEvent event) {
}

void createCheckbox() {
  
  unknow = new GCheckbox(this, 900, 350, 100, 30, "Unknow");
  unknow.setSelected(true);
  unknow.setTextBold();
  uninfected = new GCheckbox(this, 900, 400, 100, 30, "Uninfected");
  uninfected.setSelected(true);
  uninfected.setTextBold();
  exposed = new GCheckbox(this, 900, 450, 100, 30, "Exposed");
  exposed.setSelected(true);
  exposed.setTextBold();
  asymptomatic = new GCheckbox(this, 900, 500, 100, 30, "Asymptomatic");
  asymptomatic.setSelected(true);
  asymptomatic.setTextBold();
  symptomatic = new GCheckbox(this, 900, 550, 100, 30, "Symptomatic");
  symptomatic.setSelected(true);
  symptomatic.setTextBold();
  chronic = new GCheckbox(this, 900, 600, 100, 30, "Chronic");
  chronic.setSelected(true);
  chronic.setTextBold();
}

void handleSliderEvents(GValueControl slider, GEvent event) {
  if (slider == sliderStart) {
    worldStart = (int)(86400 * sliderStart.getValueF());
  }
  else if (slider == sliderDay) {
    worldDay = (int)(365 * sliderDay.getValueF());
  }
  else if (slider == sliderSpeed) {
    speed = (int)(10 * sliderSpeed.getValueF());
  }
  controlPress = true;
}

void handleToggleControlEvents(GToggleControl checkbox, GEvent event) {
  if (checkbox == unknow) {
    showState[0] = !showState[0];
  }
  else if (checkbox == uninfected) {
    showState[1] = !showState[1];
  }
  else if (checkbox == exposed) {
    showState[2] = !showState[2];
  }
  else if (checkbox == asymptomatic) {
    showState[3] = !showState[3];
  }
  else if (checkbox == symptomatic) {
    showState[4] = !showState[4];
  }
  else if (checkbox == chronic) {
    showState[5] = !showState[5];
  }
  controlPress = true;
}

void handleButtonEvents(GButton button, GEvent event) {
  int nowZoomLevel;
  if (button == plus && map.getZoomLevel() < 12) {
    nowZoomLevel = map.getZoomLevel();
    map.zoomAndPanTo(zoomLocation[nowZoomLevel+1-4], nowZoomLevel+1);
    controlPress = true;
  }
  else if (button == minus && map.getZoomLevel() > 4) {
    nowZoomLevel = map.getZoomLevel();
    map.zoomAndPanTo(zoomLocation[nowZoomLevel-1-4], nowZoomLevel-1); 
    controlPress = true;
  }
  else if (button == stop && firststop) {
    noLoop();
    firststop = !firststop;
  }
  else if (button == stop && !firststop) {
    loop();
    firststop = !firststop;
  }
}


String calcDay(int day) {
  String d = "";
  int index = 0;
  for (int i = 0; i < 12; i++) {
    if ((day -= month[i]) < 0) {
      index = i;
      break;
    }
  }
  day += month[index]+1;
  index++;
  if (index < 10) {
    d = d + "0" + str(index) + "/";
  }
  else {
    d = d + str(index) + "/";
  }
  if (day < 10) {
    d = d + "0" + str(day) + "/";
  }
  else {
    d = d + str(day) + "/";
  }
  d += "2014";
  return d;
}

String calcTime(int time) {
  String t = "";
  int hour = time / 3600;
  int min = (time - hour * 3600) / 60;
  int sec = time - hour * 3600 - min * 60;
  String h, m, s;
  if (hour < 10) {
    h = "0" + str(hour);
  }
  else {
    h = str(hour);
  }
  if (min < 10) {
    m = "0" + str(min);
  }
  else {
    m = str(min);
  }
  if (sec < 10) {
    s = "0" + str(sec);
  }
  else {
    s = str(sec);
  }
  t = h + ":" + m + ":" + s;
  return t;
}

//function to convert string time to second
int calcSecond(String str) {
  int second = 0;
  int[] list = int(split(str, ":"));
  second += list[0] * 60 * 60;
  second += list[1] * 60;
  second += list[2];
  return second;
}

//function to initeante all the data
void initiateStatus() {
  changeState[0] = 0; changeState[1] = 3; changeState[2] = 5;
  changeState[3] = 2; 
  changeState[4] = 4; changeState[5] = 1;
  changeState[6] = 3; changeState[7] = 5; changeState[8] = 2;
  changeState[9] = 4; changeState[10] = 1; changeState[11] = 1;
  changeState[12] = 1; changeState[13] = 3; changeState[14] = 5;
  changeState[15] = 2; changeState[16] = 4; changeState[17] = 1;
  changeState[18] = 3; changeState[19] = 5; changeState[20] = 2;
  changeState[21] = 4; changeState[22] = 1;
  colorTable[0] = color(0, 0, 0); //initiate
  colorTable[1] = color(228, 26, 28); //uninfected
  colorTable[2] = color(221, 154, 14); //exposed
  colorTable[3] = color(77, 175, 74); //asymptomatic
  colorTable[4] = color(0, 0, 184); //symptomatic
  colorTable[5] = color(152, 78, 163); //chronic

  colorTable1[0] = color(1, 1, 1); //initiate
  colorTable1[1] = color(228, 26, 28); //uninfected
  colorTable1[2] = color(255, 144, 34); //exposed
  colorTable1[3] = color(98, 188, 95); //asymptomatic
  colorTable1[4] = color(73, 143, 200); //symptomatic
  colorTable1[5] = color(168, 96, 179); //chronic

  colorTable2[0] = color(2, 2, 2); //initiate
  colorTable2[1] = color(236, 86, 88); //uninfected
  colorTable2[2] = color(255, 161, 68); //exposed
  colorTable2[3] = color(122, 198, 119); //asymptomatic
  colorTable2[4] = color(99, 159, 208); //symptomatic
  colorTable2[5] = color(181, 119, 190); //chronic

  for (int i = 0; i < 6; i++) {
    showState[i] = true;
  }

  zoomLocation[0] = new Location(39f, -77.3f);
  zoomLocation[1] = new Location(39f, -77.3f);
  zoomLocation[2] = new Location(39f, -77.3f);
  zoomLocation[3] = new Location(39f, -77.3f);
  zoomLocation[4] = new Location(39f, -76.5f);
  zoomLocation[5] = new Location(38.8f, -77f);
  zoomLocation[6] = new Location(38.9f, -77f);
  zoomLocation[7] = new Location(38.9f, -77f);
  zoomLocation[8] = new Location(38.92f, -77.05f);

  zoomImage[0] = loadImage("./images/4.jpg");
  zoomImage[1] = loadImage("./images/5.jpg");
  zoomImage[2] = loadImage("./images/6.jpg");
  zoomImage[3] = loadImage("./images/7.jpg");
  zoomImage[4] = loadImage("./images/8.jpg");
  zoomImage[5] = loadImage("./images/9.jpg");
  zoomImage[6] = loadImage("./images/10.jpg");
  zoomImage[7] = loadImage("./images/11.jpg");
  zoomImage[8] = loadImage("./images/12.jpg");

  month[0] = 31; month[1] = 28; month[2] = 31;
  month[3] = 30; month[4] = 31; month[5] = 30;
  month[6] = 31; month[7] = 31; month[8] = 30;
  month[9] = 31; month[10] = 30; month[11] = 31;
}


//function to map the time to the brightness of map
float maptime(int t) {
  float trans = 255;
  if (t >= 0 && t <= 21600) {
    trans = map(t, 0, 21600, 60, 140);
  }
  else if (t > 21600 && t <= 43200) {
    trans = map(t, 21600, 43200, 140, 220);
  }
  else if (t > 43200 && t <= 64800) {
    trans = map(t, 43200, 64800, 220, 140);
  }
  else if (t > 64800 && t <= 86400) {
    trans = map(t, 64800, 86400, 140, 60);
  }
  return trans;
}

void drawClock() {
  int cx, cy;
  float secondsRadius;
  float minutesRadius;
  float hoursRadius;
  float clockDiameter;
  float second = 0;
  float minute = 0;
  float hour = 0;
  stroke(255);
   
  int radius = 40;
  secondsRadius = radius * 0.72;
  minutesRadius = radius * 0.60;
  hoursRadius = radius * 0.50;
  clockDiameter = radius * 1.8;
  cx = 47;
  cy = 55;
  fill(80);
  noStroke();
  ellipse(cx, cy, clockDiameter, clockDiameter);
  String tempTime = calcTime(worldStart);
  String[] smh = split(tempTime, ":");
  second = float(smh[2]);
  minute = float(smh[1]);
  hour = float(smh[0]); 
  // Angles for sin() and cos() start at 3 o'clock;
  // subtract HALF_PI to make them start at the top
  float s = map(second, 0, 60, 0, TWO_PI) - HALF_PI;
  float m = map(minute + norm(second, 0, 60), 0, 60, 0, TWO_PI) - HALF_PI;
  float h = map(hour + norm(minute, 0, 60), 0, 24, 0, TWO_PI * 2) - HALF_PI;
   
  // Draw the hands of the clock
  stroke(255);
  //strokeWeight(1);
  //line(cx, cy, cx + cos(s) * secondsRadius, cy + sin(s) * secondsRadius);
  strokeWeight(2);
  line(cx, cy, cx + cos(m) * minutesRadius, cy + sin(m) * minutesRadius);
  strokeWeight(4);
  line(cx, cy, cx + cos(h) * hoursRadius, cy + sin(h) * hoursRadius);
   
  // Draw the minute ticks
  strokeWeight(2);
  beginShape(POINTS);
  for (int a = 0; a < 360; a+=6) {
    float angle = radians(a);
    float x = cx + cos(angle) * secondsRadius;
    float y = cy + sin(angle) * secondsRadius;
    vertex(x, y);
  }
  endShape();
}

//class of person
class Person {
  int id;
  float x, y;
  float ox, oy;
  float vx, vy;
  int state;
  int startTime;
  int endTime;
  int index;
  boolean doDraw;
  ArrayList<PLocation> location;
  ArrayList<Event> event;

  Person(int n) {
    id = n;
    doDraw = true;
    location = new ArrayList<PLocation>();
    event = new ArrayList<Event>();
  }

  int getState(int n) {
    if (event.size() == 0 || n == 0)
      return 0;
    for (int i = 0; i < event.size(); i++) {
      if (n < event.get(i).day) {
        return event.get(i).oldstate;
      }
    }
    return event.get(event.size()-1).oldstate;
  }

  void initiate(int n) {
    ScreenPosition startPos;
    ScreenPosition endPos;
    int time1, time2;
    float distance;
    int flag = 0;
    if (n >= 0) {
      endTime = time2 = location.get(n).endTime;
      startTime = time1 = location.get(n).startTime;
      startPos = map.getScreenPosition(location.get(n).startLocation);
      endPos = map.getScreenPosition(location.get(n).endLocation);
      distance = dist(startPos.x, startPos.y, endPos.x, endPos.y);
      x = startPos.x;
      y = startPos.y;
      vx = (endPos.x - startPos.x) / (time2 - time1);
      vy  =(endPos.y - startPos.y) / (time2 - time1);
    }
    else {
      for (int i = 0; i < location.size(); i++) {
        time2 = location.get(i).endTime;
        time1 = location.get(i).startTime;
        if (worldStart <= time2 && worldStart >= time1) {
          startPos = map.getScreenPosition(location.get(i).startLocation);
          endPos = map.getScreenPosition(location.get(i).endLocation);
          distance = dist(startPos.x, startPos.y, endPos.x, endPos.y);
          if (distance < 30 * (map.getZoomLevel() / 4) || distance > 600*1.5) {
            doDraw = false;
            index = i;
            break;
          }
          distance = 1.0 * (worldStart - time1) / (time2 - time1);
          x = startPos.x + distance * (endPos.x - startPos.x);
          y = startPos.y + distance * (endPos.y - startPos.y);
          vx = (endPos.x - startPos.x) / (time2 - time1);
          vy  =(endPos.y - startPos.y) / (time2 - time1);
          startTime = worldStart;
          endTime = time2;
          index = i;
          doDraw = true;
          flag = 1;
          break;
        }
      }
      if (flag == 0) {
        doDraw = false;
      }
    }
  } 


  void update() {
    ox = x;
    oy = y;
    x += speed * vx;
    y += speed * vy;
    startTime += speed;
    if (startTime > endTime) {
      index++;
      if (index < location.size()) {
        int nextstartTime = location.get(index).startTime;
        if (nextstartTime <= startTime) {
          initiate(index);
        }
        else {
          vx = 0;
          vy = 0;
          endTime = nextstartTime;
          index--;
        }
      }
      else {
        doDraw = false;
      }
    }
  }

  void drawPerson() {
    noStroke();
    state = getState(worldDay);
    if (showState[state] && doDraw) {
     fill(tempcolorTable[state]);
     //println(10 * speed * vx);
     float distance = dist(ox, oy, x, y);
     if (distance < 4) {
      ellipse(x, y, 2.5, 2.5);
     }
     else {
      float pspeed = sqrt(vx*vx + vy*vy);
      for (int i = 1; i <= speed*pspeed/1.8; i++) {
        ellipse(ox+=1.8/pspeed*vx, oy+=1.8/pspeed*vy, 2.5, 2.5);
      }
      ellipse(x, y, 2.5, 2.5);
     }
     //strokeWeight(3);
     //line(x, y, x + speed * vx, y + speed * vy);
    }
  }
}


//class of PLocation
class PLocation {
  int startTime;
  int endTime;
  Location startLocation;
  Location endLocation;

  PLocation(int d1, int d2, float d3, float d4, float d5, float d6) {
    startTime = d1;
    endTime = d2;
    startLocation = new Location(d3, d4);
    endLocation = new Location(d5, d6);
  }
}


//class of Event
class Event {
  int time;
  int day;
  int oldstate;
  int newstate;

  Event(int t, int d, int o, int n) {
    time = t;
    day = d;
    oldstate = o;
    newstate = n;
  }
}
