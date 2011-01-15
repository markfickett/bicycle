/**
 * Collect data from a bicycle wheel revolution sensor and report it.
 */

#define PIN_STATUS     13
#define BLINK_LENGTH   100

// This pin will drop from effectively infinite to 1K Ohm resistance.
#define PIN_REV_SENSE  2

void setup()
{
  pinMode(PIN_STATUS, OUTPUT);
  digitalWrite(PIN_STATUS, LOW);
  
  pinMode(PIN_REV_SENSE, INPUT);
  digitalWrite(PIN_REV_SENSE, HIGH); // Enable the pullup resistor.
}

void loop()
{
  int revSense = digitalRead(PIN_REV_SENSE);
  if (revSense == LOW) // closed == low resistance == magnet nearby sensor
  {
    digitalWrite(PIN_STATUS, HIGH);
    delay(BLINK_LENGTH);
    digitalWrite(PIN_STATUS, LOW);
  }
}
