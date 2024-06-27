
procedure ready;
begin
 repeat
  by:=port[status] and 128;
 until by=128;
end;

procedure initialise;
begin
  ready;
  for i:=1 to 4 do
    port[status]:=0;
  ready;
  port[data]:=init_;
end;

procedure moveto(x,y : integer);
begin
  if x<left+1 then x:=left+1;
  if x>right-1 then x:=right-1;
  if y<top+1 then y:=top+1;
  if y>bottom-1 then y:=bottom-1;
  ready;
  port[data]:=mto_;
  ready;
  port[data]:=lo(x);
  port[data]:=hi(x);
  port[data]:=lo(y);
  port[data]:=hi(y);
end;

procedure lto(x,y : integer);
begin
  if x<left+1 then x:=left+1;
  if x>right-1 then x:=right-1;
  if y<top+1 then y:=top+1;
  if y>bottom-1 then y:=bottom-1;
  ready;
  port[data]:=lto_;
  ready;
  port[data]:=lo(x);
  port[data]:=hi(x);
  port[data]:=lo(y);
  port[data]:=hi(y);
end;

procedure sccol(c : byte);
begin
  ready;
  port[data]:=sccol_;
  ready;
  port[data]:=c;
end;

procedure spcol(c : byte);
begin
  ready;
  port[data]:=spcol_;
  ready;
  port[data]:=c;
end;

procedure bfill;
begin
  ready;
  port[data]:=bfill_;
end;

procedure ffill;
begin
  ready;
  port[data]:=ffill_;
end;

procedure sfcol(c : byte);
begin
  ready;
  port[data]:=sfcol_;
  ready;
  port[data]:=c;
end;

procedure sstle(c : byte);
begin
  ready;
  port[data]:=sstle_;
  ready;
  port[data]:=c;
end;

procedure sbcol(c : byte);
begin
  ready;
  port[data]:=sbcol_;
  ready;
  port[data]:=c;
end;

procedure setcfs(c : byte);
begin
  ready;
  port[data]:=scsp_;
  ready;
  port[data]:=c;
end;

procedure setcwp(c : byte);
begin
  ready;
  port[data]:=scwp_;
  ready;
  port[data]:=c;
end;

procedure setcdp(c : byte);
begin
  ready;
  port[data]:=scdp_;
  ready;
  port[data]:=c;
end;


procedure icp(var x,y : integer);
var
  b : integer;
begin
  ready;
  port[data]:=icp_;
  ready;
  b:=port[data];
  x:=b;
  b:=port[data]*256;
  x:=x+b;
  b:=port[data];
  y:=b;
  b:=port[data]*256;
  y:=y+b;
end;


procedure icwp(var x : byte);
begin
  ready;
  port[data]:=icwp_;
  ready;
  x:=port[data];
end;

procedure rsel(x : integer);
begin
 ready;
 port[data]:=$B8;
 ready;
  port[data]:=x;
end;

procedure wprot(x : integer);
begin
  ready;
  port[data]:=$8C;
  ready;
  port[data]:=x;
end;

