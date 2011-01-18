

// Any button press >= HOLD_THRESHOLD milliseconds is considered a hold, not a click.
#define HOLD_THRESHOLD   2000

/**
 * Encapsulate tracking pushes on a normally-open momentary button.
 *
 * After a call to check(), the button may report that it:
 *  - wasClicked(): tapped briefly
 *  - wasHeld(): pressed for a longer period of time (and perhaps still closed)
 * The next call to check() will not report on that previous event.
 */
class MomentaryButton {
  private:
    // Was this button pushed (closed) when last checked?
    boolean wasClosed;
    // Only report a hold once (even though the condition is satisfied continuously).
    boolean holdReported;
    // When was this button pushed (closed)?
    unsigned long closeTimeMillis;
    const int pin;
    boolean clicked, held; // At last check, was this button clicked (held)?
  public:
    MomentaryButton(int inputPin) : wasClosed(false), pin(inputPin), holdReported(false)
    {}
    
    void setup()
    {
      pinMode(pin, INPUT);
      digitalWrite(pin, HIGH);
    }
    
    void check()
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
      boolean overHoldThreshold = (currentTimeMillis - closeTimeMillis) >= HOLD_THRESHOLD;
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
    
    boolean wasClicked() {
      return clicked;
    }
    
    boolean wasHeld() {
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
};

