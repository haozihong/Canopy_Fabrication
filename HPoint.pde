class HPoint extends IParticle {
  IVec direction=new IVec();
  HTriangle[] adjTri = new HTriangle[10];
  HPoint[] adjPoint=new HPoint[10];
  int adjPointNum=0;
  int adjNum = 0;
  double upOffset=200;
  double downOffset=70;

  HPoint(IVec p) {
    super(p);
  }

  void update() {
    direction = pos().dif(centerPoint).unit();
  }
  
  void addTri(HTriangle t){
    adjTri[adjNum]=t;
    ++adjNum; 
    
  }
  
  void addPoint(HPoint p){
    adjPoint[adjPointNum]=p;
   ++adjPointNum; 
    
  }

}

