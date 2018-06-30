/*
 * Written by Juho Kim
 */

import shiffman.box2d.*;
import java.util.*;
import java.util.concurrent.*;
import java.io.*;
import java.awt.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

Game game;

void setup() {
  size(1280, 720, P2D);
  frameRate(1000);
  smooth();
  
  rectMode(CENTER);
  ellipseMode(CENTER);
  imageMode(CENTER);
  textAlign(CENTER, CENTER);
  
  game = new Game(this);
}

void draw() {
  game.update();
  game.display();
}

void keyPressed() {
  game.keyPressed();
}

void keyReleased() {
  game.keyReleased();
}

void mousePressed() {
  game.mousePressed();
}

void mouseReleased() {
  game.mouseReleased();
}

void mouseDragged(MouseEvent event) {
  game.mouseDragged(event);
}

void mouseWheel(MouseEvent event) {
  game.mouseWheel(event);
}
