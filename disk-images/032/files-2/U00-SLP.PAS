Program slp;   {Sideways Label Printing}
{Program to  print the labels sideways.
All other options, create Queue etc., are done in ULP
modified to execute this program instead of calling an
overlay procedure.}
{$V-,R-}
{$C-} {Turn off check for ^C and ^S. Required to see if a
       key has been pressed to stop printing}
label dropout;

{$I header.slp}

var
  numdone,  sl : integer;
  hold : char;
  ln : str14;
  sixline : sixbyte;
  bottom1,right1 : integer;
  xscal, yscal : real;  {Scale Factors for Partn. 0 for sideways}
  sctop, scbottom, scleft, scright : integer;
  sidedata : TEXT;

{$I pluto.slp}
{$I utils.slp}


Procedure update_current;
begin
  if lab.scale <> scl then
      begin
        scl:=lab.scale;
        fontname:=lab.font;
        assign(cf,labeldrive+fontname+'.CHR');
        {$I-} reset(cf); {$I+}
        if ioresult<>0 then
        begin
         gotoxy(1,8);write('Font ',fontname,' not on current drive');
         delay(3);
         exit
        end;
        loadfont;
        scalefont;
        close(cf);
      end;
      if lab.pen <> curpen then
      begin
        curpen:=lab.pen;
      end;
        case curpen of
         1 : penwidth:=1;
         2 : penwidth:=3;
         3 : penwidth:=2;
         4 : penwidth:=3;
        end; {of case}
      if lab.font <> fontname then
      begin
        fontname:=lab.font;
        assign(cf,labeldrive+fontname+'.CHR');
        reset(cf);
        loadfont;
        scalefont;
      end;
      areanum:=lab.area;
      set_area_boundries;
      cx:=lab.across; cy:=lab.down;
      tl:=lab.text;
      if param.partition=2 then
        cx:=cx+rightone;
end; {of update_current}

Procedure put_on_screen;
begin
    areanum:=lab.area;
    set_area_boundries;
    with lab do
    if (stat=TRUE) and (param.contents=Textarea) then
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
    if (lab.stat=TRUE) and (param.contents=Symbolarea) then
    with lab do
    begin
      sccol(green);
      areanum:=area;
      symname:=text;
      set_area_boundries;
      xoffs:=left; yoffs:=top;
      put_symbol(text);
    end; {of symbol}
end; {of put_on_screen}

Procedure display_queue;
var
  posn,sl : integer;
begin
  posn:=1;
  gotoxy(1,10);
  flush(batchfile);
  reset(batchfile);
  while not eof(batchfile) do
  begin
    read(batchfile,batchitem);
    with batchitem do
    begin
     gotoxy(1,posn+9);
     write(posn:3,'   Label= ',labelname:10);
     gotoxy(27,posn+9);
     write('Qty to Print= ',QtyToPrint,' ');
     clreol;
     posn:=posn+1;
    end;  {of with}
  end; {of while}
  if posn<16 then
  begin
   gotoxy(1,posn+9);
   write(posn:3);
  end;
end;  {of display_queue}

Begin      { *************** Main Part ********************}
  clrscr;
  sideways:='MONKEYNUTS';
  xscal:=0.613;
  yscal:=1.7;
  workdrive:='M:';
  labeldrive:='B:';
  bdr:=false;
  gotoxy(22,1);lowvideo;
  writeln(' KENILWORTH SIDEWAYS LABEL PROCESSOR ');normvideo;
  gotoxy(1,7);writeln(conststr('*',79));
  gotoxy(1,9);writeln(conststr('*',79));
  gotoxy(29,8);lowvideo;write(version);normvideo;delay(2000);
  show_function_line;
  clrframe(10,25);
  gotoxy(31,4);lowvideo;
  write('EPSON TYPE PRINTER.');
  normvideo;
  assign(sidedata,labeldrive+'SIDEDATA.T'+labext);
  {$I-} reset(sidedata);  {$I+}
  if ioresult = 0 then
  begin
   readln(sidedata,number_across);
   readln(sidedata,space_between_labels);
   readln(sidedata,slabeldrop);
   close(sidedata);
  end
  else
  begin
    gotoxy(1,8);
    write('Sideways label layout file missing');clreol;
    delay(3000);
    exit;
  end;
  gotoxy(1,6);
  write('Printing ',number_across,' labels across, with ');
  write(space_between_labels/10:4:1,' ins gap between ');
  write('and ',slabeldrop:3:1,' inch label drop');
  clrframe(10,25);

   repeat
     gotoxy(1,8);lowvideo;
     write('Press RETURN when printer is ON LINE, or ESC to exit');
     normvideo;clreol;
     read(kbd,ans);
     if ans=#27 then goto dropout;
   until ans = ^M;
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
      write(' created into data for printer. Please wait..');
      clreol;
      bottom1:=0;
      right1:=0;
      twoscreens:=FALSE;
      reset(paramf);
      read(paramf,param);   {get rid of first record}
      while not eof(paramf) do
      begin
        read(paramf,param);
        with param do
        begin
          if by>bottom1 then bottom1:=by;
          if bx>right1 then right1:=bx;
        end; {of with}
      end; {of while};
      bottom1:=round(bottom1*yscal);
      right1:=round(right1*xscal);
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
(*        write(lst,chr(12));*)
        gotoxy(41,entrynum+9);
        write(batchitem.QtyToPrint-numdone,' ');
        gotoxy(65,entrynum+9);
        write(numdone,' ');
        hold:=' ';
        if keypressed then
         read(kbd,hold);
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
end.