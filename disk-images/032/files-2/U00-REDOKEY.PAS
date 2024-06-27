Program Redokey;
 { A program to read in each record in the data file and modify
 the key to contain no trailing spaces.}

{$V-}
const
   IndexMax              =  300;
   RecCountErr           =   -2;
   NewFileCreated        =   -1;
   NoError               =    0;
   RecordNotFound        =    1;
   NoMoreRoom            =    2;
   AlreadyExists         =    3;
   OutOfRange            =    4;

   esc = #27;  cul = #28;  cur = #29;  cup = #30;  cud = #31;
   ins = #23;  del = #127;  cr = #13;  bs = #8;  ch = #25;


type
   Keytype        = string[10];
   FileStr        = string[14];
   str80          = string[80];
   MaxPhraseSize  = string[125];

   DataRec = record
      case Boolean of
         TRUE      : (NumRecs    : Integer);
         FALSE     : (Key        : Keytype;
                      phrase     : MaxPhraseSize);
   end; {of record}

   IndexRec  = record
     Key   : KeyType;
     Num   : Integer;
   end; {of record}

   IndexList  =  array[1..IndexMax] of IndexRec;

var
   Klist      :  Indexlist;
   Ifile      :  File of Indexlist;
   Rec,NewRec :  DataRec;
   Dfile      :  File of DataRec;
   MaxRec     :  Integer;
   Up, Down, Noup, NoDown, Done, Query, Fin : Boolean;
   FileName, IndexName   :  FileStr;
   ans        :  char;
   Err,i,j,k  :  integer;
   Item       :  integer;
   tempkey    : string[10];

function ConstStr(C : Char; N : Integer) : MaxPhraseSize;
var
  S : MaxPhraseSize;
begin
  if N < 0 then
    N := 0;
  S[0] := Chr(N);
  FillChar(S[1],N,C);
  ConstStr := S;
end;


Procedure SortIndexList;
var
  I,J,Min : integer;
  Temp    : IndexRec;
Begin
  for I:=1 to MaxRec-1 do
  begin
    Min:=I;
    for J:=I+1 to MaxRec do
      if KList[J].Key < Klist[Min].Key then
        Min:=J;
    Temp:=KList[I];
    KList[I]:=Klist[Min];
    KList[Min]:=Temp;
  end;
End; {of SortIndexList}


PROCEDURE getinput(maxnum : integer;
                ac,dn : integer;
                VAR line : MaxPhraseSize;
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
 gotoxy(60,1);
 lowvideo;
 write('Insert= ',inst);
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
              gotoxy(60,1);
              lowvideo;
              write('Insert= ',inst); clreol;
              normvideo;
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
 gotoxy(60,1);clreol;
END; {of getinput}

BEGIN           {************ Main Part **************}
 clrscr;
 gotoxy(5,10);
 write('Program to amend Key field in RISKSAFT.DAT.');
 assign(Dfile,'RISKSAFT.DAT');
 reset(Dfile);
 seek(dfile,1);
 i:=filesize(dfile)-1;
 k:=1;
 While not eof(dfile) do
 begin
  read(dfile,rec);
  newrec.phrase:=rec.phrase;
  j:=pos(' ',rec.key)-1;
  if j<1 then j:=length(rec.key);
  tempkey:=rec.key;
  rec.key:=copy(rec.key,1,j);
  newrec.key:=rec.key;
  gotoxy(5,12);
  write('Key *',tempkey,'* changed to *',newrec.key,'*');clreol;
  seek(dfile,filepos(dfile)-1);
  write(dfile,newrec);
  gotoxy(5,14);write(k,' done out of ',i);
  k:=k+1;
 end;
 gotoxy(5,16);write('Program finished');
 close(dfile);
END.