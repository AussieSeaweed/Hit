abstract class Firearm {
  public final static boolean SEMI_AUTOMATIC = false;
  public final static boolean AUTOMATIC = true;
  
  private final float rps, firingIntervalMillis, reloadTime, maxAngleOffset;
  private final int magazineCapacity;
  private int lastFiredTime, reloadStartedTime;
  private int bulletsLeft;
  private boolean reloading, active;
  private boolean firingMode;
  private boolean firingModeCyclable;
  private Entity user;
  private Box2DProcessing box2d;
  private Environment environment;
  private final float noiseOffset;
  
  public Firearm(float rps, float reloadTime, float maxAngleOffset, int magazineCapacity, int bulletsLeft, boolean firingMode, boolean firingModeCyclable, Entity user, Box2DProcessing box2d, Environment environment) {
    this.rps = rps;
    this.firingIntervalMillis = 1f / rps * 1000;
    this.reloadTime = reloadTime * 1000f;
    this.maxAngleOffset = maxAngleOffset;
    this.magazineCapacity = magazineCapacity;
    this.bulletsLeft = bulletsLeft;
    this.reloading = false;
    this.active = false;
    this.firingModeCyclable = firingModeCyclable;
    this.firingMode = firingMode;
    this.user = user;
    this.box2d = box2d;
    this.environment = environment;
    noiseOffset = getNoiseOffset();
    
    lastFiredTime = -ceil(firingIntervalMillis);
    reloadStartedTime = 0;
    
    reloading = false;
    active = false;
  }
  
  protected Entity getUser() {
    return user;
  }
  
  protected Box2DProcessing getWorld() {
    return box2d;
  }
  
  protected Environment getEnvironment() {
    return environment;
  }
  
  public int getMagazineCapacity() {
    return magazineCapacity;
  }
  
  public boolean isReloading() {
    return reloading;
  }
  
  public void beginReload() {
    if (!reloading) {
      reloading = true;
      reloadStartedTime = millis();
      //animateReloading();
    }
  }
  
  public void endReload() {
    reloading = false;
    bulletsLeft = magazineCapacity;
  }
  
  public String getFiringMode() {
    return firingMode ? "Automatic" : "Semi-Automatic";
  }
  
  public void cycleFiringMode() {
    if (firingModeCyclable) firingMode = !firingMode;
  }
  
  public boolean isActive() {
    return active;
  }
  
  public void setActive(boolean active) {
    this.active = active;
  }
  
  public boolean fireable() {
    return bulletsLeft > 0 && active && !reloading && millis() - lastFiredTime >= firingIntervalMillis;
  }
  
  public void fire() {
    lastFiredTime = millis();
    bulletsLeft--;
    createProjectile();
    //animateFiring();
    if (firingMode == SEMI_AUTOMATIC)
      setActive(false);
  }
  
  public void update() {
    if (reloading && millis() - reloadStartedTime >= reloadTime)
      endReload();
      
    if (fireable())
      fire();
      
    if (bulletsLeft == 0)
      beginReload();
  }
  
  protected float getRandomAngleOffset() {
    return random(-maxAngleOffset, maxAngleOffset);
  }
  
  protected float getNoiseAngleOffset() {
    return map(getNoise(), 0, 1, -maxAngleOffset, maxAngleOffset);
  }
  
  public void swing() {
    //animateSwinging();
    // TODO: SWING, handle damage with getSwingDamate();
  }
  
  public void switchOff() {
    reloading = false;
    setActive(false);
  }
  
  protected float getNoise() {
    return noise(millis() / 1000f + noiseOffset);
  }
  
  public abstract Vec2 getBarrelTipLocation();
  public abstract void createProjectile();
  //public abstract float getSwingDamage();
  //public abstract void animateFiring();
  //public abstract void animateSwinging(); TODO: IMPLEMENT THESE
  //public abstract void animateReloading();
  public abstract void display();
  public abstract float getMovingForceMultiplier();
}

// TODO: USE IMAGES TO DISPLAY

class Pistol extends Firearm {
  private final int damage;
  private final float movingForceMultiplier = 1;
  /*float rps, float reloadTime, float maxAngleOffset, int magazineCapacity, int bulletsLeft, boolean firingMode, boolean firingModeCyclable, Entity user, Box2DProcessing box2d, Environment environment*/
  
  public Pistol(int damage, float rps, float reloadTime, float maxAngleOffset, int magazineCapacity, int bulletsLeft, boolean firingMode, boolean firingModeCyclable, Entity user, Box2DProcessing box2d, Environment environment) {
    super(rps, reloadTime, maxAngleOffset, magazineCapacity, bulletsLeft, firingMode, firingModeCyclable, user, box2d, environment);
    this.damage = damage;
  }
  
  public void display() {
    pushMatrix();
    getUser().translateToEntity();
    displayWeapon();
    popMatrix();
  }
  
  public void displayWeapon() {
    pushStyle();
    fill(0);
    stroke(0);
    strokeWeight(1);
    rotate(HALF_PI);
    translate(15, -15);
    rect(0, 0, 4, 20);
    popStyle();
  }
  
  public Vec2 getBarrelTipLocation() {
    return getUser().getLocation().add(getUnitVectorOf(getUser().getAngle()).mul(30));
  }
  
  public void createProjectile() {
    getEnvironment().addEntity(new PistolRound(getBarrelTipLocation(), getUser().getAngle() + getRandomAngleOffset(), damage, getWorld(), getEnvironment(), getUser()));
  }
  
  public float getMovingForceMultiplier() {
    return movingForceMultiplier;
  }
}

class Rifle extends Firearm {
  private final int damage;
  private final float movingForceMultiplier = 0.8;

  public Rifle(int damage, float rps, float reloadTime, float maxAngleOffset, int magazineCapacity, int bulletsLeft, boolean firingMode, boolean firingModeCyclable, Entity user, Box2DProcessing box2d, Environment environment) {
    super(rps, reloadTime, maxAngleOffset, magazineCapacity, bulletsLeft, firingMode, firingModeCyclable, user, box2d, environment);
    this.damage = damage;
  }

  public void display() {
    pushMatrix();
    getUser().translateToEntity();
    displayWeapon();
    popMatrix();
  }
  
  public void displayWeapon() {
    pushStyle();
    fill(0);
    stroke(0);
    strokeWeight(1);
    rotate(HALF_PI);
    translate(15, -15);
    rect(0, 0, 4, 40);
    popStyle();
  }

  public Vec2 getBarrelTipLocation() {
    return getUser().getLocation().add(getUnitVectorOf(getUser().getAngle()).mul(30));
  }
  
  public void createProjectile() {
    getEnvironment().addEntity(new RifleRound(getBarrelTipLocation(), getUser().getAngle() + getRandomAngleOffset(), damage, getWorld(), getEnvironment(), getUser()));
  }
  
  public float getMovingForceMultiplier() {
    return movingForceMultiplier;
  }
}

class SniperRifle extends Firearm {
  private final int damage;
  private final float movingForceMultiplier = 0.7;

  public SniperRifle(int damage, float rps, float reloadTime, float maxAngleOffset, int magazineCapacity, int bulletsLeft, boolean firingMode, boolean firingModeCyclable, Entity user, Box2DProcessing box2d, Environment environment) {
    super(rps, reloadTime, maxAngleOffset, magazineCapacity, bulletsLeft, firingMode, firingModeCyclable, user, box2d, environment);
    this.damage = damage;
  }

  public void display() {
    pushMatrix();
    getUser().translateToEntity();
    displayWeapon();
    popMatrix();
  }
  
  public void displayWeapon() {
    pushStyle();
    fill(0);
    stroke(0);
    strokeWeight(1);
    rotate(HALF_PI);
    translate(15, -15);
    rect(0, 0, 3, 60);
    popStyle();
  }

  public Vec2 getBarrelTipLocation() {
    return getUser().getLocation().add(getUnitVectorOf(getUser().getAngle()).mul(30));
  }
  
  public void createProjectile() {
    getEnvironment().addEntity(new SniperRound(getBarrelTipLocation(), getUser().getAngle() + getRandomAngleOffset(), damage, getWorld(), getEnvironment(), getUser()));
  }
  
  public float getMovingForceMultiplier() {
    return movingForceMultiplier;
  }
}

class Minigun extends Firearm {
  private final int damage;
  private final float movingForceMultiplierWhenInactive = 0.7, movingForceMultiplierWhenActive = 0.1, movingForceMultiplierStep = 1;
  private float movingForceMultiplier;
  
  public Minigun(int damage, float rps, float reloadTime, float maxAngleOffset, int magazineCapacity, int bulletsLeft, Entity user, Box2DProcessing box2d, Environment environment) {
    super(rps, reloadTime, maxAngleOffset, magazineCapacity, bulletsLeft, Firearm.AUTOMATIC, false, user, box2d, environment);
    this.damage = damage;
    this.movingForceMultiplier = movingForceMultiplierWhenInactive;
  }
  
  public void display() {
    pushMatrix();
    getUser().translateToEntity();
    displayWeapon();
    popMatrix();
  }
  
  public void displayWeapon() {
    pushStyle();
    fill(0);
    stroke(0);
    strokeWeight(1);
    rotate(HALF_PI);
    translate(15, -15);
    rect(0, 0, 6, 40);
    popStyle();
  }
  
  public void update() {
    super.update();

    if (isActive())
      movingForceMultiplier = max(movingForceMultiplierWhenActive, movingForceMultiplier - perSecond(movingForceMultiplierStep));
    else
      movingForceMultiplier = min(movingForceMultiplierWhenInactive, movingForceMultiplier + perSecond(movingForceMultiplierStep));
  }
  
  
  
  public Vec2 getBarrelTipLocation() {
    return getUser().getLocation().add(getUnitVectorOf(getUser().getAngle()).mul(30));
  }
  
  public void createProjectile() {
    getEnvironment().addEntity(new RifleRound(getBarrelTipLocation(), getUser().getAngle() + getRandomAngleOffset(), damage, getWorld(), getEnvironment(), getUser()));
  }
  
  public float getMovingForceMultiplier() {
    return movingForceMultiplier;
  }
}

class Shotgun extends Firearm {
  private final int buckshotDamage, numBuckshots;
  private final float movingForceMultiplier = 0.7;
  
  public Shotgun(int buckshotDamage, int numBuckshots, float rps, float reloadTime, float maxAngleOffset, int magazineCapacity, int bulletsLeft, boolean firingMode, boolean firingModeCyclable, Entity user, Box2DProcessing box2d, Environment environment) {
    super(rps, reloadTime, maxAngleOffset, magazineCapacity, bulletsLeft, firingMode, firingModeCyclable, user, box2d, environment);
    this.buckshotDamage = buckshotDamage;
    this.numBuckshots = numBuckshots;
  }
  
  public void display() {
    pushMatrix();
    getUser().translateToEntity();
    displayWeapon();
    popMatrix();
  }
  
  public void displayWeapon() {
    pushStyle();
    fill(0);
    stroke(0);
    strokeWeight(1);
    rotate(HALF_PI);
    translate(15, -15);
    rect(0, 0, 6, 40);
    popStyle();
  }
  
  public Vec2 getBarrelTipLocation() {
    return getUser().getLocation().add(getUnitVectorOf(getUser().getAngle()).mul(30));
  }
  
  public void createProjectile() {
    Vec2 barrelTipLocation = getBarrelTipLocation();
    for (int i = 0; i < numBuckshots; i++) {
      Buckshot buckshot = new Buckshot(barrelTipLocation, getUser().getAngle() + getRandomAngleOffset(), buckshotDamage, getWorld(), getEnvironment(), getUser());
      getEnvironment().addEntity(buckshot);
    }
  }
  
  public float getMovingForceMultiplier() {
    return movingForceMultiplier;
  }
}

class GrenadeLauncher extends Firearm {
  private final int directHitDamage, explosiveDamage;
  private final float movingForceMultiplier = 0.7;
  
  public GrenadeLauncher(int directHitDamage, int explosiveDamage, float rps, float reloadTime, float maxAngleOffset, int magazineCapacity, int bulletsLeft, boolean firingMode, boolean firingModeCyclable, Entity user, Box2DProcessing box2d, Environment environment) {
    super(rps, reloadTime, maxAngleOffset, magazineCapacity, bulletsLeft, firingMode, firingModeCyclable, user, box2d, environment);
    this.directHitDamage = directHitDamage;
    this.explosiveDamage = explosiveDamage;
  }
  
  public void display() {
    pushMatrix();
    getUser().translateToEntity();
    displayWeapon();
    popMatrix();
  }
  
  public void displayWeapon() {
    pushStyle();
    fill(0);
    stroke(0);
    strokeWeight(1);
    rotate(HALF_PI);
    translate(15, -15);
    rect(0, 0, 10, 30);
    popStyle();
  }
  
  public Vec2 getBarrelTipLocation() {
    return getUser().getLocation().add(getUnitVectorOf(getUser().getAngle()).mul(30));
  }
  
  public void createProjectile() {
    getEnvironment().addEntity(new Grenade(getBarrelTipLocation(), getUser().getAngle() + getRandomAngleOffset(), directHitDamage, explosiveDamage, getWorld(), getEnvironment(), getUser()));
  }
  
  public float getMovingForceMultiplier() {
    return movingForceMultiplier;
  }
}

class RocketLauncher extends Firearm {
  private final int directHitDamage, explosiveDamage;
  private final float movingForceMultiplier = 0.7;
  
  public RocketLauncher(int directHitDamage, int explosiveDamage, float rps, float reloadTime, float maxAngleOffset, int magazineCapacity, int bulletsLeft, boolean firingMode, boolean firingModeCyclable, Entity user, Box2DProcessing box2d, Environment environment) {
    super(rps, reloadTime, maxAngleOffset, magazineCapacity, bulletsLeft, firingMode, firingModeCyclable, user, box2d, environment);
    this.directHitDamage = directHitDamage;
    this.explosiveDamage = explosiveDamage;
  }
  
  public void display() {
    pushMatrix();
    getUser().translateToEntity();
    displayWeapon();
    popMatrix();
  }
  
  public void displayWeapon() {
    pushStyle();
    fill(0);
    stroke(0);
    strokeWeight(1);
    rotate(HALF_PI);
    translate(15, -15);
    rect(0, 0, 5, 60);
    popStyle();
  }
  
  public Vec2 getBarrelTipLocation() {
    return getUser().getLocation().add(getUnitVectorOf(getUser().getAngle()).mul(30));
  }
  
  public void createProjectile() {
    getEnvironment().addEntity(new Rocket(getBarrelTipLocation(), getUser().getAngle() + getRandomAngleOffset(), directHitDamage, explosiveDamage, getWorld(), getEnvironment(), getUser()));
  }
  
  public float getMovingForceMultiplier() {
    return movingForceMultiplier;
  }
}
