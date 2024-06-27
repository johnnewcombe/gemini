procedure clrframe;
var i : integer;
begin
  for i:=10 to 24 do
  begin
   gotoxy(1,i);
   clreol;
  end;
end;

procedure display_edit_options;
begin
  gotoxy(10,20);
  write('^A = Start of line. ^F = End of line. ^V = Toggle Insert on/off.');
  gotoxy(10,21);
  write('^Y = Kill to end of line. Del = Delete character to right.');
  gotoxy(10,22);
  write('Back Space Deletes character to left and moves cursor.');
  gotoxy(10,23);
  write('Left & Right cursor arrows move one character at a time.');
end;

procedure kill_edit_options;
var
 i : integer;
begin
 for i:=20 to 23 do
 begin
   gotoxy(1,i);clreol;
 end;
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

label exit;

const Underscore = '_';

var
    inst,dec,done : boolean;
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
 dec:=FALSE; inst:=TRUE;
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
 IF ans IN [esc,cul,cur,cup,cud,ins,del,cr,bs,ch,'?',^G,^A,^F,^V] THEN
   begin
     CASE ans OF
       esc : begin
              fin:=TRUE;
              goto exit;
             end;

      cr,'?' : begin
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
UNTIL fin or done;

Case ans of
cup,cud :   IF ((ans=cup)and(noup=FALSE))or((ans=cud)and(nodown=FALSE))THEN
              done:=TRUE;

       esc : begin
               fin:=TRUE;
             end;

       '?' : IF kind='n' THEN
              query:=TRUE
             ELSE
             IF kind IN ['a'..'c'] THEN
             printchar;
 end;  {of case}
 gotoxy(65,8); clreol;
END; {of getinput}



Procedure remove_cursor;
begin
 case penup of
 TRUE: begin
           sstle(6);
           sccol(yellow);
           moveto(cx-5,cy);
           lto(cx+5,cy);
           moveto(cx,cy-4);
           lto(cx,cy-1);
           moveto(cx,cy+1);
           lto(cx,cy+4);
           sstle(0);
         end;
 FALSE: begin
           sstle(6);
           sccol(yellow);
           moveto(sx,sy);
           lto(cx,cy);
           sstle(0);
         end;
 end; {of case}
end;

procedure put_cursor;
begin
 case penup of
 TRUE: begin
           sstle(4);
           sccol(blue);
           cx:=cx+cx1;
           if cx<=left then cx:=left+1;
           if cx>=right then cx:=right-1;
           cy:=cy+cy1;
           if cy<=top then cy:=top+1;
           if cy>=bottom then cy:=bottom-1;
           moveto(cx-5,cy);
           lto(cx+5,cy);
           moveto(cx,cy-4);
           lto(cx,cy-1);
           moveto(cx,cy+1);
           lto(cx,cy+4);
           moveto(cx,cy);
           sstle(0);         {standard mode}
         end;
 FALSE: begin
           sstle(4);
           sccol(blue);
           cx:=cx+cx1;
           if cx<=left then cx:=left+1;
           if cx>=right then cx:=right-1;
           cy:=cy+cy1;
           if cy<=top then cy:=top+1;
           if cy>=bottom then cy:=bottom-1;
           moveto(sx,sy);
           lto(cx,cy);
           sstle(0);
         end;
 end; {of case}
end;



procedure setkeys;
begin
  write(chr(27),'f');
  write(chr($81),'M');
  write(chr($82),'D');
  write(chr($83),'A');
  write(chr($84),'E');
  write(chr($85),'F');
  write(chr($86),'T');
  write(chr($87),'Q');
  write(chr($88),'S');
  write(chr($89),'R');
  write(chr($8A),'a');
  write(chr($A0),'&');
  write(chr($A1),chr(30));
  write(chr($A2),'(');
  write(chr($A4),chr(28));
  write(chr($A6),chr(29));
  write(chr($A8),')');
  write(chr($A9),chr(31));
  write(chr($AA),'_');
  write(chr($C0));
 end;


Procedure setup;
begin
 initialise;
 xoff:=10; yoff:=6;
 xoffs:=600; yoffs:=6;
 Lgleft:=9; Lgright:=550;
 Lgtop:=5; Lgbottom:=283;
 cx:=10; cy:=6; sx:=10; sy:=6;
 scl:=125/540;
 symname:='';
 penup:=TRUE;
 commandset:=['M','D','A','E','Q','F','T','R'];
 quitset:=['S','R','a'];
 spcol(green);
 sbcol(white);
end;

Procedure Display_command_screen;
begin
 clrscr;
 gotoxy(24,1);lowvideo;
 writeln(' KENILWORTH LABEL SYMBOL CREATOR ');
 normvideo;
 gotoxy(6,3);lowvideo;write('Symbol');normvideo;
 gotoxy(25,3);lowvideo;write('Cursor Speed');normvideo;
 gotoxy(63,3);lowvideo;write('Mode');normvideo;
 gotoxy(1,4);writeln(conststr('~',79));
 gotoxy(1,7);writeln(conststr('*',79));
 gotoxy(1,8);lowvideo;writeln('Option: ');normvideo;
 gotoxy(1,9);writeln(conststr('*',79));
 gotoxy(13,3);write(symname+copy('          ',1,10-length(symname)));
 if penup then
  begin gotoxy(68,3);write('Move '); end
 else
  begin gotoxy(68,3);write('Draw '); end;
 xspd:=0; yspd:=0;
 gotoxy(38,3);write(yspd:3);
end; {of display_command_screen}
