int SQUARE_FLOW_FIELD_SZ = 193;
int n_xres = SQUARE_FLOW_FIELD_SZ;
int n_yres = SQUARE_FLOW_FIELD_SZ;
int MAXPARTICLE = n_xres*n_yres;
int numParticle = 0;
int generate = 0;
ArrayList particle = new ArrayList();
float[] pVectr = new float[2*n_xres*n_yres];

void setup() {
  background(0);
  size(193*3,193*3);
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
  fill(0,15);
  rect(0,0,width,height);
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
      int index = ((n_yres-1-posy) * n_xres + posx) << 1;
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
        m = (int)random(0,n_xres);
        n = (int)random(n_yres-5,n_yres);
        generate++;
      }
      else {
        m = (int)random(0,5);
        n = (int)random(0,n_yres);
        generate++;
      }
      Particle q = new Particle();
      q.x = m*3-1.5;
      q.y = n*3-1.5;
      particle.add(q);
      numParticle++;
    }
  }
  // println(particle[0].life);
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
      ellipse(x,y,1,1);
  }
}