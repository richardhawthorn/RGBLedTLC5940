#include <Tlc5940.h>


/*
    Basic Pin setup:
 ------------                                  ---u----
 ARDUINO   13|-> SCLK (pin 25)           OUT1 |1     28| OUT channel 0
 12|                           OUT2 |2     27|-> GND (VPRG)
 11|-> SIN (pin 26)            OUT3 |3     26|-> SIN (pin 11)
 10|-> BLANK (pin 23)          OUT4 |4     25|-> SCLK (pin 13)
 9|-> XLAT (pin 24)             .  |5     24|-> XLAT (pin 9)
 8|                             .  |6     23|-> BLANK (pin 10)
 7|                             .  |7     22|-> GND
 6|                             .  |8     21|-> VCC (+5V)
 5|                             .  |9     20|-> 2K Resistor -> GND
 4|                             .  |10    19|-> +5V (DCPRG)
 3|-> GSCLK (pin 18)            .  |11    18|-> GSCLK (pin 3)
 2|                             .  |12    17|-> SOUT
 1|                             .  |13    16|-> XERR
 0|                           OUT14|14    15| OUT channel 15
 ------------                                  --------
 
 -  Put the longer leg (anode) of the LEDs in the +5V and the shorter leg
 (cathode) in OUT(0-15).
 -  +5V from Arduino -> TLC pin 21 and 19     (VCC and DCPRG)
 -  GND from Arduino -> TLC pin 22 and 27     (GND and VPRG)
 -  digital 3        -> TLC pin 18            (GSCLK)
 -  digital 9        -> TLC pin 24            (XLAT)
 -  digital 10       -> TLC pin 23            (BLANK)
 -  digital 11       -> TLC pin 26            (SIN)
 -  digital 13       -> TLC pin 25            (SCLK)
 -  The 2K resistor between TLC pin 20 and GND will let ~20mA through each
 LED.  To be precise, it's I = 39.06 / R (in ohms).  This doesn't depend
 on the LED driving voltage.
 - (Optional): put a pull-up resistor (~10k) between +5V and BLANK so that
 all the LEDs will turn off when the Arduino is reset.
 
 If you are daisy-chaining more than one TLC, connect the SOUT of the first
 TLC to the SIN of the next.  All the other pins should just be connected
 together:
 BLANK on Arduino -> BLANK of TLC1 -> BLANK of TLC2 -> ...
 XLAT on Arduino  -> XLAT of TLC1  -> XLAT of TLC2  -> ...
 The one exception is that each TLC needs it's own resistor between pin 20
 and GND.
 
 This library uses the PWM output ability of digital pins 3, 9, 10, and 11.
 Do not use analogWrite(...) on these pins.
 */
 
int rangeMax = 1024; //led range
int rgbArray[4][4][4] = 
  {
    {
    {800, 800, 800, 800},
    {800, 0, 0, 800},
    {800, 0, 0, 800},
    {800, 800, 800, 800}
    },
    {
    {200, 0, 0, 0},
    {0, 200, 0, 0},
    {0, 0, 200, 0},
    {0, 0, 0, 200}
    },
    {
    {0, 0, 0, 400},
    {0, 0, 400, 0},
    {0, 400, 0, 0},
    {400, 0, 0, 0}
    },
    {
    {0, 0, 0, 0},
    {0, 0, 0, 0},
    {0, 0, 0, 0},
    {0, 0, 0, 0}
    }
  };

void setup()
{
  Tlc.init();
  Serial.begin(9600);
}


void loop()
{

 
  allOnColours(4058, 0, 0);
  delay(2000);
  allOnColours(0, 4058, 0);
  delay(2000);
  allOnColours(0, 0, 4058);
  delay(2000);
  allOnColours(4058, 4058, 0);
  delay(2000);
  allOnColours(4058, 0, 4058);
  delay(2000);
  allOnColours(0, 4058, 4058);
  delay(2000);
  allOnColours(4058, 4058, 4058);
  delay(2000);
  
  rgbCycle(20); //seconds to cycle through the colours
  randomColours(10);  
  
  commitRgbArray(3);
  delay(2000);
  commitRgbArray(0);
  delay(2000);
  commitRgbArray(1);
  delay(2000);
  commitRgbArray(2);
  delay(2000);
  commitRgbArray(3);
  delay(2000);

}

void randomColours(int time){
  int timeLoop = 0;
  while (timeLoop < time * 4){
  
  //first loop
  int ledNum1 = 4;
  int ledLoop1 = 0;
  
  //second loop
  int ledNum2 = 4;
  int ledLoop2 = 0;
  
  //what led are we talking about
  int ledSequence = 0;

  while (ledLoop1 < ledNum1){
    ledLoop2 = 0;
    while (ledLoop2 < ledNum2){
      lightRgb(ledSequence, random(1024));
      ledSequence++;
      ledLoop2++; 
    }
    ledLoop1++; 
  }
  
  Tlc.update(); 
  delay(300);
  timeLoop++;
  }  
}

void commitRgbArray(int frame){
  //first loop
  int ledNum1 = 4;
  int ledLoop1 = 0;
  
  //second loop
  int ledNum2 = 4;
  int ledLoop2 = 0;
  
  //what led are we talking about
  int ledSequence = 0;

  while (ledLoop1 < ledNum1){
    ledLoop2 = 0;
    while (ledLoop2 < ledNum2){
      lightRgb(ledSequence, rgbArray[frame][ledLoop1][ledLoop2]);
      ledSequence++;
      ledLoop2++; 
    }
    ledLoop1++; 
  }
  
  Tlc.update();   
}

void allOnColours(int red, int green, int blue) {

    int cycleNum = 16;
    int cycleLoop = 0;

    while (cycleLoop < cycleNum){
      Tlc.set(cycleLoop, red);
      Tlc.set(cycleLoop + 16, green);
      Tlc.set(cycleLoop + 32, blue);
      cycleLoop++;
    }

    Tlc.update();        

  }

void rgbCycle(int time)
{
  int ledNum = 16;   //number of leds in colour cycle
  int ledCycle[ledNum];  //colour array
  
  int ledCycleLoop = 0;

  //setup led starting colours
  int cycleNum = ledNum;
  int cycleLoop = 0;

  while (cycleLoop < cycleNum){
    //distributing the total range between the leds, giving them all a spread out colour
    ledCycle[cycleLoop] = (rangeMax / ledNum) * cycleLoop;  
    cycleLoop++;
  }

  while(ledCycleLoop < (time * 100)) {

    cycleNum = 16;
    cycleLoop = 0;

    while (cycleLoop < cycleNum){
      ledCycle[cycleLoop]++;

      //loop though the leds, increasing all their values by 1
      if (ledCycle[cycleLoop] == (rangeMax+1) ){
        ledCycle[cycleLoop] = 1; 
      }

      //run the subroutine to convert this number into an actual colour
      lightRgb(cycleLoop,ledCycle[cycleLoop]);

      cycleLoop++;
    }

    delay(10);
    Tlc.update();        
    ledCycleLoop++;
  }

}


void lightRgb(int light, int value){

  int valMax[3];
  int valMin[3];
  int valMid[3];
  int ledVal[3];

  //number of colours
  int rgbNum = 3;
  int rgbLoop = 0;

  //3 base colours, therefore the interval is 1/3
  int rangeInterval = rangeMax/3;
  int rangeMultiplier = (4096 / (rangeMax - 2) * 3); //*3 to increase the maximum to full led capacity (after deviding by 3 above

  valMax[0] = rangeInterval * 2;
  valMin[0] = 0;

  valMax[1] = rangeInterval * 3;
  valMin[1] = rangeInterval;

  valMax[2] = rangeInterval * 4;
  valMin[2] = rangeInterval * 2;

  while (rgbLoop < rgbNum){
    if (value == 0){
      //if the input is 0, turn the led off
      ledVal[rgbLoop] = 0;
    } else {
      
      valMid[rgbLoop] = ((valMax[rgbLoop] - valMin[rgbLoop])/2) + valMin[rgbLoop];
      ledVal[rgbLoop] = 0;
  
      //looping around so on the 3rd loop the value goes from 170 - 85, looping back around 0
      if (rgbLoop == 2){
        if (value < rangeInterval){
          value = value + rangeMax;
        } 
      }
  
      if (value < valMin[rgbLoop]){
        ledVal[rgbLoop] = 0;
      } 
      else if (value < valMid[rgbLoop]){
        ledVal[rgbLoop] = value - valMin[rgbLoop];
      } 
      else if (value < valMax[rgbLoop]){
        ledVal[rgbLoop] = valMax[rgbLoop] - value;
      } 
      else {
        ledVal[rgbLoop] = 0;
      }

      ledVal[rgbLoop] = ledVal[rgbLoop] * rangeMultiplier;
    }

    rgbLoop++;
  }

  //R
  Tlc.set(light, ledVal[0]);
  //G
  Tlc.set(light + 16, ledVal[1]);
  //B
  Tlc.set(light + 32, ledVal[2]);

}

