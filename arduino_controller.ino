/* Sweep
 by BARRAGAN <http://barraganstudio.com>
 This example code is in the public domain.

 modified 8 Nov 2013
 by Scott Fitzgerald
 http://www.arduino.cc/en/Tutorial/Sweep
*/




/*    PREPROCESSOR DIRECTIVES    */
#define l1 16   // length of first adjunct - const
#define l2 12.5   // length of second adjunct - const
#define l3 12.5   // length of third adjunct - const
#define l4 16   // length of fourth adjunct - const


#pragma mark - Servo
#include <Servo.h>

/*    GLOBAL VARIABLES    */
Servo servo_1;  // create servo object to control a servo
Servo servo_2;
Servo servo_3;
int pos = 0;    // variable to store the servo position
bool error = false; //true if selected point is outside the working space

/*    FUNCTIONS    */

/// create a array consisting of three angles theta_1, theta_2, theta_3
/// @param  px - coordinate in X axis
/// @param  py - coordinate in Y axis
/// @param  pz - coordinate in Z axis
/// @return array of angles in rads
double* retrieveVariables(double px, double py, double pz);

/// converts rad into angles
/// @param  rad  measure in rad
/// @return angle 
double radToAngles(double rad);

/// moving on the value of angle for about 90 degrees
/// @param  angle value of angle
/// @return moved on value of angle
double remap (double angle);

/// holding down the value of angle
/// @param  angle the value of angle
/// @return 
double holdDownValueOfAngle(double angle);

/// chcecking if value of angles are in the range from -90 to 90
/// @param  angle angle in degrees
/// @return true if everything is OK
bool checkIfValueOfAngleIsOK(double angle);



#pragma mark - SerialSoftware
#include <SoftwareSerial.h>
 
 /*
  This set of global variables and functions is crucial to the correct work of the program.

*/

String buffor = "";
char character = 0;
SoftwareSerial mySerial(10, 11); // RX, TX
void readDataFromBluetooth (String characters);
void readDataLoop();
void readDataSetup();

struct Location {
    float px =0.0, py=0.0, pz=0.0;
    bool doCalculation = false;
    void setPx(float p){
      px = p;
    }
    void setPy(float p){
      py = p;
    }
    void setPz(float p){
      pz = p;
    }
    void setCalculatePermission (bool calc){
      doCalculation = calc;
    }
    bool getCalculatePermission(){
      return doCalculation;
    }
};
Location location;



#pragma mark - Arduino setup() and loop()

/*    SETUP    */
void setup() {
  servo_1.attach(9);  // attaches the servo on pin 9 to the servo object
  servo_2.attach(6);
  servo_3.attach(5);
  
  readDataSetup();
  


}

/*    LOOP    */
void loop() {

  if (mySerial.available()) {
    readDataLoop();

    if (location.getCalculatePermission()){
      double * theta_position = new double [3];
      //   theta_position = retrieveVariables(7,22,32);   //   theta_position = retrieveVariables(12.5,12.5,32); 
      theta_position = retrieveVariables(location.px,location.py,location.pz);
      servo_1.write(theta_position[0]);
      delay(100);
      servo_2.write(theta_position[1]);
      delay(100);
      servo_3.write(theta_position[2]);
      delay(100);
      location.setCalculatePermission(false);

      
      
      if(!error){
        mySerial.print(theta_position[0]);
        mySerial.print("-");
        mySerial.print(theta_position[1]);
        mySerial.print("-");
        mySerial.print(theta_position[2]);
        mySerial.print("!");
      }
      
      
      if(Serial){
          Serial.println("Theta position:");
          Serial.println(theta_position[0]);
          Serial.println(theta_position[1]);
          Serial.println(theta_position[2]);
      }

    }
  }  
  delay(10);
}

#pragma mark - Servo

double radToAngles(double rad){
  return rad * 180/3.14;
}

double remap (double angle){
  return map(angle, -90, 90, 0, 180);
}
double holdDownValueOfAngle(double angle){
  
}

bool checkIfValueOfAngleIsOK(double angle){
  if((-90 <angle) && (angle> 90)){
    return true;
  } else {
//    Serial.println("The value of angle is out of range. Move cannot be accomplished");
    return false;
  }
}

double* retrieveVariables(double px, double py, double pz){
  error = false;
  double *theta = new double [3];
  /*  THETA_3  */
  double sinus_3 = (pz-l1)/l4;
  double cosinus_3 = sqrt(1-pow(sinus_3,2));
  double theta_3 = atan2(sinus_3,cosinus_3);
  if (Serial) {
    Serial.println("theta3:");
    Serial.println(radToAngles(sinus_3));
    Serial.println(radToAngles(cosinus_3));
    Serial.println(radToAngles(theta_3));
  }

  /*  THETA_2  */
  double cosinus_2= (px*px + py*py - l2*l2 - ((l3+l4*cosinus_3)*(l3+l4*cosinus_3)))/(2*l2*(l3+l4*cosinus_3));
  double sinus_2 = sqrt(1-pow(cosinus_2,2));
  double theta_2 = atan2(sinus_2,cosinus_2);
  if (Serial) {
    Serial.println("theta2:");
    Serial.println(radToAngles(sinus_2));
    Serial.println(radToAngles(cosinus_2));
    Serial.println(radToAngles(theta_2));
  }
  
  /*  THETA_1  */
      if(px>0) {
          double alfa = atan2(px,py);
          double beta = atan2(sinus_2*(l3+l4*cosinus_3),l2+cosinus_2*(l3+l4*cosinus_3));
          double theta_1 = alfa - beta;
          theta[0] = radToAngles(theta_1)+90;
             if (Serial) {
                Serial.println("theta1:");
                Serial.println(radToAngles(alfa));
                Serial.println(radToAngles(beta));
                Serial.println(radToAngles(theta_1));
             }
        } else {
          double alfa = atan2(-px,py);
          double beta = atan2(sinus_2*(l3+l4*cosinus_3),l2+cosinus_2*(l3+l4*cosinus_3));
          double theta_1 = -alfa + beta;
          theta[0] = radToAngles(theta_1)+90;
            if (Serial) {
              Serial.println("theta1:");
              Serial.println(radToAngles(alfa));
              Serial.println(radToAngles(beta));
              Serial.println(radToAngles(theta_1));
            }
        }
  
  /*  THETA in degrees */
//  theta[0] = radToAngles(theta_1)+90;
  theta[1] = radToAngles(theta_2)+90;
  theta[2] = radToAngles(theta_3)+90;
 
  if(theta[0] >180 && theta[0]<180.1){ // TODO Should be solved in proper way. Important.
    theta[0] = 180;
  }

  if(theta[1] >180 && theta[1]<180.1){
    theta[1] = 180;
  }

  if(theta[2] >180 && theta[2]<180.1){
    theta[2] = 180;
  }
  
  if(theta[0] <0 && theta[0]>-0.1){
    theta[0] = 0;
  }

  if(theta[1] <0 && theta[1]>-0.1){
    theta[1] = 0;
  }
   if(theta[2] <0 && theta[2]>-0.1){
    theta[2] = 0;
  }

/*Errory - ustawia wszystkie serwa na 90 stopni, jesli ktorys kąt nie leży w zakresie*/
if(theta[0]<0 || theta[0]>180 ||theta[1]<0 || theta[1]>180 || theta[2]<0 || theta[2]>180)
{
  mySerial.print("Error: ");
  mySerial.print(theta[0]);
  mySerial.print("-");
  mySerial.print(theta[1]);
  mySerial.print("-");
  mySerial.print(theta[2]);
  mySerial.print("!");
  error = true;
  
  theta[0]=90;
  theta[1]=90;
  theta[2]=90;

}

  if (Serial) {
    Serial.println("theta:");
    Serial.println(theta[0]);
    Serial.println(theta[1]);
    Serial.println(theta[2]);
  }
  
  return theta;

}


#pragma mark - SerialSoftware

void readDataSetup(){
    ////   Open serial communications and wait for port to open:
  Serial.begin(9600);
  int milisToDelay = 10;
  while(!Serial){
    //wait for serial port to connect. Needed for native USB port only.
    delay(1000);
    if (!milisToDelay){
      break;
    }
    milisToDelay--;
  }
 
 
    if(Serial) Serial.println("Goodnight moon!");

  // set the data rate for the SoftwareSerial port
  mySerial.begin(38400);
  mySerial.println("Hello, world?");
}

void readDataLoop(){
    character = mySerial.read();
    
    if (character == 'm') { // just for testing if connection via Bluetooth is alive
      digitalWrite(2, HIGH);
    } else {
      digitalWrite(2, LOW);
    }

    switch (character){
        case '<':{
            buffor = "";
            if (Serial) Serial.println("start");
            break;
        }
        case '>':{
            readDataFromBluetooth(buffor);
            buffor = "";
            if (Serial) Serial.println("stop");
            break;
        }
        default:{
            buffor += character;
            break;
        }
    }
  
}


typedef enum : int {
    px,
    py,
    pz,
} Coordinate;



void readDataFromBluetooth (String character) {
    float value;

    // TODO - should be global
    
    Coordinate coordinate;
    String buffor;
    String calculation = "calculate";
    if (character[0] == 'p'){
        switch (character[1]){
            case 'x':{
                coordinate = px;
                break;
            }
            case 'y':{
                coordinate = py;
                break;
            }
            case 'z':{
                coordinate = pz;
                break;
            }
        }
        value = character.substring(3).toFloat();
        
        switch (coordinate) {
            case px:
                location.setPx(value);
                if (Serial){
                Serial.print("px=:");
                Serial.print(location.px);
           
                }
                break;
            case py:
                location.setPy(value);
                if (Serial){
                Serial.print("py=:");
                Serial.print(location.py);
           
                }
                break;
            case pz:
                location.setPz(value);
                if (Serial){
                Serial.print("pz=:");
                Serial.print(location.pz);
            
                }
                break;
            default:
                break;
        }
    } else if (character == calculation){ 
      location.setCalculatePermission(true);
    }

   
}






 
