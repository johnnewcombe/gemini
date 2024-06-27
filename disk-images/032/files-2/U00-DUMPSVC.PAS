procedure dumpsvc;
var
  line : string[82];
  screen,ox,oy,ap : integer;
  bt : byte;
  ch : char;

procedure getchar;
begin
   repeat
    bt:=port[$B2];
   until bt and 128 = 0;
   bt:=port[$B1];
   ch:=chr(bt);
end;

begin
 write(chr(27),'?');
 getchar; oy:=ord(ch);
 getchar; ox:=ord(ch);
 getchar; {dummy get of character not required}
 writeln(scdmp,'-',conststr('-',79),'-');
 for screen:=1 to 25 do
 begin
  gotoxy(1,screen);
  write(chr(27),'Z');
  line[0]:=chr(81);
  line[1]:='|';
  line[81]:='|';
  FillChar(line[2],79,' ');
  ap:=2;
  repeat
   getchar;
   if bt<>13 then
    line[ap]:=chr(bt);
   ap:=ap+1;
  until bt=13;
  writeln(scdmp,line);
 end;
 writeln(scdmp,'-',conststr('-',79),'-');
 for screen:=1 to 4 do
  writeln(scdmp,'');
 gotoxy(ox+1,oy+1);
end;  {of dumpsvc}


