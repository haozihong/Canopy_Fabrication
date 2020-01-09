int triangleNum=0; 

class HTriangle extends IAgent {
  int num;
  int adjNum = 0;
  HPoint[] pts = new HPoint[3];
  HTriangle[] adjTri = new HTriangle[3];
  HEdge[] adjEdge=new HEdge[3];

  boolean combined = false;
  HTriangle cbTri;

  ISurface triSurf, cbSurf;

  boolean isClockwise(HPoint pt1, HPoint pt2, HPoint pt3) {
    IVec cp = pt2.pos().dif(pt1.pos()).cross(pt3.pos().dif(pt1.pos()));
    return cp.z()<0;
  }

  HTriangle (HPoint p1, HPoint p2, HPoint p3) {
    pts[0] = p1;
    if (!isClockwise(p1, p2, p3)) {
      pts[1] = p2;
      pts[2] = p3;
    } else {
      pts[1] = p3;
      pts[2] = p2;
    }
    num=triangleNum++;
    for (int i=0;i<3;++i){
    adjEdge[i]=new HEdge(pts[i], pts[(i+1)%3],num+"-"+i);
    adjEdge[i].ang[0]=getAng(pts[i])/2;  
    adjEdge[i].ang[1]=getAng(pts[(i+1)%3])/2;
    edges.add(adjEdge[i]);
    }
  }
  
    void printNum(){
    IVec nml=pts[1].pos().dif(pts[0].pos()).cross(pts[2].pos().dif(pts[0].pos())).unit();
    IVec center=new IVec();
    center.add(pts[0]).add(pts[1]).add(pts[2]).div(3);
    IVec dir=pts[0].dif(center);
    new IText(num+" ",300,center,dir,nml.cross(dir)).clr(1.,1.,0);
    new ICurve(center,pts[0]).clr(1.,0,0);
    new ICurve(center,pts[1]).clr(0.,1.,0);
    new ICurve(center,pts[2]).clr(0.,0,1.);

  }
  
  void changeAng(){
    for (int i=0;i<3;++i){
    adjEdge[i].ang[0]=getAng(pts[i])/2;  
    adjEdge[i].ang[1]=getAng(pts[(i+1)%3])/2;
    }
    
    
  }
  
  double getAng(HPoint p){
    if (p==pts[0]) return pts[1].pos().dif(pts[0].pos()).angle(pts[2].pos().dif(pts[0].pos())); 
    if (p==pts[1]) return pts[0].pos().dif(pts[1].pos()).angle(pts[2].pos().dif(pts[1].pos())); 
    return pts[0].pos().dif(pts[2].pos()).angle(pts[1].pos().dif(pts[2].pos()));
  }

  ISurface surf() {
    if (triSurf == null) {
      triSurf = new ISurface(pts[0].pos(), pts[1].pos(), pts[2].pos());
    }
    return triSurf;
  }

  void addAdj (HTriangle tri2) {
    for (int i=0; i<adjNum; i++) {
      if (adjTri[i] == tri2) {
        return;
      }
    } 
    adjTri[adjNum] = tri2;
    adjNum++;
  }

  void delAdj(HTriangle tri2) {
    HTriangle[] tempAdj = new HTriangle[3];
    int t = 0;
    for (int i=0; i<adjNum; i++) {
      if (adjTri[i] != tri2) {
        tempAdj[t] = adjTri[i];
        t++;
      }
    }
    adjTri = tempAdj;
    adjNum = t;
  }

  void delSelf() {
    for (int i=0; i<adjNum; i++) {
      if (!adjTri[i].combined) {
        adjTri[i].delAdj(this);
      }
    }
  }

  boolean isAdj(HTriangle tri2) {
    for (int i=0; i<adjNum; i++) {
      if (adjTri[i] == tri2) {
        return true;
      }
    }
    int sameP = 0; 
    for (int i=0; i<3; i++) {
      for (int j=0; j<3; j++) {
        sameP += int(pts[i]==tri2.pts[j]);
      }
    }
    if (sameP == 2) {
      addAdj(tri2); 
      tri2.addAdj(this); 
      return true;
    }
    return false;
  }

  ISurface combine (HTriangle tri2) {
    if (combined || tri2.combined) {
      return null;
    }

    //Get 4 corners of the combined quadrangle
    HPoint[] pt4 = new HPoint[4];
    for (int i=0; i<3; i++) {
      pt4[i] = pts[i];
    }
    for (int i=0; i<3; i++) {
      boolean diff = true; 
      for (int j=0; j<3; j++) {
        if (tri2.pts[i] == pts[j]) {
          diff = false; 
          break;
        }
      }
      if (diff) {
        pt4[3] = tri2.pts[i]; 
        break;
      }
    }

    //Still use the mesh package to create the convex hull of the 4 points.
    PVector[] pt4t = new PVector[4];
    for (int i=0; i<4; i++) {
      pt4t[i] = new PVector((float)pt4[i].pos().x(), (float)pt4[i].pos().y());
    }
    ConvexHull ch = new ConvexHull(pt4t);
    int[] pi = ch.getExtrema();
    //The hull only has 3 vertexes means one of the inner angles is greater than PI. Don't combine.
    if (pi.length < 4) {
      return null;
    }
    combined = true; 
    cbTri = tri2; 
    tri2.combined = true; 
    tri2.cbTri = this; 
    ISurface cbSurf = new ISurface(pt4[pi[0]].pos(), pt4[pi[1]].pos(), pt4[pi[2]].pos(), pt4[pi[3]].pos()); 
    tri2.cbSurf = cbSurf;
    delSelf();
    tri2.delSelf();
    return cbSurf;
  }

  void makeConnection() {
    makeConnection(pts[2], pts[1], pts[0],num+"-"+1);
    makeConnection(pts[0], pts[2], pts[1],num+"-"+2);
    makeConnection(pts[1], pts[0], pts[2],num+"-"+0);
  }

  void makeConnection(HPoint p2, HPoint p1, HPoint p3,String s) {
    IVec r1=p2.dif(p1).unit();
    IVec r2=p3.dif(p1).unit();
    // use edgesurf direction instead
    HEdge edge1=getEdge(p1, p2);
    HEdge edge2=getEdge(p3, p1);
    IVec upCenter=p1.sum(p1.direction.cp().mul(p1.upOffset)); 
    IVec downCenter=p1.sum(p1.direction.cp().mul(p1.upOffset-p1.downOffset)); 
    r1=edge1.direction.cross(r1).cross(p1.direction).unit();
    r2=p1.direction.cross(r2.cross(edge2.direction)).unit();
     connections.add(createConnection(upCenter, r1, r2, p1.direction,connectionThickness+edgeThickness,true,s));
    connections.add(createConnection(downCenter, r1, r2, p1.direction,connectionThickness+edgeThickness,false,s));
  }


}

