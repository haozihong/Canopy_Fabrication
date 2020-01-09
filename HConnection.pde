double innerRadius=90;
double outterRadius=160;
double holeHeight=13;
double holeDistance=30;
int cirDivide=10; 
double holeRadius = 3.25;
double wingHeight = 20;


HConnection createConnection(IVec p, IVec r1, IVec r2, IVec axis, double offset, boolean up,String s) {
    IVec4[][] surfPts=new IVec4[2][cirDivide];
    IVec nml12 = axis.cross(r1).unit();
    IVec nml21 = r2.cross(axis).unit();
    IVec pi1 = r1.cp().len(innerRadius).add(nml12.cp().len(offset));
    IVec po1 = r1.cp().len(outterRadius).add(nml12.cp().len(offset));
    IVec pi2 = r2.cp().len(innerRadius).add(nml21.cp().len(offset));
    IVec po2 = r2.cp().len(outterRadius).add(nml21.cp().len(offset));
    double innerAng = pi1.angle(pi2,axis);
    double outterAng = po1.angle(po2,axis);
    double weight=1;
    for (int i=0; i<cirDivide; ++i) {
      surfPts[0][i]=new IVec4(pi1.cp().rot(axis, innerAng*i/(cirDivide-1)), weight); 
      surfPts[1][i]=new IVec4(po1.cp().rot(axis, outterAng*i/(cirDivide-1)), weight);
    }
    return new HConnection(surfPts,p,nml12,nml21,pi1,pi2,po1,po2,axis,up,s);
}



class HConnection extends ISurface {
  boolean upside;
  IVec4 nml12,nml21,axis;
  IVec p,pi1,pi2,po1,po2;
  ICurve r1,r2,w1,w2;
  ICurve[] wings = new ICurve[6];
  IVec[] holeCenters = new IVec[4];
  ICircle[] holes = new ICircle[4];
  String num;
  IText text;
  
  HConnection (IVec4[][] v,IVec p, IVec nml12, IVec nml21, IVec pi1, IVec pi2, IVec po1, IVec po2, IVec axis, boolean up,String s){
    super(v,1,2);
    upside = up;
    this.nml12 = new IVec4(nml12,0);
    this.nml21 = new IVec4(nml21,0);
    this.axis = new IVec4(axis,0);
    this.pi1 = pi1;
    this.pi2 = pi2;
    this.po1 = po1;
    this.po2 = po2;
    this.p = new IVec(0,0,0);
     
    transform(move(p));
    num=s;
   
    
  }
  
  void make2D() {
    transform(orientOXY(p.cp(),pi2.dif(pi1),axis.cross(pi2.dif(pi1))));
    IVec[][] v = (IVec[][])cps();
    r1 = new ICurve(v[0],2).layer("shao").clr(1.,0,0);
    r2 = new ICurve(v[1],2).layer("shao").clr(1.,0,0);
    w1 = new ICurve(pi1,po1).layer("ke").clr(0,1.,0);
    w2 = new ICurve(pi2,po2).layer("ke").clr(0,1.,0);
    hide();
    text=new IText(num,fontSize,pi1.sum(po1.dif(pi1).len(3)).sum(nml12.cp().len(3)),po1.dif(pi1),nml12.cp());
    text.layer("text");
//    r1.clr(1.,0,0);
//    r2.clr(1.,0,0);
//    w1.clr(0,1.,0);
//    w2.clr(0,1.,0);
  }
  
  void transform(IMatrix4 m) {
    super.transform(m.cp());
    super.updateGraphic();
    transform4(nml12,m.cp());
    transform4(nml21,m.cp());
    transform4(axis,m.cp());
    p.transform(m.cp());
    pi1.transform(m.cp());
    pi2.transform(m.cp());
    po1.transform(m.cp());
    po2.transform(m.cp());
   // text.transform(m.cp());
    for (ICurve c : wings)
      if (c != null) c.transform(m.cp());
    for (IVec v : holeCenters)
      if (v != null) v.transform(m.cp());
    for (ICircle c : holes)
      if (c != null) {
        c.transform(m.cp());
        c.updateGraphic();
      }
  }
  
  void makeWings() {
    IVec wing1i = pi1.sum(nml12.cp().len(-wingHeight));
    IVec wing1o = po1.sum(nml12.cp().len(-wingHeight));
    IVec wing2i = pi2.sum(nml21.cp().len(-wingHeight));
    IVec wing2o = po2.sum(nml21.cp().len(-wingHeight));
    
    wings[0] = new ICurve(pi1.cp(),wing1i.cp()).layer("shao");
    wings[1] = new ICurve(wing1i.cp(),wing1o).layer("shao");
    wings[2] = new ICurve(wing1o.cp(),po1.cp()).layer("shao");
    wings[3] = new ICurve(pi2.cp(),wing2i.cp()).layer("shao");
    wings[4] = new ICurve(wing2i.cp(),wing2o.cp()).layer("shao");
    wings[5] = new ICurve(wing2o.cp(),po2.cp()).layer("shao");
    
    holeCenters[0] = pi1.sum(po1).mul(.5).sum(nml12.cp().len(-holeHeight)).sum(pi1.dif(po1).len(holeDistance/2));
    holeCenters[1] = pi1.sum(po1).mul(.5).sum(nml12.cp().len(-holeHeight)).sum(po1.dif(pi1).len(holeDistance/2));
    holeCenters[2] = pi2.sum(po2).mul(.5).sum(nml21.cp().len(-holeHeight)).sum(pi2.dif(po2).len(holeDistance/2));
    holeCenters[3] = pi2.sum(po2).mul(.5).sum(nml21.cp().len(-holeHeight)).sum(po2.dif(pi2).len(holeDistance/2));
    
    for (int i=0; i<4; i++)
      holes[i] = (ICircle)(new ICircle(holeCenters[i].cp(),axis.cp(),holeRadius).layer("shao"));
  }
}
