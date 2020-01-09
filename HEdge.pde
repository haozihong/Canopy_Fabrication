double edgeHeight=80;
double edgeVoid=10;
double edgeThickness=1;
double connectionThickness=2;
double edgeOffset=25;
double edgeHoleDistance=250;
double edgeWingHoleDistance=150;
double rotateAng=PI/180*85;

int wingHoleNum=0;
int edgeHoleNum=0;

class HEdge extends IAgent {
  HPoint[] pts = new HPoint[2];
  HTriangle[] adjTri = new HTriangle[2];
  int adjNum=0;
  IVec direction=new IVec();
  IVec normal=new IVec();
  ISurface edgeSurf;
  ISurface wingSurf;
  IVec[] surfPts;
  IVec[] wingPts;
  ArrayList<IPoint> holes=new ArrayList<IPoint>();
  ArrayList<ICurve> curves=new ArrayList<ICurve>();
  double[] ang=new double[2];
  String num;
  IVec printPoint;
  HEdge pair=null;
  IVec[] upPts=new IVec[2];
  


  HEdge(HPoint p1, HPoint p2, String s) {
    pts[0]=p1;
    pts[1]=p2;
    num=s;
  }

  void drawLine(){
  new ICurve(pts[0].pos(),pts[1].pos()) ;
}
  
  void addTri(HTriangle t) {
    adjTri[adjNum]=t;
    ++adjNum;
  }





  boolean matchPoint(HPoint p1, HPoint p2) {
    return pts[0]==p1 && pts[1]==p2;
  }

  void drawGraph() {
    IVec u=pts[1].pos().dif(pts[0].pos()).unit();
    IVec nml=u.cross(pts[0].direction).unit();
    IVec v=nml.cross(u).unit();
    
    
    wingPts=new IVec[6];
    IVec[] p=new IVec[4];
    
    
    upPts[0]=(solve2(pts[0].pos(), pts[0], pts[1], edgeHeight/2+10, edgeVoid));
    upPts[1]=(solve2(pts[1].pos(), pts[1], pts[0], edgeHeight/2+10, edgeVoid));
    p[0]=getDownPoint(pts[0], pts[1], edgeVoid);
    p[1]=getDownPoint(pts[0], pts[1], outterRadius*1.2);
    p[2]=getDownPoint(pts[1], pts[0], outterRadius*1.2);
    p[3]=getDownPoint(pts[1], pts[0], edgeVoid);
    
    double shortDis=4 ;   
    
    wingPts[0]=upPts[0].sum(u.cp().len(shortDis));
    wingPts[2]=upPts[0].sum(u.cp().len(edgeOffset/Math.tan(ang[0]))).sum(v.cp().len(edgeOffset));
    wingPts[3]=upPts[1].sum(u.cp().len(-edgeOffset/Math.tan(ang[1]))).sum(v.cp().len(edgeOffset));
    wingPts[1]=upPts[0].sum(wingPts[2].dif(upPts[0]).len(shortDis));
    wingPts[4]=upPts[1].sum(wingPts[3].dif(upPts[1]).len(shortDis));
    wingPts[5]=upPts[1].sum(upPts[0].dif(upPts[1]).len(shortDis));

    
    IVec[] pp=solve(p[0], p[1], p[2], p[3], pts[0].pos(), pts[1].pos(), edgeHeight/2);
    surfPts=new IVec[pp.length+4];
    surfPts[0]=wingPts[0].cp();
    surfPts[1]=upPts[0].sum(p[0].dif(upPts[0]).len(shortDis));
    for (int i=0;i<pp.length;++i) surfPts[2+i]=pp[i];
    surfPts[surfPts.length-2]=upPts[1].sum(p[3].dif(upPts[1]).len(shortDis));
    surfPts[surfPts.length-1]=wingPts[5].cp();
    

    edgeSurf=new ISurface(surfPts);
    wingSurf=new ISurface(wingPts.clone()); 
    wingSurf.rot(upPts[0],u,-rotateAng);
  }


  IVec getDownPoint(HPoint p1, HPoint p2, double dis) {
    IVec v= p1.direction.cp().unit();
    IVec nml=p2.pos().dif(p1.pos()).cross(v).unit();
    IVec u=v.cross(nml).unit();
    return p1.pos().sum(u.cp().mul(dis)).sum(v.cp().mul(p1.upOffset-p1.downOffset));
  }

  //  IVec solve(IVec a, IVec b, IVec c, HPoint p1, HPoint p2) { 
  //    IVec edgeNor=p1.direction.cross(p2.direction);
  //    IVec u=edgeNor.cross(p1.direction).unit();
  //    double x=(b.dif(a).dot(u)-edgeVoid)/c.dif(b).dot(u);
  //    return b.sum(c.dif(b).mul(-x));
  //  }

  IVec solve2(IVec a, HPoint p1, HPoint p2, double h, double r) {
    IVec edgeNor=p1.direction.cross(p2.direction);
    IVec u=edgeNor.cross(p1.direction).unit();
    IVec b=p1.pos().sum(direction.cp().len(h));
    IVec c=p2.pos().sum(direction.cp().len(h));
    double x=(b.dif(a).dot(u)-r)/c.dif(b).dot(u);
    return b.sum(c.dif(b).mul(-x));
  };

  void drawHole() {
    double safeDis=outterRadius+100;
    //holes for connections
    drawHole(pts[0], pts[1]);
    drawHole(pts[1], pts[0]);
    //holes for pair edges
    IVec u=pts[1].pos().dif(pts[0].pos());
    double dis=u.len()-2*safeDis;
    u.unit();
    int holeNum=(int)Math.floor(dis/edgeHoleDistance)+1;
    edgeHoleNum+=holeNum+1;
    for (int i=0; i<=holeNum; ++i) holes.add(new IPoint(pts[0].pos().sum(u.cp().mul(safeDis+dis*i/holeNum))).layer("holes"));
  }

  //add holes between two points (the two points will also be added)
  void addHole(IVec p1, IVec p2, double holeDis) {
    IVec u=p2.dif(p1);
    double dis=u.len();
    u.unit();
    int holeNum=(int)Math.floor(dis/holeDis)+1;
    wingHoleNum+=holeNum+1;
    for (int i=0; i<=holeNum; ++i) holes.add(new IPoint(p1.sum(u.cp().mul(dis*i/holeNum))).layer("holes"));
  }

  void drawHole(HPoint p1, HPoint p2) {
    IVec edgeNor=p1.direction.cross(p2.direction);
    IVec u=edgeNor.cross(p1.direction).unit();
    IVec v=u.cross(edgeNor).unit();
    holes.add(new IPoint(p1.sum(u.cp().mul((outterRadius+innerRadius)/2+holeDistance/2).sum(v.cp().mul(p1.upOffset-holeHeight)))).layer("holes"));
    holes.add(new IPoint(p1.sum(u.cp().mul((outterRadius+innerRadius)/2+holeDistance/2).sum(v.cp().mul(p1.upOffset-p1.downOffset+holeHeight)))).layer("holes"));
    holes.add(new IPoint(p1.sum(u.cp().mul((outterRadius+innerRadius)/2-holeDistance/2).sum(v.cp().mul(p1.upOffset-holeHeight)))).layer("holes"));
    holes.add(new IPoint(p1.sum(u.cp().mul((outterRadius+innerRadius)/2-holeDistance/2).sum(v.cp().mul(p1.upOffset-p1.downOffset+holeHeight)))).layer("holes"));
    edgeHoleNum+=4;
  }



  void changeConnection() {
    normal= pts[0].direction.cross(pts[1].direction).unit();
    direction=pts[1].direction.dif(pts[0].direction).cross(normal).unit();
    changeConnection(pts[0], pts[1]);
    changeConnection(pts[1], pts[0]);
  }

  void changeConnection(HPoint p1, HPoint p2) {
    IVec p=solve2(p1.pos(), p1, p2, edgeHeight/2, outterRadius);
    double dis=p.dif(p1.pos()).dot(p1.direction);
    if (dis<p1.upOffset) p1.upOffset=dis;
  }

  boolean isClockwise(IVec p1, IVec p2, IVec p3, IVec nml) {
    return p2.dif(p1).angle(p3.dif(p1), nml)>0;
  }
  //cal the downside curve
  IVec[] solve(IVec p1, IVec p2, IVec p3, IVec p4, IVec p5, IVec p6, double dis) {
    ArrayList<IVec> p=new ArrayList<IVec>();
    IVec u=p6.dif(p5).unit();
    IVec nml=p1.dif(p5).cross(u).unit();
    IVec v=nml.cross(u).unit();
    p5=p5.sum(v.cp().mul(-dis));
    p6=p6.sum(v.cp().mul(-dis));
    if (!isClockwise(p5, p6, p2, nml)) {
      p.add(p1.cp());
      p.add(p2.cp());
      if (isClockwise(p1, p2, p2.sum(p6.dif(p5)), nml)) {
        p.add(verticalPoint(p1, p2, p5, p6));
      } else {
        p.add(crossPoint(p2, p2.sum(v), p5, p6));
      }
    } else {
      p.add(p1.cp());
      p.add(crossPoint(p1, p2, p5, p6));
    }
    if (!isClockwise(p5, p6, p3, nml)) {
      if (isClockwise(p4, p3, p3.sum(p5.dif(p6)), nml.cp().flip())) {
        p.add(verticalPoint(p4, p3, p6, p5));
      } else {
        p.add(crossPoint(p3, p3.sum(v), p6, p5)) ;
      }
      p.add(p3.cp());
      p.add(p4.cp());
    } else {
      p.add(crossPoint(p4, p3, p6, p5));
      p.add(p4.cp());
    }
    IVec[] pp=new IVec[p.size()];
    for (int i=0; i<p.size (); ++i) pp[i]=p.get(i);
    return pp;
  }

  IVec crossPoint(IVec p1, IVec p2, IVec p3, IVec p4) {
    double x=p3.dif(p1).cross(p4.dif(p3)).len()/p2.dif(p1).cross(p4.dif(p3)).len();
    return p1.sum(p2.dif(p1).mul(x));
  }

  IVec verticalPoint(IVec p1, IVec p2, IVec p3, IVec p4) {
    IVec nml=p1.dif(p3).cross(p2.dif(p3));
    IVec v=p1.dif(p2).cross(nml);
    return crossPoint(p2, p2.sum(v), p3, p4);
  }
  void printGraph() {
    IVec u=pts[1].pos().dif(pts[0].pos()).unit();
    IVec nml=u.cross(pts[0].direction).unit();
    IVec v=nml.cross(u).unit();

    
    curves.add(new ICurve(wingPts[0].cp(), wingPts[wingPts.length-1].cp()));
    for (int i=0;i<wingPts.length-1;++i) curves.add(new ICurve(wingPts[i].cp(),wingPts[i+1].cp()));
    for (int i=0;i<surfPts.length-1;++i) curves.add(new ICurve(surfPts[i].cp(),surfPts[i+1].cp()));
    
    //holes for faces
    IVec p3=upPts[0].mid(wingPts[2]).sum(u.cp().mul(4*holeRadius/Math.sin(ang[0])));
    IVec p4=upPts[1].mid(wingPts[3]).sum(u.cp().mul(-4*holeRadius/Math.sin(ang[1])));
    addHole(p3, p4, edgeWingHoleDistance);



    for (IPoint hole : holes) {
      curves.add(new ICircle(hole.pos().cp(), nml.cp(), holeRadius));
      hole.hide();
    }
    IVec pos = printOrigin();
    for (ICurve c : curves) {
      c.layer("shao").clr(1., 0, 0);
      c.transform(orientOXY(upPts[1], u.cp().flip(), v)).transform(move(pos));
    }
    curves.get(0).layer("ke").clr(0, 1., 0);

    printPoint=upPts[0].mid(upPts[1]).sum(v.cp().len(-edgeHeight/2));
    printPoint.transform(orientOXY(upPts[1], u.cp().flip(), v)).transform(move(pos));
    new IText(num+(pair==null? "":"--"+pair.num), fontSize, printPoint).layer("text");
  }

}

HEdge getEdge(HPoint p1, HPoint p2) {
  for (int i=0; i<edges.size (); ++i) {
    HEdge edge=edges.get(i);
    if (edge.matchPoint(p1, p2)) return edge;
  } 
  return null;
}

void linkPairEdge() {
  for (HEdge edge1 : edges) {
    if (edge1.pair!=null) continue;
    for (HEdge edge2 : edges) {
      if ((edge1.pts[0]==edge2.pts[1])&&(edge1.pts[1]==edge2.pts[0])) {
        edge1.pair=edge2;
        edge2.pair= edge1;
      }
    }
  }
  addEdgePair();
}

void addEdgePair() {
  ArrayList<HEdge> e=new ArrayList<HEdge>();

  for (HEdge edge : edges) {
    if (edge.pair==null) {
      if (edge.pts[0].pos().z<0.00001)
        if  (edge.pts[1].pos().z<0.00001) continue;
      HEdge edge1=new HEdge(edge.pts[1], edge.pts[0], (triangleNum++)+"-"+3);
      edge1.ang[0]=PI/8;
      edge1.ang[1]=PI/8;
      edge1.pair=edge;
      edge.pair=edge1;
      e.add(edge1);
    }
  }
  for (HEdge edge : e) {
    edges.add(edge);
  }
}

