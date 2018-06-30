class Game {
  private class GUI {
    public static final int MAINMENU = 0;
    public static final int LOADING = 1;
    public static final int IN_GAME = 2;
  }
  
  private class Properties {
    public Properties() {
      
    }
  }
  
  public PApplet root;
  
  private Queue<Event> eventQueue;
  private LinkedList<Widget> widgets;
  
  private int gui;
  private Environment environment;
  
  public Game(PApplet root) {
    this.root = root;
    
    eventQueue = new ConcurrentLinkedQueue<Event>();
    widgets = new LinkedList<Widget>();
    
    gui = /*GUI.MAINMENU*/ GUI.IN_GAME;  // DEBUG
    environment = null;
    
    changeTo(gui);
  }
  
  public PApplet getRoot() {
    return root;
  }
  
  public void update() {
    if (!eventQueue.isEmpty()) {
      Event event = eventQueue.remove();
      event.call();
    }
    
    switch (gui) {
      case GUI.MAINMENU: {
        
      }
      break;
      case GUI.LOADING: {
        
      }
      break;
      case GUI.IN_GAME: {
        environment.update();
      }
      break;
      default: break;
    }
    
    updateWidgets();
  }
  
  public void display() {
    switch (gui) {
      case GUI.MAINMENU: {
        
      }
      break;
      case GUI.LOADING: {
        
      }
      break;
      case GUI.IN_GAME: {
        environment.display();
      }
      break;
      default: break;
    }
    
    displayWidgets();
  }
  
  private void updateWidgets() {
    for (Widget widget : widgets)
      widget.update();
  }
  
  private void displayWidgets() {
    for (Widget widget : widgets)
      widget.display();
  }
  
  private void changeFrom() {
    clearEvents();
    
    switch (gui) {
      case GUI.MAINMENU: {
      }
      break;
      case GUI.LOADING: {
      }
      break;
      case GUI.IN_GAME: {
        environment = null;
      }
      break;
      default: break;
    }
  }
  
  private void changeTo(int gui) {
    changeFrom();
    
    this.gui = gui;
    
    switch (gui) {
      case GUI.MAINMENU: {
        
      }
      break;
      case GUI.LOADING: {
        
      }
      break;
      case GUI.IN_GAME: {
        environment = new Environment(this);
      }
      break;
      default: break;
    }
  }
  
  public void addEvent(Event event) {
    eventQueue.add(event);
  }
  
  public void clearEvents() {
    eventQueue.clear();
  }
  
  void keyPressed() {
    switch (gui) {
      case GUI.MAINMENU: {
        
      }
      break;
      case GUI.LOADING: {
        
      }
      break;
      case GUI.IN_GAME: {
        environment.keyPressed();
      }
      break;
      default: break;
    }
  }
    
  void keyReleased() {
    switch (gui) {
      case GUI.MAINMENU: {
        
      }
      break;
      case GUI.LOADING: {
        
      }
      break;
      case GUI.IN_GAME: {
        environment.keyReleased();
      }
      break;
      default: break;
    }
  }
  
  void mousePressed() {
    switch (gui) {
      case GUI.MAINMENU: {
        
      }
      break;
      case GUI.LOADING: {
        
      }
      break;
      case GUI.IN_GAME: {
        environment.mousePressed();
      }
      break;
      default: break;
    }
  }
  
  void mouseReleased() {
    switch (gui) {
      case GUI.MAINMENU: {
        
      }
      break;
      case GUI.LOADING: {
        
      }
      break;
      case GUI.IN_GAME: {
        environment.mouseReleased();
      }
      break;
      default: break;
    }
  }
  
  void mouseDragged(MouseEvent event) {
    switch (gui) {
      case GUI.MAINMENU: {
        
      }
      break;
      case GUI.LOADING: {
        
      }
      break;
      case GUI.IN_GAME: {
        environment.mouseDragged(event);
      }
      break;
      default: break;
    }
  }
  
  void mouseWheel(MouseEvent event) {
    switch (gui) {
      case GUI.MAINMENU: {
        
      }
      break;
      case GUI.LOADING: {
        
      }
      break;
      case GUI.IN_GAME: {
        environment.mouseWheel(event);
      }
      break;
      default: break;
    }
  }
}
