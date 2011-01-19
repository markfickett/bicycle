#pragma once

/**
 * Record a log-scale histogram of wheel-revolution timing intervals,
 * and save/restore to/from EEPROM.
 */


#include "WProgram.h"


// This is calibrated empirically with two trials:
//	2.00km = 959revs, 2.01km = 962revs.
#define METERS_PER_REVOLUTION  2.0874544508068715

// The LilyPad Arduino has 512 bytes of EEPROM.
//   http://arduino.cc/en/Main/ArduinoBoardLilyPad
#define EEPROM_SIZE  512

// histogram of revolution intervals,
// 'too small' and 'too large' clamped to ends
// Expected values:
// (1h/ MPH mi) * (1mi/(1000*1.609344)m) * (2.087m/1cycle) * (1000*60*60ms/1h)
// mph	ms/cycle	ln(ms/cycle)
// .5	9336		9.14
//  1	4668		8.45
//  2	2334		7.76
//  3	1556		7.35
//  5	 934		6.84
// 12	 389		5.96
// 20	 233		5.45
// 35	 133		4.89
// 46	 101		4.61
// 50	  93		4.54
// 80	  58		4.07
#define HISTOGRAM_MIN		4.05
#define HISTOGRAM_MAX		10.00
const int HISTOGRAM_SIZE = EEPROM_SIZE/2; // two bytes per value (int)
const float HISTOGRAM_INC = (HISTOGRAM_MAX-HISTOGRAM_MIN)/(HISTOGRAM_SIZE-1);


class Histogram {
private:
	unsigned int intervalHistogram[HISTOGRAM_SIZE];
	unsigned long lastAddMillis;

public:
	Histogram();

	void addNow();

	void clear();

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

