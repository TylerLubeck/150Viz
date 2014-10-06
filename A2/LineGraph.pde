class LineGraph {
  //XYAxis axis;
  ArrayList<Point> points;
  ArrayList<Point> backupPoints;
  float w, h;
  float leftSpacing;
  float rightSpacing;
  float paddedHeight;
  float min, max; 
  ArrayList<Boolean> isAnimating;
  float xDelta, yDelta;
  boolean firstRender = true;

  LineGraph(float w, float h) {
    this.xDelta = 12.5;
    this.yDelta = 12.5;
    this.w = w;
    this.h = h - 100;
    this.leftSpacing = 40;
    this.rightSpacing = width/4;
    this.paddedHeight = height - 100;
    this.points = new ArrayList<Point>(); 
    this.backupPoints = new ArrayList<Point>(); 
    this.isAnimating = new ArrayList<Boolean>();
  } 

  void setAxis( XYAxis a) {
    axis = a;
  }

  void addPoint( String lbl, int val) {
    Point p = new Point(lbl, val);
    Point p2 = new Point(lbl, val);
    points.add(p);
    this.backupPoints.add(p2);
    this.isAnimating.add(false);
  }

  void setGeometry(BarGraph barGraph) { 
    float numPoints = points.size(); 
    float totalSpacing = numPoints - 1;
    float xInterval = (width - this.leftSpacing - width/4) / numPoints; 
    float yInterval = 2.0; 
    barGraph.setGeometry(); 
    if (this.firstRender) {
      for (int i = 0; i < numPoints; i++) {
        points.get(i).setCoord(barGraph.bars.get(i).pointX, 
        barGraph.bars.get(i).pointY); 
        backupPoints.get(i).setCoord(barGraph.bars.get(i).pointX, 
        barGraph.bars.get(i).pointY);
      }
      this.firstRender = false;
    }
  }

  void connectTheDots(float stepVal) {
    for (int i = 0; i < this.points.size () - 1; i++) {
      fill(color(0));
      strokeWeight(2);
      float newX = lerp(this.backupPoints.get(i).getPosX(), 
      this.backupPoints.get(i+1).getPosX(), 
      stepVal);
      float newY = lerp(this.backupPoints.get(i).getPosY(), 
      this.backupPoints.get(i+1).getPosY(), 
      stepVal);
      line(this.backupPoints.get(i).getPosX(), 
      this.backupPoints.get(i).getPosY(), 
      newX, 
      newY);
    }
  }

  void connectTheDots() {
    for (int i = 0; i < this.points.size () - 1; i++) {                     
      fill(color(0));
      strokeWeight(2); 
      line(this.points.get(i).getPosX(), 
      this.points.get(i).getPosY(), 
      this.backupPoints.get(i+1).getPosX(), 
      this.backupPoints.get(i+1).getPosY());
    }
  }

  /* bit of a cop out, but should look better with some coloring tweaks */
  void disconnectTheDots(float stepVal) {
    for (int i = 0; i < this.points.size () - 1; i++) {
      fill(color(255));
      stroke(color(255)); 
      strokeWeight(2);
      float newX = lerp(this.backupPoints.get(i).getPosX(), 
      this.backupPoints.get(i+1).getPosX(), 
      stepVal);
      float newY = lerp(this.backupPoints.get(i).getPosY(), 
      this.backupPoints.get(i+1).getPosY(), 
      stepVal);
      line(this.backupPoints.get(i).getPosX(), 
      this.backupPoints.get(i).getPosY(), 
      newX, 
      newY);
    }
  }
  boolean isSafeToAnimate() {
    for (boolean b : this.isAnimating) if (b) return false;
    return true;
  }

  void startAnimating() {
    for (int i = 0; i < this.isAnimating.size (); i++) {
      this.isAnimating.set(i, true);
    }
  }

  /* old disconnect the dots */
  void disconnectTheDotsTest(float stepVal) {
    stroke(color(255, 0, 0));
    fill(color(255, 0, 0));
    strokeWeight(2); 
    for (int i = 0; i < this.points.size () - 1; i++) {
      Point thisPoint = this.points.get(i);
      Point thisPointBack = this.backupPoints.get(i);
      Point thatPoint = this.backupPoints.get(i+1);
      float newX = lerp(thisPointBack.getPosX(), thatPoint.getPosX(), stepVal);
      float newY = lerp(thisPointBack.getPosY(), thatPoint.getPosY(), stepVal); 
      this.points.get(i).change(newX, newY);
      line(newX, 
      newY-5, 
      thatPoint.getPosX(), 
      thatPoint.getPosY()-5);
    }
  }

  void moveDotsTo(float destX, float destY, float stepVal) {
    for (int i = 0; i < this.points.size (); i++) {
      float currX = lerp(this.backupPoints.get(i).getPosX(), destX, stepVal);
      float currY = lerp(this.backupPoints.get(i).getPosY(), destY, stepVal);
      this.points.get(i).setCoord(currX, currY);
      this.points.get(i).render();
    }
  }

  void reset() {
    this.points.clear();
    for (Point p : this.backupPoints) {
      this.points.add(new Point(p));
    }
    this.startAnimating();
    this.firstRender = true;
  }

  void render(BarGraph barGraph) {
    setGeometry(barGraph); 
    for (Point p : this.points) {
      p.render();
    }
    connectTheDots();
  }


  void drawPoints(BarGraph barGraph) {
    setGeometry(barGraph);
    for (Point p : points) {
      p.render();
    }
  }

  void drawBars(BarGraph barGraph, float stepVal, float stepHeight) {
    ArrayList<Bar> bars = barGraph.bars;
    float finalBarHeight = 0; 
    for (int i=0; i< bars.size (); i++) {
      if (stepHeight < bars.get(i).bHeight) {
        Bar newBar = bars.get(i); 
        newBar.yCoord += stepVal;
        newBar.bHeight = stepHeight; 
        newBar.render(); 
       } else {
         bars.get(i).render(); 
       }
    }
  }
}

