Program Phrases;
 { A program to create a data file of Safety and Risk phrases
   for the PLUTO version of the labelling program.  The file
   is a file of records comprising an index field which is the
   Safety or Risk phrase number, and a string of 125 characters.
   The maximum length of a phrase is at the moment 110 characters.
   There are a few combination phrases available is as per the
   official list of phrases, e.g. S36/37.}
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
   labeldrive            =    'B:';
   esc = #27;  cul = #28;  cur = #29;  cup = #30;  cud = #31;
   ins = #23;  del = #127;  cr = #13;  bs = #8;  ch = #25;
   version = 'Version 2.02  17/02/88';

type
   Keytype        = string[10];
   FileStr        = string[14];
   str80          = string[80];
   str3           = string[3];
   str8           = string[8];
   str2           = string[2];
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

   labelcont = record
         stat : boolean;
         area,
         across,
         down : integer;
         scale : real;
         font : string[14];
         pen : byte;
         mode : char;
         key : keytype;
         modif : byte;
         text : string[125];
    end;  {of record}

    Dimension = (Line, Box);
    picture = (Symbolarea, Textarea, Null);

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

(*   labelpointer = ^labelrecord;
   labelrecord =record
             name : string[8];
             next : labelpointer
             end;

   udpointer = ^ud;
   ud = record
          name : keytype;
          next : udpointer;
        end;
  *)

var
   Klist      :  Indexlist;
   Ifile      :  File of Indexlist;
   Rec        :  DataRec;
   Dfile      :  File of DataRec;
   MaxRec     :  Integer;
   Up, Down, Noup, NoDown, Done, Query, Fin : Boolean;
   FileName, IndexName   :  FileStr;
   ans        :  char;
   Err,i      :  integer;
   Item       :  integer;
   f          :  FILE;
   udfile     :  File of keytype;
   date       :  keytype;
   bt         :  byte;
   lf         :  FILE of labelcont;
   lab        :  labelcont;
   print_label_name : boolean;
   paramf : FILE of paramrec;
   param : paramrec;
   design_name : string[8];
   udcount : integer;
   uddat : array[1..300] of keytype;
   labcount : integer;
   labdat : array[1..500] of string[8];
   file_to_check : boolean;

Procedure clrframe(t,b : integer);
var
  i : integer;
begin
  for i:=t to b do
  begin
    gotoxy(1,i);
    clreol;
  end;
end;

{$I utils.phr}
{$I add.phr}
{$I del.phr}
{$I amend.phr}
{$I print.phr}
{$I disp.phr}

Procedure Print_List;
label skip;
Var
 (* labheaptop,udheaptop : ^integer;
  firstlabel, lastlabel,newlabel : labelpointer;
  firstud, lastud, newud, nextud : udpointer; *)
  dma : string[129]; {Location to store portion of DIR read in}
  filename : filestr;
  fcb : array[1..12] of byte absolute $5c;  {Location filename is stored}
  x,j,k,entry :integer;
  drivenum : char;
  xx : FILE;
  ln : string[8];
  ext : string[3];
  drv : char;
  udcount : integer;


procedure get_design;

begin
  clrframe(10,25);
  gotoxy(1,8); clreol;
  write('Select a label design, or <ESC> to exit: ');
  gotoxy(1,10);writeln('Designs available: ');
  display_files('DSN',11,'B');
  repeat
    design_name:='';
    getinput(8,41,8,design_name,'c',fin,1);
    assign(paramf,labeldrive+design_name+'.DSN');
    {$I-} reset(paramf); {$I+}
  until (ioresult=0) or (fin=TRUE);
  if fin=TRUE then exit;
  read(paramf,param);
  ext:='L'+param.label_extension;
end;  {of get_design}

procedure get_drive;
var
 d : str8;
begin
 clrframe(10,25);
 repeat
  d:='';
  gotoxy(1,8);clreol;
  write('Enter Drive to be searched for affected labels: ');
  getinput(1,50,8,d,'c',fin,1);
 until d in ['A'..'E','M'];
 drv:=d[1];
end;

procedure dump_udfile;
begin
 udcount:=0;
 reset(udfile);
 read(udfile,date);
 while not eof(udfile) do
 begin
   udcount:=udcount+1;
   read(udfile,uddat[udcount]);
 end;
end;  {of dump_udfile}


procedure printit;
begin
    labcount:=labcount+1;
    entry:=(x*32)+1;                   {uses 32 bytes. The first 12  }
    ln:=copy(dma,entry+1,8);           {give the drive, name & extension.}
    ln:=copy(ln,1,pos(' ',ln)-1);
    write(ln:10);
    labdat[labcount]:=ln;
end;  {of print_it}

procedure dump_label_names;
begin
 labcount:=0;
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
   repeat
     x:=bdos($12);             {Find next entry ......}
     if x<>255 THEN
      printit;
     if keypressed then x:=255;
   until (x=255); {.... until no more found}
 end;
end; {of dump_label_names}

procedure check_against_changes;
begin
 for i:=1 to udcount do
 begin
   if lab.key=uddat[i] then
   begin
    if print_label_name=TRUE then
    begin
     write(lst,'Label ',drv,':',labdat[j]);
     writeln(lst,' The following entry(s) on the label need checking :');
     print_label_name:=FALSE;
    end;
    writeln(lst,'          ',uddat[i]);
   end;
 end;
end;  {of check_against_changes}

begin  {Print_List}
  gotoxy(1,1);lowvideo;write(' LIST');normvideo;
  clrframe(3,25);
  {$I-} reset(udfile); {$I+}
  if (ioresult>0) or (filesize(udfile)<2) then
  begin
   gotoxy(1,8); write('No changes to be listed.');clreol;
   delay(2000);
   exit;
  end;
  gotoxy(1,7);writeln(conststr('*',79));
  gotoxy(1,9);writeln(conststr('*',79));
  dump_udfile;
  repeat
    get_design;
    if fin=TRUE then exit;
    get_drive;
    if fin=TRUE then exit;
    write(lst,chr(12));
    write(lst,'LABELS AFFECTED BY CHANGES DATED: ');
    writeln(lst,date,'  Label Design= ',design_name,', On Drive= ',drv);
    writeln(lst,conststr('*',79));
    clrframe(10,25);
    dump_label_names;
    for j:=1 to labcount do
    begin
      gotoxy(1,8);
      write('Checking Label ',labdat[j]);clreol;
      print_label_name:=true;
      assign(lf,drv+':'+labdat[j]+'.'+ext);
      {$I-} reset(lf); {$I+}
      k:=ioresult;
      if k>0 then
      begin
       gotoxy(1,8);clreol;
       write('ERROR ',k,' opening label ',drv,':',labdat[j],'.',ext);
       delay(2000);
       goto skip;
      end;
      while not eof(lf) do
      begin
       read(lf,lab);
       if lab.key<>'' then
        check_against_changes;
      end;
      if print_label_name=FALSE then
       writeln(lst,conststr('-',79));
skip:
    end; {of for loop}
    clrframe(10,25);
    repeat
     gotoxy(1,8);clreol;
     write('Do you wish to check another drive or label design? Y/N ');
     read(kbd,ans);
    until ans in ['Y','y','N','n'];
  until ans in ['N','n'];
  repeat
    gotoxy(1,9);clreol;
    write('Do you wish to save changes for checking later? Y/N ');
    read(kbd,ans);
  until ans in ['Y','y','N','n'];
  close(udfile);
  if ans in ['N','n'] then
  begin
   erase(udfile);
   file_to_check:=FALSE;
  end;
  writeln(lst,conststr('*',79));
end;   {or Print_List}

Procedure PrintArray;
begin
  gotoxy(1,6);
  for i:=1 to MaxRec do
    writeln(Klist[i].key,'--',Klist[i].Num);
  read(kbd,ans);
end;


BEGIN {  Main Part  }
  clrscr;
  file_to_check:=FALSE;
  FileName:='RISKSAFT.DAT';
  gotoxy(23,1);lowvideo;
  write(' KENILWORTH LABEL DATABASE EDITOR ');normvideo;
  gotoxy(29,2);write(version);
  normvideo;
  repeat
    gotoxy(1,4);
    write('Put plain paper in printer. Press ESC when printer is ready.');
    read(kbd,ans);
  until ans=#27;
  gotoxy(1,4);clreol;
  write('Enter Date: ');
  repeat
    date:='';
    getinput(8,13,4,date,'c',fin,1);
  until date<>'';
  gotoxy(1,4);clreol;write(' Opening File. Please wait..');
  assign(udfile,labeldrive+'CHANGES.DAT');
  {$I-} reset(udfile); {$I+}
  if ioresult=0 then
  begin
   gotoxy(1,4);clreol;
   writeln('A file of database changes exists. You must print list of ');
   writeln('labels affected before doing more changes. Continue? Y/N  ');
   repeat
     gotoxy(65,5);read(kbd,ans);
   until ans in ['Y','y','N','n'];
   if ans in ['Y','y'] then Print_List
   else
   begin
     close(udfile);clrscr;exit;
   end;
  end;
  {$I-} rewrite(udfile); {$I+}
  if ioresult>0 then
  begin
   close(udfile); erase(udfile);
   assign(udfile,labeldrive+'CHANGES.DAT');
   rewrite(udfile);
  end;
  write(udfile,date);

REPEAT
  clrscr;
  FileName:='RISKSAFT.DAT';
  gotoxy(23,1);lowvideo;
  write(' KENILWORTH LABEL DATABASE EDITOR ');normvideo;
  gotoxy(29,2);write(version);
  normvideo;
  gotoxy(1,4);clreol; gotoxy(1,5);clreol;
  gotoxy(38,4);
  write('MENU');
  gotoxy(30,6);write('1]  Add Phrases.');
  gotoxy(30,8);write('2]  Delete Phrases.');
  gotoxy(30,10);write('3]  Amend Phrases.');
  gotoxy(30,12);write('4]  Print Phrases.');
  gotoxy(30,14);write('5]  List Labels Affected.');
  gotoxy(30,16);write('6]  Exit Program.');
  repeat
    gotoxy(30,18);read(kbd,ans);
  until ans In ['0'..'6'];

  Case ans of
   '0' : PrintArray;
   '1' : AddPhrase;
   '2' : DeletePhrase;
   '3' : AmendPhrase;
   '4' : PrintPhrases;
   '5' : Print_List;
  end; {of case}
UNTIL ans ='6';
if file_to_check=TRUE then
begin
  clrframe(3,25);
  gotoxy(10,20);
  writeln('List of affected labels must be done before more changes ');
  writeln('          are done the next time this program is used.');
  delay(3000);
  close(udfile);
end;
assign(f,'MENU.COM');
execute(f);
END.