procedure setscreen(title : str80);

begin
  clrscr;
  gotoxy(26,1);
  lowvideo; write(' KENILWORTH LABEL PROCESSOR ');
  normvideo;
  gotoxy(trunc((78-length(title))/2),2);
  write(title);
  lowvideo;
  gotoxy(1,3);write(' F0 ');
  gotoxy(9,3);write(' F1 ');
  gotoxy(17,3);write(' F2 ');
  gotoxy(25,3);write(' F3 ');
  gotoxy(33,3);write(' F4 ');
  gotoxy(41,3);write(' F5 ');
  gotoxy(49,3);write(' F6 ');
  gotoxy(57,3);write(' F7 ');
  gotoxy(65,3);write(' F8 ');
  gotoxy(73,3);write(' F9 ');
  normvideo;
  gotoxy(1,7);writeln(conststr('*',79));
  gotoxy(1,9);writeln(conststr('*',79));
end;

procedure setkeys;
begin
  write(chr(27),'f');
  write(chr($81),^L);
  write(chr($82),^A);
  write(chr($83),^F);
  write(chr($84),^S);
  write(chr($85),^P);
  write(chr($86),^T);
  write(chr($87),^E);
  write(chr($88),^Q);
  write(chr($89),^X);
  write(chr($8A),'a');
  write(chr($8B),'');  {Disable EDIT Key}
  write(chr($C0));
end;

procedure set_area_boundries;
begin
 with param[areanum] do
 begin
      top:=ty+1;
   bottom:=by-1;
     left:=tx+1;
    right:=bx-1;
    setcwp(partition);
    setcdp(partition);
 end;
end; {of set_area_boundries}

procedure scalefont;
var
  m,t : integer;
  i,j : integer;

begin
if (scl<>1.0) and (fontname<>'NONE') then
 begin
  for i:=1 to 95 do
  begin
    num:=lo(vecary[i][0]);
    for j:=1 to num do
    begin
      t:=vecary[i][j];
      m:=hi(t) and 128;
      vecary[i][j]:=(round((hi(t)-m)*scl)+m) shl 8 +round(lo(t)*scl);
    end;
  end;

 end;
end;  {of scalefont}

procedure loadfont;
begin
  {$I-} reset(cf); {$I+}
  if ioresult=0 then
  begin
    read(cf,vector);
    base:=vector[0];
    scalbase:=round(base*scl);
    for i:=1 to 95 do
     read(cf,vecary[i]);
  end
  else
  begin
   gotoxy(25,8);lowvideo;Write(fontname,' DOES NOT EXIST. ');
   normvideo; clreol;
   delay(3000);
   fontname:='NONE';
  end;
end;

procedure fontchange;
begin
  gotoxy(1,8);write('Font Name: ');clreol;
  fontname:='';
  getinput(10,12,8,fontname,'c',fin,1);
  assign(cf,labeldrive+fontname+'.CHR');
  gotoxy(25,8);write('Loading Font, please wait...');
  loadfont;
  if fontname<>'NONE' then
   scalefont;
  options;
end; {of fontchange}

procedure scalechange;
var
 j : integer;
 tempstr : str125;
begin
 repeat
  gotoxy(1,8);write('Scale: ');clreol;
  tempstr:='';
  getinput(3,8,8,tempstr,'n',fin,1);
  val(tempstr,scl,j);
 until j=0;
  gotoxy(1,8);write('Re-Scaling Font. Please wait... ');clreol;
  scalefont;
  scalbase:=round(base*scl);
  options;
end; {of scalechange}

procedure penchange;
var
  tempstr :str125;
begin
  for i:=15 to 25 do
  begin
    gotoxy(1,i);clreol;
  end;
  options;

  gotoxy(1,15); write('Pen shapes available:');
  gotoxy(1,17); write('1.  *');
  gotoxy(1,19); write('     *');
  gotoxy(1,20); write('2.  ***');
  gotoxy(1,22); write('    **');
  gotoxy(1,23); write('3.  **');
  gotoxy(1,25); write('4.  ***');
  repeat
   gotoxy(1,8);write('Pen: ');clreol;
   tempstr:='';
   getinput(1,6,8,tempstr,'n',fin,1);
   val(tempstr,curpen,j);
  until curpen in [1..4];
  case curpen of
   1 : penwidth:=1;
   2 : penwidth:=3;
   3 : penwidth:=2;
   4 : penwidth:=3;
  end; {of case}
  for i:=15 to 25 do
  begin
    gotoxy(1,i);clreol;
  end;
  options;
end; {of penchange}


Procedure remove_cursor;
begin
if areanum>0 then
 begin
  sstle(6);
  sccol(cyan);
  moveto(cx-5,cy);
  lto(cx+5,cy);
  moveto(cx,cy-4);
  lto(cx,cy-1);
  moveto(cx,cy+1);
  lto(cx,cy+4);
  sstle(0);
 end;
end;

procedure put_cursor;
begin
if areanum>0 then
 begin
  sstle(4);
  sccol(red);
  cx:=cx+cx1;
  if cx<5 then cx:=5;
  if cx>762 then cx:=762;
  cy:=cy+cy1;
  if cy<4 then cy:=4;
  if cy>263 then cy:=263;
  moveto(cx-5,cy);
  lto(cx+5,cy);
  moveto(cx,cy-4);
  lto(cx,cy-1);
  moveto(cx,cy+1);
  lto(cx,cy+4);
  moveto(cx,cy);
  sstle(0);         {standard mode}
 end;
end;

Procedure write_it(s : str255);

procedure print;
begin
   for l:=1 to length(s) do
   begin
     vector:=vecary[ord(s[l])-31];
     num:=lo(vector[0]);
      for j:=1 to num do
      begin
        inp:=vector[j];
        if inp<0 then moveto(cx+hi(inp)-128,cy-lo(inp))
        else lto(cx+hi(inp),cy-lo(inp));
      end;
      cx:=cx+charsize;
   end;
   cx:=tx; cy:=ty+scalbase;

end;  {of print in write_it}

begin
   cy:=cy+scalbase;
   case curpen of
   1 : print;
   2 : begin
        print;
        cx:=cx+1; print;
        cx:=cx+2; print;
        cx:=cx+1; cy:=cy-1; print;
       end;
   3 : begin
        print;
        cx:=cx+1; print;
        cx:=cx+1; cy:=cy-1; print;
        cy:=cy-1; print;
       end;
   4 : begin
        print;
        cx:=cx+1; print;
        cx:=cx+2; print;
       end;
   ELSE begin
         curpen:=1; print;
        end;
   end; {of case}
end; {of write_it}

Procedure breakline(ll : str255);
var
  last, numchar : integer;
  ts : str125;  {temp string}
begin
   error:=0; breaknum:=1;
   sx:=cx; sy:=cy;{Start pos of first line}
   tx:=cx; ty:=cy;{Temporary Vars for line start}
   charsize:=round(15*scl)+penwidth;
   repeat
        {Get number of possible chars on line}
     numchar:=round((right-cx+round(scl))/charsize);

     if numchar<length(ll) then   {Are there too many?}
     begin                       {Yes, so split line up}
       last:=numchar;
       breaknum:=breaknum+1;
       while ll[last]<>' ' do
       begin
         last:=last-1;
        if last<1 then
        begin
         gotoxy(1,8);
         if length(ll)<59 then
         begin
          lowvideo; write(ll,' is too long for line.');normvideo;
         end
         else
         begin
          lowvideo; write('This is too long for the line.');normvideo;
         end;
         clreol;
         delay(3000);
         error:=1;
         cx:=sx; cy:=sy;
         ll:=copy(tl,1,length(tl)-length(ll));
         breakline(ll);
         exit;
        end;
       end;
       ts:=copy(ll,1,last);
       write_it(ts);
       cx:=left+5;
       tx:=cx;
       cy:=ty+round(20*scl);
       ty:=cy;
       ll:=copy(ll,last+1,length(ll))
     end
     else                        {No. So do whole line}
     begin
       write_it(ll);
       ll:='';
     end;
   until length(ll)=0;
   cx:=sx; cy:=sy;  {Restore start of line}
   moveto(cx,cy);   {and move to it}
end;  {of breakline}

procedure setup;
begin
 plutoinit;
 sbcol(6);
 sccol(blue);
 sstle(0);
 fontname:='NONE';
 labname:='NONE';
 areanum:=0;
 cx1:=0; cy1:=0;
 scl:=0.5; curpen:=1;
 left:=0; right:=767;
 top:=0; bottom:=287;
 twoscreens:=FALSE;
 sstle(4);
 reset(paramf);
 read(paramf,param[0]);
 areamax:=0;
 while not eof(paramf) do
 begin
   areamax:=areamax+1;
   read(paramf,param[areamax]);
   if param[areamax].partition<>0 then
   with param[areamax] do
   begin
     if partition>1 then twoscreens:=TRUE;
     setcwp(partition);setcdp(partition);
     case areatype of
      Line : begin
              sccol(green);
              moveto(tx,ty);
              lto(bx,by);
             end;
       Box : begin
              if Noprint then sccol(blue)
              else
              sccol(green);
              moveto(tx,ty);
              lto(bx,ty);
              lto(bx,by);
              lto(tx,by);
              lto(tx,ty);
             end;
      end;  {of case}
    end;  {of with param}
  end; {eof}
  close(paramf);
  tl:='';
  penwidth:=1;
  txtmode:='F';
  inst:=TRUE;
end;

Procedure putsymbol(sn : str14;
                    col: integer);

var
  symsclx    : real;
  symscly    : real;

begin
  assign(sf,labeldrive+sn+'.SYM');
  {$I-} reset(sf); {$I+}
  if ioresult>0 then
  begin
    gotoxy(1,8);
    write('File for Symbol ',sn,' not on current drive');
    delay(3000);exit;
  end;
  symsclx:=(right-left+1)/symbol_sizex;
  symscly:=(bottom-top+1)/symbol_sizey;
  sccol(col);
  while not eof(sf) do
  begin
    read(sf,symvec);
    if symvec.status<>0 then
    begin
      with symvec do
      begin
        moveto(round(startx*symsclx)+left,round(starty*symscly)+top);
        if status=1 then lto(round(endx*symsclx)+left,round(endy*symscly)+top);
        if status=2 then ffill;
      end;
    end;
  end;
  close(sf);
end;

Procedure update_current;
begin
  if (lab.scale<>scl) or (lab.font<>fontname) then
  begin
    scl:=lab.scale;
    fontname:=lab.font;
    assign(cf,labeldrive+fontname+'.CHR');
    {$I-} reset(cf); {$I+}
    if ioresult<>0 then
    begin
      printerror('Font '+fontname+' not on current drive, ');
      exit;
    end;
    loadfont;
    scalefont;
    close(cf);
  end;
  if lab.pen<>curpen then
  begin
    curpen:=lab.pen;
    case curpen of
      1 : penwidth:=1;
      2 : penwidth:=3;
      3 : penwidth:=2;
      4 : penwidth:=3;
    end; {of case}
  end;
  cx:=lab.across; cy:=lab.down;
  tl:=lab.text;
end; {of update_current}

Procedure put_on_screen;
begin
  areanum:=lab.area;
  set_area_boundries;
  with lab do
  begin
    if (stat) and (param[areanum].contents=Textarea) then
    begin
      update_current;
      if mode='V' then
      begin
        VarsExist:=TRUE;
        sccol(cyan);
      end
      else
      sccol(green);
      breakline(text);
    end; {of text line}
    if (stat) and (param[areanum].contents=Symbolarea) then putsymbol(text,green);
  end;
end; {of put_on_screen}

procedure get_design;
var
  design_name : str8;

begin
  gotoxy(1,8);clreol;
  write('Select a label design, or <ESC> to exit: ');
  gotoxy(1,10);writeln('Designs available: ');
  display_files('DSN',11,labeldrive[1]);
  repeat
    design_name:='';
    getinput(8,41,8,design_name,'c',fin,1);
    assign(paramf,labeldrive+design_name+'.DSN');
    {$I-} reset(paramf); {$I+}
  until (ioresult=0) or (fin);
  if fin then exit;
  gotoxy(1,8);
  write('Opening Files for label design ',design_name,', Please wait...');
  clreol;
  read(paramf,param[0]);
  labext:=param[0].label_extension;
  labeldrop:=param[0].label_drop;
  close(paramf);
end;  {of get_design}

procedure output(VAR ch : byte);
begin
  inline($DB/$B4/    {IN A,B4}
         $1F/        {RRA}
         $38/$FB/    {JR,C }
         $2A/ch/     {LD HL,(CH)}
         $7E/        {LD A,(HL)}
         $D3/$B5/    {OUT (B5),A}
         $AF/        {XOR A}
         $D3/$B4/    {OUT (B4),A}
         $3C/$3C/    {INC A INC A}
         $D3/$B4     {OUT (B4),A}
);
end;
