const
data       = $A1;
black      = 0;        green      = 1;         blue        = 2;
cyan       = 3;        red        = 4;         yellow      = 5;
magent     = 6;        white      = 7;         paint       = 8;

procedure plutoinit;
var
i          : integer;
begin
  repeat until port[$A0]>127;
  for i:=1 to 4 do port[$A0]:=0;
  repeat until port[$A0]>127;
  port[data]:=$a6;
end;

procedure moveto(x,y : integer);
begin
  repeat until port[$A0]>127;
  port[data]:=$97;
  repeat until port[$A0]>127;
  port[data]:=lo(x);
  port[data]:=hi(x);
  port[data]:=lo(y);
  port[data]:=hi(y);
end;

procedure lto(x,y : integer);
begin
  repeat until port[$A0]>127;
  port[data]:=$80;
  repeat until port[$A0]>127;
  port[data]:=lo(x);
  port[data]:=hi(x);
  port[data]:=lo(y);
  port[data]:=hi(y);
end;

procedure lrels(x,y : integer);
begin
  repeat until port[$A0]>127;
  port[data]:=$9E;
  repeat until port[$A0]>127;
  port[data]:=lo(x);
  port[data]:=lo(y);
end;

procedure mrels(x,y : integer);
begin
  repeat until port[$A0]>127;
  port[data]:=$99;
  repeat until port[$A0]>127;
  port[data]:=lo(x);
  port[data]:=lo(y);
end;

procedure sccol(c : byte);
begin
  repeat until port[$A0]>127;
  port[data]:=$89;
  repeat until port[$A0]>127;
  port[data]:=c;
end;

procedure spcol(c : byte);
begin
  repeat until port[$A0]>127;
  port[data]:=$ba;
  repeat until port[$A0]>127;
  port[data]:=c;
end;

procedure bfill;
begin
  repeat until port[$A0]>127;
  port[data]:=$b0;
end;

procedure ffill;
begin
  repeat until port[$A0]>127;
  port[data]:=$82;
end;

procedure sstle(c : byte);
begin
  repeat until port[$A0]>127;
  port[data]:=$8a;
  repeat until port[$A0]>127;
  port[data]:=c;
end;

procedure sbcol(c : byte);
begin
  repeat until port[$A0]>127;
  port[data]:=$87;
  repeat until port[$A0]>127;
  port[data]:=c;
end;

procedure setcwp(c : byte);
begin
  repeat until port[$A0]>127;
  port[data]:=$a5;
  repeat until port[$A0]>127;
  port[data]:=c;
end;

procedure setcdp(c : byte);
begin
  repeat until port[$A0]>127;
  port[data]:=$83;
  repeat until port[$A0]>127;
  port[data]:=c;
end;

procedure rsel(x : integer);
begin
 repeat until port[$A0]>127;
 port[data]:=$B8;
 repeat until port[$A0]>127;
  port[data]:=x;
end;

procedure clrcwp;
begin
  moveto(0,0);
  repeat until port[$A0]>127;
  port[data]:=$ac;
end;

procedure plutoclear;
begin
  setcdp(1);
  setcwp(2);
  clrcwp;
  setcwp(1);
  clrcwp;
end;
