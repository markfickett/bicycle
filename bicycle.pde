/**
 * Collect data from a bicycle wheel revolution sensor and report it.
 */
/*
#include <morse.h>

#define PIN_STATUS         13
#define BLINK_LENGTH       100

// This pin will drop from effectively infinite to 1K Ohm resistance.
#define PIN_REV_SENSE      12

// a momentary switch, pressed to generate the report
#define PIN_REPORT_SWITCH  2

// histogram of revolution intervals, 'too small' and 'too large' clamped to ends
#define HISTOGRAM_MIN      90
#define HISTOGRAM_MAX      2010
#define HISTOGRAM_INC      10
const int HISTOGRAM_SIZE = (HISTOGRAM_MAX-HISTOGRAM_MIN)/HISTOGRAM_INC + 1;
unsigned long intervalHistogram[HISTOGRAM_SIZE] = {0};
unsigned int minInterval;

// Track whether the status LED is on, to avoid excess digitalWrite calls.
boolean statusIsOn;
unsigned long lastRevolutionTime;

// Use a state machine for responding to sensor input.
const int
  FIRST_REVOLUTION = 0,
  SENSOR_WAS_ON = 1,
  SENSOR_WAS_OFF = 2;
int currentSensorState;

boolean reportSwitchWasClosed;

void setup()
{
  pinMode(PIN_STATUS, OUTPUT);
  digitalWrite(PIN_STATUS, HIGH);
  
  pinMode(PIN_REV_SENSE, INPUT);
  digitalWrite(PIN_REV_SENSE, HIGH); // Enable the pullup resistor.
  
  pinMode(PIN_REPORT_SWITCH, INPUT);
  digitalWrite(PIN_REPORT_SWITCH, HIGH);
  reportSwitchWasClosed = false;
  
  statusIsOn = true;
  lastRevolutionTime = millis();
  
  currentSensorState = FIRST_REVOLUTION;
  
  Serial.begin(28800);
  Serial.println("Setup complete.");
}

**
 * Print a Python list of of (interval, count) tuples.
 *
void printHistogramData()
{
  Serial.println("(");
  for(int i = 0; i < HISTOGRAM_SIZE; i++)
  {
    Serial.print("\t(");
    Serial.print(HISTOGRAM_MIN + HISTOGRAM_INC*i);
    Serial.print(",\t");
    Serial.print(intervalHistogram[i]);
    Serial.println("),");
  }
  Serial.println(")");
}

void loop()
{
  unsigned long currentTime = millis();
  unsigned long elapsedTime = currentTime - lastRevolutionTime;
  boolean revSensorTriggered = digitalRead(PIN_REV_SENSE) == LOW;
  
  boolean reportSwitchIsClosed = digitalRead(PIN_REPORT_SWITCH) == LOW;
  if (reportSwitchIsClosed != reportSwitchWasClosed)
  {
    if (reportSwitchIsClosed)
    {
      printHistogramData();
    }
    reportSwitchWasClosed = reportSwitchIsClosed;
  }
  
  switch(currentSensorState)
  {
    case(SENSOR_WAS_OFF) :
      if (statusIsOn && (elapsedTime >= BLINK_LENGTH))
      {
        //Serial.println("status light turning off");
        digitalWrite(PIN_STATUS, LOW);
        statusIsOn = false;
      }
      
      if (revSensorTriggered) {
        //Serial.println("was off -> was on");
        Serial.println(elapsedTime);
        
        intervalHistogram[
          min(max(elapsedTime, HISTOGRAM_MIN), HISTOGRAM_MAX)
          / HISTOGRAM_INC
        ] += 1;
        
        lastRevolutionTime = currentTime;
        
        digitalWrite(PIN_STATUS, HIGH);
        statusIsOn = true;
        
        currentSensorState = SENSOR_WAS_ON;
      }
      break;
    
    case(SENSOR_WAS_ON) :
      if (!revSensorTriggered) {
        // Make sure the sensor turns off before triggering again.
        //Serial.println("was on -> was off");
        currentSensorState = SENSOR_WAS_OFF;
      }
      break;
    
    case(FIRST_REVOLUTION) :
      if (revSensorTriggered) {
        minInterval = elapsedTime;
        lastRevolutionTime = currentTime;
        
        digitalWrite(PIN_STATUS, LOW);
        statusIsOn = false;
        
        //Serial.println("first -> was on");
        currentSensorState = SENSOR_WAS_ON;
      }
      break;
  }

}
*/
