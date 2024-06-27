overlay procedure pxstrt;

label
  dropout;

var
  numdone, entrynum : integer;
  hold : char;
  ln : str14;
  sixline : sixbyte;
  bottom1,bottom2,right1,right2 : integer;
  tlines     : integer;

begin
  writeln(lst,chr(3),'INCHES;',labeldrop:3:1);
  write(lst,chr(12));
  clrframe(10,25);
  display_queue;
  reset(batchfile);entrynum:=1;
  while not eof(batchfile) do
  begin
    setup;
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
      {$I-} reset(lf);{$I+}
      error:=ioresult;
      if error<>0 then
      begin
        ermsg(error);
        goto dropout;
      end;
      sccol(green);
      while not eof(lf) do
      begin
        read(lf,lab);
        put_on_screen;
      end;
      close(lf);
      clreol;
      setcdp(1);
      top:=0; bottom1:=0; bottom2:=0;
      left:=0; right1:=0; right2:=0;
      twoscreens:=FALSE;
      for j:=1 to areamax do
      begin
        with param[j] do
        begin
          case partition of

            1 :
            begin
              if by>bottom1 then bottom1:=by;
              if bx>right1 then right1:=bx;
            end;

            2 :
            begin
              if by>bottom2 then bottom2:=by;
              if bx>right2 then right2:=bx;
              twoscreens:=TRUE;
            end;

          end; {case}
        end; {with}
      end; {for};
      assign(fname,workdrive+'DUMP6.DAT');
      rewrite(fname);
      gotoxy(1,8); write('Label ',batchitem.labelname:8,' being');
      write(' created into data for printer. ');
      if bdr=FALSE then rsel(green) else rsel(white);
      sixpos:=1; lastdata:=0; finish:=false;
      setcwp(1);
      end_one:=trunc(right1/8+0.875);
      end_two:=trunc(right2/8+0.875);
      if bottom1>bottom2 then last_line:=bottom1 else last_line:=bottom2;
      moveto(1,1);
      repeat until port[$A0]>127;
      port[data]:=$BE;
      repeat until port[$A0]>127;
      port[data]:=lo(right1);
      port[data]:=hi(right1);
      port[data]:=lo(bottom1);
      port[data]:=hi(bottom1);
      dump_to_file(end_one,bottom1,workdrive+'P1.DAT');
      assign(mf1,workdrive+'P1.DAT');reset(mf1);

      if twoscreens then
      begin
        setcwp(2);
        moveto(1,1);
        repeat until port[$A0]>127;
        port[data]:=$BE;
        repeat until port[$A0]>127;
        port[data]:=lo(right2);
        port[data]:=hi(right2);
        port[data]:=lo(bottom2);
        port[data]:=hi(bottom2);
        dump_to_file(end_two,bottom2,workdrive+'P2.DAT');
        assign(mf2,workdrive+'P2.DAT');reset(mf2);
      end;
      tlines:=last_line;
      gotoxy(60,8);
      write('out of',tlines:4,' lines scanned');
      FOR pline:=1 to last_line do
      begin
        gotoxy(54,8);
        write(pline:4);
        lastdata:=0;
        FOR crl:=1 to end_one do
        begin
          if eof(mf1) then eight[crl]:=0 else
          read(mf1,eight[crl]);
          if eight[crl]>0 then lastdata:=crl;
        end;

        if twoscreens then
        begin
          FOR crl:=end_one+1 to end_one+end_two do
          begin
            if eof(mf2) then eight[crl]:=0 else
            read(mf2,eight[crl]);
            if eight[crl]>0 then lastdata:=crl;
          end;
        end;

        IF lastdata=0 then
        begin
          place(5); place(64); place(13); place(10);
        end
        else
        begin
          binpos:=1;
          for count:=1 to lastdata do
          if eight[count]=0 then
          begin
            for c:=1 to 4 do
            begin
              oddline[binpos]:=FALSE;
              evenline[binpos]:=FALSE;
              binpos:=binpos+1;
           end;
         end
         else
         begin
           tb:=eight[count];
           oddline[binpos]:=(tb and 128) >0;
           evenline[binpos]:=(tb and 64) >0;
           binpos:=binpos+1;
           oddline[binpos]:=(tb and 32) >0;
           evenline[binpos]:=(tb and 16) >0;
           binpos:=binpos+1;
           oddline[binpos]:=(tb and 8) >0;
           evenline[binpos]:=(tb and 4) >0;
           binpos:=binpos+1;
           oddline[binpos]:=(tb and 2) >0;
           evenline[binpos]:=(tb and 1) >0;
           binpos:=binpos+1;
         end; {of for(count)}
         for c:=1 to 4 do
           begin
             oddline[binpos]:=FALSE;
             evenline[binpos]:=FALSE;
             binpos:=binpos+1;
           end;
        binpos:=binpos-4;
        place(4);
        convert_to_six(evenline);
        place(13); place(10); place(5);
        convert_to_six(oddline);
        place(13); place(10);
      end;
    end;  {of for(line)}
    finish:=TRUE;
    for count:=sixpos to 127 do
    sixline[count]:=0;
    sixpos:=128;
    place(0);
    close(fname);
    gotoxy(1,8); write('Label ',ln:8,' being ');
    write('printed. Press ^K to stop after label being printed.');
    clreol;
      for numdone:=1 to batchitem.qtytoprint do
      begin
        reset(fname);
        repeat
          Blockread(fname,sixline,1);
          for count:=1 to 128 do output(sixline[count]);
        until eof(fname);
        write(lst,chr(12));
        gotoxy(41,entrynum+9);
        write(batchitem.QtyToPrint-numdone,' ');
        gotoxy(65,entrynum+9);
        write(numdone,' ');
        if keypressed then read(kbd,hold);
        if hold=^K then
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
        if QtyToPrint=0 then erase(lf);
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
  {$I-}
  close(batchfile);
  error:=ioresult;
  erase(batchfile);
  error:=ioresult;
  close(numberfile);
  error:=ioresult;
  erase(numberfile);
  error:=ioresult;
  {$I+}
dropout:
  ans:=' ';
  clrframe(10,25);
  gotoxy(1,20);
end;
