/* PS/2 to parallel ASCII converter. 
 * 2019 (c) John Newcombe.
 * 
 * https://glasstty.com
 * 
 * See geminikeyboard.h for pin assignments.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA 
 * 
 * PS/2 device wiring:
 * 
 * Pin 4 (Green) is +5V
 * Pin 3 (Black) is Ground
 * Pin 1 (Brown) is Data
 * Pin 5 (Yellow) is Clock
 * Pin 2 (White) N/C
 * Pin 6 (Red) N/C 
 * 
 */
  

#include "geminikeyboard.h"

/* Set the initial state of the strobe pin, if the keyboard requires +ve strobe, set the initial value
 *  to LOW. For a negative strobe set the initial Value HIGH.
 */
int strobeState = LOW; 

/* Set this to false to use the mapping table defined below. Setting this to false will output 
 *  the value as determined by the PS/2 Library. Special keys can, be changed by updating the library's
 *  keyboard.h file.
 */
bool useMappingTable = false;

PS2KeyAdvanced keyboard;
unsigned long lastPass = 0;

void setup() {

  Serial.begin(19200);  
  delay(500);

  /* Display a confidence message */
  Serial.print(F("PS/2 to Parallel ASCII Converter."));
  
  keyboard.begin(ps2DataPin, ps2ClockPin);

  /* Setup parallel data pins for 7 bit digital output */
  for (int i = 0; i < 7; i++)
  {
      pinMode(p_dataPins[i], OUTPUT);
  }

  pinMode(strobePin, OUTPUT);
  pinMode(resetPin, OUTPUT);
  digitalWrite(strobePin, strobeState);

}

void writeParallel(byte value) {

    Serial.print("Writing 0x");
    Serial.println(value, HEX);
    
    /* Write the byte to the parallel pins 0 - 6 (7 bits)*/
    for (int i = 0; i < 7; i++)
    {
        // shift value right by 'i' places and perform a logical and with 1.
        digitalWrite(p_dataPins[i], (value >> i) & 0x01);
    }

    /* An ascii value has been placed on the output pins so set the strobe */
    /* Allow time for the connected system to detect the strobe before resetting it */
    toggleStrobe();
    delay(25); 
    toggleStrobe();

}

void toggleStrobe() {

  /* Set the strobe */
  digitalWrite(strobePin, (strobeState) ? HIGH : LOW);
  strobeState = !strobeState;
}

byte translate(uint16_t raw_value) {

  byte result = 0;
  int key_code = raw_value & 0xFF;
  int key_status = raw_value >> 8;


/*
        Define name bit     description
        PS2_BREAK   15      1 = Break key code
                   (MSB)    0 = Make Key code
        PS2_SHIFT   14      1 = Shift key pressed as well (either side)
                            0 = NO shift key
        PS2_CTRL    13      1 = Ctrl key pressed as well (either side)
                            0 = NO Ctrl key
        PS2_CAPS    12      1 = Caps Lock ON
                            0 = Caps lock OFF
        PS2_ALT     11      1 = Left Alt key pressed as well
                            0 = NO Left Alt key
        PS2_ALT_GR  10      1 = Right Alt (Alt GR) key pressed as well
                            0 = NO Right Alt key
        PS2_GUI      9      1 = GUI key pressed as well (either)
                            0 = NO GUI key
        PS2_FUNCTION 8      1 = FUNCTION key non-printable character (plus space, tab, enter)
                            0 = standard character key
 */
  bool key_make = !key_status & B10000000;
  bool key_break = key_status & B10000000;
  bool key_shift = key_status & B01000000;
  bool key_ctrl = key_status & B00100000;
  bool key_caps = key_status & B00010000;
  bool key_alt = key_status & B00001000;
  bool key_art_gr = key_status & B00000100;
  bool key_gui = key_status & B00000010;
  bool key_function = key_status & B00000001;


  // Note that all keys are repeated even Ctrl, Shift etc)
  if(!key_break && key_code > 0 && key_code < keymap_size) {
   
    Serial.print( F( "Key Code 0x" ) );
    Serial.println( key_code, HEX );
    Serial.print( F( "Key Status 0x" ) );
    Serial.println( key_status, HEX );

    /* bool to determine if we have entered [A-Z][a-z] with the CAPS Lock key. */
    bool key_caps_alpha = key_caps && key_code >= 0x41 && key_code <= 0x5A;

    /* Check for control A - Z, and '[', '\', ']' */
    if (key_ctrl) {

      Serial.println("Using normal Keymap.");
      
      /* convert to ascii */
      result = keymap_normal[key_code];

      /* if within the ctrl range, move to the range 0 - 1f, otherwise ignore */
      if (key_code >= 0x40 && key_code <= 0x5f) {
        
        result = key_code - 0x40;               

      }

    /* check for caps lock and shift combinations */
    } else if ((key_caps_alpha && !key_shift) || (!key_caps_alpha && key_shift )) {

      Serial.println("Using shifted Keymap.");
    
      result = keymap_shift[key_code];      
   
    } else {      

      Serial.println("Using normal Keymap.");

      result = keymap_normal[key_code];        
    
    }
  }
  return result;
}

void loop() {
  
  if (keyboard.available()) {
    
    // read the next key
    uint16_t raw_value = keyboard.read();
    
    /* raw_value contains the keycode, this is converted to ASCII using the keymap tables. 
    *  If the high bit is set then the ASCII escape character (1B) will be sent 
    *  before this character. */
    if(raw_value > 0) {

      byte c = translate(raw_value);
      
      if(c > 0) {
        
        Serial.print("ASCII Value 0x");
        Serial.println(c, HEX);

        if(c & B10000000) {
          /* function key, which includes F1-F12, ESC, PgUp. PgDn, Ins, Home etc. so preceed with ESC */
           writeParallel(0x1B);   
        }
        
        /* Write the ascii value to the parallel pins */
        writeParallel(c & 0x7F);
      }
    }
  }    
}

