abstract class Event {
  public abstract void call();
}

class SetEntityTransformEvent extends Event {
  protected Entity entity;
  protected Vec2 location, velocity;
  protected float angle, angularVelocity;
  
  public SetEntityTransformEvent(Entity entity, Vec2 location, float angle, Vec2 velocity, float angularVelocity) {
    this.entity = entity;
    this.location = location;
    this.angle = angle;
    this.velocity = velocity;
    this.angularVelocity = angularVelocity;
  }
  
  public void call() {
    entity.setTransform(location, angle);
    entity.setLinearVelocity(velocity);
    entity.setAngularVelocity(angularVelocity);
  }
}

class AddEntitiesEvent extends Event {
  protected LinkedList<Entity> entities;
  protected Environment environment;
  
  public AddEntitiesEvent(LinkedList<Entity> entities, Environment environment) {
    this.entities = entities;
    this.environment = environment;
  }
  
  public void call() {
    for (Entity entity : entities)
      environment.addEntity(entity);      
  }
}
