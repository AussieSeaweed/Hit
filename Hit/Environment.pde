class Environment {
  private class Camera {
    private Vec2 location;
    private Vec2 velocity;
    private Vec2 acceleration;
    private float angle;
    private float angularVelocity;
    private float angularAcceleration;
    private float chaseDampener;
    private float maxDistanceToTarget;
    
    public Camera(Vec2 location) {
      this.location = location;
      velocity = new Vec2();
      acceleration = new Vec2();
      angle = 0;
      angularVelocity = 0;
      angularAcceleration = 0;
      chaseDampener = 0.8;
      maxDistanceToTarget = 100;
    }
    
    public float getDiagonal() {
      return sqrt(width * width + height * height);
    }
    
    public Vec2 getLocation() {
      return location;
    }
    
    public Vec2 getTopLeftLocation() {
      return location.sub(new Vec2(width / 2f, height / 2f));
    }
    
    public Vec2 getBottomRightLocation() {
      return location.add(new Vec2(width /2f, height / 2f));
    }
    
    public void setLocation(float x, float y) {
      location.set(x, y);
    }
    
    public void update() {
      velocity.addLocal(acceleration);
      location.addLocal(velocity);
      acceleration.setZero();
      angularVelocity += angularAcceleration;
      angle += angularVelocity;
      angularAcceleration = 0;
    }
    
    public void move() {
      translate(-(location.x - width / 2f), -(location.y - height / 2f));
      rotate(angle);
    }
    
    public boolean isVisible(Entity entity) {
      float distance = entity.getLongestDistanceFromCenter();
      Vec2 target = entity.getLocation();
      return (location.x - width / 2 <= target.x + distance && target.x - distance <= location.x + width / 2) &&
              (location.y - height / 2 <= target.y + distance && target.y - distance <= location.y + height / 2);
    }
    
    public boolean isVisible(Vec2 target, float distance) {
      return (location.x - width / 2 <= target.x + distance && target.x - distance <= location.x + width / 2) &&
              (location.y - height / 2 <= target.y + distance && target.y - distance <= location.y + height / 2);
    }
    
    public void chase(Vec2 target) {
      Vec2 offset = target.sub(location);
      
      if (offset.length() > maxDistanceToTarget) {
        Vec2 difference = offset.clone();
        difference.normalize();
        difference.mulLocal(offset.length() - maxDistanceToTarget);
        acceleration.addLocal(difference);
      }
      
      offset.subLocal(velocity);
      acceleration.addLocal(offset.mul(chaseDampener));  // TODO: USE PERSECOND
    }
    
    public void chase(float target) {
      float offset = target - angle;
      offset *= chaseDampener;
      offset -= angularVelocity;
      angularAcceleration += offset;
    }
  }
  
  private final int maxNumEnemies = 10, scorePerKill = 10;
  private final float minEnemyDiameter = 40, maxEnemyDiameter = 50;
  private final float numCells = 10, backgroundCellBorderWeight = 3;
  private final color backgroundCellBorderColor = color(0), backgroundColor = color(255);
  
  private int numEnemiesSpawned;
  
  private Game game;
  private Box2DProcessing box2d;
  private Camera camera;
  
  private LinkedList<Entity> entities;
  private LinkedList<Enemy> enemies;
  private LinkedList<ParticleSystem> particleSystems;
  private Player player;
  
  public Environment(Game game) {
    this.game = game;
    numEnemiesSpawned = 0;
    
    box2d = new Box2DProcessing(game.getRoot());
    box2d.createWorld(new Vec2(0, 0), true, true);
    box2d.listenForCollisions();
    
    camera = new Camera(new Vec2(0, 0));
    
    entities = new LinkedList<Entity>();
    enemies = new LinkedList<Enemy>();
    particleSystems = new LinkedList<ParticleSystem>();
    Vec2 playerLocation = new Vec2(0, 0);
    player = new Player("Player", playerLocation, getAngleOf(new Vec2(mouseX, mouseY).sub(playerLocation)), 40, color(0, 255, 0), color(0), 2, box2d, this);
    
    addEnemies(maxNumEnemies);
  }
  
  private Vec2 getRandomEnemySpawnLocation(float offset) {
    float minDistanceFromPlayer = camera.getDiagonal() / 2f;
    float maxDistanceFromPlayer = camera.getDiagonal();
    Vec2 directionFromPlayer = getRandomUnitVector();
    directionFromPlayer.mulLocal(random(minDistanceFromPlayer, maxDistanceFromPlayer) + offset);
    return directionFromPlayer.add(getPlayerLocation());
  }
  
  private void addEnemies(int count) {
    for (int i = 0; i < count; i++) {
      float diameter = random(minEnemyDiameter, maxEnemyDiameter);
      Vec2 location = getRandomEnemySpawnLocation(diameter / 2f);
      Enemy enemy = new Enemy("Enemy " + ++numEnemiesSpawned, diameter, location, random(0, TAU), int(random(1, 9)), box2d, this);
      enemies.add(enemy);
    }
  }
  
  public void update() {
    box2d.step(perSecond(1f), 10, 8);
    box2d.world.clearForces();
    
    updateParticleSystems();
    updateEntities();
    updateEnemies();
    updatePlayer();
    
    camera.chase(player.getLocation());
    camera.update();
  }
  
  public void display() {
    pushMatrix();
    camera.move();
    displayBackground();
    displayEntities();
    displayEnemies();
    displayParticleSystems();
    player.display();
    popMatrix();
  }
  
  private void displayBackground() {
    pushStyle();
    background(backgroundColor);
    stroke(backgroundCellBorderColor);
    strokeWeight(backgroundCellBorderWeight);
    
    Vec2 topLeft = camera.getTopLeftLocation();
    Vec2 bottomRight = camera.getBottomRightLocation();
    float step = camera.getDiagonal() / numCells;
    
    for (float x = (topLeft.x - topLeft.x % step) - step; x <= bottomRight.x; x += step)
      line(x, topLeft.y, x, bottomRight.y);
    
    for (float y = (topLeft.y - topLeft.y % step) - step; y <= bottomRight.y; y += step)
      line(topLeft.x, y, bottomRight.x, y);
    
    popStyle();
  }
  
  private void updateParticleSystems() {
    for (ListIterator<ParticleSystem> it = particleSystems.listIterator(); it.hasNext();) {
      ParticleSystem particleSystem = it.next();
      particleSystem.update();
      
      if (particleSystem.isMarkedForDeletion())
        it.remove();
    }
  }
  
  private void updateEntities() {
    for (ListIterator<Entity> it = entities.listIterator(); it.hasNext();) {
      Entity entity = it.next();
      entity.update();
      
      if (entity.isMarkedForDeletion()) {
        entity.destroy();
        it.remove();
      }
    }
  }
  
  private void updateEnemies() {
    for (ListIterator<Enemy> it = enemies.listIterator(); it.hasNext();) {
      Enemy enemy = it.next();
      enemy.update();
      
      if (enemy.isMarkedForDeletion()) {
        enemy.destroy();
        it.remove();
      }
    }
    
    if (enemies.size() < maxNumEnemies)
      addEnemies(maxNumEnemies - enemies.size());
  }
  
  private void updatePlayer() {
    if (!player.isDead()) {
      player.pointTo(camera.getTopLeftLocation().add(new Vec2(mouseX, mouseY)));
      player.update();
    }
  }
  
  private void displayEntities() {
    for (Entity entity : entities)
      if (camera.isVisible(entity))
        entity.display();
  }
  
  private void displayEnemies() {
    for (Enemy enemy : enemies)
      if (camera.isVisible(enemy))
        enemy.display();
  }
  
  private void displayParticleSystems() {
    for (ParticleSystem particleSystem : particleSystems)
      particleSystem.display();
  }
  
  private void addEntity(Entity entity) {
    entities.add(entity);
  }
  
  private void addParticleSystem(ParticleSystem particleSystem) {
    particleSystems.add(particleSystem);
  }
  
  public boolean isVisible(Vec2 target, float longestDistanceFromCenter) {
    return camera.isVisible(target, longestDistanceFromCenter);
  }
  
  public boolean isVisible(Entity entity) {
    return camera.isVisible(entity);
  }
  
  public Vec2 getPlayerLocation() {
    return player.getLocation();
  }
  
  public Player getPlayer() {
    return player;
  }
  
  public boolean isPlayerDead() {
    return player.isDead();
  }
  
  public void createFeed(Entity entityA, Entity entityB) {
    if (entityA == player) {

    }
    
    if (entityB != player) {
      
    }
  }
  
  void keyPressed() {
    if (!isPlayerDead()) {
      if (key == CODED) {
        switch (keyCode) {
          case UP: {
            if (!isPlayerDead()) player.moveUp(true);
          }
          break;
          case DOWN: {
            if (!isPlayerDead()) player.moveDown(true);
          }
          break;
          case LEFT: {
            if (!isPlayerDead()) player.moveLeft(true);
          }
          break;
          case RIGHT: {
            if (!isPlayerDead()) player.moveRight(true);
          }
          break;
          default: break;
        }
      } else {
        switch (key) {
          case 'r': case 'R': {
            if (!isPlayerDead()) player.reload();
          }
          break;
          case 'w': case 'W': {
            if (!isPlayerDead()) player.moveUp(true);
          }
          break;
          case 's': case 'S': {
            if (!isPlayerDead()) player.moveDown(true);
          }
          break;
          case 'a': case 'A': {
            if (!isPlayerDead()) player.moveLeft(true);
          }
          break;
          case 'd': case 'D': {
            if (!isPlayerDead()) player.moveRight(true);
          }
          break;
          case 'f': case 'F': {
            if (!isPlayerDead()) player.setLocation(new Vec2(width / 2, height / 2));
          }
          break;
          default: break;
        }
      }
    }
  }
  
  void keyReleased() {
    if (key == CODED) {
      switch (keyCode) {
        case UP: {
          if (!isPlayerDead()) player.moveUp(false);
        }
        break;
        case DOWN: {
          if (!isPlayerDead()) player.moveDown(false);
        }
        break;
        case LEFT: {
          if (!isPlayerDead()) player.moveLeft(false);
        }
        break;
        case RIGHT: {
          if (!isPlayerDead()) player.moveRight(false);
        }
        break;
        default: break;
      }
    } else {
      switch (key) {
        case 'w': case 'W': {
          if (!isPlayerDead()) player.moveUp(false);
        }
        break;
        case 's': case 'S': {
          if (!isPlayerDead()) player.moveDown(false);
        }
        break;
        case 'a': case 'A': {
          if (!isPlayerDead()) player.moveLeft(false);
        }
        break;
        case 'd': case 'D': {
          if (!isPlayerDead()) player.moveRight(false);
        }
        break;
        default: break;
      }
    }
  }
  
  void mousePressed() {
    if (mouseButton == LEFT) {
      if (!isPlayerDead()) player.beginAction();
    } else if (mouseButton == RIGHT) {
      
    } else/* if (mouseButton == MIDDLE) */{

    }
  }
  
  void mouseReleased() {
    if (mouseButton == LEFT) {
      if (!isPlayerDead()) player.endAction();
    } else if (mouseButton == RIGHT) {
      
    } else/* if (mouseButton == MIDDLE) */{

    }
  }
  
  void mouseDragged(MouseEvent event) {
    
  }
  
  void mouseWheel(MouseEvent event) {
    if (!player.isDead())
      player.changeFirearm(-event.getCount());
  }
}

void beginContact(Contact cp) {
  Fixture fixtureA = cp.getFixtureA();
  Fixture fixtureB = cp.getFixtureB();
  
  if ((fixtureA.getBody().getUserData() instanceof Projectile && fixtureB.getBody().getUserData() instanceof WorldEntity) ||
      (fixtureA.getBody().getUserData() instanceof WorldEntity && fixtureB.getBody().getUserData() instanceof Projectile)) {
    Projectile projectile;
    WorldEntity worldEntity;
        
    if (fixtureA.getBody().getUserData() instanceof Projectile && fixtureB.getBody().getUserData() instanceof WorldEntity) {
      projectile = (Projectile) fixtureA.getBody().getUserData();
      worldEntity = (WorldEntity) fixtureB.getBody().getUserData();
    } else/* if (fixtureA.getBody().getUserData() instanceof WorldEntity && fixtureB.getBody().getUserData() instanceof Projectile) */{
      worldEntity = (WorldEntity) fixtureA.getBody().getUserData();
      projectile = (Projectile) fixtureB.getBody().getUserData();
    }
    
    handleCollision(projectile, worldEntity);
  } else if (fixtureA.getBody().getUserData() instanceof Projectile && fixtureB.getBody().getUserData() instanceof Projectile) {
    Projectile projectileA = (Projectile) fixtureA.getBody().getUserData();
    Projectile projectileB = (Projectile) fixtureB.getBody().getUserData();
    
    handleCollision(projectileA, projectileB);
  }
}

void endContact(Contact cp) {
  
}

void preSolve(Contact cp) {
  
}

void postSolve(Contact cp) {
  
}

void handleCollision(Projectile projectile, WorldEntity worldEntity) {
  if (!projectile.hasImmunity(worldEntity)) {
    projectile.damage(worldEntity);
    
    if (projectile.destroyOnHit()) {
      projectile.markForDeletion();
    } else {
      game.addEvent(new SetEntityTransformEvent(projectile, worldEntity.getVectorToEdgeOpposite(projectile.getLocation(), projectile.getLinearVelocity(), 0),
                    projectile.getAngle(), projectile.getLinearVelocity(), projectile.getAngularVelocity()));
      worldEntity.getEnvironment().addParticleSystem(worldEntity.createHitEffect(worldEntity.getVectorToEdgeOpposite(projectile.getLocation(), projectile.getLinearVelocity(), 0)));
    }
    
    worldEntity.getEnvironment().addParticleSystem(worldEntity.createHitEffect(worldEntity.getVectorToEdge(projectile.getLocation())));
  }
}

void handleCollision(Projectile projectileA, Projectile projectileB) {
  if (!(projectileA instanceof Buckshot && projectileB instanceof Buckshot) && !(projectileA instanceof ExplosionProjectile && projectileB instanceof ExplosionProjectile)) {
    if (projectileA.destroyOnHit()) {
      projectileA.markForDeletion();
    }
    
    if (projectileB.destroyOnHit()) {
      projectileB.markForDeletion();
    }
  }
}
