program convfile;
{To convert old small labels to new file format}
label loop;

type
  old = record
   a : boolean;
   b : integer;
   c : integer;
   d : integer;
   e : real;
   f : string[14];
   g : byte;
   h : char;
   m : string[125]
  end; {of record}

  new = record
   aa : boolean;
   bb : integer;
   cc : integer;
   dd : integer;
   ee : real;
   ff : string[14];
   gg : byte;
   hh : char;
   jj : string[10];
   kk : byte;
   mm : string[125]
  end; {of record}

  labelpointer = ^labelrecord;
  labelrecord =record
             name : string[8];
             next : labelpointer
  end;

var
  sof : FILE of old;
  snf : FILE of new;
  so : old;
  sn : new;
  ans : char;
  dummy : integer;
  heaptop : ^integer;
  firstlabel, lastlabel,newlabel : labelpointer;
  dma : string[129]; {Location to store portion of DIR read in}
  filename : string[12];
  fcb : array[1..12] of byte absolute $5c;  {Location filename is stored}
  x,j,entry,count :integer;
  drivenum : char;
  xx : FILE;
  ln : string[8];
  drv : string[1];
  ext : string[3];
  df : TEXT;


procedure nothing;
begin
 writeln('');
end;

procedure printit;
begin
    entry:=(x*32)+1;                   {uses 32 bytes. The first 12  }
    ln:=copy(dma,entry+1,8);           {give the drive, name & extension.}
    ln:=copy(ln,1,pos(' ',ln)-1);
    write('*',ln,'*');
    new(newlabel);
    newlabel^.name:=ln;
    if firstlabel=nil then
     firstlabel:=newlabel
    else
     lastlabel^.next:=newlabel;
    lastlabel:=newlabel;
    lastlabel^.next:=nil;
end;  {of print_it}

begin
  drv:='C';
  firstlabel:=nil;
  mark(heaptop);
  gotoxy(1,10);
  assign(xx,drv+':Z.Z'); close(xx);
  dma:='';
  for j:=1 to 129 DO
    dma:=dma+' ';
  drivenum:=chr(ord(drv)-$40);

  filename:='????????LAB';
  fcb[1]:=ord(drivenum);             {First byte indicates drive, 0=A etc.}
  for x:=2 to 12 do
   fcb[x]:=ord(filename[x-1]);  {Put filename in fcb}
  x:=bdos($1a,addr(dma)+1);     {Tell CP/M where to put portion of DIR}
                               {First byte of a string address contains}
                               {its length. }
  x:=bdos($11,$5c);             {Find first entry}
  if x<>255 THEN                {If x=255 then no entry found}
  begin
   printit;
    repeat
      x:=bdos($12);             {Find next entry ......}
      if x<>255 THEN
       printit;
      if keypressed then x:=255;
    until (x=255); {.... until no more found}
  end;

  while firstlabel<>nil do
  begin
    ln:=firstlabel^.name;
    if keypressed then exit;
    assign(xx,drv+':Z.Z'); close(xx);
    assign(sof,'C:'+ln+'.LAB');
    {$I-} reset(sof); {$I+}
    j:=ioresult;
    if j<>0 then
    begin
     writeln('Error ',j,' reading file');
     goto loop;
    end;
    assign(snf,'M:'+ln+'.LAB');
    rewrite(snf);
    while not eof(sof) do
    begin
     read(sof,so);
     with so,sn do
     begin
       aa:=a;
       bb:=b;
       cc:=c;
       dd:=d;
       ee:=e;
       ff:=f;
       gg:=g;
       hh:=h;
       jj:='';
       kk:=0;
       mm:=m;
     end;
     write(snf,sn);
    end; {while not eof}
    close(sof); close(snf);
 loop:
    if keypressed then firstlabel:=nil else
    firstlabel:=firstlabel^.next;
  end;
  release(heaptop);
end.