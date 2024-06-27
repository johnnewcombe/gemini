PROGRAM life(input,output);

{A program to play the game of 'Life'}
{Copyright (C) 1982 Prospero Software}
{Programmer: M.S.Oakes}
{Date: 14 January 1982}

CONST depth = 24;   {if screen size different, alter appropriately}
      width = 80;   {ditto}
      maxage = 70;
      blank = ' ';
      infantcell = '.';
      youngcell = '*';
      oldcell = 'o';
      text1 = 'The Game of Life';
      text2 = 'Generation No: ';

TYPE byte = -128..127;
     rowrange = 1..depth;
     colrange = 1..width;
     agerange = 0..maxage;
     cellrecord = RECORD
                    age: agerange;
                    neighbours: 0..8;
                  END;
     screenimage = ARRAY [rowrange,colrange] OF cellrecord;

VAR row,lastrow,minrow,maxrow,nextminrow,nextmaxrow: rowrange;
    col,lastcol,mincol,maxcol,nextmincol,nextmaxcol: colrange;
    ch: char;
    auto: boolean;
    screen: screenimage;
    middleage: agerange;
    generation: integer;
    gentext: string[11];
    text: string[width];
 
FUNCTION rand: real;  EXTERNAL;

PROCEDURE wait(msecs: integer);
  {Causes program to idle for (approx.) the specified number of milliseconds}
  VAR inner: 1..45;
      outer: integer;
  BEGIN
    FOR outer := 1 TO msecs DO
      FOR inner := 1 TO 45 DO ;
  END {wait};

PROCEDURE print(frow: rowrange;  fcol: colrange;  fch: char);
  CONST esc = 1BH;
  BEGIN
    {For VDUs other than ADM 3A+, this procedure may need altering}
    IF (frow <> lastrow) OR (fcol <> succ(lastcol)) THEN
      write(chr(esc),'=',chr(1FH + frow),chr(1FH + fcol));  {position cursor}
    write(fch);
    lastrow := frow;  lastcol := fcol;
  END {print};
 
PROCEDURE clearscreen;
  BEGIN
    {For VDUs other than ADM 3A+, this procedure may need altering}
    write(chr(1AH));
  END {clearscreen};

FUNCTION min(b1,b2: byte): byte;
  BEGIN
    IF b1 < b2 THEN min := b1
    ELSE min := b2;
  END {min};
 
FUNCTION max(b1,b2: byte): byte;
  BEGIN
    IF b1 > b2 THEN max := b1
    ELSE max := b2;
  END {max};
 
PROCEDURE incneighbours;
  VAR lrow: rowrange;
      lcol: colrange;
  BEGIN
    FOR lrow := succ(minrow) TO pred(maxrow) DO
      FOR lcol := succ(mincol) TO pred(maxcol) DO
        IF screen[lrow,lcol].age > 0 THEN
          BEGIN
            WITH screen[pred(lrow),pred(lcol)] DO neighbours := succ(neighbours);
            WITH screen[pred(lrow),lcol] DO neighbours := succ(neighbours);
            WITH screen[pred(lrow),succ(lcol)] DO neighbours := succ(neighbours);
            WITH screen[lrow,pred(lcol)] DO neighbours := succ(neighbours);
            WITH screen[lrow,succ(lcol)] DO neighbours := succ(neighbours);
            WITH screen[succ(lrow),pred(lcol)] DO neighbours := succ(neighbours);
            WITH screen[succ(lrow),lcol] DO neighbours := succ(neighbours);
            WITH screen[succ(lrow),succ(lcol)] DO neighbours := succ(neighbours);
          END;
  END {incneighbours};
 
PROCEDURE nextgeneration;
  VAR lrow: rowrange;
      lcol: colrange;
 
  FUNCTION image(antiquity: agerange): char;
    BEGIN
      IF antiquity = 0 THEN image := blank
      ELSE
        IF antiquity = 1 THEN image := infantcell
        ELSE
          IF antiquity <= middleage THEN image := youngcell
          ELSE image := oldcell;
    END {image};

  PROCEDURE livingcell;
    VAR lchar: char;
    BEGIN
      WITH screen[lrow,lcol] DO
        BEGIN
          age := age + 1;
          lchar := image(age);
          IF lchar <> image(pred(age)) THEN print(lrow,lcol,lchar);
        END;
      nextminrow := min(nextminrow,lrow);
      nextmaxrow := max(nextmaxrow,lrow);
      nextmincol := min(nextmincol,lcol);
      nextmaxcol := max(nextmaxcol,lcol);
    END {livingcell};
 
  BEGIN {nextgeneration}
    generation := succ(generation);
    nextminrow := depth-1;  nextmaxrow := 1;
    nextmincol := width;  nextmaxcol := 1;
    FOR lrow := minrow TO maxrow DO
      FOR lcol := mincol TO maxcol DO
        WITH screen[lrow,lcol] DO
          BEGIN
            IF age = 0 THEN
              BEGIN
                {screen was blank here;  is there a birth? }
                IF neighbours = 3 THEN livingcell;
              END
            ELSE
              {screen had cell here;  is there a death? }
              IF ((neighbours = 2) OR (neighbours = 3)) AND (age < maxage) THEN
                livingcell
              ELSE
                BEGIN
                  {cell dies}
                  age := 0;
                  print(lrow,lcol,blank);
                END;
            neighbours := 0;
          END;
    {Update bottom line of screen}
    IF generation = 1 THEN
      BEGIN
        print(depth,1,' ');  {to position cursor}
        write(text1,text2:(width-13-length(text1)));
        lastcol := width-12;
      END;
    str(generation,gentext);
    FOR lcol := 1 TO length(gentext) DO
      print(depth,lcol+width-12,gentext[lcol]);
    {Set "window" for next iteration}
    minrow := max(pred(nextminrow),1);
    maxrow := min(succ(nextmaxrow),depth-1);
    mincol := max(pred(nextmincol),1);
    maxcol := min(succ(nextmaxcol),width);
  END {nextgeneration};
 
BEGIN
  middleage := maxage DIV 2;
  REPEAT
    writeln('The Game of Life  -  A Pro Pascal program from Prospero Software');
    writeln;
    writeln('A "generation" consists of a number of "cells"');
    writeln('An "infant" cell (age 1) is displayed as  "',infantcell,'"');
    writeln('A "young" cell (age 2 thru ',middleage:1,') is displayed as  "',
            youngcell,'"');
    writeln('An "old" cell (age ',(middleage+1):1,' thru ',maxage:1,
            ') is displayed as  "',oldcell,'"');
    writeln;
    writeln('From one generation to the next, a cell''s fate is as follows:');
    writeln('    a cell is BORN in a space with exactly 3 neighbouring cells;');
    writeln('    a cell SURVIVES if it has 2 or 3 neighbours;');
    writeln('    a cell DIES');
    writeln('         (from isolation) if it has less than 2 neighbours, or');
    writeln('         (from overcrowding) if it has more than 3 neighbours, or');
    writeln('         (from old age) if it has lived for more than ',maxage:1,
            ' generations.');
    writeln;
    write('Do you want to input the initial configuration (Y/N) ?');
    REPEAT
      read(ch);
    UNTIL ch <> blank;
    readln;  writeln;
    IF ch IN ['Y','y'] THEN
      BEGIN
        auto := false;
        writeln('Please input initial cell colony:');
        writeln('(Type ',depth-1:1,' lines, each up to ',width:1,' characters long,');
        writeln('with non-blank character(s) representing the cells)');
      END
    ELSE auto := true;
    FOR row := 1 TO depth-1 DO
      BEGIN
        FOR col := 1 TO width DO
          WITH screen[row,col] DO
            BEGIN
              IF auto AND (rand < 0.5) THEN age := 1 {cell present}
              ELSE age := 0;  {no cell}
              neighbours := 0;
            END;
        IF NOT auto THEN
          BEGIN
            col := 0;
            WHILE NOT eoln DO
              BEGIN  col := succ(col);
                read(ch);
                IF ch <> ' ' THEN screen[row,col].age := 1;
              END;
            readln;
          END;
      END;
    clearscreen;
    generation := 0;  lastrow := 0;
    minrow := 1;  maxrow := depth-1;
    mincol := 1;  maxcol := width;
    REPEAT
      incneighbours;
      nextgeneration;
    UNTIL (minrow > maxrow) OR (mincol > maxcol)  {i.e. no cells left}
      OR auto AND (generation >= 200);
    wait(4000 {msecs});
    clearscreen;
  UNTIL false;  {i.e. indefinitely}
END.
