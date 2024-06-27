label dropout;

var
  numdone,  sl : integer;
  hold : char;
  ln : str14;
  sixline : array[1..128] of byte;
  bottom1,right1,right2 : integer;
  xscal, yscal : real;  {Scale Factors for Partn. 0 for sideways}
  sctop, scbottom, scleft, scright : integer;
  sidedata : TEXT;

PROCEDURE dump_pluto(xx1,yy1 : integer);
type
  bitarray=array[1..388] of boolean;
var i,c : integer;
 eight : array[1..588] of byte;
 status : byte;
 finish,
 the_end,
 e,
 e1 : boolean;
 line, crl : integer;
 sixpos, lastdata : integer;
 oddline, evenline : bitarray;
 arraypos, binpos : integer;
 bt : integer;
 result,tb : byte;
 end_one, end_two,last_line : integer;
 dots,
 start,
 remainder,
 bitcount,
 xc,yc, Lcount : integer;

begin    {dump_pluto}
  if bdr=FALSE then rsel(green) else rsel(white);
  sixpos:=1; lastdata:=0;
  last_line:=yy1;
  start:=xx1-(xx1 mod 8)+8;
  finish:=FALSE;
  Fillchar(oddline,yy1 div 2,0);
  Fillchar(evenline,yy1 div 2,0);
  Fillchar(eight,yy1,0);
  REPEAT
   sccol(red);
   start:=start-8;
   if start<0 then
   begin
     finish:=TRUE;
     place($1a);
   end
   else
   begin
     moveto(start,0);
     drawtopos(start,255);
     moveto(start,0);
     ready;
     port[data]:=$BE;
     ready;
     port[data]:=lo(8);
     port[data]:=hi(8);
     port[data]:=lo(yy1+2);
     port[data]:=hi(yy1+2);
     gotoxy(54,8);
     write((xx1-start)/xx1*100:4:1,'% done.');clreol;
{Read one row of bytes from Pluto}
     for count:=1 to yy1+3 do
        eight[count]:=port[data];

{for each bit in turn, LSBF or lowest remainder bit,
 check each byte for that bit and put T or F into two boolean arrays,
 one for the odd bytes and one for the even}
     bitcount:=1;
     repeat
      count:=1; lcount:=1;
      repeat
                   {The first byte's bit goes into oddline[1],
                   the second byte's bit goes into evenline[1] }

         e:=(eight[count] and bitcount) > 0;
         e1:=(eight[count+1] and bitcount) > 0;

         evenline[Lcount]:=e;
         oddline[Lcount]:=e1;

         if e or e1 then
          lastdata:=count;

         count:=count+2;
         Lcount:=Lcount+1
      until count>=yy1+2;
{If line contains no data then send a blank else;
 these two boolean arrays now have to be converted into bytes
 for the printer. Do odd first, take six bits, invert them, add 64
 then send it!!!!!}
      if lastdata =0 then
      begin
       place(5); place(64); place(13); place(10);
      end
      else
      begin
       binpos:=(yy1+2) div 2;  (* was = round(lastdata/6+0.17)*6;*)
       place(4);
       convert_to_six(oddline);
       if number_across>1 then
       for count:=2 to number_across do
       begin
         for dots:=1 to space_between_labels do
          place(64);
         convert_to_six(oddline);
       end;
       place(13); place(10); place(5);
       convert_to_six(evenline);
       if number_across>1 then
       for count:=2 to number_across do
       begin
         for dots:=1 to space_between_labels do
          place(64);
         convert_to_six(evenline);
       end;
       place(13); place(10);
      end;
      bitcount:=bitcount shl 1;    {Multiple by 2}
      lastdata:=0;
      Fillchar(oddline,sizeof(oddline),0);
      Fillchar(evenline,sizeof(evenline),0);
     until bitcount=256;
     Fillchar(eight,sizeof(eight),0);
   end;  {of if start not <0 }
      { End of one column from Pluto, go get another unless its The End. }
  UNTIL finish=TRUE;
end; {of dump_pluto}

procedure set_area_boundries;
begin
 seek(paramf,areanum);
 read(paramf,param);
 with param do
 begin
   if partition=2 then
   begin
    tx:=tx+rightone;
    bx:=bx+rightone;
   end;
        top:=ty+1;
     bottom:=by-1;
       left:=tx+1;
      right:=bx-1;
      sctop:=round(ty*yscal)+1;
   scbottom:=round(by*yscal)-1;
     scleft:=round(tx/xscal)+1;
    scright:=round(bx/xscal)-1;
 end;
end; {of set_area_boundries}


Procedure Display_label_area;
begin
 rightone:=0;
 twoscreens:=FALSE;
 sstle(4);
 reset(paramf);
 read(paramf,param);
 labeldrop:=param.label_drop;
 seek(paramf,1);
 while not eof(paramf) do
 begin
   read(paramf,param);
   if param.partition=1 then
    if param.bx>rightone then rightone:=param.bx;
 end;
 seek(paramf,1);
 while not eof(paramf) do
 begin
   read(paramf,param);
   if param.partition<>0 then
   with param do
   begin
     if partition=2 then
     begin
       tx:=tx+rightone;
       bx:=bx+rightone;
     end;
     case areatype of
      Line : begin
              sccol(green);
              moveto(round(tx/xscal),round(ty*yscal));
              lto(round(bx/xscal),round(by*yscal));
             end;
       Box : begin
              if Noprint=TRUE then sccol(blue)
              else
              sccol(green);
              moveto(round(tx/xscal),round(ty*yscal));
              lto(round(bx/xscal),round(ty*yscal));
              lto(round(bx/xscal),round(by*yscal));
              lto(round(tx/xscal),round(by*yscal));
              lto(round(tx/xscal),round(ty*yscal));
             end;
      end;  {of case}
   end;  {of with param}
 end; {eof}
end; {display_label_area}

Procedure write_it(s : str255);
var
  xp,yp : integer;
  xo : integer;

procedure print;
var
   xl, yl : integer;
begin
   ac:=charsize; dn:=0;
   if ord(s[1])-31>0 then
   for l:=1 to length(s) do
   begin
     vector:=vecary[ord(s[l])-31];
     num:=lo(vector[0]);
     xl:=round(cx/xscal);
     yl:=round(cy*yscal);
     for j:=1 to num do
     begin
        inp:=vector[j];
        ac:=hi(inp); dn:=lo(inp);
        if ac>127 then
        begin
          ac:=ac-128;
          moveto(xl+round((ac-xo)/xscal)+xo+xp
                ,yl-round(dn*yscal)+yp);
        end
        else
          lto(xl+round((ac-xo)/xscal)+xo+xp
             ,yl-round(dn*yscal)+yp);

     end;
     cx:=cx+ac+penwidth;
   end;
   cx:=tx; cy:=ty+scalbase;

end;  {of print in write_it}

begin
   xo:=round(7*Scl);
   cy:=cy+scalbase;
   case curpen of
   1 : begin
          xp:=0; yp:=0; print;
       end;
   2 : begin
        xp:=0; yp:=0; print;
        xp:=1; print;
        xp:=2; print;
        xp:=1; yp:=-1; print;
       end;
   3 : begin
        xp:=0; yp:=0; print;
        xp:=1; print;
        yp:=-1; print;
        xp:=0; print;
       end;
   4 : begin
        xp:=0; yp:=0; print;
        xp:=1; print;
        xp:=2; print;
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
   charsize:=round(16*scl)+penwidth;
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
        { breakline(ll);}
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
   moveto(round(cx/yscal),round(cy*yscal));   {and move to it}
end;  {of breakline}

Procedure put_symbol(sn : str14);
begin
   assign(sf,labeldrive+sn+'.SYM');
   {$I-} reset(sf); {$I+}
   if ioresult>0 then
   begin
     gotoxy(1,8);
     write('File for Symbol ',sn,' not on current drive');
     delay(3000);exit;
   end;
   while not eof(sf) do
   begin
     read(sf,symvec);
     if symvec.status<>0 then
     with symvec do
      draw_vector(startx,starty,endx,endy,green);
Procedure draw_vector(sx2,sy2,cx2,cy2,col : integer);
var
  ssx,ssy,scx,scy : integer;
  sysclx, syscly : real;
begin
  set_area_boundries;
  sysclx:=(right-left)/symbol_sizex;
  syscly:=(bottom-top)/symbol_sizey;
  ssx:=round(sx2*sysclx)+xoffs;
  ssy:=round(sy2*syscly)+yoffs;
  scx:=round(cx2*sysclx)+xoffs;
  scy:=round(cy2*syscly)+yoffs;
  if symvec.status=1 then
  begin
    sccol(col);
    moveto(round(ssx/xscal),round(ssy*yscal));
    lto(round(scx/xscal),round(scy*yscal));
  end;
  if symvec.status=2 then
  begin
   moveto(round(ssx/xscal),round(ssy*yscal));
   sccol(col);
   ffill;
  end;
end;  {of draw_vector}

   end;
   close(sf);
end;

procedure setup;
begin
 initialise;
 sbcol(6);
 sccol(blue);
 sstle(0);
 fontname:='NONE';
 labname:='NONE';
 areanum:=0;
 cx1:=0; cy1:=0;
 scl:=0.5; curpen:=1;
 scleft:=0; scright:=767;
 sctop:=0; scbottom:=575;
 tl:='';
 penwidth:=1;
 txtmode:='F';
 inst:=TRUE;
end;

Procedure display_sidedata;
begin
  gotoxy(10,12);clreol;
  writeln('Number of Labels Across = ',number_across:3);
  gotoxy(10,14);clreol;
  writeln('Horizontal gap between labels [tenths of inches] = ',
           space_between_labels:3);
  gotoxy(10,16);clreol;
  writeln('Drop between tops of labels [in inches] = ',labeldrop:3:0);
end; {of display_sidedata}

Procedure get_sidedata;
begin
    rewrite(sidedata);
    repeat
      display_sidedata;

    {get number across}
      repeat
       gotoxy(36,12);
       read(kbd,ans);
       val(ans,number_across,j);
      until j=0;
      gotoxy(36,12);write(number_across:3);

    {get_spacebetween}
      repeat
       gotoxy(61,14);
       {$I-} read(space_between_labels); {$I+}
      until ioresult=0;
      gotoxy(61,14);write(space_between_labels:3);

    {get_labeldrop}
    {Although labeldrop is a real the figure sent has to be an integer
     as the page length can only be set to either a number of inches or lines.
     The line spacing is not a convenient size to allow accurate measurement
     of the label drop.  As all labels encountered so far have all had a
     whole number of inches for the drop then this method has been used.}
      repeat
       gotoxy(52,16);
       {$I-} read(labeldrop);  {$I+}
      until ioresult=0;
      gotoxy(52,16);write(labeldrop:3:0);

    {check_ok}
      gotoxy(10,18);
      write('Is this Correct? [Y/N]: ');
      read(kbd,ans);
    until ans in ['Y','y'];

    writeln(sidedata,number_across);
    writeln(sidedata,space_between_labels);
    writeln(sidedata,labeldrop);
    close(sidedata);
end; {of get_sidedata}

Procedure check_sidedata;
begin
  display_sidedata;
  repeat
   gotoxy(10,18);
   write('Is this Correct? [Y/N]: ');
   read(kbd,ans);
  until ans IN ['Y','y','N','n'];
  if ans in ['n','N'] then
   get_sidedata
  else
   close(sidedata);
end;  {of check_sidedata}



Begin      { *************** Main Part ********************}
  clrscr;
  sideways:='MONKEYNUTS';

  xscal:=1.7;
  yscal:=1.7;
  workdrive:='M:';
  labeldrive:='B:';
  bdr:=false;
  gotoxy(22,1);lowvideo;
  writeln(' KENILWORTH SIDEWAYS LABEL PROCESSOR ');normvideo;
  gotoxy(1,7);writeln(conststr('*',79));
  gotoxy(1,9);writeln(conststr('*',79));
  gotoxy(29,8);lowvideo;write(version);normvideo;delay(2000);
  clrframe(10,25);
  gotoxy(28,3);lowvideo;
  write('PRINTRONIX TYPE PRINTER.');
  normvideo;

  number_across:=0;
  space_between_labels:=0;
  labeldrop:=0.0;
  assign(sidedata,labeldrive+'SIDEDATA.T'+labext);
  {$I-} reset(sidedata);  {$I+}
  if ioresult = 0 then
  begin
   readln(sidedata,number_across);
   readln(sidedata,space_between_labels);
   readln(sidedata,labeldrop);
   reset(sidedata);
   check_sidedata
  end
  else
   get_sidedata;

  gotoxy(1,6);
  write('Printing ',number_across,' labels across, with ');
  write(space_between_labels/10:4:1,' ins gap between ');
  write('and ',labeldrop:3:0,' inch label drop');
  clrframe(10,25);

   repeat
     gotoxy(1,8);lowvideo;
     write('Press RETURN when printer is ON LINE, or ESC to exit');
     normvideo;clreol;
     read(kbd,ans);
     if ans=^D then dumpsvc;
     if ans=#27 then goto dropout;
   until ans = ^M;
   writeln(lst,chr(27),'C',chr(0),chr(trunc(labeldrop)));
{   write(lst,chr(12));}
   clrframe(10,25);
   display_queue;
   reset(batchfile);entrynum:=1;
   while not eof(batchfile) do
   begin
     setup;
     hires;
     setcdp(0);
     setcwp(0);
     display_label_area;
     numdone:=0;
     read(batchfile,batchitem);
     if batchitem.QtyToPrint>0 then
     begin
      ln:=batchitem.labelname;
      assign(lf,batchitem.QueName+'.Q'+labext);
      gotoxy(1,8);
      write('Label ',ln:8,' being read to colour screen....');
      clreol;
      gotoxy(1,entrynum+9);
      lowvideo; write('>',entrynum:2);normvideo;
      write('   Label= ',ln:10);
      gotoxy(27,entrynum+9);
      write('Qty to Print= ',batchitem.QtyToPrint);
      gotoxy(52,entrynum+9);
      write('Qty Printed= ',numdone,' ');
      reset(lf);
      sccol(green);
      while not eof(lf) do
      begin
        read(lf,lab);
        put_on_screen;  {for sideways printing}
      end;
      close(lf);
      gotoxy(22,8);
      write(' created into data for printer. ');
      clreol;
      bottom1:=0;
      right1:=0;
      right2:=0;
      twoscreens:=FALSE;
      reset(paramf);
      read(paramf,param);   {get rid of first record}
      while not eof(paramf) do
      begin
        read(paramf,param);
        with param do
        begin
          if by>bottom1 then bottom1:=by;
          if partition=1 then
            if bx>right1 then right1:=bx;
          if partition=2 then
            if bx>right2 then right2:=bx;
        end; {of with}
      end; {of while};
      bottom1:=round(bottom1*yscal);
      right1:=right1+right2;
      right1:=round(right1/xscal);
      assign(fname,workdrive+'DUMP6.DAT');
      rewrite(fname);
      dump_pluto(right1,bottom1);
      close(fname);
      gotoxy(22,8);
      write('printed. Press ^K to stop after label being printed.');
      clreol;
      for numdone:=1 to batchitem.qtytoprint do
       begin
        reset(fname);
        repeat
          Blockread(fname,sixline,1);
          for count:=1 to 128 do
           output(sixline[count]);
        until eof(fname);
        write(lst,chr(12));
        gotoxy(41,entrynum+9);
        write(batchitem.QtyToPrint-numdone,' ');
        gotoxy(65,entrynum+9);
        write(numdone,' ');
        hold:=' ';
        if keypressed then
         read(kbd,hold); if hold=^D then dumpsvc;
        if hold = ^K then
        begin
          close(fname);
          with batchitem do
          begin
           QtyToPrint:=QtyToPrint-numdone;
           gotoxy(1,entrynum+9);normvideo;
           write(entrynum:3,'   Label= ',ln:10);
           gotoxy(27,entrynum+9);
           write('Qty to Print= ',QtyToPrint,' ');
           gotoxy(52,entrynum+9);
           write('Qty Printed= ',numdone,' ');
           clreol;
          end;
          seek(batchfile,filepos(batchfile)-1);
          write(batchfile,batchitem);
          close(batchfile);
          goto dropout;
        end;
       end;
       close(fname);
       with batchitem do
       begin
        QtyToPrint:=QtyToPrint-numdone;
        if QtyToPrint=0 then
          erase(lf);
        gotoxy(1,entrynum+9);normvideo;
        write(entrynum:3,'   Label= ',ln:10);
        gotoxy(27,entrynum+9);
        write('Qty to Print= ',QtyToPrint,' ');
        gotoxy(52,entrynum+9);
        write('Qty Printed= ',numdone,' ');
        clreol;
       end;
       seek(batchfile,filepos(batchfile)-1);
       write(batchfile,batchitem);
     end; {if qtytoprint>0}
     entrynum:=entrynum+1;
   end; {of while not eof batchfile}
   BatchExists:=FALSE;
   close(batchfile);
   erase(batchfile);
   dropout:
   ans:=' ';
   clrframe(10,25);
   gotoxy(1,20);
   assign(f,'ULP.COM');
   {$I-} execute(f);{$I+}
   if ioresult>0 then
   write('ULP program not found.');
end.