PROGRAM PHONELIST; {$A+R-}

{ PHONE is a program that allows you to maintain a list of      }
{ names, addresses and phone numbers. Each record contains 6    }
{ fields: A first name, a last name, three address fields, and  }
{ a phone number. The records are sorted by last name and then  }
{ by first name. On running the program, you are prompted for a }
{ file name (don't give a file type, as this is automatically   }
{ added by the program). If the file you specify does not exist }
{ a new file is created. The main menu of the program allows    }
{ you to add records, to find records, or to quit. On finding a }
{ record, you must specify a first name and a last name. You    }
{ may specify the names in full, or only the first characters.  }
{ Note, however, that anything but an empty first name implies  }
{ that the last name is specified in full. When a record has    }
{ been located, you are allowed to move forwards and backwards  }
{ in alphabetical order, and once you quit this menu, you may   }
{ choose to edit or delete the record shown on the screen.      }

CONST
  MAXENTRY = 1000;              { Max. number of entries }
  ENTER = 13;                   { Enter key }
  BACK = 8;                     { Backspace key }
  CLEAR = 127;                  { Clear line key }
  LEFT = 28;                    { Cursor left key }
  RIGHT = 29;                   { Cursor right key }
  BOLIN = 30;                   { Start of line key }
  EOLIN = 31;                   { End of line key }
TYPE
  CHAR = STRING[1];
  STR10 = STRING[10];
  STR16 = STRING[16];
  STR20 = STRING[20];
  STR30 = STRING[30];
  STR51 = STRING[51];
  REC = RECORD                  { Data record format }
          FNAME: STR20;         { First name }
          LNAME: STR30;         { Last name }
          ADDR1: STR30;         { Address 1 }
          ADDR2: STR30;         { Address 2 }
          ADDR3: STR30;         { Address 3 }
          PHONE: STR16;         { Phone number }
        END;
  IDX = ARRAY[0..MAXENTRY] OF INTEGER;
VAR
  RECF: FILE OF REC;            { Record file (FILENAME.REC) }
  IDXF: FILE OF IDX;            { Index file (FILENAME.IDX) }
  INDEX: IDX;                   { Memory copy of index }
  A: REC;                       { Record buffer }
  FILENAME: STR10;              { Disk file name }
  I,J,P,NUMREC: INTEGER;
  OK: BOOLEAN;
  S,T: CHAR;

{ INDEX[MAXENTRY] holds the number of entries in your phone     }
{ list. This value is loaded into NUMREC in the beginning of    }
{ the program. The elements from INDEX[0] to INDEX[NUMREC-1]    }
{ holds the record numbers of the records in alphabetical or-   }
{ der, and INDEX[NUMREC] through INDEX[MAXENTRY-1] holds poin-  }
{ ters to empty records in the data file.                       }

{ UPCASE converts its argument to an upper case character       }

FUNCTION UPCASE(CH: CHAR): CHAR;
BEGIN
  IF (CH>='a') AND (CH<='}') THEN
  UPCASE:=CHR(ORD(CH)-32) ELSE UPCASE:=CH;
END;

{ STRINP inputs a string of maximum length L, at the cursor co- }
{ ordinates X and Y. S holds the default value. Upon entry, the }
{ default string is displayed, followed by a number of dots to  }
{ show the maximum length of the input field. A number of edi-  }
{ ting keys are available. The constants listed in the begin-   }
{ ning of the program defines the ASCII values of these editing }
{ keys. Briefly, BACK backspaces one character, CLEAR clears    }
{ the input field, LEFT moves one character left, RIGHT moves   }
{ one character right, BOLIN moves to the beginning of the in-  }
{ put line, EOLIN moves to the end of the input line, and ENTER }
{ terminates the input. Characters are always inserted in front }
{ of the character under the cursor.                            }

FUNCTION STRINP(S: STR30; X,Y,L: INTEGER): STR30;
CONST
  DOTS = '..............................';
VAR
  P: INTEGER;
  CH: CHAR;
BEGIN
  GOTOXY(X,Y);
  WRITE(S); IF LEN(S)<L THEN WRITE(DOTS[1..L-LEN(S)]);
  P:=0;
  REPEAT
    GOTOXY(X+P,Y); GET(CH);
    IF (ORD(CH)=BACK) AND (P>0) THEN
    BEGIN
      IF P>1 THEN S:=S[1..P-1]+S[P+1..L] ELSE S:=S[2..L];
      WRITE(CH,S[P..L],'.'); P:=P-1;
    END ELSE
    IF ORD(CH)=CLEAR THEN
    BEGIN
      P:=0; S:=''; GOTOXY(X,Y); WRITE(DOTS[1..L]);
    END ELSE
    IF (ORD(CH)=LEFT) AND (P>0) THEN P:=P-1 ELSE
    IF (ORD(CH)=RIGHT) AND (P<LEN(S)) THEN P:=P+1 ELSE
    IF ORD(CH)=BOLIN THEN P:=0 ELSE
    IF ORD(CH)=EOLIN THEN P:=LEN(S) ELSE
    IF (CH>=' ') AND (CH<='~') THEN
    BEGIN
      IF P=0 THEN S:=CH+S[1..L-1] ELSE S:=S[1..P]+CH+S[P+1..L-1];
      P:=P+1; WRITE(S[P..L]);
    END;
  UNTIL (ORD(CH)=ENTER);
  GOTOXY(X+LEN(S),Y); WRITE('':L-LEN(S));
  GOTOXY(X+LEN(S),Y);
  STRINP:=S;
END;

{ SELECT displays a prompt string, and waits for the user to    }
{ select one of the options displayed, by pressing a key. Upon  }
{ entry, PROMPT is displayed on line Y, followed by the list of }
{ valid one-character answers held in KEYS. The routine then    }
{ waits for the user to enter one of the valid answers.         }

FUNCTION SELECT(PROMPT: STR30; KEYS: STR10; Y: INTEGER): CHAR;
VAR
  P: INTEGER;
  FOUND: BOOLEAN;
  CH,CU: CHAR;
BEGIN
  GOTOXY(0,Y); WRITE(PROMPT,' (',KEYS[1]);
  FOR P:=2 TO LEN(KEYS) DO WRITE('/',KEYS[P]);
  WRITE(')? '); CLREOL;
  REPEAT
    GET(CH); CU:=UPCASE(CH); FOUND:=FALSE;
    FOR P:=1 TO LEN(KEYS) DO IF CU=KEYS[P] THEN FOUND:=TRUE;
  UNTIL FOUND;
  WRITE(CH);
  SELECT:=CU;
END;

{ CORRECT displays the prompt 'Is this correct (Y/N)?', waits   }
{ for the user to press 'Y' or 'N', and returns a boolean value }
{ depending on the answer (Y=TRUE,N=FALSE).                     }

FUNCTION CORRECT: BOOLEAN;
BEGIN
  CORRECT:=SELECT('Is this correct','YN',10)='Y';
END;

{ READREC uses STRINP and CORRECT to input a record. If VALID   }
{ is false upon entry, the record is cleared. Otherwise, the    }
{ user is allowed to edit the current contents.                 }

PROCEDURE READREC(VAR A: REC; VALID: BOOLEAN);
BEGIN
  IF NOT VALID THEN
  BEGIN
    A.FNAME:=''; A.LNAME:=''; A.ADDR1:='';
    A.ADDR2:=''; A.ADDR3:=''; A.PHONE:='';
  END;
  REPEAT
    A.FNAME:=STRINP(A.FNAME,18,3,20);
    A.LNAME:=STRINP(A.LNAME,18,4,30);
    A.ADDR1:=STRINP(A.ADDR1,18,5,30);
    A.ADDR2:=STRINP(A.ADDR2,18,6,30);
    A.ADDR3:=STRINP(A.ADDR3,18,7,30);
    A.PHONE:=STRINP(A.PHONE,18,8,16);
  UNTIL CORRECT;
END;

{ FINDPOS finds the position of the first record that matches   }
{ (or comes closest to matching) the criterions (last name and  }
{ first name) given in the parameter record. FINDPOS uses a bi- }
{ nary search. Briefly, the method is to halve the search in-   }
{ terval contiguously, until only one record remains. Note that }
{ the records are sorted by last name, and then by first name.  }

FUNCTION FINDPOS(VAR A: REC): INTEGER;
VAR
  B: REC;
  POS,LOW,GUESS,LA: INTEGER;
  AN,BN: STR51;
BEGIN
  AN:=A.LNAME+CHR(0)+A.FNAME; LA:=LEN(AN);
  LOW:=-1; POS:=NUMREC;
  WHILE POS-LOW>1 DO
  BEGIN
    GUESS:=(POS-LOW) DIV 2+LOW;
    SEEK(RECF,INDEX[GUESS]); GET(RECF,B);
    BN:=B.LNAME+CHR(0)+B.FNAME;
    IF BN[1..LA]<AN THEN LOW:=GUESS ELSE POS:=GUESS;
  END;
  FINDPOS:=POS;
END;

BEGIN
  GOTOXY(0,0); CLREOS;
  WRITELN('Phone List Version 1.1');
  WRITELN;
  WRITELN('File name.......: ');
  REPEAT
    FILENAME:=STRINP('',18,2,10);
    {$I-} RESET(RECF,FILENAME+'.REC') {$I+};
    OK:=IORES=0;
    IF NOT OK THEN
    BEGIN
      GOTOXY(0,4);
      S:=SELECT('No such file. Create new file','YN',4);
      IF S='Y' THEN
      BEGIN
        FOR I:=0 TO MAXENTRY-1 DO INDEX[I]:=I;
        INDEX[MAXENTRY]:=0;
        REWRITE(IDXF,FILENAME+'.IDX');
        REWRITE(RECF,FILENAME+'.REC');
        OK:=TRUE;
      END ELSE
      BEGIN
        GOTOXY(0,4); CLREOL;
      END;
    END ELSE
    BEGIN
      RESET(IDXF,FILENAME+'.IDX'); GET(IDXF,INDEX);
    END;
  UNTIL OK;
  NUMREC:=INDEX[MAXENTRY];
  GOTOXY(26,0); WRITE('File=',FILENAME);
  GOTOXY(45,0); WRITE('Free=',MAXENTRY-NUMREC);
  GOTOXY(0,2); CLREOS;
  WRITELN('Record number...:');
  WRITELN('First name......:');
  WRITELN('Last name.......:');
  WRITELN('Address 1.......:');
  WRITELN('Address 2.......:');
  WRITELN('Address 3.......:');
  WRITELN('Phone number....:');
  REPEAT
    S:=SELECT('Add, Find, Quit','AFQ',10);
    IF (S='A') AND (NUMREC<MAXENTRY) THEN
    BEGIN
      I:=INDEX[NUMREC]; GOTOXY(18,2); WRITE(I);
      READREC(A,FALSE); SEEK(RECF,I); PUT(RECF,A);
      P:=FINDPOS(A);
      FOR J:=PRED(NUMREC) DOWNTO P DO INDEX[SUCC(J)]:=INDEX[J];
      INDEX[P]:=I; NUMREC:=SUCC(NUMREC);
      GOTOXY(50,0); WRITE(MAXENTRY-NUMREC,' ');
    END ELSE
    IF (S='F') AND (NUMREC>0) THEN
    BEGIN
      A.FNAME:=''; A.LNAME:='';
      REPEAT
        A.FNAME:=STRINP(A.FNAME,18,3,20);
        A.LNAME:=STRINP(A.LNAME,18,4,30);
      UNTIL CORRECT;
      P:=FINDPOS(A); IF P=NUMREC THEN P:=PRED(P);
      REPEAT
        SEEK(RECF,INDEX[P]); GET(RECF,A);
        GOTOXY(18,2); WRITE(INDEX[P]); CLREOL;
        GOTOXY(18,3); WRITE(A.FNAME); CLREOL;
        GOTOXY(18,4); WRITE(A.LNAME); CLREOL;
        GOTOXY(18,5); WRITE(A.ADDR1); CLREOL;
        GOTOXY(18,6); WRITE(A.ADDR2); CLREOL;
        GOTOXY(18,7); WRITE(A.ADDR3); CLREOL;
        GOTOXY(18,8); WRITE(A.PHONE); CLREOL;
        T:=SELECT('Previous, Next, Quit','PNQ',10);
        IF (T='P') AND (P>0) THEN P:=PRED(P) ELSE
        IF (T='N') AND (P<PRED(NUMREC)) THEN P:=SUCC(P);
      UNTIL T='Q';
      T:=SELECT('Edit, Delete, Quit','EDQ',10);
      IF T='E' THEN
      BEGIN
        I:=INDEX[P];
        FOR J:=P TO PRED(NUMREC) DO INDEX[J]:=INDEX[SUCC(J)];
        NUMREC:=PRED(NUMREC);
        READREC(A,TRUE); P:=FINDPOS(A);
        FOR J:=PRED(NUMREC) DOWNTO P DO INDEX[SUCC(J)]:=INDEX[J];
        NUMREC:=SUCC(NUMREC);
        INDEX[P]:=I;
        SEEK(RECF,I); PUT(RECF,A);
      END ELSE
      IF T='D' THEN
      BEGIN
        I:=INDEX[P];
        FOR J:=P TO PRED(NUMREC) DO INDEX[J]:=INDEX[SUCC(J)];
        INDEX[NUMREC]:=I; NUMREC:=PRED(NUMREC);
        GOTOXY(50,0); WRITE(MAXENTRY-NUMREC);
      END;
    END;
    IF S<>'Q' THEN
    FOR I:=2 TO 8 DO
    BEGIN
      GOTOXY(18,I); CLREOL;
    END;
  UNTIL S='Q';
  INDEX[MAXENTRY]:=NUMREC;
  SEEK(IDXF,0); PUT(IDXF,INDEX);
  CLOSE(IDXF,LOCK); CLOSE(RECF,LOCK);
  GOTOXY(0,0); CLREOS;
END.
