Program symbedit;
{A program to create symbols}
{ modified 3/10/86}
{ modified to ver 3 24/4/87 to allow for variable scaled symbols}
{$R+}
{$V-}
const
  data = $A1;    status = $A0;    alloc_ = $a3;    copy_ = $85;
  iccol_ = $8d;    icp_ = $96;    icwp_ = $93;    init_ = $a6;
  lrel_ = $9d;    lrels_ = $9e;    lto_ = $80;    lsym_ = $a0; ffill_ = $82;
  mrel_ = $98;    mrels_ = $99;    mto_ = $97;    pfill_ = $82; bfill_ = $B0;
  rfill_ = $81;    sbcol_ = $87;    sccol_ = $89;    sfcol_ = $88;
  scsp_ = $a4;    scwp_ = $a5;    scdp_ = $83;    sstle_ = $8a;
  spcol_ = $BA;  prs_ = $9c;    pat_ = $9a;     red = 4;    blue = 2;
  green = 1;    yellow = 5;    cyan = 3;    magent = 6;    black = 0;
  white = 7;    paint = 8;

  esc = #27;  cul = #28;  cur = #29;  cup = #30;  cud = #31;
  ins = #23;  del = #127; cr = #13;  bs = #8;  ch = #25;
  version = 'Version  3.01 17/02/88';

Label e1;

Type
   charset = set of char;
   str10 = string[10];
   str80 = string[80];
   str14 = string[14];
   str2 = string[2];
   str3  = string[3];
   str4  = string[4];
   str125 = string[125];
   str255 = string[255];

   vecrec = Record
      case  status : integer of
       1,2 : (startx,starty,endx,endy  : integer);
         3 : (lrt, lbtm,llft,ltp : integer);
   end; {of record}

Var
   commandset,editset,quitset : charset;
   cx,cy : integer;          {Current xpos & ypos}
   sx, sy : integer;         {Start xpos & ypos}
   cx1, cy1 : integer;
   by : byte;
   err, a, d, i, j, k : integer;
   Left, Right, Top, Bottom : integer;  {Parameters in actual use }
   Lgleft,Lgright,Lgtop,Lgbottom :integer;       {Parameters for large display}
   Smleft,Smright,Smtop,Smbottom :integer;       {Parameters for small display}
   ac,dn : integer;
   sac,sdn : string[3];
   factor : real;
   command, ans : char;
   up, down, query  : boolean;
   noup, nodown, fin : boolean;
   symname, newname : str10;
   delt, penup : boolean;
   vector : vecrec;
   sf,tf,nf : FILE of vecrec;
   labeldrive : str2;
   f : FILE;
   s : string[1];
   xspd, yspd : integer;     {cursor speed}
   xoff, yoff : integer;     {large screen offset when designing symbol}
   xoffs,yoffs: integer;     {small screen offset when designing symbol}
   scl : real;               {Scale smalldisplay/largedisplay }

{$I disp.sed}
{$I pluto.sed}
{$I utils.sed}
{$I othprocs.sed}
{$I options.sed}

BEGIN           {Main Program Part}
 clrscr;
 gotoxy(26,1);lowvideo;
 write(' KENILWORTH LABEL PROCESSOR ');normvideo;
 gotoxy(29,4);write(version);delay(2000);
 setkeys;
 labeldrive:='B:'; symname:=''; s:='';
 REPEAT
  setup;
  display_command_screen; clrframe;
  yspd:=5;
  xspd:=round(yspd*1.8);
  gotoxy(38,3);
  write(yspd:3);
  gotoxy(1,5);clreol;
  gotoxy(1,6);clreol;
  gotoxy(1,10);write('Symbol Files on drive ',labeldrive,' are listed below:');
  clreol;
  Assign(tf,labeldrive+'TEMP.$$$');
  rewrite(tf);
  display_files('SYM',11,labeldrive[1]);
  gotoxy(1,8);write('Symbol Name: ');clreol;
  display_edit_options;
  symname:='';
  getinput(10,14,8,symname,'c',fin,1);
  kill_edit_options;
    gotoxy(13,3);write(symname+copy('          ',1,10-length(symname)));
  Assign(sf,labeldrive+symname+'.SYM');
  {$I-} reset(sf); {$I+}
  err:=ioresult;
  if err=0 then
  begin
    sccol(green);
    sstle(0);
    gotoxy(1,12);
    read(sf,vector);
    if vector.status=3 then
    with vector do
     begin
        Lgright:=lrt;
        Lgbottom:=lbtm;
        Lgtop:=ltp;
        Lgleft:=llft;
        Smright:=round(Lgright*scl)+xoffs;
        Smleft:=xoffs;
        Smtop:=yoffs;
        Smbottom:=round(Lgbottom*scl)+yoffs;
        display_pluto_screen;
     end
    else
       with vector do
       begin
        status:=3;
        lrt:=Lgright;
        lbtm:=Lgbottom;
        llft:=Lgleft;
        Ltp:=Lgtop;
        write(tf,vector);
       end;

    while not eof(sf) do
    begin
      sccol(green);
      read(sf,vector);
      draw_on_pluto;
      write(tf,vector);
    end;
    reset(tf);
    reset(sf);
    gotoxy(13,3);write(symname+copy('          ',1,10-length(symname)));
  end
  else
  begin
    if err>1then
    begin
     erase(sf);
     Assign(sf,labeldrive+symname+'.SYM');
    end;
    rewrite(sf);
    gotoxy(13,3);write(symname+copy('          ',1,10-length(symname)));
    ac:=0; dn:=0;
    sac:=''; sdn:='';
    repeat
     clrframe;
     gotoxy(1,12);
     writeln('A height and width ratio is required, so give the size');
     writeln('in millimeters, of a typical area for this symbol.');
     writeln('It will be possible to put the symbol into any size of area');
     writeln('but unless the area''s ratio is the same as the symbol, then');
     writeln('the symbol will be distorted. (Press ESC to exit)');
     write('Size in mm across? ');getinput(3,20,17,sac,'n',fin,1);
     if fin then exit;
     gotoxy(1,18);
     write('Size in mm down?   ');getinput(2,20,18,sdn,'n',fin,1);
     if fin then exit;
     gotoxy(1,19);
     write('Is This Correct? (Y/N) ');
     repeat
      gotoxy(24,19);read(kbd,ans);
     until ans IN ['Y','N','y','n'];
     val(sac,ac,i);
     val(sdn,dn,j);
     if (i>0) or (j>0) then
     begin
      write('One of these numbers has an illegal character');
      delay(1500);
     end;
    until (ans IN ['Y','y']) and (i=0) and (j=0);
    Lgright:=round(ac*4.8);
    Lgbottom:=round(dn*2.4);
    if ac>dn then
      factor:=540/Lgright
    else
      factor:=270/Lgbottom;
    Lgright:=round(lgright*factor)+xoff;
    Lgbottom:=round(Lgbottom*factor)+yoff;
    Lgleft:=xoff;
    Lgtop:=yoff;
    with vector do
    begin
      status:=3;
      lrt:=Lgright;
      lbtm:=Lgbottom;
      llft:=Lgleft;
      Ltp:=Lgtop;
      write(tf,vector);
    end;
    Smright:=round(Lgright*scl)+xoffs;
    Smleft:=xoffs;
    Smtop:=yoffs;
    Smbottom:=round(Lgbottom*scl)+yoffs;
    display_pluto_screen;
  end;
  show_function_line;
  show_basic_options;
   REPEAT
    cx1:=0; cy1:=0;
    gotoxy(1,8);write('Option: ');clreol;
    read(kbd,ans);
   CASE ans of
   #28 : begin
          if cx>left then cx1:=-xspd;
          remove_cursor;
          put_cursor;
         end;
   #29 : begin
          if cx<right then cx1:=xspd;
          remove_cursor;
          put_cursor;
         end;
   #30 : begin
          if cy>top then cy1:=-yspd;
          remove_cursor;
          put_cursor;
         end;
   #31 : begin
          if cy<bottom then cy1:=yspd;
          remove_cursor;
          put_cursor;
         end;
   '&' : begin
          if cx>left then cx1:=-xspd;
          if cy>top then cy1:=-yspd;
          remove_cursor;
          put_cursor;
         end;
   '(' : begin
          if cx<right then cx1:=xspd;
          if cy>top then cy1:=-yspd;
          remove_cursor;
          put_cursor;
         end;
   ')' : begin
          if cx>left then cx1:=-xspd;
          if cy<bottom then cy1:=yspd;
          remove_cursor;
          put_cursor;
         end;
   '_' : begin
          if cx<right then cx1:=xspd;
          if cy<bottom then cy1:=yspd;
          remove_cursor;
          put_cursor;
         end;
   'M' : begin
           remove_cursor;
           penup:=not(penup);
           put_cursor;
           gotoxy(68,3);
           if penup=TRUE then write('Move ')
           else write('Draw ');
           gotoxy(2,6);
           if penup=TRUE then write('  Draw            Set  ')
           else write('  Move   Delete  Accept');
         end;
   'D' : begin
          if (penup=FALSE) and (filesize(tf)-1>=0) then
          begin
            remove_cursor;
            seek(tf,filesize(tf)-1);
            read(tf,vector);
            if vector.status=0 then
            repeat
              seek(tf,filepos(tf)-2);
              read(tf,vector);
            until vector.status<>0;
            with vector do
            begin
             moveto(startx+xoff,starty+yoff);
             deleteline(startx+xoff,starty+yoff,endx+xoff,endy+yoff);
            end;
            put_cursor;
          end
         end;
   'A' : write_vector_to_file;
   'F' : begin
          yspd:=yspd+1;
          if yspd>100 then yspd:=100;
          xspd:=round(yspd*1.8);
          gotoxy(38,3);
          write(yspd:3)
         end;
   'T' : begin
          yspd:=yspd-1;
          if yspd<0 then yspd:=0;
          xspd:=round(yspd*1.8);
          gotoxy(38,3);
          write(yspd:3)
         end;
   'E' : begin
          remove_cursor;
          show_edit_options;
          move_through_vectab;
          show_basic_options;
          put_cursor;
         end;
   'Q' : begin
          display_quit_options;
          get_quit_option;
          ans:='Q';
         end;
   'R' : begin
          if (penup=TRUE) and (cx>xoff) and (cy>yoff) then
          begin
            sccol(yellow);
            bfill;
            with vector do
            begin
              status:=2;
              startx:=cx-xoff;
              starty:=cy-yoff;
              endx:=cx-xoff;
              endy:=cy-yoff;
              drawsmall(startx,starty,endx,endy,green);
            end;
            seek(tf,filesize(tf));
            write(tf,vector);
            sx:=cx;
            sy:=cy;
          end;
         end;
    end; {of case}
   UNTIL ans='Q';
   repeat
     gotoxy(1,8);write('Another Symbol? Y/N');clreol;
     read(kbd,ans);
   until ans in ['Y','y','N','n'];
  UNTIL ans in ['N','n'];
  clrscr;
  write(chr(27),'fd');  {Reset function keys to standard settings}
  assign(f,'MENU.COM');
  execute(f);
END.