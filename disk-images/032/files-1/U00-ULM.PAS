PROGRAM ULM; {Universal Label Mass print} {26/9/86}
{Modified from Wide label version to do all designs. 33/10/86}
{$C-}
{$V-}
{$R-}
{$I header.ulm}
{$I pluto.ulm}
{$I utils.ulm}

PROCEDURE display_files(ext : str3; dn : integer; drv : char);
Var
  dma : string[129]; {Location to store portion of DIR read in}
  filename : string[12];
  fcb : array[1..12] of byte absolute $5c;  {Location filename is stored}
  x,j,entry,count :integer;
  prog : string[12];
  drivenum : char;
  xx : FILE;

procedure printit;                    {x = the number (0 - 3) of the}
 begin                                {entry in the DMA. Each entry }
   entry:=(x*32)+1;                   {uses 32 bytes. The first 12  }
   prog:=copy(dma,entry+1,8);         {give the drive, name & extension.}
   write(prog:10);
 end;


BEGIN
assign(xx,drv+':Z.Z'); close(xx);
dma:='';
for j:=1 to 129 DO
  dma:=dma+' ';
drivenum:=chr(ord(drv)-$40);
gotoxy(5,dn);
 filename:='????????'+ext;
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
   count:=1;                   {Set up count to print 4 on a line}
   repeat
     if count MOD 7=0 THEN     {If 7 printed do a linefeed}
     begin
      writeln;write('    ');
      IF count MOD (24-dn)*7=0 THEN   {If max lines start again}
      begin
        write('Press any key to display more, or <ESC> to select.');
        read(kbd,ans);
        if ans=#27 then exit;
        for k:=0 to 24-dn do
        begin
          gotoxy(1,dn+k);clreol;
        end;
        gotoxy(5,dn);
      end;

     end;
     x:=bdos($12);             {Find next entry ......}
     if x<>255 THEN
      printit;
     count:=count+1;
   until x=255;                {.... until no more found}
 end
 ELSE
 begin
   gotoxy(1,10);
   write('No files of extension ',ext,' found on drive ',drv,'.');
 end;
END;


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
         delay(3000);
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
       {$I-} reset(cf); {$I+}
          error:=ioresult;
          if error>0 then
            begin
              gotoxy(1,8);write('Unable to find Font ',fontname);
              clreol; exit;
            end;
        loadfont;
        scalefont;
      end;
      areanum:=lab.area;
      set_area_boundries;
      cx:=lab.across; cy:=lab.down;
      tl:=lab.text;
end; {of update_current}

Procedure put_on_screen;
begin
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




Procedure Print_each_label;
Type
   labelpointer = ^labelrecord;
   labelrecord =record
             name : str8;
             next : labelpointer
             end;
Label
  exzz;
Var
  heaptop : ^integer;
  firstlabel, lastlabel,newlabel : labelpointer;
  dma : string[129]; {Location to store portion of DIR read in}
  filename : string[12];
  fcb : array[1..12] of byte absolute $5c;  {Location filename is stored}
  x,j,entry,count :integer;
  drivenum : char;
  xx : FILE;
  ln : str8;
  number_printed, current_number : integer;
  sixline : sixbyte;
  bottom1,bottom2,right1,right2 : integer;
  drv : string[1];
  ext : str3;
  first_one,last_one, hold : string[5];
  in_range : boolean;
  df : TEXT;
  newlist : boolean;

procedure get_design;
var
  design_name : str8;

begin
  gotoxy(1,8); clreol;
  write('Select a label design, or <ESC> to exit: ');
  gotoxy(1,10);writeln('Designs available: ');
  display_files('DSN',11,labeldrive[1]);
  repeat
    design_name:='';
    getinput(8,41,8,design_name,'c',fin,1);
    assign(paramf,labeldrive+design_name+'.DSN');
    {$I-} reset(paramf); {$I+}
  until (ioresult=0) or (fin=TRUE);
  if fin=TRUE then exit;
  read(paramf,param);
  ext:='L'+param.label_extension;
  labeldrop:=param.label_drop;

end;  {of get_design}


procedure printit;
begin
    entry:=(x*32)+1;                   {uses 32 bytes. The first 12  }
    ln:=copy(dma,entry+1,8);           {give the drive, name & extension.}
    ln:=copy(ln,1,pos(' ',ln)-1);
    write(ln:10);
    new(newlabel);
    newlabel^.name:=ln;
    if firstlabel=nil then
     firstlabel:=newlabel
    else
     lastlabel^.next:=newlabel;
    lastlabel:=newlabel;
    lastlabel^.next:=nil;
end;  {of print_it}

procedure get_list;
var
  count : integer;

begin
 count:=0;
 if firstlabel<>nil then
  release(heaptop);
 firstlabel:=nil;
 mark(heaptop);
 clrframe(10,24);
 gotoxy(1,10);
 assign(xx,drv+':Z.Z'); close(xx);
 dma:='';
 for j:=1 to 129 DO
   dma:=dma+' ';
 drivenum:=chr(ord(drv)-$40);

 filename:='????????'+ext;
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
   count:=count+1;
   repeat
     if count MOD 80=0 then
     begin
       gotoxy(1,25);clreol;
       write('Press any key to display more, or <ESC> to select.');
       read(kbd,ans);
       if ans=#27 then exit;
       clrframe(10,25);
       gotoxy(1,10);
     end;
     x:=bdos($12);             {Find next entry ......}
     if x<>255 THEN
      printit;
      count:=count+1;
     if keypressed then x:=255;
   until (x=255); {.... until no more found}
 end;
 newlist:=FALSE;
end; {of get_list}

BEGIN
  clrscr;
  initialise;
  setkeys;
  workdrive:='M:';
  labeldrive:='B:';
  drv:=labeldrive[1];
  first_one:='First';
  Last_one:='Last';
  firstlabel:=nil;
  bdr:=TRUE;
  gotoxy(24,1);lowvideo;
  writeln(' KENILWORTH LABEL PROCESSOR ');normvideo;
  gotoxy(1,7);writeln(conststr('*',79));
  gotoxy(1,9);writeln(conststr('*',79));
  gotoxy(28,8);write(version);delay(2000);
  show_function_line;
  Key_use(masp);
  get_design;
  if fin=TRUE then exit;
  gotoxy(1,6);write(labeldrive);
  gotoxy(17,6);
  if bdr=FALSE then
    write('OFF')
  else
    write('ON ');
  repeat
     repeat
      gotoxy(1,8);clreol;
      write('Which type of printer; P)rintronix or E)pson ?');
      read(kbd,ans);
     until ans in ['P','p','E','e'];
     case ans of
      'P','p' : printertype:='P';
      'E','e' : printertype:='E';
     end; {of case}
     gotoxy(1,8);lowvideo;
     write('Press ESC when printer is ON LINE.');normvideo;clreol;
     read(kbd,ans);
  until ans = esc;
  write(lst,chr(12));
  gotoxy(23,25);lowvideo;
  write('Check paper is aligned in printer.');normvideo;
  gotoxy(25,6);write('First   Last    ');
  get_list;
  repeat
   if newlist=TRUE then
    get_list;
   gotoxy(1,8);clreol;
   write('Select option or <Esc> to exit.');
   read(kbd,ans);
   case ans of
    ^L : begin
          repeat
           gotoxy(1,8);clreol;drv:='';
           write('Select drive: (A,B,C,D,M) ');
           getinput(1,27,8,drv,'c',fin,1);
          until drv in ['A','B','C','D','E','M'];
          labeldrive:=drv+':';
          gotoxy(1,6);write(labeldrive);
          newlist:=TRUE;
         end;
    ^F : begin
          bdr:= not bdr;
          gotoxy(17,6);
          if bdr=FALSE then
           write('OFF')
          else
           write('ON ');
         end;
    ^S  : begin
          gotoxy(1,8);clreol;
          hold:=first_one; first_one:='';
          write('Enter first label to print or <Esc> if no change: ');clreol;
          getinput(8,50,8,first_one,'c',fin,1);
          if fin=TRUE then first_one:=hold;
          ans:=' ';
          gotoxy(25,6);write(first_one,copy('       ',1,8-length(first_one)));
         end;
    ^P  : begin
          gotoxy(1,8);clreol;
          hold:=last_one; last_one:='';
          write('Enter last label to print or <Esc> if no change: ');clreol;
          getinput(8,49,8,last_one,'c',fin,1);
          if fin=TRUE then last_one:=hold;
          ans:=' ';
          gotoxy(33,6);write(last_one,copy('       ',1,8-length(last_one)));
         end;
   end; {of case}
 until (ans=^A) or (ans=esc);
 if ans=esc then exit;
 if first_one='First' then
  in_range:=TRUE else
 in_range:=FALSE;
 while firstlabel<>nil do
 begin
    if firstlabel^.name=first_one then in_range:=TRUE;
    if in_range=False then goto exzz;
    setup;
    ln:=firstlabel^.name;
    if keypressed then exit;
    assign(xx,drv+':Z.Z'); close(xx);
    assign(lf,drv+':'+ln+'.'+ext);
    {$I-} reset(lf);{$I+}
    error:=ioresult;
    if ioresult>0 then
    begin
      gotoxy(1,8);
      write('Error reading ',firstlabel^.name);
      clreol;
      goto exzz;
    end;
    if printertype='E' then
     write(lst,chr(27),'2');
    gotoxy(1,8);
    write('Label ',ln:5,'.',ext);clreol;
    gotoxy(17,8);write(' being read onto colour screen...');
    writeln(lst,'LABEL ',ln,'. Database entries used: ');
    sccol(green);
    while not eof(lf) do
    begin
      read(lf,lab);
      areanum:=lab.area;
      set_area_boundries;
      if length(lab.key)>0 then
      begin
       write(lst,lab.key:14,'= ');
       writeln(lst,lab.text);
      end;
      put_on_screen;
    end;
    close(lf);
    gotoxy(23,8);clreol;
    setcdp(1);
    write(' created into data for printer. Please wait..');
    writeln(lst,'');
      setcdp(1);
      top:=0; bottom1:=0; bottom2:=0;
      left:=0; right1:=0; right2:=0;
      twoscreens:=FALSE;
      reset(paramf);
      read(paramf,param);  {Get ride of first sector}
      while not eof(paramf) do
      begin
        read(paramf,param);
        with param do
        begin
         case partition of
          1 : begin
                if by>bottom1 then bottom1:=by;
                if bx>right1 then right1:=bx;
              end;
          2 : begin
                if by>bottom2 then bottom2:=by;
                if bx>right2 then right2:=bx;
                twoscreens:=TRUE;
              end;
         end; {of case}
        end; {of with}
      end; {of while};

    assign(fname,'DUMP6.DAT');
    rewrite(fname);
    dump_pluto(right1,bottom1,right2,bottom2);
    close(fname);
    gotoxy(17,8);
    write('Data going to printer.');
    clreol;

    reset(fname);
    repeat
        Blockread(fname,sixline,1);
        for count:=1 to 128 do
         output(sixline[count]);
    until eof(fname);
    writeln(lst,chr(12));
    close(fname);
    ans:=' ';
    if keypressed then firstlabel:=nil else
exzz :
    if firstlabel^.name=Last_one then in_range:=FALSE;
    firstlabel:=firstlabel^.next;
 end;
release(heaptop);
close(paramf);
END;



BEGIN
   print_each_label;
   if printertype='E' then
    writeln(lst,chr(27),'2');
   assign(f,'MENU.COM');
   {$I-} execute(f); {$I+}
   if ioresult>0 then
    write('MENU program not found.');
END.