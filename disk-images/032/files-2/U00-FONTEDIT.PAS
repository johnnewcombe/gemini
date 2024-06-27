program charcon; {To create character set vector file}
const
 topbit = 128;
 version = 'Version 2.02  17/02/88';

type
 vecline = array[0..30] of integer;

var
 vecarry : array [1..96] of vecline;
 fn : FILE of vecline;
 vector : vecline;
 i, ac, dn, let, num, count, inp : integer;
 ty, l : char;
 ans : char;
 diskname : string[10];
 base : integer;
 do_init : boolean;
 f : FILE;

Procedure clreos;
begin
 write(chr(27),chr(37)); {gemini}
 (*write(chr(19)); {nascom}  *)
end;

Procedure display_vector;
 begin
 gotoxy(1,5);clreos;
   for i:=1 to 30 do
   begin
     if i<16 then
      gotoxy(5,i+6)
     else
      gotoxy(45,i-9);
     write(i:2,']  ');
     ac:=hi(vector[i]);
     dn:=lo(vector[i]);
     if ac>0 then
     begin
       if (ac and 128) >0 then
       begin
         write('Move to: ');
         ac:=ac-128;
       end
       else
        write('Line to: ');
       writeln(ac:2,' Across  ',dn:2,' Up');
     end;
   end;
 end; {of display_vector}

PROCEDURE DISPLAY_ON_PLUTO;
const
  data =$A1; status = $A0; mto_ =$97; lto_ =$80;
  sccol_ = $89; sbcol_ = $87; sstle_ = $8A;
  green = 1; blue = 2; red = 4;

var
  num,x,y,i,j : integer;
  scl : real;
  by : byte;

procedure ready;
begin
 repeat
  by:=port[$A0] and 128;
 until by=128;
end; {of ready}

procedure lto(x,y : integer);
begin
  ready;
  port[data]:=lto_;
  ready;
  port[data]:=lo(x);
  port[data]:=hi(x);
  port[data]:=lo(y);
  port[data]:=hi(y);
end;

procedure moveto(x,y : integer);
begin
  ready;
  port[data]:=mto_;
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


procedure writeit;
 begin
  sccol(green);
  for j:=1 to 30 do
  if vector[j]<>0 then
  begin
    ac:=hi(vector[j]); dn:=lo(vector[j]);
    if (ac and 128)>0 then
    begin
      ac:=ac-128;
      sccol(green);
      moveto(x+round(ac*scl),y-round(dn*scl));
    end
    else
    begin
      sccol(green);
      lto(x+round(ac*scl),y-round(dn*scl));
    end;
  end;
end;{of writeit}

procedure boxit;
begin
 ac:=18; dn:=18;
 sccol(blue);
 moveto(x,y);
 lto(x,y-round(dn*scl));
 lto(x+round(ac*scl),y-round(dn*scl));
 lto(x+round(ac*scl),y);
 lto(x,y);
end;

begin {main display_on_pluto}
if do_init=TRUE then
 begin
  ready;
  for i:=1 to 4 do
   port[$A0]:=0;
  ready;
  port[$A1]:=$A6;
  do_init:=FALSE;
 end;

 num:=lo(vector[0]);
 x:=50; y:=200; scl:=0.5;
 boxit;
 writeit;
 x:=200; y:=200; scl:=1;
 y:=y+round(base*scl);
 boxit;
 writeit;
 x:=400; y:=200; scl:=3;
 y:=y+round(base*scl);
 boxit;
 writeit;
 sccol(red);
 if vector[1]<>0 then
  lto(x+round(ac*scl),y-round(dn*scl));

end; {of display_on_pluto}

Procedure Addnew;
label
  fin,ex;
var
  pos : byte;
  x,y : byte;

begin
 count:=0;
 REPEAT
   reset(fn);
   count:=1; do_init:=TRUE;
   repeat
     gotoxy(5,5);clreos;
     write('Enter letter to edit or ESC to exit:   ');
     gotoxy(42,5);read(kbd,l);
   until l in [#27,' '..'~'];
   if l=#27 then goto fin;
   gotoxy(32,4);
   read(fn,vector);
   base:=vector[0];
   write('Character= ',l,'  Ascii Code= ',ord(l),'  Base line= ',base);
   clreos;
   pos:=ord(l)-31;
   seek(fn,pos); read(fn,vector); seek(fn,filepos(fn)-1);
   display_vector;
   display_on_pluto;
   let:=ord(l) shl 8;
   repeat
    repeat
     gotoxy(5,5);write('<RETURN> to accept or ');
     write('M)ove, L)ine, D)elete, I)nsert, R)edraw, E)xit? ');
     clreol;
     if count<16 then
     begin
      x:=10; y:=count+6;
     end
     else
     begin
      x:=50; y:=count-9;
     end;
     gotoxy(x,y);
     read(kbd,ty);
     if ty=#13 then
     begin
       if (hi(vector[count]) and 128) = 128 then ty:='M'
       else
       if vector[count] <> 0 then ty:='L';
     end;
    until ty IN ['M','m','L','l','E','e','D','d','I','i',
                 'R','r',#30,#31];
    gotoxy(5,5);clreol;
    CASE ty of
    'M','m' : begin
                 gotoxy(x,y);
                 write('Move to: ');
              end;
    'L','l' : begin
                 gotoxy(x,y);
                 write('Line to: ');
              end;
    'D','d' : begin
               for i:=count to 29 do
                vector[i]:=vector[i+1];
               vector[30]:=0;
               display_vector;
               do_init:=TRUE;
               display_on_pluto;
              end;
    'I','i' : begin
               for i:=30 downto count+1 do
                vector[i]:=vector[i-1];
               vector[count]:=0;
               display_vector;
              end;
    'R','r' : begin
                do_init:=TRUE;
                display_on_pluto;
              end;
    'E','e' : goto ex;
    #30     : begin
                count:=count-1;
                if count<1 then count:=30;
                if vector[count]=0 then
                begin
                 repeat
                   count:=count-1;
                 until vector[count]<>0;
                 count:=count+1;
                end;
                do_init:=TRUE;
              end;
    #31     : begin
                if vector[count]<>0 then
                begin
                  count:=count+1;
                  do_init:=TRUE;
                end;
                if count>30 then count:=1;
              end;
    end; {of case}
    if ty in ['D','d','I','i','R','r',#30,#31] then goto ex;

    gotoxy(5,5);write('<RETURN> to accept or type complete number.');clreol;
    repeat
     ac:=hi(vector[count]) and 31;
     {$I-}
     gotoxy(x+12,y);write('Across');gotoxy(x+9,y);read(ac);
     {$I+}
    until (ac in [0..18]) and (ioresult=0);
    gotoxy(x+9,y);write(ac:2);
    repeat
     dn :=lo(vector[count]) and 31;
     {$I-}
     gotoxy(x+23,y);write('Up');gotoxy(x+20,y);read(dn);
     {$I+}
    until (dn in[0..18]) and (ioresult=0);
    gotoxy(x+20,y);write(dn:2);

    if ty in ['M','m'] then ac:=ac+topbit;
    ac:=ac shl 8;
    vector[count]:=ac+dn;
    count:=count+1;
    if count>30 then count:=1;
    display_on_pluto;
    gotoxy(5,5);clreol;
   ex:
   until ty in ['E','e'];
   i:=1; count:=0;
   while (vector[i] <> 0) and (i<31) do
   begin
     count:=count+1;
     i:=i+1;
   end;
   vector[0]:=let+count;
    write(fn,vector);
   fin:
 UNTIL l=#27;
 close(fn);
 clrscr;
end; {of addnew}

begin     {  MAIN PART  }
 clrscr;
 gotoxy(25,1); lowvideo;
 write(' KENILWORTH LABEL FONT EDITOR '); normvideo;
 gotoxy(29,4); write(version); delay(2000);
 REPEAT
   gotoxy(1,4); clreol;
   write('Enter file name of font ( eg ME2 ): ');
   read(diskname);
   assign(fn,diskname+'.CHR');
   {$I-} reset(fn); {$I+}
   if ioresult >0 then
   begin
    repeat
     gotoxy(20,5);write('Create a new file? Y/N');
     read(kbd,ans);
    until ans in ['Y','y','N','n'];
    if ans in ['Y','y'] then
    begin
     gotoxy(20,5);write('Creating New File......');
     rewrite(fn);
     fillchar(vector,sizeof(vector),0);
     for i:=0 to 95 do
      write(fn,vector);
     reset(fn);
     gotoxy(20,6);
     write('Base line of character set ? (normally 5) ');
     read(vector[0]);
     write(fn,vector);
    end;
   end;
   gotoxy(1,4);clreos;
   gotoxy(1,4);write('Character set= ',diskname);
   addnew;
   repeat
     gotoxy(5,4);clreos;write('Edit another character set? Y/N ');
     read(kbd,ans);
   until ans in ['Y','y','N','n'];
   close(fn);
UNTIL ans in ['N','n'];
writeln('  Program Terminated.');
assign(f,'MENU.COM');
execute(f);
end.