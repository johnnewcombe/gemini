Program ulp;   {Universal Label Printing}  {6/10/86}
{Program to create the label print queue and print the labels.
With Editing and adding to queue and entering of variable data at
print time. For any label design.
Wording of main menu option 2 changed.
Separate programs executed to print.
Multiple Copies across implemented.}
{$V-,R-}
{$C-} {Turn off check for ^C and ^S. Required to see if a
       key has been pressed to stop printing}

label
  out;

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

{$I gemio.inc}
{$I dispfils.inc}
{$I pluto.inc}
{$I plutodmp.inc}
{$I labutils.inc}
{$I procs.ulp}

Begin      { *************** Main Part ********************}
  plutoinit;
  setkeys;
  workdrive:='M:';
  labeldrive:='B:';
  bdr:=false;
  setscreen(title);
  get_design;
  if fin then goto out;
  batchexists:=true;
  assign(batchfile,labeldrive+'MASTER.Q'+labext);
  {$I-}  reset(batchfile);  {$I+}
  j:=ioresult;
  if j<>0 then batchexists:=false;
  assign(numberfile,labeldrive+'NUMBER.Q'+labext);
  {$I-}  reset(numberfile);  {$I+}
  j:=ioresult;
  if j<>0 then batchexists:=false;
  if batchexists then
  begin
    read(numberfile,nextnum);
    reset(numberfile);
    maxnum:=filesize(batchfile);
  end;
  REPEAT
    if BatchExists=FALSE then
    begin
       rewrite(batchfile);
       rewrite(numberfile);
       nextnum:=1;
       write(numberfile,nextnum);
       maxnum:=0;
    end;
    repeat
      clrframe(10,25);
      gotoxy(ax,11);lowvideo;  write(' F0 ');normvideo;
      if BatchExists then write('   Print Labels in Label Print Queue.');
      gotoxy(ax,13);lowvideo;  write(' F1 ');normvideo;
      gotoxy(ax,15);lowvideo;  write(' F2 ');normvideo;
      if BatchExists then write('   Add to, Amend or Examine Print Queue.')
      else                     write('   Create New Print Queue.');
      gotoxy(ax,17);lowvideo;  write(' F3 ');normvideo;
      gotoxy(ax,19);lowvideo;  write(' F4 ');normvideo;
      write('   Exit Program WITHOUT printing Label Print Queue.');
      gotoxy(ax,21);lowvideo;  write(' F5 ');normvideo;
      if BatchExists then write('   Delete Label Print Queue.');
      clrframe(4,5);
      write('Print           Maintain        Exit    Delete');
      writeln;
      write('Labels          Queue           Program Queue');
      options;
      read(kbd,ans);
      Case ans of

        f0 :
        begin
          if BatchExists then
          begin
            clrframe(10,25);
            gotoxy(10,12);write('1.    Printronix - Straight.');
            gotoxy(10,13);write('2.    C Itoh - Straight.');
            gotoxy(10,14);write('3.    Epson - Straight.');
            gotoxy(10,15);write('4.    Printronix - Sideways.');
            gotoxy(10,16);write('5.    C Itoh - Sideways.');
            gotoxy(10,17);write('6.    Epson - Sideways.');
            repeat
              gotoxy(1,8); clreol;
              write('Select Printing method, or ESC to exit.');
              read(kbd,ans1);
            until ans1 in ['1'..'4',esc];
            case ans1 of

              '1' :
              begin
                assign(f,'PXSTRT.COM');
                {$I-} execute(f); {$I+}
                if ioresult<>0 then printerror('Printronix Straight print program not found');
              end;

              '2' : {cistrt};

              '3' : {epstrt};

              '4' : {pxsw};

              '5' : {cisw};

              '6' : {epsw};

            end; {of case}
          end;
        end;

        f2 : editqueue;

        f4 :
        begin
          close(batchfile); close(numberfile);
          clrframe(10,25);
        end;

        f5 :
        if BatchExists then
        begin
          {$I-} reset(batchfile);{$I+}
          error:=ioresult;
          if error>0 then
          begin
            ermsg(error);
            exit;
          end;
          reset(batchfile);
          while not eof(batchfile) do
          begin
            read(batchfile,batchitem);
            ln:=labeldrive+batchitem.labelname+'.Q'+labext;
            assign(nf,ln);
            {$I-} reset(nf); {$I+}
            if ioresult=0 then
            erase(nf);
          end;
          {$I-}
          close(batchfile);
          i:=ioresult;
          erase(batchfile);
          i:=ioresult;
          close(numberfile);
          i:=ioresult;
          erase(numberfile);
          i:=ioresult;
          {$I+}
          Batchexists:=FALSE;
        end;

      end; {of case}
    until ans in [f0,f2,f4,f5]
  UNTIL ans = f4;
  out:
  assign(f,'MENU.COM');
  {$I-} execute(f);{$I+}
  if ioresult>0 then
  write('MENU program not found.');
end.
