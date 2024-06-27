PROGRAM CALCULATOR; {$R-}

{ This program acts like a calculator - You type an expression  }
{ and the program calculates its value. Each time the calcula-  }
{ tor is ready to accept an input line, it prints an asterisk.  }
{ You must then type the expression and end it by pressing the  }
{ RETURN key, and shortly after, the result is displayed. If    }
{ the calculator finds an error, it displays a pointer, which   }
{ points at the error. There are five different operators (^, * }
{ /, +, and -), and seven standard functions (ABS, SQRT, SIN,   }
{ COS, ARCTAN, LN, and EXP). Parentheses within expressions are }
{ allowed. A special variable, called X, always holds the value }
{ of the last computation. To end the program, type QUIT when   }
{ the calculator prompts for an input line.                     }

CONST
  STRLEN = 48;
TYPE
  CHAR = STRING[1];
  STR = STRING[STRLEN];
VAR
  E: INTEGER;
  R: REAL;
  S: STR;

PROCEDURE EVALUATE(VAR EXPR: STR; VAR VALUE: REAL; VAR ERRPOS: INTEGER);
CONST
  ERRCH = '?';
VAR
  POS: INTEGER;
  CH: CHAR;

PROCEDURE NEXTCHAR;
BEGIN
  REPEAT
    POS:=POS+1; CH:=EXPR[POS];
  UNTIL CH<>' ';
END;

FUNCTION EXPRESSION: REAL;
VAR
  E: REAL;
  OPR: CHAR;

FUNCTION SIMEXPR: REAL;
VAR
  S: REAL;
  OPR: CHAR;

FUNCTION TERM: REAL;
VAR
  T: REAL;

FUNCTION SIGNEDFACTOR: REAL;

FUNCTION FACTOR: REAL;
TYPE
  STDF = (FABS,FSQRT,FSIN,FCOS,FARCTAN,FLN,FEXP);
  STDFLIST = ARRAY[STDF] OF STRING[6];
CONST
  STDFUN = STDFLIST('ABS','SQRT','SIN','COS','ARCTAN','LN','EXP');
VAR
  E,EE,L: INTEGER;
  DECPOINT,NEGEXP,FOUND: BOOLEAN;
  F: REAL;
  SF: STDF;
BEGIN
  IF (CH>='0') AND (CH<='9') THEN
  BEGIN
    F:=0.0; E:=0; DECPOINT:=FALSE;
    REPEAT
      F:=F*10.0+(ORD(CH)-48);
      IF DECPOINT THEN E:=E-1;
      NEXTCHAR;
      IF (CH='.') AND NOT DECPOINT THEN
      BEGIN
        DECPOINT:=TRUE; NEXTCHAR;
      END;
    UNTIL (CH<'0') OR (CH>'9');
    IF CH='E' THEN
    BEGIN
      EE:=0; NEXTCHAR;
      IF (CH='-') OR (CH='+') THEN
      BEGIN
        NEGEXP:=CH='-'; NEXTCHAR;
      END ELSE
      NEGEXP:=FALSE;
      WHILE (CH>='0') AND (CH<='9') DO
      BEGIN
        EE:=EE*10+ORD(CH)-48;
        NEXTCHAR;
      END;
      IF NEGEXP THEN E:=E-EE ELSE E:=E+EE;
    END;
    F:=F*PWRTEN(E);
  END ELSE
  IF CH='(' THEN
  BEGIN
    NEXTCHAR;
    F:=EXPRESSION;
    IF CH=')' THEN NEXTCHAR ELSE CH:=ERRCH;
  END ELSE
  IF CH='X' THEN
  BEGIN
    NEXTCHAR; F:=VALUE;
  END ELSE
  BEGIN
    FOUND:=FALSE;
    FOR SF:=FABS TO FEXP DO
    IF NOT FOUND THEN
    BEGIN
      L:=LEN(STDFUN[SF])-1;
      IF EXPR[POS..POS+L]=STDFUN[SF] THEN
      BEGIN
        POS:=POS+L; NEXTCHAR;
        F:=FACTOR;
        CASE SF OF
          FABS: F:=ABS(F);
          FSQRT: F:=SQRT(F);
          FSIN: F:=SIN(F);
          FCOS: F:=COS(F);
          FARCTAN: F:=ARCTAN(F);
          FLN: F:=LN(F);
          FEXP: F:=EXP(F);
        END;
        FOUND:=TRUE;
      END;
    END;
    IF NOT FOUND THEN CH:=ERRCH;
  END;
  FACTOR:=F;
END {OF FACTOR};

BEGIN {SIGNEDFACTOR}
  IF CH='-' THEN
  BEGIN
    NEXTCHAR; SIGNEDFACTOR:=-FACTOR;
  END ELSE
  SIGNEDFACTOR:=FACTOR;
END {OF SIGNEDFACTOR};

BEGIN {TERM}
  T:=SIGNEDFACTOR;
  WHILE CH='^' DO
  BEGIN
    NEXTCHAR; T:=EXP(LN(T)*SIGNEDFACTOR);
  END;
  TERM:=T;
END {OF TERM};

BEGIN {SIMEXPR}
  S:=TERM;
  WHILE (CH='*') OR (CH='/') DO
  BEGIN
    OPR:=CH; NEXTCHAR;
    IF OPR='*' THEN S:=S*TERM ELSE S:=S/TERM;
  END;
  SIMEXPR:=S;
END {OF SIMEXPR};

BEGIN {EXPRESSION}
  E:=SIMEXPR;
  WHILE (CH='+') OR (CH='-') DO
  BEGIN
    OPR:=CH; NEXTCHAR;
    IF OPR='+' THEN E:=E+SIMEXPR ELSE E:=E-SIMEXPR;
  END;
  EXPRESSION:=E;
END {OF EXPRESSION};

BEGIN {EVALUATE}
  POS:=0; NEXTCHAR; VALUE:=EXPRESSION;
  IF CH=EMPTY THEN ERRPOS:=0 ELSE ERRPOS:=POS;
END {OF VALUE};

BEGIN {CALCULATOR}
  REPEAT
    WRITE('* '); BUFLEN:=STRLEN; READ(S);
    IF (S<>EMPTY) AND (S<>'QUIT') THEN
    BEGIN
      EVALUATE(S,R,E);
      IF E=0 THEN
      BEGIN
        WRITE(' =');
        IF R>=0.0 THEN WRITE(R:17) ELSE WRITE(R:18);
      END ELSE
      BEGIN
        WRITELN;
        WRITE('^ ERROR':E+8);
      END;
    END;
    WRITELN;
  UNTIL S='QUIT';
END {OF CALCULATOR}.
