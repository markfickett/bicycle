#pragma once

/**
 * Record a histogram of wheel-revolution timing intervals,
 * and save/restor to/from EEPROM.
 */


#include "WProgram.h"


// histogram of revolution intervals,
// 'too small' and 'too large' clamped to ends
#define HISTOGRAM_MIN      90
#define HISTOGRAM_MAX      2010
#define HISTOGRAM_INC      10
const int HISTOGRAM_SIZE = (HISTOGRAM_MAX-HISTOGRAM_MIN)/HISTOGRAM_INC + 1;

// The LilyPad Arduino has 512 bytes of EEPROM.
//   http://arduino.cc/en/Main/ArduinoBoardLilyPad
#define EEPROM_SIZE  512


class Histogram {
private:
	unsigned long intervalHistogram[HISTOGRAM_SIZE];
	unsigned long lastAddMillis;

public:
	Histogram();

	void addNow();

	/**
	 * Print a Python list of of (interval, count) tuples on Serial.
	 * (Serial.begin(..) should already have been called.)
	 */
	void print();

	/**
	 * Read the histogram from EEPROM.
	 */
	void restore();

	/**
	 * Save the histogram to EEPROM.
	 */
	void save();
};

