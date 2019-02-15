import interfascia.*;
import javax.swing.JOptionPane;
import javax.swing.JFrame;

// Image to be edited
File imageFile = null;
PImage loadedImage;
int dispX, dispY;
float scale = 1f;

int canvasH = 450;
boolean doUpdate = false;

// GUI Components
GUIController controller;
IFButton bImageLoad;
IFButton bImageSave;
IFLabel lImageWidth;
IFLabel lImageHeight;
IFLabel tImageWidth;
IFLabel tImageHeight;

IFLabel lResize;
IFTextField tResize;

void setup() {
  size(600, 600);
  drawBG();

  // Start GUI Controller
  controller = new GUIController(this);

  // Start Buttons
  bImageLoad = new IFButton("Load Image", 15, 560);
  bImageSave = new IFButton("Save", bImageLoad.getWidth()+40, 560);

  bImageLoad.addActionListener(this);
  bImageSave.addActionListener(this);

  lImageWidth = new IFLabel("Width", 15, 490, 20);
  lImageHeight = new IFLabel("Height", 15, 490 + 30, 20);


  tImageWidth = new IFLabel("-", 75, 490);
  tImageHeight = new IFLabel("-", 75, 490 + 30);

  lResize = new IFLabel("Scale", 150, 490, 20);
  tResize = new IFTextField("imScale", 200, 490);
  tResize.setValue(String.format("%.2f", scale));
  tResize.addActionListener(this);

  // Add buttons to GUI Controller
  controller.add(bImageLoad);
  controller.add(bImageSave);
  controller.add(lImageWidth);
  controller.add(lImageHeight);
  controller.add(tImageWidth);
  controller.add(tImageHeight);
  controller.add(lResize);
  controller.add(tResize);
}

// Required to process Events
void draw() {
  if (doUpdate) {
    update();
  }
}

// Performed when the screen must be updated
void update() {
  println("Update");
  drawBG();
  image(loadedImage, 0, 0, dispX, dispY);
  doUpdate = false;
}

/**
 Callback for select Input method.
 Handles images as they come through.
 */
void selectImageFile(File f) {
  if (f == null) {
    println("No file selected");
  } else {

    println("Image is "+f.getAbsolutePath());
    loadedImage = loadImage(f.getAbsolutePath());
    
    setDisplayDimensions();
    setImageDimensions();
    
    println("Dimensions are "+dispX+", "+dispY);
    
    String fname = f.getName();
    String[] parts = fname.split("\\.");
    fname = parts[0]+"_resized.jpg";
    
    imageFile = new File(fname);
    doUpdate = true;
  }
}

void saveImageFile(File f) {
  if (f == null) {
    println("File not saved");
  } else if (loadedImage == null) {
    JOptionPane.showMessageDialog(new JFrame(), "You must load an image before saving", "dialogue", JOptionPane.ERROR_MESSAGE);
  } else {
    println("Image Save Path "+f.getAbsolutePath());
    loadedImage.resize(floor(loadedImage.width*scale), floor(loadedImage.height*scale));
    loadedImage.save(f.getAbsolutePath());
  }
}

void selectImage() {
  selectInput("Please select image to load", "selectImageFile");
}

void saveImage() {
  selectOutput("Please save your resized image", "saveImageFile", imageFile);
}

/**
 Redraw the background layer
 */
void drawBG() {
  fill(0);
  rect(0, 0, width, canvasH);
  fill(200);
  rect(0, canvasH, width, height-canvasH);
  fill(0);
}

void setImageDimensions() {
  tImageWidth.setLabel(Integer.toString(floor(loadedImage.width*scale)));
  tImageHeight.setLabel(Integer.toString(floor(loadedImage.height*scale)));
}

void setDisplayDimensions() {
  // Find scaled with for image the size of the viewport
  dispY = canvasH;
  dispX = floor(map(dispY, 0, loadedImage.height, 0, loadedImage.width));

  // Check if this width is greater than the width of the viewport
  if (dispX > width) {
    // Set display width to width of the viewport
    dispX = width;
    dispY = floor(map(dispX, 0, loadedImage.width, 0, loadedImage.height));
  }
}

void scaleDimensions() {
  if (!tResize.getValue().isEmpty()) {
    Float newVal;
    try {
      newVal= Float.parseFloat(tResize.getValue());
    }
    catch(NumberFormatException nfe) {
      newVal= scale;
    }
    scale = newVal;
    setImageDimensions();
    doUpdate = true;
  }
}

// GUI Event Handler
void actionPerformed (GUIEvent e) {
  println("Action Performed");
  if (e.getSource() == bImageLoad) {
    selectImage();
  }

  if (e.getSource() == bImageSave) {
    saveImage();
  }

  if (e.getSource() == tResize) {
    scaleDimensions();
  }
}
