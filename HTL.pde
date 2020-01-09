class HTensionLine extends IAgent {
  HPoint pt1, pt2;
  double len, tension; // proportial coefficient
  ICurve line;

  HTensionLine(HPoint p1, HPoint p2, double l, double t) {
    pt1 = p1;
    pt2 = p2;
    len = l;
    tension = t;
    line = new ICurve(pt1.pos(), pt2.pos()).clr(clr());
    tensionLine.add(line);
  }

  void setTension(double t) {
    tension = t;
    println(t);
  }

  void interact(ArrayList < IDynamics > agents) {
    IVec dif = pt2.pos().dif(pt1.pos());
    double dl = dif.len();
    dif.len(dl-len).mul(tension);
    pt1.push(dif);
    pt2.pull(dif); //opposite force
  }

  void update() {

      line.updateGraphic();
    
  }
}


