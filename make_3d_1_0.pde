//import megamu.mesh.*;

import igeo.*;
import igeo.p.*;
import igeo.io.*;
import igeo.gui.*;

import toxi.geom.*;
import toxi.geom.mesh2d.*;

import toxi.util.*;
import toxi.util.datatypes.*;

import toxi.processing.*;


Voronoi vor = new Voronoi(7000f);

//Delaunay deTri;

ArrayList<ISurface> grid = new ArrayList<ISurface>();
ArrayList<HTriangle> tris = new ArrayList<HTriangle>();
ArrayList<HEdge> edges=new ArrayList<HEdge>();
ArrayList<HConnection> connections=new ArrayList<HConnection>();
ArrayList<ICurve> tensionLine=new ArrayList<ICurve>();

IVec centerPoint=new IVec(0, 0, 0);

int fontSize=20;



int[] countLinks(int[][] links, int pt) {
  int[] l = new int[links.length];
  int p = 0;
  for (int i=0; i<links.length; i++) {
    if (links[i][0]==pt || links[i][1]==pt) {
      l[p] = links[i][0]+links[i][1]-pt;
      p++;
    }
  }
  return subset(l, 0, p);
}

int searchPoint(IVec pt1, HPoint[] pts) {
  for (int i=0; i<pts.length; i++) {
    if (pt1.dist2(pts[i].pos())<0.0001) 
      return i;
  }
  return -1;
}

void setup() {
  size(1000, 750, IG.GL);
  //  IG.updateRate(0.001);
  IG.bg(.9);
  IG.duration(300);
  IG.open("p-161124-1.3dm");
  IG.layer("Default").hide();
  IG.layer("Selected").hide();

  //Input points. The fixed points are defined by layer in .3dm file.
  IPoint[] ptsp = IG.layer("Selected").points();
  IPoint[] ptsfp = IG.layer("Fix").points();
  HPoint[] pts = new HPoint[ptsp.length+ptsfp.length];
  for (int i=0; i<ptsp.length; i++) {
    pts[i] = new HPoint(ptsp[i].pos());
    pts[i].fric(0.05);
  }
  for (int i=0; i<ptsfp.length; i++) {
    pts[ptsp.length+i] = new HPoint(ptsfp[i].pos());
    pts[ptsp.length+i].fix();
  }

  Vec2D[] ptst = new Vec2D[pts.length];
  for (int i=0; i<pts.length; i++) {
    ptst[i] = new Vec2D((float)pts[i].pos().x(), (float)pts[i].pos().y());
  }
  for (int i=0; i<pts.length; i++) {
    vor.addPoint(ptst[i]);
  }

  //  for (Triangle2D tri : vor.getTriangles()) {
  //    new ICurve(tri.a.x,tri.a.y,0,tri.b.x,tri.b.y,0);
  //    new ICurve(tri.a.x,tri.a.y,0,tri.c.x,tri.c.y,0);
  //    new ICurve(tri.b.x,tri.b.y,0,tri.c.x,tri.c.y,0);
  //  }

  boolean[][] dontLink = new boolean[pts.length][pts.length];
  for (ICurve link : IG.layer ("cross").curves()) {
    int pi1 = searchPoint(link.pt(0), pts);
    int pi2 = searchPoint(link.pt(1), pts);
    dontLink[pi1][pi2] = true;
    dontLink[pi2][pi1] = true;
  }

  boolean[][] linked = new boolean[pts.length][pts.length];
  int linkNum = 0;
  for (Triangle2D tri : vor.getTriangles ()) {
    int[] vt = new int[3];
    int p = 0;
    for (int i=0; i<pts.length; i++) {
      if (tri.a.distanceToSquared(ptst[i])<0.0001 || tri.b.distanceToSquared(ptst[i])<0.0001 || tri.c.distanceToSquared(ptst[i])<0.0001) {
        vt[p++] = i;
      }
    }
    if (p<3) continue;
    boolean cantLink = false;
    for (int i=0; i<3; i++) {
      if (dontLink[vt[i]][vt[(i+1)%3]]) {
        cantLink = true; 
        break;
      }
    }
    if (cantLink) continue;
    for (int i=0; i<3; i++) {
      linked[vt[i]][vt[(i+1)%3]] = true;
      linked[vt[(i+1)%3]][vt[i]] = true;
    }
    tris.add(new HTriangle(pts[vt[0]], pts[vt[1]], pts[vt[2]]));
  }



  int p = 0;
  ArrayList<int[]> linkt = new ArrayList<int[]>();
  for (int i=0; i<pts.length-1; i++) {
    for (int j=i+1; j<pts.length; j++) {
      if (linked[i][j]) {
        int[] t = {
          i, j
        };
        linkt.add(t);
      }
    }
  }
  int[][] links = new int[linkt.size()][];
  for (int i=0; i<links.length; i++) {
    links[i] = linkt.get(i);
  }
  //Build tension lines.
  for (int i=0; i<links.length; i++) {
    HPoint pt1 = pts[links[i][0]];
    HPoint pt2 = pts[links[i][1]];
    new HTensionLine(pt1, pt2, pt1.pos().dist(pt2.pos())*.9, 2);
  }

  new IGravity(0, 0, 150);
  IG.perspective();
  IG.start();
  IG.pause();

  //Construct the adjacency links between triangles.
  for (int i=0; i<tris.size ()-1; i++) {
    for (int j=i+1; j<tris.size (); j++) {
      tris.get(i).isAdj(tris.get(j));
    }
  }

  //Combine the triangles.
//  for (int min=1; min<=3; min++) {
//    boolean change = false;
//    for (HTriangle tri : tris) {
//      if (tri.adjNum <= min && !tri.combined) {
//        for (int j=0; j<tri.adjNum; j++) {
//          ISurface cb = tri.combine(tri.adjTri[0]);
//          if (cb != null) {
//            grid.add(cb);
//            cb.hide();
//            change = true;
//          }
//        }
//      }
//    }
//    if (change) {
//      min--;
//    }
//  }
  println(grid.size());
}
void draw() {
  //ISurface can't update automatically. I don't know why.
  for (ISurface surf : grid) {
    surf.updateGraphic();
  }
}

void keyPressed() {
  if (key == 'u') {
    IG.stop();
    linkPairEdge();
    printOriginFix(new IVec (6000, 0, 0));
    for (ICurve line : tensionLine) {
      line.hide();
    }
    for (HTriangle tri : tris) {
      tri.changeAng();
      //      tri.printNum();
            if (!tri.combined) {
              grid.add(tri.surf());
            }
    }
    for (HEdge edge : edges) {
      edge.changeConnection();
    }
    for (HEdge edge : edges) {  
      edge.drawLine();
      edge.drawGraph();
      edge.drawHole();
    }
    for (HTriangle tri : tris) {
      tri.makeConnection();
    }

    for (HConnection con : connections) {
      if (con.upside) {
        con.makeWings();
      }
    } 
    println(edgeHoleNum/2+" "+wingHoleNum);
  }
  if (key=='i') {
    for (HEdge edge : edges) {  
      edge.printGraph();
    }
    printOriginFix();
    rowDis=250;
    lineDis=250;
    maxRow=15;
    for (HConnection con : connections) {
      if (con.upside) {
        con.make2D();
        IVec pos=printOrigin();
        con.transform(move(pos));
        con.text.transform(move(pos));
      }
    }
    IG.top();
  }


  if (key == 'a') {
    new IAttractor(0, 0, 1000).intensity(-1000);
  }
  println(grid.size());
}

