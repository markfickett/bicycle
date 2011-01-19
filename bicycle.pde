/**
 * Collect information from a bicycle wheel revolution sensor and report it.
 *
 * Controls:
 *	tap PIN_BUTTON_REPORT: odometers' values output in Morse
 *	tap PIN_BUTTON_A: odometer A reset
 *	tap PIN_BUTTON_B: odometer B reset
 *	hold PIN_BUTTON_REPORT: histogram printed over serial
 *	hold PIN_BUTTON_A: histogram saved to EEPROM (always read on startup)
 *	hold PIN_BUTTON_B: histogram cleared
 *
 * Hardware:
 * This is written for an Arduino LilyPad (ATMega328) with the following
 * connections to the numbered digital pins. The bicycle sensor is paired
 * with a magnet on a spoke, and falls from infinite resistance to about
 * 2K Ohms when the magnet is nearby.
 *
 * The second leads of all the components are connected to ground.
 *
 * PIN_REV_SENSOR	wheel revolution sensor (COTS)
 * PIN_SPEAKER		speaker (telephone ringer)
 * PIN_BUTTON_REPORT	momentary push/rock button (from a VCR's board);
 *				easy to trigger
 * PIN_BUTTON_A		momentary push button (LilyPad);
 *				hard to accidentally trigger
 * PIN_BUTTON_B		''
 */


#define PIN_STATUS		13
#define PIN_REV_SENSOR		12
#define PIN_SPEAKER		3
#define PIN_BUTTON_REPORT	2
#define PIN_BUTTON_A		11
#define PIN_BUTTON_B		10

#define METERS_PER_KILOMETER	1000

#include <morse.h>

// Pre-include, since the IDE doesn't pre-process non-.pde files.
#include <EEPROM.h>
#include "Histogram.h"

#include "MomentaryButton.h"


Histogram histogram;
LEDMorseSender statusSender(PIN_STATUS);


SpeakerMorseSender speakerSender(PIN_SPEAKER);
MomentaryButton revSensor(PIN_REV_SENSOR);
MomentaryButton reportButton(PIN_BUTTON_REPORT);

#define NUM_TRIP_METERS  2
unsigned int tripMeters[NUM_TRIP_METERS] = {0, 0};
const char *tripMeterNames[NUM_TRIP_METERS] = {"e", "i"};
MomentaryButton tripMeterButtons[NUM_TRIP_METERS] = {
  MomentaryButton(PIN_BUTTON_A),
  MomentaryButton(PIN_BUTTON_B)
};

void setup()
{
  Serial.begin(9600);
  
  statusSender.setup();
  speakerSender.setup();
  
  revSensor.setup();
  
  reportButton.setup();
  
  for(int i = 0; i < NUM_TRIP_METERS; i++)
  {
    tripMeterButtons[i].setup();
  }
  
  histogram.restore();

  statusSender.setMessage(String("k"));
  statusSender.sendBlocking();
  
  statusSender.setMessage(String("e")); // just blink
  Serial.println("setup complete");
}

void loop()
{
  revSensor.check();
  reportButton.check();
  for(int i = 0; i < NUM_TRIP_METERS; i++)
  {
    tripMeterButtons[i].check();
  }
  
  if (revSensor.wasClicked() || revSensor.wasHeld())
  {
    for(int i = 0; i < NUM_TRIP_METERS; i++)
    {
      tripMeters[i]++;
    }
    histogram.addNow();
    
    statusSender.startSending();
  }
  
  if (reportButton.wasClicked())
  {
    String msg;
    for(int i = 0; i < NUM_TRIP_METERS; i++)
    {
      msg += String(tripMeterNames[i]) + String(" ")
        + formatRevolutions(tripMeters[i]) + String(" ");
    }
    speakerSender.setMessage(msg);
    speakerSender.startSending();
  }
  else if (reportButton.wasHeld())
  {
    histogram.print();
  }


  for(int i = 0; i < NUM_TRIP_METERS; i++)
  {
    if (tripMeterButtons[i].wasClicked())
    {
      tripMeters[i] = 0;
      speakerSender.setMessage(String(tripMeterNames[i]) + String(" ")
        + String(PROSIGN_SK));
      speakerSender.startSending();
    }
  }

  if (tripMeterButtons[0].wasHeld())
  {
    speakerSender.setMessage(String("s"));
    speakerSender.sendBlocking();
    digitalWrite(PIN_STATUS, HIGH);
    histogram.save();
    digitalWrite(PIN_STATUS, LOW);
    speakerSender.setMessage(String(PROSIGN_KN));
    speakerSender.sendBlocking();
  }
  if (tripMeterButtons[1].wasHeld())
  {
    speakerSender.setMessage(String("x"));
    speakerSender.sendBlocking();
    histogram.clear();
  }
  
  statusSender.continueSending();
  speakerSender.continueSending();
}


/**
 * Format a revolutions number to be sent as a Morse message.
 */
String formatRevolutions(unsigned int revolutions)
{
  float meters = METERS_PER_REVOLUTION*revolutions;
  if(meters >= METERS_PER_KILOMETER)
  {
    meters /= METERS_PER_KILOMETER;
    char buffer[10];
    dtostrf(meters, 0, 1, buffer);
    String value = String(buffer) + " km";
    return value;
  }
  else
  {
    return String((int)round(meters), DEC) + String(" m");
  }
}

