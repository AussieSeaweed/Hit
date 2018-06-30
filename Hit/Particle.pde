abstract class Particle {
  private Vec2 location, velocity, acceleration;
  private float angle, angularVelocity, angularAcceleration;
  private boolean markedForDeletion;
  private color c;
  
  public Particle(Vec2 location, Vec2 velocity, float angle, float angularVelocity, color c) {
    this.location = location.clone();
    this.velocity = velocity.clone();
    this.acceleration = new Vec2();
    this.angle = angle;
    this.angularVelocity = angularVelocity;
    this.angularAcceleration = 0;
    this.c = c;
    markedForDeletion = false;
  }
  
  public boolean isMarkedForDeletion() {
    return markedForDeletion;    
  }
  
  public void markForDeletion() {
    markedForDeletion = true;
  }
  
  public color getColor() {
    return c;
  }
  
  public Vec2 getLocation() {
    return location;
  }
  
  public float getAngle() {
    return angle;
  }
  
  public void applyForce(Vec2 force) {
    acceleration.addLocal(force);
  }
  
  public void update() {
    velocity.addLocal(acceleration);
    location.addLocal(perSecond(velocity));
    acceleration.setZero();
    angularVelocity += angularAcceleration;
    angle += perSecond(angularVelocity);
    angularAcceleration = 0;
  }
  
  public void applyStyle() {
    fill(c);
    strokeWeight(0);
  }
  
  public void translateToParticle() {
    Vec2 location = getLocation();
    float angle = getAngle();
    
    translate(location.x, location.y);
    rotate(angle);
  }
  
  public abstract float getLongestDistance();
  public abstract void display();
}

abstract class FadingParticle extends Particle {
  protected float alphaValue, fadingRate;
  
  public FadingParticle(Vec2 location, Vec2 velocity, float angle, float angularVelocity, color c, float fadingTime) {
    super(location, velocity, angle, angularVelocity, c);
    alphaValue = alpha(c);
    this.fadingRate = alphaValue / fadingTime;
  }
  
  public void applyStyle() {
    fill(red(getColor()), green(getColor()), blue(getColor()), alphaValue);
    strokeWeight(0);
  }
  
  public void update() {
    super.update();
    alphaValue -= perSecond(fadingRate);
    if (alphaValue <= 0)
      markForDeletion();
  }
}

class FadingCircularParticle extends FadingParticle {
  protected float diameter;
  
  public FadingCircularParticle(Vec2 location, float diameter, Vec2 velocity, color c, float fadingTime) {
    super(location, velocity, 0, 0, c, fadingTime);
    this.diameter = diameter;
  }
  
  public void display() {
    pushMatrix();
    translateToParticle();
    pushStyle();
    applyStyle();
    ellipse(0, 0, diameter, diameter);
    popStyle();
    popMatrix();
  }
  
  public float getLongestDistance() {
    return diameter / 2f;
  }
}
