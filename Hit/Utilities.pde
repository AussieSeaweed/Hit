float perSecond(float scalar) {
  return scalar / frameRate;
}

Vec2 perSecond(Vec2 vector) {
  return vector.mul(perSecond(1));
}

Vec2 rotate(Vec2 vector, float angle) {
  float x = vector.x * cos(angle) - vector.y * sin(angle);
  float y = vector.x * sin(angle) + vector.y * cos(angle);
  return new Vec2(x, y);
}

float getAngleOf(Vec2 vector) {
  return atan2(vector.y, vector.x);
}

Vec2 getUnitVectorOf(float angle) {
  return rotate(new Vec2(1, 0), angle);
}

Vec2 getRandomUnitVector() {
  return getUnitVectorOf(random(0, TAU));
}

float getAngleBetween(Vec2 v1, Vec2 v2) {
  return acos(Vec2.dot(v1, v2) / (v1.length() * v2.length()));
}

float getDistanceBetween(Vec2 v1, Vec2 v2) {
  float dx = v1.x - v2.x;
  float dy = v1.y - v2.y;
  return sqrt(dx * dx + dy * dy);
}

Firearm getRandomFirearm(Entity user, Box2DProcessing box2d, Environment environment) {
    Firearm[] firearms = new Firearm[7];
    firearms[0] = new Pistol(20, 5, 1, PI / 36f, 18, 18, Firearm.SEMI_AUTOMATIC, false, user, box2d, environment);
    firearms[1] = new Rifle(25, 10, 1, PI / 360f, 30, 30, Firearm.AUTOMATIC, true, user, box2d, environment);
    firearms[2] = new Minigun(25, 100, 2, PI / 12f, 1000, 1000, user, box2d, environment);
    firearms[3] = new SniperRifle(500, 2, 1.5, PI / 1020f, 10, 10, Firearm.SEMI_AUTOMATIC, false, user, box2d, environment);
    firearms[4] = new Shotgun(20, 20, 2, 1, PI / 24f, 6, 6, Firearm.SEMI_AUTOMATIC, false, user, box2d, environment);
    firearms[5] = new GrenadeLauncher(100, 150, 3, 1, PI / 72f, 6, 6, Firearm.AUTOMATIC, false, user, box2d, environment);
    firearms[6] = new RocketLauncher(1000, 200, 1, 1, PI / 72f, 1, 1, Firearm.SEMI_AUTOMATIC, false, user, box2d, environment);
    return firearms[int(random(firearms.length))];
}

float __noise_counter = 0;
float __noise_step = 100f;

float getNoiseOffset() {
  return __noise_counter += __noise_step;
}
