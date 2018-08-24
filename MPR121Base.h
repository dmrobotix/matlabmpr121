#include "LibraryBase.h"
#include "Adafruit_MPR121.h"



const char MSG_MPR121_CREATE_MPR121_DRIVER[]       PROGMEM = "Adafruit::AFMD = new Adafruit_MPR121()->begin(%d);\n";
const char MSG_MPR121_DELETE_MPR121_DRIVER[]       PROGMEM = "Adafruit::delete AFMD;\n";
const char MSG_MPR121_TOUCHED_MPR121_DRIVER[]      PROGMEM = "Adafruit::AFMD->touched();\n";

#define CREATE_MPR121_DRIVER      0x00
#define DELETE_MPR121_DRIVER      0x01
#define TOUCHED_MPR121_DRIVER     0x02
#define MPR121_I2CADDR_DEFAULT    0x5A

Adafruit_MPR121 *AFMD;

class MPR121Base : public LibraryBase {

  public:
    MPR121Base(MWArduinoClass& a)
    {
      libName = "Adafruit/MPR121";
      a.registerLibrary(this);
    }

  public:
  	void commandHandler(byte cmdID, byte* dataIn, unsigned int payloadSize)
  	{
            switch (cmdID){
                // Motor shield
                case CREATE_MPR121_DRIVER:{
                    //byte i2caddress = dataIn[0];
                    //createMPR121Driver(i2caddress);
                    boolean status = createMPR121Driver(MPR121_I2CADDR_DEFAULT);
                    //byte msg[9] = "No work.";
                    if (status == true) {
                      byte msg[9]= "Success!";
                      sendResponseMsg(cmdID, msg, 9);
                    } else {
                      byte msg[9] = "Failed!!";
                      sendResponseMsg(cmdID, msg, 9);
                    }
                    break;
                }
                case DELETE_MPR121_DRIVER:{
                    deleteMPR121Driver();
                    sendResponseMsg(cmdID, 0, 0);
                    break;
                }

                case TOUCHED_MPR121_DRIVER:{
                    uint16_t value = touchedMPR121Driver();
                    byte lo = value & 0xFF;
                    byte hi = value >> 8;

                    byte status[2] = {hi,lo};
                    sendResponseMsg(cmdID, status, 2);
                    break;
                }

                default:
  				          break;
            }
  	}

  public:
    static boolean createMPR121Driver(uint8_t i2caddress = MPR121_I2CADDR_DEFAULT) {
      AFMD = new Adafruit_MPR121();
      boolean status = AFMD->begin(i2caddress);
      debugPrint(MSG_MPR121_CREATE_MPR121_DRIVER,i2caddress);
      return status;
    }

    static void deleteMPR121Driver() {
      delete AFMD;
      debugPrint(MSG_MPR121_DELETE_MPR121_DRIVER);
    }

    static uint16_t touchedMPR121Driver() {
      //uint16_t touched = AFMD->touched();
      uint16_t touched = 0b0000111111111111;

      debugPrint(MSG_MPR121_TOUCHED_MPR121_DRIVER);
      return touched;
    }

};
