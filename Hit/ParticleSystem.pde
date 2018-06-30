abstract class ParticleSystem {
  private LinkedList<Particle> particles;
  private Environment environment;
  private boolean markedForDeletion;
    
  public ParticleSystem(Environment environment) {
    particles = new LinkedList<Particle>();
    this.environment = environment;
    markedForDeletion = false;
  }
  
  public void addParticle(Particle particle) {
    particles.add(particle);
  }
  
  public void update() {
    for (ListIterator<Particle> it = particles.listIterator(); it.hasNext();) {
      Particle particle = it.next();
      particle.update();
      
      if (particle.isMarkedForDeletion())
        it.remove();
    }
    
    if (particles.isEmpty())
      markForDeletion();
  }
  
  public void display() {
    for (Particle particle : particles)
      if (environment.isVisible(particle.getLocation(), particle.getLongestDistance()))
        particle.display();
  }
  
  public void markForDeletion() {
    markedForDeletion = true;
  }
  
  public boolean isMarkedForDeletion() {
    return markedForDeletion;
  }
}

class BloodEffect extends ParticleSystem {
  protected final int numParticles = 12;
  protected final float minSize = 1, maxSize = 8, maxVelocityMagnitude = 200;
  
  public BloodEffect(Vec2 location, color c, Environment environment) {
    super(environment);
    createParticles(location, c);
  }
  
  private void createParticles(Vec2 location, color c) {
    for (int i = 0; i < numParticles; i++) {
      float size = random(minSize, maxSize);
      Vec2 randomDirection = getRandomUnitVector();
      addParticle(new FadingCircularParticle(location, size, randomDirection.mul(random(maxVelocityMagnitude)), c, 0.5));
    }
  }
}

class Explosion extends ParticleSystem {
  protected final int numParticles = 20;
  protected final float minSize = 10, maxSize = 80, maxVelocityMagnitute = 200;
  protected color[] colors;
  
  public Explosion(Vec2 location, Environment environment) {
    super(environment);
    createParticles(location);
  }
  
  public void createParticles(Vec2 location) {
    createColors();
    
    for (int i = 0; i < numParticles; i++) {
      float size = random(minSize, maxSize);
      Vec2 randomDirection = getRandomUnitVector();
      addParticle(new FadingCircularParticle(location, size, randomDirection.mul(random(maxVelocityMagnitute)), colors[int(random(colors.length))], 0.5));
    }
  }

  public void createColors() {
    colors = new color[5];
    colors[0] = color(255, 0, 0);
    colors[1] = color(50);
    colors[2] = color(25);
    colors[3] = color(247, 123, 0);
    colors[4] = color(255, 208, 0);
  }
}
