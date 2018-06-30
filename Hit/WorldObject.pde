abstract class WorldObject {
  private Body body;
  private BodyDef bodyDef;
  private FixtureDef fixtureDef;
  private color fillColor, strokeColor;
  private float strokeWeightValue;
  private Box2DProcessing box2d;
  
  private boolean markedForDeletion;
  
  public WorldObject(Vec2 location, float angle, Vec2 linearVelocity, 
                      float angularVelocity, float linearDamping, 
                      float angularDamping, float friction, float restitution,
                      float density, color fillColor, color strokeColor,
                      float strokeWeightValue, Box2DProcessing box2d) {
    this.box2d = box2d;
    markedForDeletion = false;
    setStyle(fillColor, strokeColor, strokeWeightValue);
    createBodyDef(location, angle, linearVelocity, angularVelocity, linearDamping, angularDamping);
    createFixtureDef(friction, restitution, density);
  }
  
  protected BodyDef getBodyDef() {
    return bodyDef;
  }
  
  private void createBodyDef(Vec2 location, float angle, Vec2 linearVelocity, float angularVelocity, float linearDamping, float angularDamping) {
    bodyDef = new BodyDef();
    bodyDef.type = BodyType.DYNAMIC;
    bodyDef.setBullet(true);
    bodyDef.position = box2d.coordPixelsToWorld(location);
    bodyDef.setAngle(-angle);
    bodyDef.setLinearVelocity(box2d.vectorPixelsToWorld(linearVelocity));
    bodyDef.setAngularVelocity(-angularVelocity);
    bodyDef.setLinearDamping(linearDamping);
    bodyDef.setAngularDamping(angularDamping);
  }
  
  protected FixtureDef getFixtureDef() {
    return fixtureDef;
  }
  
  private void createFixtureDef(float friction, float restitution, float density) {
    fixtureDef = new FixtureDef();
    fixtureDef.setFriction(friction);
    fixtureDef.setRestitution(restitution);
    fixtureDef.setDensity(density);
  }
  
  protected Box2DProcessing getWorld() {
    return box2d;
  }
  
  protected void setBody(Body body) {
    this.body = body;
  }
  
  protected Body getBody() {
    return body;
  }
  
  public void setFill(color fillColor) {
    this.fillColor = fillColor;
  }
  
  public void setStroke(color strokeColor) {
    this.strokeColor = strokeColor;
  }
  
  public void setStrokeWeight(float strokeWeightValue) {
    this.strokeWeightValue = strokeWeightValue;
  }
  
  public void setStyle(color fillColor, color strokeColor, float strokeWeightValue) {
    this.fillColor = fillColor;
    this.strokeColor = strokeColor;
    this.strokeWeightValue = strokeWeightValue;
  }
  
  protected void applyStyle() {
    fill(fillColor);
    stroke(strokeColor);
    strokeWeight(strokeWeightValue);
  }
  
  public void setUserData(Object userData) {
    body.setUserData(userData);
  }
  
    public Vec2 getLocation() {
    return box2d.coordWorldToPixels(body.getWorldCenter());
  }
  
  public void setLocation(Vec2 location) {
    body.setTransform(box2d.coordPixelsToWorld(location), body.getAngle());
  }
  
  public float getAngle() {
    return -body.getAngle();
  }
  
  public void setAngle(float angle) {
    body.setTransform(body.getWorldCenter(), -angle);
  }
  
  public void setTransform(Vec2 location, float angle) {
    body.setTransform(box2d.coordPixelsToWorld(location), -angle);
  }
  
  public Vec2 getLinearVelocity() {
    return box2d.vectorWorldToPixels(body.getLinearVelocity());
  }
  
  public float getAngularVelocity() {
    return -body.getAngularVelocity();
  }
  
  public void setLinearVelocity(Vec2 velocity) {
    body.setLinearVelocity(box2d.vectorPixelsToWorld(velocity));
  }
  
  public void setAngularVelocity(float angularVelocity) {
    body.setAngularVelocity(-angularVelocity);
  }
  
  public void applyForceToCenter(Vec2 force) {
    body.applyForceToCenter(box2d.vectorPixelsToWorld(force));
  }
  
  public void applyForce(Vec2 force, Vec2 location) {
    body.applyForce(box2d.vectorPixelsToWorld(force), box2d.coordPixelsToWorld(location));
  }
  
  public void setLinearDamping(float linearDamping) {
    body.setLinearDamping(linearDamping);
  }
  
  public void setAngularDamping(float angularDamping) {
    body.setAngularDamping(angularDamping);
  }
  
  public float getMass() {
    return body.getMass();
  }
  
  public void translateToBody() {
    Vec2 location = getLocation();
    float angle = getAngle();
    
    translate(location.x, location.y);
    rotate(angle);
  }
  
  public void destroy() {
    box2d.destroyBody(body);
  }
  
  public void markForDeletion() {
    markedForDeletion = true;
  }
  
  public boolean isMarkedForDeletion() {
    return markedForDeletion;
  }
  
  public void applyAngularImpulse(float angularImpulse) {
    body.applyAngularImpulse(-angularImpulse);
  }
  
  public abstract void update();
  public abstract void display();
}

class CircularObject extends WorldObject {
  private final float radius, diameter;
  
  public CircularObject(float diameter, Vec2 location, float angle, Vec2 linearVelocity, 
                      float angularVelocity, float linearDamping, 
                      float angularDamping, float friction, float restitution,
                      float density, color fillColor, color strokeColor,
                      float strokeWeightValue, Box2DProcessing box2d) {
    super(location, angle, linearVelocity, angularVelocity, linearDamping, angularDamping, friction, restitution, density, fillColor, strokeColor, strokeWeightValue, box2d);
    this.diameter = diameter;
    this.radius = diameter / 2f;
    createBody();
  }
  
  private void createBody() {
    setBody(getWorld().createBody(getBodyDef()));
    
    CircleShape cs = new CircleShape();
    cs.setRadius(getWorld().scalarPixelsToWorld(radius));
    getFixtureDef().setShape(cs);
    
    getBody().createFixture(getFixtureDef());
  }
  
  public void update() {
    
  }
  
  public void display() {
    pushMatrix();
    translateToBody();
    pushStyle();
    applyStyle();
    ellipse(0, 0, diameter, diameter);
    popStyle();
    popMatrix();
  }
}

class RectangularObject extends WorldObject {
  private final float width, height;
  
  public RectangularObject(float width, float height, Vec2 location, float angle, Vec2 linearVelocity, 
                      float angularVelocity, float linearDamping, 
                      float angularDamping, float friction, float restitution,
                      float density, color fillColor, color strokeColor,
                      float strokeWeightValue, Box2DProcessing box2d) {
    super(location, angle, linearVelocity, angularVelocity, linearDamping, angularDamping, friction, restitution, density, fillColor, strokeColor, strokeWeightValue, box2d);
    this.width = width;
    this.height = height;
    createBody();
  }
  
  private void createBody() {
    setBody(getWorld().createBody(getBodyDef()));
    
    PolygonShape ps = new PolygonShape();
    ps.setAsBox(getWorld().scalarPixelsToWorld(width / 2), getWorld().scalarPixelsToWorld(height / 2));
    getFixtureDef().setShape(ps);
    
    getBody().createFixture(getFixtureDef());
  }
  
  public void update() {
    
  }
  
  public void display() {
    pushMatrix();
    translateToBody();
    pushStyle();
    applyStyle();
    rect(0, 0, width, height);
    popStyle();
    popMatrix();
  }
}
