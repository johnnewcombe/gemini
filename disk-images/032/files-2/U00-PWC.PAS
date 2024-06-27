
program pwc;
type
  str6=string[6];
  str80=string[80];
  str125=string[125];

Const
  esc = #27;  cul = #28;  cur = #29;  cup = #30;  cud = #31;
  ins = #23;  del = #127; cr = #13;  bs = #8;  ch = #25;
  version = 'Version 2.2  17/02/88 ';


var
  pf : file of integer;
  pa : array[1..6] of integer;
  ps : string[6];
  df : File of real;
  inst,
  fin,
  b  : boolean;
  r  : real;
  i  : integer;
  key: string[6];
  ans : char;
  labeldrive : string[2];

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
                VAR line : str6;
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

begin
  clrscr;
  writeln(version);
  labeldrive:='B:';
  inst:=TRUE;
  b:=FALSE; key:='PHILIP';
  assign(df,labeldrive+'PASSWORD.DAT');
  rewrite(df);
  randomize;
  r:=random;
  write(df,r);
  close(df);
  assign(pf,labeldrive+'INDEX.INF');
  rewrite(pf);
  write('Enter Password: ');
  ps:='      ';
  getinput(6,41,17,ps,'a',fin,1);
  for i:=1 to 6 do
    pa[i]:=ord(ps[i])*ord(key[i]);
  for i:=1 to 6 do
    write(pf,pa[i]);
  close(pf);
  clrscr;
end.
