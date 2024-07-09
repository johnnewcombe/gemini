This Arduino sketch was created to implement a PS/2 to Parallel ASCII keyboard converter using an Arduino Micro. The primary aim was to facilitate using a PS/2 keyboard with a Gemini 80-Bus computer (see https://glasstty.com/wiki/index.php/The_Gemini_80-Bus_Saga), however, the sketch could be used with any machine requiring a Parallel ascii keyboard with positive or negative strobe.

The sketch as presented here implements 7 data bits with a positive strobe and makes use of a lookup table to enable a very configurable key to ascii configuration.

