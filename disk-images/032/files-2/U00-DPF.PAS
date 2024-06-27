 program dpf;
 {$V-,R-}
 { To create a design parameter file for a label.
 First rough version, 1/10/86
 Second better version, 8/10/86
 Third even better version  20/11/86}

 const
  data = $A1;    status = $A0;    alloc_ = $a3;    copy_ = $85;
  iccol_ = $8d;    icp_ = $96;    icwp_ = $93;    init_ = $a6;
  lrel_ = $9d;    lrels_ = $9e;    lto_ = $80;    lsym_ = $a0;
  mrel_ = $98;    mrels_ = $99;    mto_ = $97;    ffill_ = $82;
  bfill_ = $B0;  rfill_ = $81;  sbcol_ = $87;  sccol_ = $89;  sfcol_ = $88;
  spcol_ = $BA; scsp_ = $a4;   scwp_ = $a5;  scdp_ = $83;  sstle_ = $8a;
  prs_ = $9c;    pat_ = $9a;     red = 4;    blue = 2;
  green = 1;    yellow = 5;    cyan = 3;    magent = 6;    black = 0;
  white = 7;    paint = 8;
  esc = #27;  cul = #28;  cur = #29;  cup = #30;  cud = #31;
  ins = #23;  del = #127; cr = #13;  bs = #8;  ch = #25;
  version = 'Ver 1.2 20/11/86';

 Type
   Dimension = (Line, Box);
   picture   = (Symbolarea, Textarea, Null);
      str2 = string[2];
   str3 = string[3];
   str8 = string[8];
   str125 = string[125];

   paramrec = record
     case first : boolean of
      TRUE : (design_name : str8;
              design_suffix : str2;
              label_drop : real);
      FALSE:
      (Partition : integer;      {At present, 1 or 2}
        AreaType : dimension;    {Line or Box}
              tx : integer;      {If Line: tx,ty = FROM}
              ty : integer;      {If Box: tx,ty = top left corner}
              bx : integer;      {If Line: bx,by = TO}
              by : integer;      {If Box:  bx,by = bottom right corner}
         Noprint : boolean;      {TRUE = Don't print on label}
        Contents : picture);     {Symbol or Text}
   end;  {of record}

Var
     tempf, paramf : FILE of Paramrec;
     param, zzz : paramrec;
     c, ans : char;
     top, bottom, left, right : integer;
     label_name : str8;
     labeldrive : str2;
     P : boolean;
     dp : string[5];
     drop : real;
     suffix : string[2];
     newdesign : boolean;
     choice : string[1];
     s : string[25];
     query,inst : boolean;
     noup,nodown,up, down : boolean;
     x,k,j,cl,fl,ll : integer;
     fin : boolean;
     typename : str8;
{$I utils.dpf}

procedure printit;
var i : integer;
begin
  if param.first=TRUE then
  begin
    write(lst,'Design Name= ',param.design_name,'.');
    write(lst,'  Design Suffix= ',param.design_suffix);
    writeln(lst,'  Label Drop= ',param.label_drop:3:0,' inches.');
    writeln(lst,conststr('-',79));
  end
  ELSE
  with param do
  begin
    writeln(lst,'Area Number ',filepos(paramf)-1);
    writeln(lst,'Display on Pluto Partition= ',partition);
    write(lst,'Area Type= ');
     case areatype of
      Line : begin
              writeln(lst,'Line');
              writeln(lst,'Start X=',tx,' Start Y=',ty);
              writeln(lst,'Finish X=',bx,' Finish Y=',by);
             end;

      Box  : begin
              writeln(lst,'Box');
              writeln(lst,'Top Left X=',tx,' Top Left Y=',ty);
              writeln(lst,'Bottom Right X=',bx,' Bottom Right Y=',by);
              writeln(lst,'Don''t Print Box Outline = ',Noprint);
             end;
     end; {of case}

    write(lst,'Type of Contents= ');
     if contents=Symbolarea then writeln(lst,'Symbol');
     if contents=Textarea then writeln(lst,'Text');
     if contents=Null then writeln(lst,'Line');
    for i:=1 to 79 do
     write(lst,'*');
    writeln(lst,'');
  end;
end;

procedure print_header;
begin
  clrframe(10,25);
  gotoxy(1,10);
  write('Area No.  Partition.  Area Type.   TX    TY    BX    BY    ');
  write('No Print.  Contents.');
end; {of print_header}

procedure print_list;
begin
   repeat
    s:='';
    gotoxy(1,8); clreol;
    write('Enter Drive for Design Files: [A,B,C,D,M] ');
    getinput(1,43,8,s,'c',fin,1);
   until s in ['A'..'E','M'];
   clrframe(10,25);
   labeldrive:=s+':';
   display_files('DSN',11,s);
   gotoxy(1,8);clreol;
   write('Enter Design name: ');
   readln(param.design_name);
   gotoxy(1,8);clreol;
   write('Print data on printer Y/N: ');
   repeat
     readln(ans);
   until ans in ['Y','y','N','n'];
   if ans in ['y','Y'] then
    P:=TRUE else P:=FALSE;
   assign(paramf,labeldrive+param.design_name+'.DSN');
   {$I-} reset(paramf); {$I+}
   if ioresult>0 then
    begin
     write('Design ',param.design_name,' is not on drive ',labeldrive);
     delay(2000);
     exit;
    end;
   initialise;
   sstle(4);
   read(paramf,param);
   if P=TRUE then
   begin
    param.first:=TRUE;
    printit;
   end;
   while not eof(paramF) do
   begin
     read(paramf,param);
     if P=TRUE then printit;
     if param.partition<>0 then
     with param do
     begin
       setcwp(partition);setcdp(partition);
       case areatype of
        Line : begin
                sccol(green);
                moveto(tx,ty);
                lto(bx,by);
               end;
         Box : begin
                if Noprint=TRUE then sccol(blue)
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
   write(lst,chr(12));
end; {of print_list}

Procedure main_menu;
begin
  clrframe(10,25);
  gotoxy(35,11);lowvideo;
  write(' Main Menu ');normvideo;
  gotoxy(20,13);
  write('1]  Create New Design.');
  gotoxy(20,15);
  write('2]  Amend or View a Design.');
  gotoxy(20,17);
  write('3]  List Parameters on Printer.');
  gotoxy(20,19);
  write('4]  Exit Program.');
  repeat
    gotoxy(20,21);
    write('Select Option: ');
    read(kbd,ans);
  until ans in ['1'..'4'];
end; {of main_menu}

Procedure display(p : paramrec);
var
  z : integer;

begin
with p do
 begin
  z:=filepos(tempf)+9;
  gotoxy(4,z);write(z-10:2);
  gotoxy(15,z);write(partition);
  gotoxy(27,z);
   case areatype of
    Line : write('Line');
    Box  : write('Box ');
   end;
  gotoxy(36,z); write(tx:3);
  gotoxy(42,z); write(ty:3);
  gotoxy(48,z); write(bx:3);
  gotoxy(54,z); write(by:3);
  gotoxy(60,z); write(Noprint:5);
  gotoxy(71,z);
   case contents of
    Symbolarea : write('Symbol');
    Textarea   : write('Text  ');
   end;
 end; {of with}
end; {of display}


Procedure get_params;
begin
        seek(tempf,cl);
        if cl<filesize(tempf) then
        begin
         read(tempf,param);
         display(param);
         seek(tempf,filepos(tempf)-1);
        end
        else
         FillChar(param,sizeof(param),0);
        val(ans,param.partition,j);
        gotoxy(14,cl+10);
        write(param.partition:2);
        if param.partition<>0 then
        begin
          repeat
            gotoxy(1,8);clreol;
            write('Area Type L)ine or B)ox: ');
            gotoxy(26,cl+10);
            read(kbd,c);
          until c in ['L','l','b','B',^M];
          case c of
           'L','l' : begin
                   param.areatype:=Line;
                   gotoxy(27,cl+10);
                   write('Line');
                 end;
           'B','b' : begin
                   param.areatype:=Box;
                   gotoxy(27,cl+10);
                   write('Box ');
                 end;
           end; {of case}
           with param do
           begin
             case areatype of
              Line : typename:='Start';
              Box  : typename:='Top';
             end; {of case}

             str(tx,s);
             repeat
               gotoxy(1,8);clreol;
               write(typename,' X co-ord');
               getinput(3,36,cl+10,s,'n',fin,1);
               val(s,tx,j);
               gotoxy(36,cl+10);
               write(tx:3);
             until j=0;

             str(ty,s);
             repeat
               gotoxy(1,8);clreol;
               write(typename,' Y co-ord');
               getinput(3,42,cl+10,s,'n',fin,1);
               val(s,ty,j);
               gotoxy(42,cl+10);
               write(ty:3);
             until j=0;


             case areatype of
              Line : typename:='Finish';
              Box  : typename:='Bottom';
             end; {of case}


             str(bx,s);
             repeat
               gotoxy(1,8);clreol;
               write(typename,' X co-ord');
               getinput(3,48,cl+10,s,'n',fin,1);
               val(s,bx,j);
               gotoxy(48,cl+10);
               write(bx:3)
             until j=0;

             str(by,s);
             repeat
               gotoxy(1,8);clreol;
               write(typename,' Y co-ord');
               getinput(3,54,cl+10,s,'n',fin,1);
               val(s,by,j);
               gotoxy(54,cl+10);
               write(by:3);
             until j=0;

             if areatype=Line then
             begin
               Noprint:=FALSE;
               contents:=Null;
               gotoxy(60,cl+10);
               write(Noprint);
               gotoxy(71,cl+10);
               write('None');
             end
             else
             begin
               gotoxy(1,8);clreol;
               Write('Print Box on Label Y/N: ');
               repeat
                gotoxy(60,cl+10);
                read(kbd,c);
               until c in ['Y','N','y','n',^M];
               case  c of
                'Y','y' : Noprint:=FALSE;
                'N','n' : Noprint:=TRUE;
               end; {of case}
               gotoxy(60,cl+10);
               write(Noprint:5);
               gotoxy(1,8);clreol;
               write('Box Contents, S)ymbol or T)ext: ');
               repeat
                 gotoxy(71,cl+10);
                 read(kbd,c);
               until c in ['S','T','s','t',^M];
               case c of
                'S','s' : begin
                            contents:=Symbolarea;
                            gotoxy(71,cl+10);
                            write('Symbol');
                          end;
                'T','t' : begin
                            contents:=Textarea;
                            gotoxy(71,cl+10);
                            write('Text  ');
                          end;
               end; {of case}
             end; {areatype=box}
           end; {of with param}
        end;  {of if not 0}
        write(tempf,param);
  end; {of get_params}
{$I new.dpf}

Procedure Amend_old;
begin
 repeat
  s:='';
  repeat
   clrframe(10,25);
   repeat
    gotoxy(1,8); clreol;
    write('Enter Drive for Design Files: [A,B,C,D,M] ');
    getinput(1,43,8,s,'c',fin,1);
   until s in ['A'..'E','M'];
   labeldrive:=s+':';
   gotoxy(70,3);write(labeldrive);
   gotoxy(1,8);clreol;
   Write('Enter Design Name, or ESC to exit: ');
   gotoxy(1,10);label_name:='';
   write('Design files on ',labeldrive);
   display_files('DSN',11,labeldrive[1]);
   getinput(8,36,8,label_name,'c',fin,1);
   if fin=TRUE then exit;
   assign(paramf,labeldrive+label_name+'.DSN');
   {$I-} reset(paramf); {$I+}
   x:=ioresult;
   if x<> 0 then
   begin
    close(paramf);
    gotoxy(30,8);lowvideo;
    write('Error ',x,' trying to read ',labeldrive,label_name,'.DSN.');
    clreol;
    normvideo;
    delay(2000);
   end;
  until x=0;
  print_header;
  assign(tempf,'M:TEMP.DSN');
  rewrite(tempf);reset(paramf);
  read(paramf,param);
  write(tempf,param);
  while not eof(paramf) do
  begin
    read(paramf,param);
    write(tempf,param);
    display(param);
  end;
  reset(paramf); reset(tempf);
  read(tempf,param);
  ll:=filesize(tempf);;
  fl:=1;
  cl:=1;
  gotoxy(14,3);write(label_name);
  suffix:=param.design_suffix;
  gotoxy(33,3);write(suffix);
  gotoxy(49,3);write(param.label_drop:3:0);
  gotoxy(1,8);clreol;
  write('Two letter extension for design, (AA to ZZ): ');
  getinput(2,45,8,suffix,'c',fin,1);
  gotoxy(33,3);write(suffix);
  str(param.label_drop,dp);
  repeat
    gotoxy(1,8);clreol;
    write('Distance from top off one label to the next in inches: ');
    getinput(5,55,8,dp,'n',fin,1);
    j:=pos('.',dp);
    if j>0 then
     dp:=copy(dp,1,j);
    while dp[1]=' ' do
     dp:=copy(dp,2,length(dp));
    val(dp,drop,j);
  until j=0;
  gotoxy(49,3);write(drop:3:0);
  param.first:=TRUE;
  param.design_name:=label_name;
  param.design_suffix:=suffix;
  param.label_drop:=drop;
  reset(tempf);
  write(tempf,param);
  repeat
   repeat
    param.first:=FALSE;
    gotoxy(1,8);clreol;
    write('Enter Partition, cursor Up/Down, or ESC to exit.');
    gotoxy(15,cl+10);
    read(kbd,ans);
   until ans in [#30,#31,#27,'0'..'2'];
   case ans of
         #30 : begin
                cl:=cl-1;
                if cl<fl then cl:=1;
               end;
         #31 : begin
                cl:=cl+1;
                if cl>ll then
                begin
                 cl:=filesize(tempf);
                 seek(tempf,filesize(tempf));
                 ll:=cl;
                end;
               end;
         '0','1','2' : get_params;
   end; {of case}
  until ans = #27;
  close(tempf);reset(tempf);
  rewrite(paramf);
  param.first:=TRUE;
  read(tempf,param);
  write(paramf,param);
  param.first:=FALSE;
  while not eof(tempf) do
  begin
    read(tempf,param);
    if param.partition <> 0 then
    begin
     write(paramf,param);
     lowvideo;display(param);normvideo;
    end;
  end;
  close(tempf);
  close(paramf);
  repeat
    gotoxy(1,8);clreol;
    write('Another design? Y/N  ');
    read(kbd,ans);
  until ans in ['Y','y','N','n'];
 until ans in ['N','n'];
 ans:='1';
end;  {of amend_old}

BEGIN
 REPEAT
   clrscr;
   inst:=TRUE;
   top:=0; left:=0; bottom:=288; right:=768;
   labeldrive:=''; label_name:='';
   suffix:=''; dp:=''; newdesign:=FALSE;
   gotoxy(19,1);lowvideo;
   writeln(' KENILWORTH Label Design Parameter Program ');
   normvideo;
   gotoxy(1,3);lowvideo;
   write('Design Name: ');normvideo;   {14}
   gotoxy(25,3);lowvideo;
   write('Suffix: ');normvideo;        {33}
   gotoxy(37,3);lowvideo;
   write('Label Drop: ');normvideo;    {49}
   gotoxy(55,3);lowvideo;
   write('Current Drive: ');normvideo; {70}

   clreol;
   gotoxy(1,4);writeln(conststr('~',79));
   gotoxy(1,7);writeln(conststr('*',79));
   gotoxy(1,9);writeln(conststr('*',79));
   gotoxy(30,8); write(version);
   FillChar(param,sizeof(param),0);
   main_menu;
   case ans of
    '1' : create_new;
    '2' : amend_old;
    '3' : print_list;
   end;
 UNTIL ans = '4';
END.
