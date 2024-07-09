#ifndef _GEMINI_KEYBOARD_h
#define _GEMINI_KEYBOARD_h

#include "PS2KeyAdvanced.h"

/*
 * Pin used for the ps2ClockPin, needs to be an interrupt pin (e.g. Arduino Micro pins 2 or 3).
 */
const int ps2ClockPin = 2;
const int ps2DataPin = 3;

const int resetPin = 4;
const int strobePin = 12;

/* Using a UK keyboard, the keys of interest sit between 0x00 and 0x8f (other keyboards may vary. The
 * following table elements contains the ascii codes positioned by the PS/2 key_code value when the 
 * keyboard is in an un-shifted state. The value zero in an element simply means that the code is ignored.
 * 
 * Note that the codes returned with with high bit set are treated as function keys. In particular note that
 * the escape is set to 80. This, with the high bit being set, will result in ESC 0 (0x1B, 0x00) being 
 * sent to the host, this is correct for the Gemini IVC Card. To send a simple ESC (0x1B) simply set the
 * value in 1B to 0x1B.
 */
const int keymap_size = 0x90;
const byte keymap_normal[keymap_size] = 
{ 
  // 0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   // Raw Key Codes   0 - 0f
  0x00, 0x8e, 0x8f, 0x90, 0x91, 0x08, 0x09, 0x0b, 0x0a, 0x8d, 0x7f, 0x80, 0x00, 0x09, 0x0d, 0x20,   // Raw Key Codes  10 - 1f
  0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x00, 0x0d, 0x2b, 0x2d, 0x2a, 0x2f,   // Raw Key Codes  20 - 2f
  0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x27, 0x2c, 0x2d, 0x2e, 0x2f, 0x00,   // Raw Key Codes  30 - 3f
  0x7c, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f,   // Raw Key Codes  40 - 4f
  0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x3b, 0x23, 0x5b, 0x5d, 0x3d,   // Raw Key Codes  50 - 5f
  0x00, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x00, 0x00, 0x00,   // Raw Key Codes  60 - 6f
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   // Raw Key Codes  70 - 7f
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x5c, 0x00, 0x00, 0x00, 0x00,   // Raw Key Codes  80 - 8f
};

/* Using a UK keyboard, the keys of interest sit between 0x00 and 0x8f (other keyboards may vary. The
 * following table elements contains the ascii codes positioned by the PS/2 key_code value when the 
 * keyboard is in a shifted state. The value zero in an element simply means that the code is ignored.
 * 
 * Note that the codes returned with with high bit set are treated as function keys. In particular note that
 * the escape is set to 80. This, with the high bit being set, will result in ESC 0 (0x1B, 0x00) being 
 * sent to the host, this is correct for the Gemini IVC Card. To send a simple ESC (0x1B) simply set the
 * value in 1B to 0x1B.
 */
const byte keymap_shift[keymap_size] = 
{ 
  // 0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   // Raw Key Codes   0 - 0f
  0x00, 0xae, 0xaf, 0xb0, 0xb1, 0x08, 0x09, 0x0b, 0x0a, 0xab, 0x7f, 0x80, 0x00, 0x09, 0x0d, 0x20,   // Raw Key Codes  10 - 1f
  0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x00, 0x0d, 0x2b, 0x2d, 0x2a, 0x2f,   // Raw Key Codes  20 - 2f
  0x29, 0x21, 0x22, 0x23, 0x24, 0x25, 0x5e, 0x26, 0x2a, 0x28, 0x40, 0x3c, 0x5f, 0x3e, 0x3f, 0x00,   // Raw Key Codes  30 - 3f
  0x60, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f,   // Raw Key Codes  40 - 4f
  0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x3a, 0x7e, 0x7b, 0x7d, 0x2b,   // Raw Key Codes  50 - 5f
  0x00, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0x00, 0x00, 0x00,   // Raw Key Codes  60 - 6f
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   // Raw Key Codes  70 - 7f
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7c, 0x00, 0x00, 0x00, 0x00,   // Raw Key Codes  80 - 8f
};

/*
 * Array representing the pins that are used for the data bits (0-7).
 */
const int p_dataPins[8] = { 5, 6, 7, 8, 9, 10, 11 };

#endif



