#include <Colorduino.h>          //colorduino library

#define START_OF_DATA 0x10       //data markers
#define END_OF_DATA 0x20         //data markers

void setup()
{
  Colorduino.Init();
  // compensate for relative intensity differences in R/G/B brightness
  // array of 6-bit base values for RGB (0~63)
  // whiteBalVal[0]=red
  // whiteBalVal[1]=green
  // whiteBalVal[2]=blue
  unsigned char whiteBalVal[3] = {33,63,63}; // for LEDSEE 6x6cm round matrix
  Colorduino.SetWhiteBal(whiteBalVal);

  Serial.begin(115200);
}

/****************************************************
Main Functions zone
****************************************************/

void loop()
{ 
   if (Serial.available()>66) { //when buffer full, process data. 66 =  start byte + colour + 64 pixel data + end byte
    Serial.println("received data");
    // error check - make sure our data starts with the right byte   
    if (Serial.read() != START_OF_DATA) {
      Serial.println("received invalid data");
      //else handle error by reading remaining data until end of data marker (if available)
      while (Serial.available()>0 && Serial.read()!=END_OF_DATA) {}      
      return;
    }

    byte c = Serial.read(); //read our color byte so we know if these are the R, G or B pixels.
    
    //depeding on c read pixels in as R G or B
    //read red display data
    if (c == 0){
      Serial.println("Reading red channel.");
      for (byte x = 0; x < 8; x++){
        for (byte y = 0; y < 8; y++){
           PixelRGB *p = Colorduino.GetPixel(x, y); //&(*Colorduino.curWriteFrame)[x][y];
           p->r = Serial.read();
        }
      }
    }
    
    //read green display data
    if (c == 1){
      Serial.println("Reading green channel.");
      for (byte x = 0; x < 8; x++){
        for (byte y = 0; y < 8; y++){
          PixelRGB *p = Colorduino.GetPixel(x, y); //&(*Colorduino.curWriteFrame)[x][y];
           p->g = Serial.read(); 
        }
      }
    }
    
    //read blue display data
    if (c == 2){
      Serial.println("Reading blue channel.");
      for (byte x = 0; x < 8; x++){
        for (byte y = 0; y < 8; y++){
           PixelRGB *p = Colorduino.GetPixel(x, y); //&(*Colorduino.curWriteFrame)[x][y];
           p->b = Serial.read(); 
        }
      }
    }
    
    //read end of data marker
    if (Serial.read()==END_OF_DATA) {
      //if colour is blue, then update display
      if (c == 2){
        Serial.println("Time to flip.");
        Colorduino.FlipPage();
      }
    } 
  }
}





