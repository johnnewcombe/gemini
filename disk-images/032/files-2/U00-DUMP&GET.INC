procedure dumpsvc;
var
  line : string[82];
  screen,ox,oy,ap : integer;
  bt : byte;
  ch : char;

procedure getchar;
begin
   repeat
    bt:=port[$B2];
   until bt and 128 = 0;
   bt:=port[$B1];
   ch:=chr(bt);
end;

begin
 write(chr(27),'?');
 getchar; oy:=ord(ch);
 getchar; ox:=ord(ch);
 getchar; {dummy get of character not required}
 writeln(scdmp,'-',conststr('-',79),'-');
 for screen:=1 to 25 do
 begin
  gotoxy(1,screen);
  write(chr(27),'Z');
  line[0]:=chr(81);
  line[1]:='|';
  line[81]:='|';
  FillChar(line[2],79,' ');
  ap:=2;
  repeat
   getchar;
   if bt<>13 then
    line[ap]:=chr(bt);
   ap:=ap+1;
  until bt=13;
  writeln(scdmp,line);
 end;
 writeln(scdmp,'-',conststr('-',79),'-');
 for screen:=1 to 4 do
  writeln(scdmp,'');
 gotoxy(ox+1,oy+1);
end;  {of dumpsvc}


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
 IF ans IN [^D,esc,cul,cur,cup,cud,ins,del,cr,bs,ch,^G,^A,^F,^V] THEN
   begin
     CASE ans OF
       ^D : dumpsvc;
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
