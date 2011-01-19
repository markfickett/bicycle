#include "Histogram.h"
#include <EEPROM.h>


Histogram::Histogram() {
	memset(intervalHistogram, 0, sizeof(intervalHistogram));
	lastAddMillis = millis();
}

void Histogram::addNow()
{
	unsigned long currentTime = millis();
	unsigned long elapsedTime = currentTime - lastAddMillis;
	lastAddMillis = currentTime;

	intervalHistogram[
		( min(max(elapsedTime, HISTOGRAM_MIN), HISTOGRAM_MAX)
			-HISTOGRAM_MIN )
		/ HISTOGRAM_INC
	] += 1;
}

void Histogram::print()
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

void Histogram::restore()
{
	for(int address = 0; address < EEPROM_SIZE; address++)
	{
		byte value = EEPROM.read(address);
	}
}

void Histogram::save()
{
}

