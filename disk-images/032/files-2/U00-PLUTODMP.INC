procedure place(b : byte);
begin
  sixline[sixpos]:=b;
  if (sixpos=128) or (finish) then
  begin
    blockwrite(fname,sixline,1);
    sixpos:=1;
  end
  else
  sixpos:=sixpos+1;
end; {of place}

procedure convert_to_six(Var a : bitarray);
var
  temp : byte;

begin
  arraypos:=1;
  repeat
    temp:=64;
     if a[arraypos] then temp:=temp or 1;
     if a[arraypos+1] then temp:=temp or 2;
     if a[arraypos+2] then temp:=temp or 4;
     if a[arraypos+3] then temp:=temp or 8;
     if a[arraypos+4] then temp:=temp or 16;
     if a[arraypos+5] then temp:=temp or 32;
    place(temp);
    arraypos:=arraypos+6;
  until arraypos>=binpos;
end;  {of convert_to_six}

procedure dump_to_file(xd,yd : integer; pdumpf : str14);
var
  result     : byte;
  total, bytes_to_read : integer;
  f_b : file of byte;
begin
  assign(f_b,pdumpf);
  rewrite(f_b);
  bytes_to_read:=xd*yd;
  for total:=1 to bytes_to_read do
  begin
    result:=port[data];
    write(f_b,result);
  end;
  close(f_b);
end;

