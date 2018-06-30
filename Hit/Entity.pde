abstract class Entity {
  private Environment environment;
  private boolean markedForDeletion;
  private String name;
  private final float noiseOffset;
  
  public Entity(String name, Environment environment) {
    this.name = name;
    this.environment = environment;
    markedForDeletion = false;
    noiseOffset = getNoiseOffset();
  }
  
  public void markForDeletion() {
    markedForDeletion = true;
  }
  
  public boolean isMarkedForDeletion() {
    return markedForDeletion;
  }

  public String getName() {
    return name;
  }

  public Environment getEnvironment() {
    return environment;
  }
  
  protected float getNoise() {
    return noise(millis() / 1000f + noiseOffset);
  }
  
  public abstract void destroy();
  public abstract float getMass();
  public abstract Vec2 getLocation();
  public abstract void setLocation(Vec2 location);
  public abstract float getAngle();
  public abstract void setAngle(float angle);
  public abstract void setTransform(Vec2 location, float angle);
  public abstract Vec2 getLinearVelocity();
  public abstract void setLinearVelocity(Vec2 velocity);
  public abstract float getAngularVelocity();
  public abstract void setAngularVelocity(float angularVelocity);
  public abstract void setLinearDamping(float linearDamping);
  public abstract void setAngularDamping(float angularDamping);
  public abstract void translateToEntity();
  public abstract void update();
  public abstract void display();
  public abstract float getLongestDistanceFromCenter();
}

abstract class WorldEntity extends Entity {
  private final color fillColor, strokeColor;
  private WorldObject worldObject;
  private final float diameter, radius, strokeWeightValue, minLookingAngleMultiplier = 1.5, maxLookingAngleMultiplier = 2;
  private Box2DProcessing box2d;
  private int health;
  
  public WorldEntity(String name, Vec2 location, float angle, float diameter, color fillColor, color strokeColor, float strokeWeightValue, Box2DProcessing box2d, Environment environment) {
    super(name, environment);
    this.diameter = diameter;
    this.radius = diameter / 2f;
    this.fillColor = fillColor;
    this.strokeColor = strokeColor;
    this.strokeWeightValue = strokeWeightValue;
    this.box2d = box2d;
    createWorldObject(location, angle);
    health = getMaxHealth();
  }
  
  protected void createWorldObject(Vec2 location, float angle) {
    worldObject = new CircularObject(diameter, location, angle, new Vec2(), 0, 10, 10, 0.5, 0.1, 1, fillColor, strokeColor, strokeWeightValue, box2d);
    worldObject.setUserData(this);
  }
  
  protected WorldObject getWorldObject() {
    return worldObject;
  }
  
  protected Box2DProcessing getWorld() {
    return box2d;
  }
  
  public void pointTo(float x, float y) {
    pointTo(new Vec2(x, y));
  }
  
  public void pointTo(Vec2 target) {
    pointTo(getAngleOf(target.sub(getLocation())));
  }
  
  public void pointTo(float angle) {
    setAngle(angle);
  }
  
  public void destroy() {
    getEnvironment().addParticleSystem(createHitEffect(getLocation()));
    worldObject.destroy();
  }
  
  public float getMass() {
    return worldObject.getMass();
  }
  
  public boolean isDead() {
    return health == 0;
  }
  
  public int getHealth() {
    return health;
  }
  
  public void damage(int delta) {
    health = max(health - delta, 0);
  }
  
  public Vec2 getLocation() {
    return worldObject.getLocation();
  }
  
  public void setLocation(Vec2 location) {
    worldObject.setLocation(location);
  }
  
  public float getAngle() {
    return worldObject.getAngle();
  }
  
  public void setAngle(float angle) {
    worldObject.setAngle(angle);
  }
  
  public void setTransform(Vec2 location, float angle) {
    worldObject.setTransform(location, angle);
  }
  
  public void setLinearVelocity(Vec2 velocity) {
    worldObject.setLinearVelocity(velocity);
  }
  
  public void setAngularVelocity(float angularVelocity) {
    worldObject.setAngularVelocity(angularVelocity);
  }
  
  public void setLinearDamping(float linearDamping) {
    worldObject.setLinearDamping(linearDamping);    
  }
  
  public void setAngularDamping(float angularDamping) {
    worldObject.setAngularDamping(angularDamping);
  }
  
  public void translateToEntity() {
    worldObject.translateToBody();
  }
  
  public void moveTowards(float angle, float movingForce) {
    moveTowards(getUnitVectorOf(angle), movingForce);
  }
  
  public void moveTowards(Vec2 direction, float movingForce) {
    direction.mulLocal(movingForce);
    worldObject.applyForceToCenter(direction.sub(getLinearVelocity()));
  }
  
  public void update() {
    worldObject.update();
    
    if (isDead()) markForDeletion();
  }
  
  public void display() {
    worldObject.display();
    displayPointer();
  }
  
  public Vec2 getLinearVelocity() {
    return worldObject.getLinearVelocity();
  }
  
  public float getAngularVelocity() {
    return worldObject.getAngularVelocity();
  }
  
  public void displayPointer() {
    pushMatrix();
    worldObject.translateToBody();
    pushStyle();
    worldObject.applyStyle();
    line(0, 0, radius, 0);
    popStyle();
    popMatrix();
  }
  
  public float getLongestDistanceFromCenter() {
    return radius + strokeWeightValue / 2;
  }
  
  public void applyForce(Vec2 force, Vec2 location) {
    worldObject.applyForce(force, location);
  }
  
  public void applyForceToCenter(Vec2 force) {
    worldObject.applyForceToCenter(force);
  }
  
  public Vec2 getVectorToEdge(Vec2 target) {
    return getVectorToEdge(target, 0);
  }
  
  public Vec2 getVectorToEdge(Vec2 target, float additionalDistance) {
    Vec2 direction = target.sub(getLocation());
    direction.normalize();
    direction.mulLocal(radius + additionalDistance);
    return getLocation().add(direction);
  }
  
  public Vec2 getVectorToEdgeOpposite(Vec2 target, Vec2 velocity, float additionalDistance) {
    Vec2 direction = getLocation().sub(target);
    float angle = getAngleBetween(direction, velocity);
    float hypotenuse = getDistanceBetween(getLocation(), target);
    float offsetScalar = 2 * cos(angle) * hypotenuse;
    Vec2 offsetVector = velocity.clone();
    offsetVector.normalize();
    offsetVector.mulLocal(offsetScalar + additionalDistance);
    return target.add(offsetVector);
  }
  
  public void lookTowards(Vec2 targetLocation) {
    float angle = getAngleOf(targetLocation.sub(getLocation()));
    float direction = (angle - getAngle()) / TAU;
    direction -= round(direction);
    direction *= TAU;
    getWorldObject().applyAngularImpulse(direction * map(getNoise(), 0, 1, minLookingAngleMultiplier, maxLookingAngleMultiplier));
  }
  
  protected abstract int getMaxHealth();
  public abstract void beginAction();
  public abstract void endAction();
  public abstract ParticleSystem createHitEffect(Vec2 location);
}

class Enemy extends WorldEntity {
  private int rank;
  private Firearm firearm;
  private final color bloodColor = color(155, 0, 0);
  private final int maxHealth = 100;
  private final float movingForce = 3000f, maxMovingAngleOffset = 2f * PI / 3f;
  
  public Enemy(String name, float diameter, Vec2 location, float angle, int rank, Box2DProcessing box2d, Environment environment) {
    super(name, location, angle, diameter, color(map(rank, 1, 8, 0, 255)), color(map(rank, 1, 8, 255, 0), 0, 0), 1, box2d, environment);
    createWeapon();
  }
  
  public void createWeapon() {
    firearm = getRandomFirearm(this, getWorld(), getEnvironment());
  }
  
  public int getRank() {
    return rank;
  }

  public void beginAction() {
    firearm.setActive(true);
  }

  public void endAction() {
    firearm.setActive(false);
  }
  
  public void update() {
    super.update();
    firearm.update();
    
    if (!getEnvironment().isPlayerDead()) {
      Vec2 playerLocation = getEnvironment().getPlayerLocation();
      
      moveTowards(getAngleOf(playerLocation.sub(getLocation())) + map(getNoise(), 0, 1, -maxMovingAngleOffset, maxMovingAngleOffset), movingForce * firearm.getMovingForceMultiplier() * getMass());
      
      if (getEnvironment().isVisible(this))
        lookTowards(playerLocation);
      
      if (getEnvironment().isVisible(this) && 
          getAngleBetween(getUnitVectorOf(getAngle()), getUnitVectorOf(getAngleOf(playerLocation.sub(getLocation())))) <= 
          atan(getEnvironment().getPlayer().getLongestDistanceFromCenter() / getDistanceBetween(getLocation(), playerLocation))) {
        beginAction();
      } else {
        endAction();
      }
    } else {
      endAction();
    }
  }
  
  public void reload() {
    firearm.beginReload();
  }
  
  public ParticleSystem createHitEffect(Vec2 location) {
    return new BloodEffect(location, bloodColor, getEnvironment());
  }
  
  public void display() {
    super.display();
    firearm.display();
  }
  
  protected int getMaxHealth() {
    return maxHealth;
  }
}

class Player extends WorldEntity {
  private Firearm[] firearms;
  private int weaponIndex;
  private boolean movingUp, movingDown, movingLeft, movingRight;
  private final Vec2 upDirection = new Vec2(0, -1), downDirection = new Vec2(0, 1), leftDirection = new Vec2(-1, 0), rightDirection = new Vec2(1, 0);
  private final float movingForce = 5000;
  private final color bloodColor = color(175, 0, 0);
  private final int maxHealth = 1000;
  
  public Player(String name, Vec2 location, float angle, float diameter, color fillColor, color strokeColor, float strokeWeightValue, Box2DProcessing box2d, Environment environment) {
    super(name, location, angle, diameter, fillColor, strokeColor, strokeWeightValue, box2d, environment);
    weaponIndex = 0;
    movingUp = false;
    movingDown = false;
    movingLeft = false;
    movingRight = false;
    createWeapons();
  }
  
  private void createWeapons() {
    firearms = new Firearm[7];
    firearms[0] = new Pistol(20, 5, 1, PI / 36f, 18, 18, Firearm.SEMI_AUTOMATIC, false, this, getWorld(), getEnvironment());
    firearms[1] = new Rifle(25, 10, 1, PI / 360f, 30, 30, Firearm.AUTOMATIC, true, this, getWorld(), getEnvironment());
    firearms[2] = new Minigun(25, 100, 2, PI / 12f, 1000, 1000, this, getWorld(), getEnvironment());
    firearms[3] = new SniperRifle(500, 2, 1.5, PI / 1020f, 10, 10, Firearm.SEMI_AUTOMATIC, false, this, getWorld(), getEnvironment());
    firearms[4] = new Shotgun(20, 20, 2, 1, PI / 24f, 6, 6, Firearm.SEMI_AUTOMATIC, false, this, getWorld(), getEnvironment());
    firearms[5] = new GrenadeLauncher(100, 150, 3, 1, PI / 72f, 6, 6, Firearm.AUTOMATIC, false, this, getWorld(), getEnvironment());
    firearms[6] = new RocketLauncher(1000, 200, 1, 1, PI / 72f, 1, 1, Firearm.SEMI_AUTOMATIC, false, this, getWorld(), getEnvironment());
  }
  
  public void beginAction() {
    getSelectedFirearm().setActive(true);
  }
  
  public void endAction() {
    getSelectedFirearm().setActive(false);
  }
  
  private Firearm getSelectedFirearm() {
    return firearms[weaponIndex];
  }
  
  public void changeFirearm(int delta) {
    getSelectedFirearm().switchOff();
    delta %= firearms.length;
    weaponIndex = (weaponIndex + delta) % firearms.length;
    if (weaponIndex < 0) weaponIndex += firearms.length;
  }
  
  public void update() {
    super.update();
    getSelectedFirearm().update();
    
    if (isMoving())
      moveTowards(getMovingDirection(), movingForce * getSelectedFirearm().getMovingForceMultiplier() * getMass());    
  }
  
  public void display() {
    super.display();
    getSelectedFirearm().display();
  }
  
  public void reload() {
    getSelectedFirearm().beginReload();
  }
  
  public void moveUp(boolean movingUp) {
    this.movingUp = movingUp;
  }
  
  public void moveDown(boolean movingDown) {
    this.movingDown = movingDown;
  }
  
  public void moveLeft(boolean movingLeft) {
    this.movingLeft = movingLeft;
  }
  
  public void moveRight(boolean movingRight) {
    this.movingRight = movingRight;
  }
  
  public boolean isMoving() {
    return movingUp || movingDown || movingLeft || movingRight;
  }
  
  public Vec2 getMovingDirection() {
    Vec2 direction = new Vec2();
    
    if (movingUp) direction.addLocal(upDirection);
    if (movingDown) direction.addLocal(downDirection);
    if (movingLeft) direction.addLocal(leftDirection);
    if (movingRight) direction.addLocal(rightDirection);
    
    direction.normalize();
    
    return direction;
  }
  
  public ParticleSystem createHitEffect(Vec2 location) { 
    return new BloodEffect(location, bloodColor, getEnvironment());
  }
  
  protected int getMaxHealth() {
    return maxHealth;
  }
}
