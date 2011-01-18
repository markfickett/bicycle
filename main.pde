/**
 * Collect information from a bicycle wheel revolution sensor and report it.
 *
 * Hardware:
 * This is written for an Arduino LilyPad (ATMega328) with the following connections
 * to the numbered digital pins. The bicycle sensor is paired with a magnet on a spoke,
 * and falls from infinite resistance to about 2K Ohms when the magnet is nearby.
 * The second leads of all the components are connected to ground.
 *  PIN_REV_SENSOR    wheel revolution sensor (COTS)
 *  PIN_SPEAKER       speaker (telephone ringer)
 *  PIN_BUTTON_TALL   momentary push/rock button (from a VCR's board); easy to trigger
 *  PIN_BUTTON_A      momentary push button (LilyPad); hard to accidentally trigger
 *  PIN_BUTTON_B      ''
 */

#define PIN_STATUS             13
#define PIN_REV_SENSOR         12
#define PIN_SPEAKER            3
#define PIN_BUTTON_TALL        2
#define PIN_BUTTON_A           11
#define PIN_BUTTON_B           10

// This is calibrated empirically with two trials: 2.00km = 959revs, 2.01km = 962revs.
#define METERS_PER_REVOLUTION  2.0874544508068715
#define METERS_PER_KILOMETER   1000

#include <morse.h>


LEDMorseSender statusSender(PIN_STATUS);
SpeakerMorseSender speakerSender(PIN_SPEAKER);
MomentaryButton revSensor(PIN_REV_SENSOR);
MomentaryButton reportButton(PIN_BUTTON_TALL);

#define NUM_TRIP_METERS  2
unsigned int tripMeters[NUM_TRIP_METERS] = {1000, 0};
const char *tripMeterNames[NUM_TRIP_METERS] = {"e", "i"};
MomentaryButton tripMeterButtons[NUM_TRIP_METERS] = {
  MomentaryButton(PIN_BUTTON_A),
  MomentaryButton(PIN_BUTTON_B)
};


void setup()
{
  Serial.begin(28800);
  statusSender.setup();
  speakerSender.setup();
  
  revSensor.setup();
  
  reportButton.setup();
  
  for(int i = 0; i < NUM_TRIP_METERS; i++)
  {
    tripMeterButtons[i].setup();
  }
  
  statusSender.setMessage(String("e")); // just blink
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


  for(int i = 0; i < NUM_TRIP_METERS; i++)
  {
    if (tripMeterButtons[i].wasClicked())
    {
      speakerSender.setMessage(String(tripMeterNames[i]));
      speakerSender.startSending();
    }
    else if (tripMeterButtons[i].wasHeld())
    {
      tripMeters[i] = 0;
      speakerSender.setMessage(String(tripMeterNames[i]) + String(" ") + String(PROSIGN_SK));
      speakerSender.startSending();
    }
  }
  
  statusSender.continueSending();
  speakerSender.continueSending();
}


/**
 * Format a revolutions number to be sent as a Morse message.
 */
String formatRevolutions(unsigned int revolutions)
{
  Serial.print("Formatting ");
  Serial.print(revolutions);
  Serial.println(":");
  float meters = METERS_PER_REVOLUTION*revolutions;
  Serial.println(meters);
  if(meters >= METERS_PER_KILOMETER)
  {
    meters /= METERS_PER_KILOMETER;
    char buffer[10];
    dtostrf(meters, 0, 1, buffer);
    String value = String(buffer) + " km";
    Serial.println(value);
    return value;
  }
  else
  {
    return String((int)round(meters), DEC) + String(" m");
  }
}
