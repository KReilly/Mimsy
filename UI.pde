

/**
 * Create cylindrical bar segments for a nicer simulation
 */

class UIBars extends UI3dComponent {

  GraphModel model;

  public UIBars(GraphModel model) {
    super();
    this.model = model;
  }

  @Override
  protected void onDraw(UI ui, PGraphics pg) {
    int[] colors = lx.getColors();
    pg.noStroke();
    //pg.noFill();
    //pg.textureMode(NORMAL);

    for (Bar bar : model.bars) {

      pg.pushMatrix();
      pg.translate(bar.node1.x, bar.node1.y, bar.node1.z);
      //pg.translate(bar.cx, bar.cy, bar.cz);
      pg.rotateZ(bar.theta);
      pg.rotateY(-bar.azimuth);
      //drawCylinder(pg, bar.length, 1.0, LXColor.WHITE);
      
      for (LXPoint point : bar.points) {
        drawCylinder(pg, bar.spacing, BAR_RADIUS, colors[point.index]);
        pg.translate(bar.spacing, 0.0, 0.0);
      }
      pg.popMatrix();
      //System.exit(0);
    }
  }

  private void drawCylinder(PGraphics pg, float length, float radius, int bar_color) {
    pg.beginShape(TRIANGLE_STRIP);
    pg.fill(bar_color);
    for (int i = 0; i <= BAR_DETAIL; i++) {
      int ii = i % BAR_DETAIL;
      float a = i * TWO_PI / BAR_DETAIL;
      float y = radius * cos(a);
      float z = radius * sin(a);
      //pg.vertex(-length/2.0, y, z);
      //pg.vertex( length/2.0, y, z);
      pg.vertex( 0, y, z);
      pg.vertex( length, y, z);
    }
    pg.endShape(CLOSE);
  }

}


class UIMimsyControls extends UICollapsibleSection {

  public final UIButton pointsVisible;
  public final UIButton ddVisible;
  public final UIButton tlVisible;
  public final UIButton trVisible;
  //public final UIButton nodesVisible;

  public UIMimsyControls(final LXStudio.UI ui) {
    super(ui, 0, 0, ui.leftPane.global.getContentWidth(), 200);
    setTitle("RENDER");
    setLayout(UI2dContainer.Layout.VERTICAL);
    setChildMargin(2);
    
    this.pointsVisible = (UIButton) new UIButton(0, 0, getContentWidth(), 18) {
      public void onToggle(boolean on) {
        ui.preview.pointCloud.setVisible(on);
      }
    }
    .setLabel("Points")
    .setActive(ui.preview.pointCloud.isVisible())
    .addToContainer(this);
    
    this.ddVisible = (UIButton) new UIButton(0, 0, getContentWidth() / 3 - 4, 18) {
      public void onToggle(boolean on) {
        uiBarsDD.setVisible(on);
      }
    }
    .setLabel("DD")
    .setActive(uiBarsDD.isVisible())
    .addToContainer(this);
     
    this.tlVisible = (UIButton) new UIButton(0, 0, getContentWidth() / 3 - 4, 18) {
      public void onToggle(boolean on) {
        uiBarsTL.setVisible(on);
      }
    }
    .setLabel("TL")
    .setActive(uiBarsTL.isVisible())
    .addToContainer(this);

    this.trVisible = (UIButton) new UIButton(0, 0, getContentWidth() / 3 - 4, 18) {
      public void onToggle(boolean on) {
        uiBarsTR.setVisible(on);
      }
    }
    .setLabel("TR")
    .setActive(uiBarsTR.isVisible())
    .addToContainer(this);
    
  }
}



class UINodes extends UI3dComponent {

  private final float NODE_RADIUS = 10.0;
  private String COLOR_SCHEME = "LEVEL_COLOR";

  protected void onDraw(UI ui, PGraphics pg) {
    float hue =   0.0;
    float sat = 100.0;
    float brt = 100.0;
    float alp = 100.0;

    float dHue =  60;
    float dSat =  20;
    float dBrt =  20;
    noStroke();
    for (Node node : model.nodes) {
      int level = (int)Math.floor(node.index / 5.0);
      int spin = node.index % 5;

      if (COLOR_SCHEME == "SPIN_COLOR") {
        hue = level * dHue;
        sat = 100.0 - (spin * dSat);
        brt = 100.0 - (spin * dBrt);
      } else if (COLOR_SCHEME == "LEVEL_COLOR") {
        hue = spin * dHue;
        sat = 100.0 - (level * dSat);
        brt = 100.0 - (level * dBrt);
      }

      fill(hue,sat,brt,alp);
      pushMatrix();
      translate(node.x, node.y, node.z);
      sphere(NODE_RADIUS);
      popMatrix();
    }

    // NOTE: This renders the labels oriented in 3D, which makes them useless.
    if (false) {
      //noLights();
      hint(DISABLE_DEPTH_TEST);
      textAlign(CENTER, CENTER);
      textSize(24);
      fill(0,0,255);
      //fill(0, 102, 153, 51);
      for (Node node : model.nodes) {
        pushMatrix();
        translate(node.x, node.y, node.z);
        text(node.index, 0, 0, 0);
        //text(node.index, node.x, node.y, node.z);
        popMatrix();
      }
      hint(ENABLE_DEPTH_TEST);
    }
  }

  protected void swapColorScheme() {
    if (COLOR_SCHEME == "LEVEL_COLOR") {
      COLOR_SCHEME = "ROW_COLOR";
    } else {
      COLOR_SCHEME = "LEVEL_COLOR";
    }
  }
}


class UIWalls extends UI3dComponent {
  
  private final float WALL_MARGIN = 2*FEET;
  private final float WALL_SIZE = model.xRange + 2*WALL_MARGIN;
  private final float WALL_THICKNESS = 1*INCHES;
  
  protected void onDraw(UI ui, PGraphics pg) {
    fill(#666666);
    noStroke();
    pushMatrix();
    // Bottom
    translate(model.cx, model.cy, model.zMax + WALL_MARGIN);
    box(WALL_SIZE, WALL_SIZE, WALL_THICKNESS);
    // Left
    translate(-model.xRange/2 - WALL_MARGIN, 0, -model.zRange/2 - WALL_MARGIN);
    //box(WALL_THICKNESS, WALL_SIZE, WALL_SIZE);
    // Right
    translate(model.xRange + 2*WALL_MARGIN, 0, 0);
    //box(WALL_THICKNESS, WALL_SIZE, WALL_SIZE);
    // Back
    translate(-model.xRange/2 - WALL_MARGIN, model.yRange/2 + WALL_MARGIN, 0);
    //box(WALL_SIZE, WALL_THICKNESS, WALL_SIZE);
    // Front
    translate(0, -model.yRange - 2*WALL_MARGIN, 0);
    //box(WALL_SIZE, WALL_THICKNESS, WALL_SIZE);
    popMatrix();
  }
}

class UISimulationControl extends UIWindow {
  UISimulationControl(UI ui, float x, float y) {
    super(ui, "SIMULATION", x, y, UIChannelControl.WIDTH, 100);
    y = UIWindow.TITLE_LABEL_HEIGHT;
    new UIButton(4, y, width-8, 20)
      .setLabel("Show Walls")
      .setParameter(uiWalls.visible)
      .addToContainer(this);
    y += 24;
    new UIButton(4, y, width-8, 20)
      .setLabel("Show Nodes")
      .setParameter(uiNodes.visible)
      .addToContainer(this);
    y += 24;

    int w = 20;
    int b = 4;
    new UIButton(4, y, 30, 20)
      .setLabel("DD")
      .setParameter(pointCloudDodecahedron.visible)
      .addToContainer(this);
    new UIButton(38, y, 30, 20)
      .setLabel("TL")
      .setParameter(pointCloudTetraLeft.visible)
      .addToContainer(this);
    new UIButton(72, y, 30, 20)
      .setLabel("TR")
      .setParameter(pointCloudTetraRight.visible)
      .addToContainer(this);
  }
}



class UIComponentsDemo extends UIWindow {
  
  static final int NUM_KNOBS = 4; 
  final BoundedParameter[] knobParameters = new BoundedParameter[NUM_KNOBS];  
  
  UIComponentsDemo(UI ui, float x, float y) {
    super(ui, "UI COMPONENTS", x, y, 140, 10);
    
    for (int i = 0; i < knobParameters.length; ++i) {
      knobParameters[i] = new BoundedParameter("Knb" + (i+1), i+1, 0, 4);
      knobParameters[i].addListener(new LXParameterListener() {
        public void onParameterChanged(LXParameter p) {
          println(p.getLabel() + " value:" + p.getValue());
        }
      });
    }
    
    y = UIWindow.TITLE_LABEL_HEIGHT;
    
    new UIButton(4, y, width-8, 20)
    .setLabel("Toggle Button")
    .addToContainer(this);
    y += 24;
    
    new UIButton(4, y, width-8, 20)
    .setActiveLabel("Boop!")
    .setInactiveLabel("Momentary Button")
    .setMomentary(true)
    .addToContainer(this);
    y += 24;
    
    for (int i = 0; i < 4; ++i) {
      new UIKnob(4 + i*34, y)
      .setParameter(knobParameters[i])
      .setEnabled(i % 2 == 0)
      .addToContainer(this);
    }
    y += 48;
    
    for (int i = 0; i < 4; ++i) {
      new UISlider(UISlider.Direction.VERTICAL, 4 + i*34, y, 30, 60)
      .setParameter(new BoundedParameter("VSl" + i, (i+1)*.25))
      .setEnabled(i % 2 == 1)
      .addToContainer(this);
    }
    y += 80;
    
    for (int i = 0; i < 2; ++i) {
      new UISlider(4, y, width-8, 24)
      .setParameter(new BoundedParameter("HSl" + i, (i + 1) * .25))
      .setEnabled(i % 2 == 0)
      .addToContainer(this);
      y += 44;
    }
    
    new UIToggleSet(4, y, width-8, 24)
    .setParameter(new DiscreteParameter("Ltrs", new String[] { "A", "B", "C", "D" }))
    .addToContainer(this);
    y += 28;
    
    for (int i = 0; i < 4; ++i) {
      new UIIntegerBox(4 + i*34, y, 30, 22)
      .setParameter(new DiscreteParameter("Dcrt", 10))
      .addToContainer(this);
    }
    y += 26;
    
    new UILabel(4, y, width-8, 24)
    .setLabel("This is just a label.")
    .setTextAlignment(CENTER, CENTER)
    .setBorderColor(ui.theme.getControlDisabledColor())
    .addToContainer(this);
    y += 28;
    
    setSize(width, y);
  }
} 


public class UICameraControlMimsy extends UIWindow {

  public final static int WIDTH = 140;
  public final static int HEIGHT = 102;

  public UICameraControlMimsy(UI ui, UI3dContext context, float x, float y) {
    super(ui, "CAMERA", x, y, WIDTH, HEIGHT);
    
    float xp = 5;
    float yp = UIWindow.TITLE_LABEL_HEIGHT;

    new UIButton(xp, yp, WIDTH-8, 20)
      .setLabel("Ortho Persp")
      .setActiveLabel("Orthoscopic")
      .setInactiveLabel("Perspective")
      .setParameter(uiOrthoCamera)
      .addToContainer(this);
    yp += 24;
    new UIKnob(xp, yp).setParameter(context.perspective).addToContainer(this);
    xp += 34;
    new UIKnob(xp, yp).setParameter(context.depth).addToContainer(this);
    xp += 34;
    new UIKnob(xp, yp).setParameter(clipNear).addToContainer(this);
    xp += 34;
    new UIKnob(xp, yp).setParameter(clipFar).addToContainer(this);
  }

}
