PROGRAM HEXDUMP; {$A+R-}

{ This program will output a hex dump af any disk file. Each    }
{ line shows the address of the first byte of the line, then    }
{ 16 bytes in hex, and then the same bytes in ASCII, if they    }
{ are printable. On running the program, you must specify the   }
{ name of the disk file to be dumped, and the name of the disk  }
{ file or logical device (CON:, LST:, etc.), which is to reci-  }
{ eve the dump. The dump can be halted temporarily by pressing  }
{ any key, or aborted using ^C.                                 }

LABEL BREAK,EXIT;
TYPE
  BYTE = 0..255;
  SECTOR = ARRAY[0..7,0..15] OF BYTE;
  CHAR = STRING[1];
  HEXSTRING = STRING[4];
  FILENAME = STRING[14];
VAR
  LIN,POS,ADR,DATA,I,J: INTEGER;
  CH: CHAR;
  INFILENAME,OUTFILENAME: FILENAME;
  S: SECTOR;
  INFILE: FILE OF SECTOR;
  OUTFILE: TEXT;

FUNCTION HEX(NUMBER,DIGITS: INTEGER): HEXSTRING;
CONST
  HEXDIGITS = '0123456789ABCDEF';
VAR
  D: INTEGER;
  H: HEXSTRING;
BEGIN
  H:=EMPTY;
  FOR D:=1 TO DIGITS DO
  BEGIN
    H:=HEXDIGITS[SUCC(NUMBER AND $0F)]+H;
    NUMBER:=NUMBER SHIFT -4;
  END;
  HEX:=H;
END;

BEGIN
  WRITE('Input file name? '); READLN(INFILENAME);
  IF INFILENAME=EMPTY THEN GOTO EXIT;
  WRITE('Output file name? '); READLN(OUTFILENAME);
  IF OUTFILENAME=EMPTY THEN GOTO EXIT;
  {$I-} RESET(INFILE,INFILENAME) {$I+};
  IF IORES>0 THEN
  BEGIN
    WRITELN(INFILENAME,' does not exist'); GOTO EXIT;
  END;
  REWRITE(OUTFILE,OUTFILENAME);
  ADR:=0;
  WHILE NOT EOF(INFILE) DO
  BEGIN
    GET(INFILE,S);
    FOR LIN:=0 TO 7 DO
    BEGIN
      WRITE(OUTFILE,HEX(ADR,4),' ');
      FOR POS:=0 TO 15 DO
      BEGIN
        IF POS=8 THEN WRITE(OUTFILE,' ');
        WRITE(OUTFILE,HEX(S[LIN,POS],2):3);
      END;
      WRITE(OUTFILE,'  ');
      FOR POS:=0 TO 15 DO
      BEGIN
        DATA:=S[LIN,POS];
        IF (DATA>=$20) AND (DATA<$7F) THEN
        WRITE(OUTFILE,CHR(DATA)) ELSE WRITE(OUTFILE,'.');
      END;
      WRITELN(OUTFILE);
      ADR:=ADR+16;
      IF KEYPRESS THEN
      BEGIN
        GET(CH); IF ORD(CH)=3 THEN GOTO BREAK;
        GET(CH); IF ORD(CH)=3 THEN GOTO BREAK;
      END;
    END;
  END;
  BREAK:
  CLOSE(INFILE); CLOSE(OUTFILE,LOCK);
  EXIT:
END.
