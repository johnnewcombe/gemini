Program menu1;
{$V-,R-}
{ A Main Menu for the suite of label programs.}

Const
  esc = #27;  cul = #28;  cur = #29;  cup = #30;  cud = #31;
  ins = #23;  del = #127; cr = #13;  bs = #8;  ch = #25;
  version = 'Version 2.04  17/02/88';
  labeldrive = 'B:';

Type
   str3 = string[3];
   str2 = string[2];
   str8 = string[8];
   str125 = string[125];
   str14 = string[14];
   str80 = string[80];

Var
   C,ans : char;
   i,j,k : integer;
   f : FILE;
   err : integer;
   df : TEXT;
   filename : str14;
   fin,inst : boolean;

procedure beep;
begin
  write(chr(7));
end;

Procedure Ermsg(e : integer);
var
 z : integer;

begin
  Case e of
  1  : begin
        for z:=1 to 3 do
         write(chr(7));
        gotoxy(10,22);lowvideo;
        write(filename,' requested is not on the drive accessed.');
        clreol;delay(3000);
        gotoxy(10,22);normvideo;clreol;
       end;
 2,3,4 : begin
        for z:=1 to 3 do
         write(chr(7));
        gotoxy(10,22);lowvideo;
        write('File requested is not open.');
        clreol;delay(3000);
        gotoxy(10,22);normvideo;clreol;
       end;
 $90  : begin
        for z:=1 to 3 do
         write(chr(7));
        gotoxy(10,22);lowvideo;
        write('Record length mismatch.  Consult dealer.');
        clreol;delay(3000);
        gotoxy(10,22);normvideo;clreol;
       end;
 $91 : begin
        for z:=1 to 3 do
         write(chr(7));
        gotoxy(10,22);lowvideo;
        write('Seek beyond end of File.  Consult Dealer.');
        clreol;delay(3000);
        gotoxy(10,22);normvideo;clreol;
       end;
 $99 : begin
        for z:=1 to 3 do
         write(chr(7));
        gotoxy(10,22);lowvideo;
        write('Unexpected end of file. File could be blank.');
        clreol;delay(3000);
        gotoxy(10,22);normvideo;clreol;
       end;
 $F0 : begin
        for z:=1 to 3 do
         write(chr(7));
        gotoxy(10,22);lowvideo;
        write('Disk is full. Delete or transfer some files.');
        clreol;delay(3000);
        gotoxy(10,22);normvideo;clreol;
       end;
 $F1 : begin
        for z:=1 to 3 do
         write(chr(7));
        gotoxy(10,22);lowvideo;
        write('Disk Directory is full. Delete or transfer some files.');
        clreol;delay(3000);
        gotoxy(10,22);normvideo;clreol;
       end;
 $F2 : begin
        for z:=1 to 3 do
         write(chr(7));
        gotoxy(10,22);lowvideo;
        write('File size overflow. Only 65535 records allowed.');
        clreol;delay(3000);
        gotoxy(10,22);normvideo;clreol;
       end;
 $FF : begin
        for z:=1 to 3 do
         write(chr(7));
        gotoxy(10,22);lowvideo;
        write('File has disappeared!!! Have you changed disks?');
        clreol;delay(3000);
        gotoxy(10,22);normvideo;clreol;
       end;
 ELSE  begin
        for z:=1 to 3 do
         write(chr(7));
        gotoxy(10,22);lowvideo;
        write('ERROR number ',e,'.  Consult Dealer.');
        clreol;delay(3000);
        gotoxy(10,22);normvideo;clreol;
       end;
end;  {of case}
end; {of Ermsg}

function UpcaseStr(S : Str80) : Str80;
var
  P : Integer;
begin
  for P := 1 to Length(S) do
    S[P] := Upcase(S[P]);
  UpcaseStr := S;
end;

(*  ConstStr returns a string with N characters of value C *)

function ConstStr(C : Char; N : Integer) : Str125;
var
  S : str125;
begin
  if N < 0 then
    N := 0;
  S[0] := Chr(N);
  FillChar(S[1],N,C);
  ConstStr := S;
end;

PROCEDURE getinput(maxnum : integer;
                ac,dn : integer;
                VAR line : str125;
                kind : char;
                VAR fin : boolean;
                start : integer);

      (* Requires global var INST:BOOLEAN set TRUE for INSERT Mode
         or FALSE for OVERWRITE Mode *)

label exit;

const Underscore = '_';

var
    up,down,dec,done : boolean;
    pos, xadj, yadj : integer;
    noup,nodown,query : boolean;


procedure printchar;
begin
 if pos<=maxnum then
 begin
     if length(line)=maxnum then
       delete(line,maxnum,1);
     if inst=TRUE then
      insert(ans,line,pos)
     else
     begin
      if pos>length(line) then
       line:=line+' ';
      line[pos]:=ans;
     end;
 {    gotoxy(ac,dn);write(line,ConstStr(Underscore,Maxnum-length(line)));}
     IF pos<maxnum THEN
       pos:=succ(pos);
 end;
end;

BEGIN
 dec:=FALSE;
 for pos:=1 to length(line) do
   if line[pos]='.' then
    dec:=TRUE;
 fin:=FALSE;
 done:=FALSE;
 up:=FALSE;
 down:=FALSE;
 if start>maxnum THEN start:=maxnum;
 ans:=' ';
 pos:=start;
 gotoxy(65,17);
 lowvideo;
 if inst=TRUE then
  write('Insert Mode')
 else write('Overwrite Mode');
 clreol;
 normvideo;
 gotoxy(ac,dn);write(line,ConstStr(Underscore,Maxnum-length(line)));

 REPEAT
 if pos>80 then
 begin
   xadj:=80; yadj:=1;
 end
 else
 begin
   xadj:=0; yadj:=0;
 end;
 gotoxy(ac+pos-1-xadj,dn+yadj);read(kbd,ans);
 IF ans IN [esc,cul,cur,cup,cud,ins,del,cr,bs,ch,^G,^A,^F,^V] THEN
   begin
     CASE ans OF
       esc : begin
              fin:=TRUE;
              goto exit;
             end;

      cr     : begin
                done:=TRUE;
                goto exit;
               end;

    cup,cud : begin
              done:=true;
              IF (ans=cup)and(noup=FALSE) THEN
              begin
               up:=TRUE;
               goto exit;
              end;
              IF (ans=cud)and(nodown=FALSE) THEN
              begin
               down:=TRUE;
               goto exit;
              end;
              done:=FALSE;
             end;

       cul : IF pos>1 THEN
             begin
              pos:=pred(pos);
              gotoxy(ac+pos-1,dn);
             end;

       cur : IF pos<=length(line) THEN
              begin
                pos:=succ(pos);
                gotoxy(ac+pos-1,dn);
              end;

       ins : begin
                insert(' ',line,pos);
                gotoxy(ac,dn);
 {               write(line,ConstStr(Underscore,Maxnum-length(line)));}
               end;

       del,^G : begin
                if line[pos]='.' then
                  dec:=FALSE;
                delete(line,pos,1);
                gotoxy(ac,dn);
{                write(line,ConstStr(Underscore,Maxnum-length(line)));  }
               end;

        ch : begin
               write(ConstStr(Underscore,length(line)-pos+1));
               Delete(line,pos,maxnum);
             end;
        bs : IF pos<>1 THEN
              begin
                IF line[pos-1]='.' THEN
                  dec:=FALSE;
                delete(line,pos-1,1);
                gotoxy(ac,dn);
{                write(line,ConstStr(Underscore,Maxnum-length(line)));}
                pos:=pred(pos);
              end;
        ^A : pos:=1;
        ^F : pos:=length(line)+1;
        ^V : begin
              inst:=not inst;
              gotoxy(65,22);
              lowvideo;
              case inst of
              TRUE : write('Insert Mode');
              False: write('Overwrite Mode');
              end;
              normvideo;
              clreol;
             end;
     end; {of CASE }
   end
 ELSE
 begin

 CASE kind OF

   'a' : IF ans IN [' '..'/',':'..'~'] THEN
             printchar;

   'n' : IF ans IN ['0'..'9','-','.'] THEN

           Case ans of
             '0'..'9' :  printchar;

             '-' :  IF pos=1 THEN printchar;

             '.' : IF not dec THEN
                   begin
                    printchar;
                    dec:=TRUE;
                   end;
           end; {of case}

  'b' : IF ans IN [' '..'~'] THEN
                printchar;

  'c' : IF ans IN [' '..'~'] THEN
         begin
           IF ans IN ['a'..'z'] THEN
            ans:=chr(ord(ans)-$20);
           printchar;
         end;

  's' : IF ans IN ['A'..'Z','0'..'9','a'..'z','%','.',':','-',' ','/'] THEN
         begin
           IF ans IN ['a'..'z'] THEN
            ans:=chr(ord(ans)-$20);
           printchar;
         end;

 end; {of case}
 end;
exit:
 if ans in [cr,esc] then
 begin
  gotoxy(ac,dn);
{  write(line,ConstStr(' ',Maxnum-length(line)));}
 end;
UNTIL fin or done;

Case ans of
cup,cud :   IF ((ans=cup)and(noup=FALSE))or((ans=cud)and(nodown=FALSE))THEN
              done:=TRUE;

       esc : begin
               fin:=TRUE;
             end;

 end;  {of case}
 gotoxy(65,22); clreol;
END; {of getinput}

procedure clrframe(t,b : integer);
var i : integer;
begin
  for i:=t to b do
  begin
   gotoxy(1,i);
   clreol;
  end;
end;

procedure utilities;
begin
  clrframe(4,25);
  gotoxy(32,5);lowvideo;
  write(' Utilities  Menu ');normvideo;
  gotoxy(20,7); lowvideo;
  write(' 1] ');normvideo;
  write('  Compose Label Contents.');
  gotoxy(20,9); lowvideo;
  write(' 2] ');normvideo;
  write('  Print One of Each Label.');
  gotoxy(20,11); lowvideo;
  write(' 3] ');normvideo;
  write('  Design or Modify a Symbol.');
  gotoxy(20,13); lowvideo;
  write(' 4] ');normvideo;
  write('  Design or Modify a Font.');
  gotoxy(20,15);lowvideo;
  write(' 5] ');normvideo;
  write('  Maintain Database.');
  gotoxy(20,17);lowvideo;
  write(' 6] ');normvideo;
  write('  Exit this Menu.');
  repeat
    gotoxy(20,21);
    write('Select: ');clreol;
    read(kbd,ans);
   case ans of
   '1' : begin
           assign(f,'ULC.COM');
           {$i-} execute(f); {$I+}
           err:=ioresult;
           if err>0 then
           ermsg(err);
           exit;
         end;
   '2' : begin
           assign(f,'ULM.COM');
           {$i-} execute(f); {$I+}
           err:=ioresult;
           if err>0 then
           ermsg(err);
           exit;
         end;
   '3' : begin
           assign(f,'SYMBEDIT.COM');
           {$i-} execute(f); {$I+}
           err:=ioresult;
           if err>0 then
           ermsg(err);
           exit;
         end;
   '4' : begin
           assign(f,'FONTEDIT.COM');
           {$i-} execute(f); {$I+}
           err:=ioresult;
           if err>0 then
           ermsg(err);
           exit;
         end;
   '5' : begin
           assign(f,'PHRASES.COM');
           {$I-} execute(f);  {$I+}
           err:=ioresult;
           if err>0 then
           ermsg(err);
           exit;
         end;
   end; {of case}
  until ans='6';
end;  {of utilities}

procedure get_paswd;
var
  pf : file of integer;
  pa : array[1..6] of integer;
  ps : string[6];
  df : File of real;
  fin,
  b  : boolean;
  r  : real;
  i  : integer;
  key: string[6];
begin
  b:=FALSE; key:='PHILIP';
  assign(df,labeldrive+'PASSWORD.DAT');
  rewrite(df);
  randomize;
  r:=random;
  write(df,r);
  close(df);
  assign(pf,labeldrive+'INDEX.INF');
  {$I-} reset(pf); {$I+}
  i:=ioresult;
  if i<>0 then
  begin
    gotoxy(25,17);
    write(i,' Password File has been removed or corrupted. ');
    repeat beep until b=true;
  end;

  for i:=1 to 6 do
   read(pf,pa[i]);
  close(pf);
  GotoXY(25,17);
  write('Enter Password: ');
  ps:='______';
  getinput(6,41,17,ps,'a',fin,1);
  for i:=1 to 6 do
    if pa[i]<>ord(ps[i])*ord(key[i]) then
     b:=TRUE;
  if b=TRUE then
  begin
   gotoxy(25,17);clreol;
   write('PASSWORD ERROR!     PRESS RESET!');
   repeat beep Until b=FALSE;
  end;
end;

BEGIN
  clrscr;
  write(chr(27),'f');
  write(chr($8B),'');  {Disable EDIT Key}
  write(chr($C0));
  gotoxy(26,1);lowvideo;writeln(' KENILWORTH LABEL PROCESSOR ');
  normvideo; gotoxy(30,2);write(version);
  repeat
    clrframe(3,25);
    gotoxy(1,3);writeln(conststr('*',79));
    gotoxy(34,5);lowvideo;write(' Main Menu ');normvideo;
    gotoxy(25,7);lowvideo;
    write(' Press <RETURN> to  Print Labels'); normvideo;
    gotoxy(25,8);
    write('        Or select option.');
    gotoxy(25,11);lowvideo;
    write(' 1] ');normvideo;
    write('     Utilities.');
    gotoxy(25,13);lowvideo;
    write(' 2] ');normvideo;
    write('     Return to CP/M');
    gotoxy(25,15);lowvideo;
    write(' 3] ');normvideo;
    write('     Close Down');
    repeat
      gotoxy(25,17);
      write('Select: ');
      read(kbd,C);
    until C in ['1','2','3',^M];
    case C of
      ^M : begin
             assign(f,'ULP.COM');
             {$i-} execute(f); {$I+}
             err:=ioresult;
             if err>0 then
              ermsg(err);
           end;
     '1' : begin
             get_paswd;
             utilities;
           end;
     '2' : get_paswd;
     '3' : begin
            assign(f,'A:PARK.COM');
            {$I-} execute(f); {$I+}
            if ioresult <>0 then
            begin
             clrscr;
             write('Now switch off computer.');
             repeat until C ='Y';
            end;
           end;
    end; {of case};
  until C in ['2'];
  clrscr;
  write('Press Reset to re-start Labelling System.');
END.
