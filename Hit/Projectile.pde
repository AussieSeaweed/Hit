abstract class Projectile extends Entity {
  private WorldObject worldObject;
  private color fillColor, strokeColor;
  private float range, maxLifetimeMillis, strokeWeightValue;
  private Box2DProcessing box2d;
  private Vec2 initialLocation;
  private int spawnTime;
  private Entity firer;
  
  public Projectile(Vec2 location, float angle, float range, float maxLifetime,
                    color fillColor, color strokeColor, float strokeWeightValue,
                    Box2DProcessing box2d, Environment environment, Entity firer) {
    super("Projectile", environment);
    
    this.fillColor = fillColor;
    this.strokeColor = strokeColor;
    this.strokeWeightValue = strokeWeightValue;
    this.box2d = box2d;
    this.range = range;
    this.maxLifetimeMillis = maxLifetime * 1000;
    this.firer = firer;
    
    this.initialLocation = location.clone();
    this.spawnTime = millis();
    
    worldObject = createWorldObject(location, angle);
    worldObject.setUserData(this);
  }
  
  public color getFill() {
    return fillColor;
  }
  
  public color getStroke() {
    return strokeColor;
  }
  
  public float getStrokeWeight() {
    return strokeWeightValue;
  }
  
  public float getRange() {
    return range;
  }
  
  protected Box2DProcessing getWorld() {
    return box2d;
  }
  
  protected Entity getFirer() {
    return firer;
  }
  
  public float getDistanceTravelled() {
    return initialLocation.sub(getLocation()).length();
  }
  
  public float getLifetime() {
    return millis() - spawnTime;
  }
  
  public void destroy() {
    worldObject.destroy();    
  }
  
  public float getMass() {
    return worldObject.getMass();
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
  
  public Vec2 getLinearVelocity() {
    return worldObject.getLinearVelocity();
  }
  
  public void setLinearVelocity(Vec2 velocity) {
    worldObject.setLinearVelocity(velocity);
  }
  
  public float getAngularVelocity() {
    return worldObject.getAngularVelocity();
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
  
  public void update() {
    worldObject.update();
    
    if (getDistanceTravelled() > range || getLifetime() > maxLifetimeMillis)
      markForDeletion();
  }
  
  public void display() {
    worldObject.display();
  }
  
  public boolean hasImmunity(Entity entity) {
    return firer == entity;
  }
  
  public void damage(WorldEntity worldEntity) {
    worldEntity.damage(getDamage());
    getEnvironment().createFeed(firer, worldEntity);
  }
  
  protected abstract WorldObject createWorldObject(Vec2 location, float angle);
  public abstract int getDamage();
  public abstract boolean destroyOnHit();
}

class PistolRound extends Projectile {
  protected final float width = 3.5f, height =  2f, velocity = 5000, probabilityOfImpaling = 0.01;
  protected final int damage;
  
  public PistolRound(Vec2 location, float angle, int damage, Box2DProcessing box2d, Environment environment, Entity firer) {
    super(location, angle, 2500, 3, color(173, 153, 0), color(0), 0, box2d, environment, firer);
    this.damage = damage;
  }
  
  protected WorldObject createWorldObject(Vec2 location, float angle) {
    return new RectangularObject(width, height, location, angle, getUnitVectorOf(angle).mul(velocity), 0, 0, 0, 0, 0.1, 1, getFill(), getStroke(), getStrokeWeight(), getWorld());
  }
  
  public int getDamage() {
    return damage;
  }
  
  public float getLongestDistanceFromCenter() {
    return sqrt(pow(width + getStrokeWeight(), 2) + pow(height + getStrokeWeight() / 2, 2));
  }
  
  public boolean destroyOnHit() {
    return random(1) >= probabilityOfImpaling;
  }
}

class RifleRound extends Projectile {
  protected final float width = 7f, height =  3f, velocity = 2000, probabilityOfImpaling = 0.25;
  protected final int damage;
  
  public RifleRound(Vec2 location, float angle, int damage, Box2DProcessing box2d, Environment environment, Entity firer) {
    super(location, angle, 10000, 3, color(173, 153, 0), color(0), 0, box2d, environment, firer);
    this.damage = damage;
  }
  
  protected WorldObject createWorldObject(Vec2 location, float angle) {
    return new RectangularObject(width, height, location, angle, getUnitVectorOf(angle).mul(velocity), 0, 0, 0, 0, 0.1, 1, getFill(), getStroke(), getStrokeWeight(), getWorld());
  }
  
  public int getDamage() {
    return damage;
  }
  
  public float getLongestDistanceFromCenter() {
    return sqrt(pow(width + getStrokeWeight(), 2) + pow(height + getStrokeWeight() / 2, 2));
  }
  
  public boolean destroyOnHit() {
    return random(1) >= probabilityOfImpaling;
  }
}

class SniperRound extends Projectile {
  protected final float width = 10f, height =  3f, velocity = 20000;
  protected final int damage;
  protected int numImpaled;
  
  public SniperRound(Vec2 location, float angle, int damage, Box2DProcessing box2d, Environment environment, Entity firer) {
    super(location, angle, 25000, 3, color(173, 153, 0), color(0), 0, box2d, environment, firer);
    this.damage = damage;
  }
  
  protected WorldObject createWorldObject(Vec2 location, float angle) {
    return new RectangularObject(width, height, location, angle, getUnitVectorOf(angle).mul(velocity), 0, 0, 0, 0, 0.1, 1, getFill(), getStroke(), getStrokeWeight(), getWorld());
  }
  
  public int getDamage() {
    return damage;
  }
  
  public float getLongestDistanceFromCenter() {
    return sqrt(pow(width + getStrokeWeight(), 2) + pow(height + getStrokeWeight() / 2, 2));
  }
  
  public boolean destroyOnHit() {
    return false;
  }
}

class Buckshot extends Projectile {
  protected final float diameter = 5f, velocity = 3500;
  protected final int damage;
  
  public Buckshot(Vec2 location, float angle, int damage, Box2DProcessing box2d, Environment environment, Entity firer) {
    super(location, angle, 2500, 3, color(100), color(100), 0, box2d, environment, firer);
    this.damage = damage;
  }
  
  protected WorldObject createWorldObject(Vec2 location, float angle) {
    return new CircularObject(diameter, location, angle, getUnitVectorOf(angle).mul(velocity), 0, 0, 0, 0, 0.1, 1, getFill(), getStroke(), getStrokeWeight(), getWorld());
  }
  
  public int getDamage() {
    return int(damage * (getRange() - getDistanceTravelled()) / getRange());
  }
  
  public float getLongestDistanceFromCenter() {
    return diameter / 2f;
  }
  
  public boolean destroyOnHit() {
    return true;
  }
}

class Rocket extends Projectile {
  protected final float width = 30f, height =  7f, velocity = 2000, explosionRange = 250f, explosionLifeTime = 0.5;
  protected final int directHitDamage, explosiveDamage;
  protected final int detail = 36;
  
  public Rocket(Vec2 location, float angle, int directHitDamage, int explosiveDamage, Box2DProcessing box2d, Environment environment, Entity firer) {
    super(location, angle, 2500, 3, color(217, 179, 140), color(217, 179, 140), 0, box2d, environment, firer);
    this.directHitDamage = directHitDamage;
    this.explosiveDamage = explosiveDamage;
  }
  
  protected WorldObject createWorldObject(Vec2 location, float angle) {
    return new RectangularObject(width, height, location, angle, getUnitVectorOf(angle).mul(velocity), 0, 0, 0, 0, 0.1, 1, getFill(), getStroke(), getStrokeWeight(), getWorld());
  }
  
  public int getDamage() {
    return directHitDamage;
  }
  
  public float getLongestDistanceFromCenter() {
    return sqrt(pow(width + getStrokeWeight(), 2) + pow(height + getStrokeWeight() / 2, 2));
  }
  
  public boolean destroyOnHit() {
    return true;
  }
  
  public void destroy() {
    Vec2 explosionPoint = getLocation();
    Environment environment = getEnvironment();
    LinkedList<Entity> explosionProjectiles = new LinkedList<Entity>();
    super.destroy();
    float angleStep = TWO_PI / detail;
    for (float angle = 0; angle < TWO_PI; angle += angleStep) {
      ExplosionProjectile explosionProjectile = new ExplosionProjectile(explosionPoint, explosiveDamage, angle, explosionRange, explosionLifeTime, getWorld(), environment, getFirer());
      explosionProjectiles.add(explosionProjectile);
    }
    AddEntitiesEvent addEntitiesEvent = new AddEntitiesEvent(explosionProjectiles, environment);
    game.addEvent(addEntitiesEvent);
    environment.addParticleSystem(new Explosion(explosionPoint, environment));
  }
}

class Grenade extends Projectile {
  protected final float width = 12f, height = 6f, velocity = 2000, maxInitialAngularVelocity = TAU, explosionRange = 200f, explosionLifeTime = 0.5;
  protected final int directHitDamage, explosiveDamage;
  protected final int detail = 30;
  
  public Grenade(Vec2 location, float angle, int directHitDamage, int explosiveDamage, Box2DProcessing box2d, Environment environment, Entity firer) {
    super(location, angle, 100000, 2, color(173, 153, 0), color(0), 0, box2d, environment, firer);
    this.directHitDamage = directHitDamage;
    this.explosiveDamage = explosiveDamage;
  }
  
  public WorldObject createWorldObject(Vec2 location, float angle) {
    return new RectangularObject(width, height, location, angle, getUnitVectorOf(angle).mul(velocity), random(-maxInitialAngularVelocity, maxInitialAngularVelocity), 4, 0, 0, 0.1, 1, getFill(), getStroke(), getStrokeWeight(), getWorld());
  }
  
  public int getDamage() {
    return directHitDamage;
  }
  
  public float getLongestDistanceFromCenter() {
    return sqrt(pow(width + getStrokeWeight(), 2) + pow(height + getStrokeWeight() / 2, 2));
  }
  
  public boolean destroyOnHit() {
    return true;
  }
  
  public void destroy() {
    Vec2 explosionPoint = getLocation();
    Environment environment = getEnvironment();
    LinkedList<Entity> explosionProjectiles = new LinkedList<Entity>();
    super.destroy();
    float angleStep = TWO_PI / detail;
    for (float angle = 0; angle < TWO_PI; angle += angleStep) {
      ExplosionProjectile explosionProjectile = new ExplosionProjectile(explosionPoint, explosiveDamage, angle, explosionRange, explosionLifeTime, getWorld(), environment, getFirer());
      explosionProjectiles.add(explosionProjectile);
    }
    AddEntitiesEvent addEntitiesEvent = new AddEntitiesEvent(explosionProjectiles, environment);
    game.addEvent(addEntitiesEvent);
    environment.addParticleSystem(new Explosion(explosionPoint, environment));
  }
}

class ExplosionProjectile extends Projectile {
  protected final float diameter = 0.5f, velocity = 1000000;
  protected final int damage;
  
  public ExplosionProjectile(Vec2 location, int damage, float angle, float range, float maxLifeTime, Box2DProcessing box2d, Environment environment, Entity firer) {
    super(location, angle, range, maxLifeTime, color(255, 0), color(255, 0), 0, box2d, environment, firer); // DEBUG: make invisible
    
    this.damage = damage;
  }
  
  public WorldObject createWorldObject(Vec2 location, float angle) {  // TODO MAKE SURE THAT IT REACHES THE BLAST RADIUS
    return new CircularObject(diameter, location, angle, getUnitVectorOf(angle).mul(velocity), 0, 30, 0, 0, 0.1, 10000, getFill(), getStroke(), getStrokeWeight(), getWorld());
  }
  
  public int getDamage() {
    return int(damage * (getRange() - getDistanceTravelled()) / getRange());
  }
  
  public float getLongestDistanceFromCenter() {
    return diameter;
  }
  
  public boolean destroyOnHit() {
    return false;
  }
}
