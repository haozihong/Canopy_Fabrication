/*
int pNum = 40;
int pMax = 50000;
PVector[] point = new PVector[pMax];
ConvexHull chP;
*/

class ConvexHull{  //Melkman
  private int maxLen = 500;
  int num, diameter;
  int[] chpIndex = new int[maxLen];
  PVector[] chPoint = new PVector[maxLen];
  private int p,q,pn;
  private int[] qu = new int[maxLen];
  private PVector[] pts;
  private int[] oriIndex = new int[maxLen];
  
  int[] getExtrema() {
    return subset(chpIndex,0,num);
  }
  
  private int sign(float x){
    return (x>0) ?1:((x<0) ?-1:0);
  }
  
  private void update(){
    num = (q-p+maxLen)%maxLen;
    for(int i=0; i<num; i++){
      chpIndex[i] = oriIndex[qu[(p+i)%maxLen]];
      chPoint[i] = pts[qu[(p+i)%maxLen]];
    }
  }
  
  private void melkman(PVector pt, int pIndex){
    //if(pn>=maxLen){
    //  maxLen*=2;
    //  chpIndex = expand(chpIndex,maxLen);
    //  //chPoint = expand(chPoint,maxLen);
    //  qu = expand(qu,maxLen);
    //  //ps = expand(ps,maxLen);
    //}
    PVector q1 = pts[qu[(q+maxLen-1)%maxLen]];
    PVector q2 = pts[qu[q]];
    int qcp = sign(PVector.sub(q2,q1).cross(PVector.sub(pt,q1)).z);
    PVector p1 = pts[qu[(p+1)%maxLen]];
    PVector p2 = pts[qu[p]];
    int pcp = sign(PVector.sub(p2,p1).cross(PVector.sub(pt,p1)).z);
    if(qcp>=0 && pcp<=0){ //<>//
      return;
    }
    q = (q+1)%maxLen;
    qu[q] = pIndex;
    while(qcp<=0){
      q = (q+maxLen-1)%maxLen;
      qu[q] = pIndex;
      q2 = q1;
      q1 = pts[qu[(q+maxLen-2)%maxLen]];
      qcp = sign(PVector.sub(q2,q1).cross(PVector.sub(pt,q1)).z);
    }
    p = (p+maxLen-1)%maxLen;
    qu[p] = pIndex;
    while(pcp>=0){
      p = (p+1)%maxLen;
      qu[p] = pIndex;
      p2 = p1;
      p1 = pts[qu[(p+2)%maxLen]];
      pcp = sign(PVector.sub(p2,p1).cross(PVector.sub(pt,p1)).z);
    }

    //for(int i = p; i!=q; i = (i+1)%maxLen){
    // print(oriIndex[qu[i]]+" ");
    //}
    //println(oriIndex[qu[q]]);
  }
  
  void addPoint(PVector pt){
    pts[pn] = pt;
    oriIndex[pn] = pn;
    pn++;
    int pNear = p;
    for(int i = (p+1)%maxLen; i!=q; i = (i+1)%maxLen){
      if(pt.dist(pts[qu[i]])<pt.dist(pts[qu[pNear]])){
        pNear = i;
      }
    }
    while(p!=pNear){
      p = (p+1)%maxLen;
      q = (q+1)%maxLen;
      qu[q] = qu[p];
    }
    melkman(pt,pn-1);
    update();
  }
  
  ConvexHull(PVector[] pointList){
    pn = pointList.length;
//    while(pointList[pn] != null){
//      pn++;
//    }
    pts = (PVector[])expand(pointList,maxLen); //<>//
    for(int i=0; i<pn; i++){
      oriIndex[i] = i;
    }
    for(int i=0; i<pn-1; i++){
      for(int j=i+1; j<pn; j++){
        if(pts[j].y<pts[i].y || pts[j].y==pts[i].y && pts[j].x<pts[i].x){
          PVector temp = pts[i];
          pts[i] = pts[j];
          pts[j] = temp;
          int t = oriIndex[i];
          oriIndex[i] = oriIndex[j];
          oriIndex[j] = t;
        }
      }
    }
    //for(int i=0;i<pn; i++){
    //  print(oriIndex[i]+" ");
    //}
    //println();
    qu[0] = 1;
    qu[1] = 0;
    qu[2] = 1;
    p = 0;
    q = 2;
    //for(int i = p; i!=q; i = (i+1)%maxLen){
    // print(oriIndex[qu[i]]+" ");
    //}
    //println(oriIndex[qu[q]]);
    for(int i=2; i<pn; i++){
      if(i==pn-1 || pts[i].y!=pts[i+1].y){
        melkman(pts[i],i);
      }
    }
    for(int i=pn-1; i>=0; i--){
      if(i==0 || pts[i].y!=pts[i-1].y){
        melkman(pts[i],i);
      }
    }
    update();
  }
}

/*
void ranPoints(){
  for(int i=0; i<pNum; i++){
    point[i] = new PVector(random(width),random(0,height));
  }
  point[pNum] = null;
}

void mouseClicked(){
  if(mouseButton == LEFT){
    pNum = 20;
    ranPoints();
    chP = new ConvexHull(point);
  }else{
    point[pNum++].set(mouseX,mouseY);
    chP.addPoint(point[pNum-1]);
  }
}

void setup(){
  size(1600,900);
  ranPoints();
  chP = new ConvexHull(point);
  println(chP.num);
  printArray(chP.chpIndex);
}

void draw(){
  background(255);
  fill(0,50);
  for(int i=0; i<pNum; i++){
    ellipse(point[i].x,point[i].y,2,2);
   // text(i,point[i][0]+15,point[i][1]+5);
  }
  fill(0,20);
  strokeWeight(1);
  stroke(0);
  beginShape();
  for(int i=0; i<chP.num; i++){
    vertex(chP.chPoint[i].array());
  }
  endShape(CLOSE);
}
*/
