#include "MomentaryButton.h"


MomentaryButton::MomentaryButton(int inputPin)
	: wasClosed(false), pin(inputPin), holdReported(false)
{}

void MomentaryButton::setup()
{
	pinMode(pin, INPUT);
	digitalWrite(pin, HIGH);
}

void MomentaryButton::check()
{
	unsigned long currentTimeMillis = millis();
	boolean isClosed = (digitalRead(pin) == LOW);

	if (isClosed != wasClosed)
	{
		if (isClosed)
		{
			closeTimeMillis = currentTimeMillis;
		}
		else
		{
			holdReported = false;
		}
	}

	clicked = held = false;
	boolean overHoldThreshold =
		(currentTimeMillis - closeTimeMillis) >= HOLD_THRESHOLD;
	if (isClosed && overHoldThreshold)
	{
		held = true;
	}
	else if (!isClosed && wasClosed && !overHoldThreshold)
	{
		clicked = true;
	}

	wasClosed = isClosed;
}

boolean MomentaryButton::wasClicked() {
	return clicked;
}

boolean MomentaryButton::wasHeld() {
	if (held && !holdReported)
	{
        	holdReported = true;
        	return held;
	}
	else
	{
        	return false;
	}
}

