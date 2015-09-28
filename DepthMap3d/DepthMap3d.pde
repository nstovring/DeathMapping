/* --------------------------------------------------------------------------
 * SimpleOpenNI DepthMap3d Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 */

import SimpleOpenNI.*;

SimpleOpenNI context;
float        zoomF =0.3f;
float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
                                   // the data from openni comes upside down
float        rotY = radians(0);

PrintWriter output;


void setup()
{
  String viewPointFileName;
  viewPointFileName = "myPoints" + ".ply";
  output = createWriter(dataPath(viewPointFileName)); 
  
  size(1024,768,P3D);

  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  
  // disable mirror
  context.setMirror(true);

  // enable depthMap generation 
  context.enableDepth();

  stroke(255,255,255);
  smooth();
  perspective(radians(45),
              float(width)/float(height),
              10,150000);
}
boolean saving;
int counter;
void draw()
{
  GetPoints(false);
}

void GetPoints(boolean saving){
// update the cam
  context.update();

  background(0,0,0);

  translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY);
  scale(zoomF);

  int[]   depthMap = context.depthMap();
  int     steps   = 3;  // to speed up the drawing, draw every third point
  int     index;
  PVector realWorldPoint;
 
  translate(0,0,-1000);  // set the rotation center of the scene 1000 infront of the camera

  stroke(255);

  PVector[] realWorldMap = context.depthMapRealWorld();
  
  // draw pointcloud
  beginShape(POINTS);
  for(int y=0;y < context.depthHeight();y+=steps)
  {
    for(int x=0;x < context.depthWidth();x+=steps)
    {
      index = x + y * context.depthWidth();
      if(depthMap[index] > 0)
      { 
        // draw the projected point
//        realWorldPoint = context.depthMapRealWorld()[index];
        realWorldPoint = realWorldMap[index];
        vertex(realWorldPoint.x,realWorldPoint.y,realWorldPoint.z);  // make realworld z negative, in the 3d drawing coordsystem +z points in the direction of the eye
         if(saving == true){
          ExportPly(realWorldPoint);
          counter++;
      }  
    }
      //println("x: " + x + " y: " + y);
    }
  } 
  endShape();
  
  // draw the kinect cam
  context.drawCamFrustum();
}

void ExportPly(PVector v){
      //PVector v  = new PVector(v.x *-1, v.y *-1, v.z*-1);
      output.println(v.x +" "+ v.y +" "+(-v.z) +" ");
}

void keyPressed()
{
  switch(key)
  {
  case ' ':
    context.setMirror(!context.mirror());
    break;
  }

  switch(keyCode)
  {
  case LEFT:
    rotY += 0.1f;
    break;
  case RIGHT:
    // zoom out
    rotY -= 0.1f;
    break;
  case UP:
    if(keyEvent.isShiftDown())
      zoomF += 0.02f;
    else
      rotX += 0.1f;
    break;
  case DOWN:
    if(keyEvent.isShiftDown())
    {
      zoomF -= 0.02f;
      if(zoomF < 0.01)
        zoomF = 0.01;
    }
    else
      rotX -= 0.1f;
    break;
  }
  
   output.println("ply");
      output.println("format ascii 1.0");
      output.println("comment this is my Proccessing file");
      output.println("element vertex " + (23000));
      output.println("property float x");
      output.println("property float y");
      output.println("property float z");
      output.println("end_header");
  GetPoints(true);
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
  println(counter);
  exit(); // Stops the program
}
