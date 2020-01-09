

IVec4 transform4(IVec4 v, IMatrix4 mat) {
  v.set(mat.mul(v.get()));
  return v;
}

IMatrix4 move(IVec v) {
  double[][] md = new double[4][];
  md[0] = new double[]{1,0,0,v.x};
  md[1] = new double[]{0,1,0,v.y};
  md[2] = new double[]{0,0,1,v.z};
  md[3] = new double[]{0,0,0,1};
  return (IMatrix4)(new IMatrix4().set(md));
}
IMatrix4 orientOXY(IVec o, IVec ux, IVec uy) {
  ux=ux.cp().unit();
  uy=uy.cp().unit();
  IVec uz = ux.cross(uy).unit();
  uy = uz.cross(ux).unit();

  double[][] mdr = new double[4][];
  mdr[0] = new double[]{ux.x,ux.y,ux.z,0};
  mdr[1] = new double[]{uy.x,uy.y,uy.z,0};
  mdr[2] = new double[]{uz.x,uz.y,uz.z,0};
  mdr[3] = new double[]{0,0,0,1};
  IMatrix4 mr = new IMatrix4();
  mr.set(mdr);

  return mr.mul(move(o.cp().flip()));
}

IGeometry orientOXY(IGeometry geo, ISurface surfa) {
  IVec o = surfa.corner(0,0);
  IVec ux = surfa.corner(0,1).dif(o).unit();
  IVec uz = surfa.nml(0,0).unit();
  IVec uy = uz.cross(ux).unit();
  return geo.transform(orientOXY(o,ux,uy));
}

IGeometry orientOXY(IGeometry geo, IVec o, IVec ux, IVec uy) {
  return geo.transform(orientOXY(o,ux,uy));
}

int lineNum=0;
int rowNum=0;
double lineDis=400;
double rowDis=2500;
int maxRow=3;
IVec fixOrigin=new IVec();


IVec printOrigin(){
  IVec v= new IVec(rowNum*rowDis,lineNum*lineDis,0);
  v.add(fixOrigin); 
  rowNum=rowNum+1;
  if (rowNum==maxRow) {
   rowNum=0;
   lineNum++; 
  }
  return v;
  
}

void printOriginFix(){
   lineNum++;
   rowNum=0;
   fixOrigin.add(new IVec(rowNum*rowDis,lineNum*lineDis,0));
   lineNum=0;
   rowNum=0;
  
}

void printOriginFix(IVec v){
   fixOrigin=v;
   lineNum=0;
   rowNum=0;
  
}






