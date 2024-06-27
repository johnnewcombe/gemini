procedure printerror(s : str80);
var
  ans        : char;

begin
  gotoxy(1,8);
  clreol;
  lowvideo;
  write(chr(7),s,'press <SPACE> to continue ');
  repeat
    read(kbd,ans);
  until ans=' ';
  gotoxy(1,8);
  normvideo;
  clreol;
end;

Procedure Ermsg(e : integer);
var
  tempstr    : str5;

begin
  Case e of

    1 : printerror('File not found, ');

    2,3,4 : printerror('File not open, ');

    $90 : printerror('Record length mismatch, ');

    $91 : printerror('Seek beyond end of file, ');

    $99 : printerror('Unexpected end of file, ');

    $F0 : printerror('Disk full, remove some files, ');

    $F1 : printerror('Disk directory full, remove some files, ');

    $F2 : printerror('File overflow, > 65535 records, ');

    $FF : printerror('File has disappeared! ');

    ELSE
    begin
      str(e,tempstr);
      printerror('ERROR number '+tempstr+', ');
    end;

  end;  {of case}
end; {of Ermsg}

function upcasestr(s : str80) : str80;
var
p          : integer;

begin
  for p:=1 to length(s) do s[p]:=upcase(s[p]);
  upcasestr := s;
end;

function conststr(c : char; n : integer) : str255;
var
s          : str255;

begin
  if n<0 then n:=0;
  s[0]:=chr(n);
  fillchar(s[1],n,c);
  conststr:=s;
end;

function fixlen(s           : str125;
                n           : integer) : str125;
begin
  fixlen:=s+conststr(' ',n-length(s));
end;

function striplen(var line  : str255) : integer;
var
  curpos     : integer;

begin
  curpos:=length(line);
  while (curpos>0) and (line[curpos] in [' ','_']) do
  begin
    delete(line,curpos,1);
    curpos:=pred(curpos);
  end;
  striplen:=curpos;
end;

Procedure options;
begin
  gotoxy(1,8);
  write('Option: ');
  clreol;
end; {of options}

procedure clrframe(t,b : integer);
var i : integer;
begin
  for i:=b downto t do
  begin
   gotoxy(1,i);
   clreol;
  end;
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

const
  Underscore = '_';
  esc = #27;  cul = #28;  cur = #29;  cup = #30;  cud = #31;
  ins = #23;  del = #127; cr = #13;  bs = #8;  ch = #25;

var
    dec,done : boolean;
    pos, xadj, yadj : integer;
 


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
     gotoxy(ac,dn);write(line,ConstStr(Underscore,Maxnum-length(line)));
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
 gotoxy(65,8);
 lowvideo;
 write('Insert Mode'); clreol;
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
                write(line,ConstStr(Underscore,Maxnum-length(line)));
               end;

       del,^G : begin
                if line[pos]='.' then
                  dec:=FALSE;
                delete(line,pos,1);
                gotoxy(ac,dn);
                write(line,ConstStr(Underscore,Maxnum-length(line)));
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
                write(line,ConstStr(Underscore,Maxnum-length(line)));
                pos:=pred(pos);
              end;
        ^A : pos:=1;
        ^F : pos:=length(line)+1;
        ^V : begin
              inst:=not inst;
              gotoxy(65,8);
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
  write(line,ConstStr(' ',Maxnum-length(line)));
 end;
UNTIL fin or done;

Case ans of
cup,cud :   IF ((ans=cup)and(noup=FALSE))or((ans=cud)and(nodown=FALSE))THEN
              done:=TRUE;

       esc : begin
               fin:=TRUE;
             end;

 end;  {of case}
 gotoxy(65,8); clreol;
END; {of getinput}
