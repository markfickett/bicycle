#include "Histogram.h"
#include <EEPROM.h>
#include <math.h>


Histogram::Histogram() {
	lastAddMillis = millis();
	clear();
}

void Histogram::clear()
{
	memset(intervalHistogram, 0, sizeof(intervalHistogram));
}

void Histogram::addNow()
{
	unsigned long currentTime = millis();
	unsigned long elapsedTime = currentTime - lastAddMillis;
	lastAddMillis = currentTime;

	float logValue = log(elapsedTime);
	logValue = constrain(logValue, HISTOGRAM_MIN, HISTOGRAM_MAX);
	int index = (int)((logValue-HISTOGRAM_MIN)/HISTOGRAM_INC);

	intervalHistogram[index] += 1;
}

void Histogram::print()
{
	Serial.begin(28800);
	Serial.println("# Key: interval (ms)");
	Serial.println("# Value: number of revolutions"
		" taking this interval or greater");
	char buffer[10];
	dtostrf(METERS_PER_REVOLUTION, 0, sizeof(buffer)-3, buffer);
	Serial.println(String("METERS_PER_REVOLUTION = ") + String(buffer));
	Serial.println("(");
	for(int i = 0; i < HISTOGRAM_SIZE; i++)
	{
		Serial.print("\t(");
		float logValue = i*HISTOGRAM_INC + HISTOGRAM_MIN;
		float interval = exp(logValue);
		Serial.print(interval);
		Serial.print(",\t");
		Serial.print(intervalHistogram[i]);
		Serial.println("),");
	}
	Serial.println(") ");
	Serial.end();
}

void Histogram::restore()
{
	int address;
	byte lowerValue, upperValue;
	for(int i = 0; i < HISTOGRAM_SIZE; i++)
	{
		address = i*2;
		lowerValue = EEPROM.read(address);
		upperValue = EEPROM.read(address+1);
		intervalHistogram[i] = (upperValue << 8) | lowerValue;
	}
}

void Histogram::save()
{
	byte upperByte, lowerByte;
	unsigned int lowerMask = 0xFF;
	unsigned int upperMask = 0xFF00;
	int address;
	for(int i = 0; i < HISTOGRAM_SIZE; i++)
	{
		unsigned int histogramValue = intervalHistogram[i];
		address = i*2;
		upperByte = (histogramValue & upperMask) >> 8;
		EEPROM.write(address+1, upperByte);
		lowerByte = histogramValue & lowerMask;
		EEPROM.write(address, lowerByte);
	}
}

