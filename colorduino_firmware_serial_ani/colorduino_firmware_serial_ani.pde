#include <Colorduino.h>          //colorduino library
#include <HCTimer2.h>
#define START_OF_DATA 0x10       //data markers
#define END_OF_DATA 0x20         //data markers

PixelRGB aniBuffer [8*8*6];
PixelRGB* pNextFrame = aniBuffer;
byte frameCount = 0, curFrame = 0;
int Counter = 0;
void nextFrame()
{
  if(frameCount == 0)return;
  
  cli();
  Colorduino.curDrawFrame = pNextFrame;
  sei();
  
  if (curFrame + 1 >= frameCount) {
    pNextFrame = aniBuffer; //restart from the first frame.
    curFrame = 0;
  }
  else{ 
    pNextFrame += 64; //move pointer to next frame by skipping 64 pixels.
    curFrame++;
  }  
}

// get a pixel for writing in the offscreen framebuffer
PixelRGB *getPixel(PixelRGB* pOrigin, unsigned char x, unsigned char y) {
  return pOrigin + (y * 8) + x;
}

void setup()
{
  HCTimer2Init(T2_CLK_DIV_1024, 243);
  Colorduino.Init();
  // compensate for relative intensity differences in R/G/B brightness
  // array of 6-bit base values for RGB (0~63)
  // whiteBalVal[0]=red
  // whiteBalVal[1]=green
  // whiteBalVal[2]=blue
  unsigned char whiteBalVal[3] = {33,63,63}; // for LEDSEE 6x6cm round matrix
  Colorduino.SetWhiteBal(whiteBalVal);

  Serial.begin(57600);
}

/****************************************************
Main Functions zone
****************************************************/

/****************
* Ani frame data structure for one chandel one frame.
* START_OF_DATA, byte (index of frame, 0 to restart a new ani, when index>0, new frame is loaded), ColorByte, byte x 64, END_OF_DATA
*
* loop method first checks serial. If last channel was blue, we increment frameCount, so nexFrame will show this frame next time
*****************/

void loop()
{  
   if (Serial.available()>67) { //when buffer full, process data. 66 =  start byte + colour + 64 pixel data + end byte
    Serial.println("received data");
    // error check - make sure our data starts with the right byte   
    if (Serial.read() != START_OF_DATA) {
      Serial.println("received invalid data");
      //else handle error by reading remaining data until end of data marker (if available)
      while (Serial.available()>0 && Serial.read()!=END_OF_DATA) {}      
      return;
    }

    byte i = Serial.read(); //read index.
    if( i == 0 ){
      //We restart a new image. 
      frameCount = 0;
    }
    
    PixelRGB* pWrite = aniBuffer;
    //move to correct write start point
    pWrite += frameCount * 64;
    
    byte c = Serial.read(); //read our color byte so we know if these are the R, G or B pixels.
    
    //depeding on c read pixels in as R G or B
    //read red display data
    if (c == 0){
      Serial.println("Reading red channel.");
      for (byte x = 0; x < 8; x++){
        for (byte y = 0; y < 8; y++){
           PixelRGB* pDraw = getPixel(pWrite, x, y);
           pDraw->r = Serial.read();
        }
      }
    }
    
    //read green display data
    if (c == 1){
      Serial.println("Reading green channel.");
      for (byte x = 0; x < 8; x++){
        for (byte y = 0; y < 8; y++){
           PixelRGB* pDraw = getPixel(pWrite, x, y);
           pDraw->g = Serial.read();
        }
      }
    }
    
    //read blue display data
    if (c == 2){
      Serial.println("Reading blue channel.");
      for (byte x = 0; x < 8; x++){
        for (byte y = 0; y < 8; y++){
           PixelRGB* pDraw = getPixel(pWrite, x, y);
           pDraw->b = Serial.read();
        }
      }
    }
    
    //read end of data marker
    if (Serial.read()==END_OF_DATA) {
      //if colour is blue, then update display
      if (c == 2){
        frameCount++;
        Serial.println("frameCount=" + frameCount);
        Serial.println("curFrame=" + curFrame);
      }
    }
  }
}

void HCTimer2()
{
  Counter++;
  if(Counter == 128)
  {
    nextFrame();
    Counter = 0;
  }
}





