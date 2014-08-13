int SQUARE_FLOW_FIELD_SZ = 193;
int n_xres = SQUARE_FLOW_FIELD_SZ;
int n_yres = SQUARE_FLOW_FIELD_SZ;
Particle particle[] = new Particle[n_xres * n_yres];
float[] pVectr = new float[2*n_xres*n_yres];

void setup() {

  size(193*3,193*3);
  readVector(n_xres, n_yres, pVectr);
  NormalizVectrs(n_xres, n_yres, pVectr);
  int index = 0;
  for (int i = 1; i <= n_xres; i++)
    for (int j = 1; j <= n_yres; j++)
    {
      Particle p = new Particle();
      p.x = i*3-1.5;
      p.y = j*3-1.5;
      if (i % 2 ==0 || j % 2 == 0)
        p.life = false;
      particle[index] = p;
      index++;
    }
  //noLoop();
}

void readVector(int n_xres, int n_yres, float pVectr[]) {

  float vx, vy;
  int index;
  int line = 0;
  String data[] = loadStrings("wind.txt");
  for (int j = 0; j < n_yres; j++)
    for (int i = 0; i < n_xres; i++)
    {
      String number[] = split(data[line], ' ');
      vx = float(number[0]);
      vy = float(number[1]);
      index = (j * n_xres + i) << 1;
      pVectr[index] = vx;
      pVectr[index+1] = vy;
      line++;
    }
}

void NormalizVectrs(int n_xres, int n_yres, float pVectr[]) {
  for(int j = 0; j < n_yres; j ++)
    for(int i = 0; i < n_xres; i ++)
      {
        int index = (j * n_xres + i) << 1;
        float vcMag = sqrt(pVectr[index] * pVectr[index] + pVectr[index + 1] * pVectr[index + 1]);
        float scale = (vcMag == 0.0f) ? 0.0f : 1.0f / vcMag;
        pVectr[index] *= scale;
        pVectr[index+1] *= scale;
      }
}


void draw() {
  background(0);
  for (int i = 0; i < particle.length; i++)
  {
    int posx = (int)(particle[i].x / 3);
    int posy = (int)(particle[i].y / 3);
    //print(posx + " " + posy);
    if (particle[i].x >= 193*3 || particle[i].y >= 193*3 || particle[i].x <= 0 || particle[i].y <= 0)
      particle[i].life = false;
    if (particle[i].life) {
      int index = ((n_yres-1-posy) * n_xres + posx) << 1;
      particle[i].vx = pVectr[index];
      particle[i].vy = pVectr[index+1];
      particle[i].update();
      particle[i].paint();
    }
  }
}

class Particle {
  float x, y;
  float vx, vy;
  boolean life;

  Particle() {
    life = true;
  }

  void update() {
    x += vx;
    y += vy;
  }

  void paint() {
      noStroke();
      fill(255);
      ellipse(x,y,2,2);
  }
}