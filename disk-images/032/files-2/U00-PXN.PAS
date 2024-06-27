program pxn;
{assumes a print queue has been created for Printronix - normal orientation}
{$V-,R-}
{$C-} {Turn off check for ^C and ^S. Required to see if a
       key has been pressed to stop printing}

label
  out,
  dropout;

const
  symbol_sizex = 540;
  symbol_sizey = 283;
  ax : integer = 10;
  maxareas     = 20;
  esc          = #27;
  f0           = ^L;
  f1           = ^A;
  f2           = ^F;
  f3           = ^S;
  f4           = ^P;
  f5           = ^T;
  f6           = ^E;
  f7           = ^Q;
  f8           = ^X;
  f9           = 'a';
{ title size must match for this suite!
          '***************************************************************'}
  title = '****** Label Production program - version 2.04  20/03/87 ******';

type
     vecrec = Record
       status : integer;
       startx : integer;
       starty : integer;
       endx   : integer;
       endy   : integer;
     end; {of record}


  str80 = string[80];
  str14 = string[14];
  str10 = string[10];
  str5  = string[5];
  str3  = string[3];
  str2  = string[2];
  str8  = string[8];
  str125 = string[125];
  str255 = string[255];
  sixbyte = array[1..128] of byte;
  bitarray  = array[1..580] of boolean;
  vecline = array[0..30] of integer;
  charset = set of char;

  labelcont = record
         stat : boolean;
         area : integer;
         across : integer;
         down : integer;
         scale : real;
         font : string[14];
         pen : byte;
         mode : char;
         key : str10;
         modif : byte;
         text : str125;
   end; {of record}

   Labelprint  = Record
     QueName   : str10;
     LabelName : str10;
     QtytoPrint : integer;
   end; {of record}

   Dimension = (Line, Box);
   picture   = (Symbolarea, Textarea, Null);

   paramrec = record
     case first : boolean of
      TRUE : (label_name : str8;
              label_extension : str2;
              label_drop : real);
     FALSE :
      (Partition : integer;      {At present, 1 or 2}
        AreaType : dimension;    {Line or Box}
              tx : integer;      {If Line: tx,ty = FROM}
              ty : integer;      {If Box: tx,ty = top left corner}
              bx : integer;      {If Line: bx,by = TO}
              by : integer;      {If Box:  bx,by = bottom right corner}
         Noprint : boolean;      {TRUE = Don't print on label}
        Contents : picture);     {Symbolarea, Textarea or Null for line}
   end;  {of record}


var
  design     : str8;
  sixline    : sixbyte;
  finish     : boolean;
  evenline,
  oddline    : bitarray;
  arraypos,
  binpos,
  sixpos,
  lastdata   : integer;

  eight : array[1..200] of byte;
  status : byte;
  pline, crl : integer;
  bt : integer;
  tb : byte;
  mf1, mf2 : FILE of byte;
  end_one, end_two,last_line : integer;
  number_to_do,
  number_across : integer;
  nac : integer;

  symname : str10; {symbol name}
  sf : File of vecrec;
  symvec : vecrec;
  ir : byte;
  c1, col, dx, dy, sx, sy, tx, ty, width, height, psrc, pdst,
  tim1, tim2, count, inc, coll, x1, y1 : integer;
  by : byte;
  k,j,i,l,w : integer;
  x,y,x2,y2 : integer;
  a,d : real;
  fname : FILE ;
  f : FILE;
  tl : str125;
  num, inp : integer;
  ac, dn : integer;
  let : integer;
  cf : file of vecline;
  scl : real;
  vecary : array [1..95] of vecline;
  ans,ans1,command : char;
  scalbase,base,cx,cy,cx1,cy1 : integer;
  tcx,tcy,fcx,fcy : integer;
  lab : labelcont;
  newname, labname, qname : string[10];
  ln         : str14;
  tempf,lf,nf : file of labelcont;
  fontname : string[8];
  curpen : integer;
  curmode : char;
  areanum, top, bottom, left, right : integer;
  charsize : integer;
  inst, fin : boolean;
  error : integer;
  query, noup, nodown, up, down : boolean;
  xoffs, yoffs : integer;
  vector : vecline;
  penwidth : byte;
  txtmode : char;
  Breaknum : integer;
  Batchfile : FILE of labelprint;
  Batchitem : labelprint;
  BatchExists, VarsExist : boolean;
  WorkDrive, LabelDrive : str2;
  numberfile : FILE of integer;
  nextnum : integer;
  entrynum, movetonum : integer;
  curwp, curdp : integer;
  szx : str3;
  bdr : boolean;
  maxnum : integer;
  paramf : FILE of Paramrec;
  param : array [0..maxareas] of paramrec;
  labext : str2;
  twoscreens : boolean;
  labeldrop : real;
  printertype : char;

  C  : integer;
  ss,entry : str8;
  tempitem : labelprint;
  zf : FILE of labelcont;
  testq : real;
  areamax    : integer;

  numdone    : integer;
  hold : char;
  bottom1,bottom2,right1,right2 : integer;
  tlines     : integer;

{$I gemio.inc}
{$I dispfils.inc}
{$I pluto.inc}
{$I plutodmp.inc}
{$I labutils.inc}
{$I procs.pxn}

Begin      { *************** Main Part ********************}
  plutoinit;
  setkeys;
  workdrive:='M:';
  labeldrive:='B:';
  bdr:=false;
  setscreen(title);
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
end.
