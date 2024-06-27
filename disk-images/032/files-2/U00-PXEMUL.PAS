program pxemul; {2/3/87}
{Printronix Emulator for Epson.
 This is to check if a Printronix data file will print
 correctly when there is no Printronix to test it on.}

{$V-,R-}
{$C-} {Turn off check for ^C and ^S. Required to see if a
       key has been pressed to stop printing}

type
  str14 = string[14];
  str10 = string[10];
  str2  = string[2];
  str125 = string[125];
  sixbyte = array[1..256] of byte;

var
  count,i : integer;
  fname : FILE ;
  ans : char;
  WorkDrive : str2;
  rightone : integer;
  sixline : sixbyte;

procedure clrframe(t,b : integer);
var i : integer;
begin
  for i:=t to b do
  begin
   gotoxy(1,i);
   clreol;
  end;
end;

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

Procedure Convert_to_Epson;
type
  bitarray=array[1..768] of byte;
var
  firstbyte : byte;
  dot_array : array[1..8,1..1024] of boolean;
  epsdata : array[1..1024] of byte;
  pdat : byte;
  Data_in_even : boolean;
  vpos, zpos, apos, acount,
  maxpos, line_count : integer;
  oddline,
  evenline : bitarray;
  lastdata : integer;

begin
  Data_in_even:=FALSE;
  line_count:=1;
  firstbyte:=0;
  maxpos:=0;
  FillChar(epsdata,sizeof(epsdata),0);
  Fillchar(dot_array,sizeof(dot_array),0);
  Fillchar(evenline,sizeof(evenline),0);
  Fillchar(oddline,sizeof(oddline),0);
  while not eof(fname) do
  begin
    Blockread(fname,sixline,1);
    for count:=1 to 128 do
      if firstbyte=0 then
        if sixline[count] in [4,5] then
        begin
          firstbyte:=sixline[count];
          zpos:=1;
        end
        else
        begin
          writeln('ERROR IN FILE');
          exit;
        end
        else   {if firstbyte=4 or 5}
        begin
          pdat:=sixline[count];
          case firstbyte of

            4 :
            begin
              case pdat of
             13 : begin     {throw away, next should be 10}
                  end;
             10 : begin         {End of evenline, next should be 5 for odd}
                   firstbyte:=0;
                   data_in_even:=TRUE;
                  end;
            else  begin         { Its an ordinary data byte.}
                    evenline[zpos]:=pdat;
                    zpos:=zpos+1;
                    if zpos>maxpos then maxpos:=zpos;
                  end;
            end; {of case within case}
          end;
      5 : begin
            case pdat of
             13 : begin
                  end;
             10 : begin          {End of line, now combine odd & even}
                    firstbyte:=0;
                    if data_in_even then   {Check its data not blank}
                    begin
                     {convert evenline to dot_array[line_count]}
                     apos:=2; {dot_array position}
                     for acount:=1 to maxpos do
                     begin
                      dot_array[line_count,apos]:=(evenline[acount] and 1)>0;
                      apos:=apos+2;
                      dot_array[line_count,apos]:=(evenline[acount] and 2)>0;
                      apos:=apos+2;
                      dot_array[line_count,apos]:=(evenline[acount] and 4)>0;
                      apos:=apos+2;
                      dot_array[line_count,apos]:=(evenline[acount] and 8)>0;
                      apos:=apos+2;
                      dot_array[line_count,apos]:=(evenline[acount] and 16)>0;
                      apos:=apos+2;
                      dot_array[line_count,apos]:=(evenline[acount] and 32)>0;
                      apos:=apos+2;
                     end;
                     {convert oddline to dot_array[line_count]}
                     apos:=1; {dot_array position}
                     for acount:=1 to maxpos do
                     begin
                      dot_array[line_count,apos]:=(oddline[acount] and 1)>0;
                      apos:=apos+2;
                      dot_array[line_count,apos]:=(oddline[acount] and 2)>0;
                      apos:=apos+2;
                      dot_array[line_count,apos]:=(oddline[acount] and 4)>0;
                      apos:=apos+2;
                      dot_array[line_count,apos]:=(oddline[acount] and 8)>0;
                      apos:=apos+2;
                      dot_array[line_count,apos]:=(oddline[acount] and 16)>0;
                      apos:=apos+2;
                      dot_array[line_count,apos]:=(oddline[acount] and 32)>0;
                      apos:=apos+2;
                     end;
                    end
                    else         {Oddline only means a blank line.}
                     {fill dot_array[line_count] with 0's}
                    begin
                       for apos:=1 to 1024 do
                        dot_array[line_count,apos]:=FALSE;
                    end;
                    Fillchar(evenline,sizeof(evenline),0);
                    Fillchar(oddline,sizeof(oddline),0);
                    line_count:=line_count+1;
                    if line_count=9 then
                    begin    {We must have 8 lines done, so convert to Epson}
                      line_count:=1;
                      lastdata:=0;

             {Now convert dot_array to Epson Data
              Put data into a new array, checking for lastdata.
              If lastdata<>0 then
                Send code for number of bytes in lastdata
                Send data bytes
              Send CR/LF
              Data_in_even:=FALSE.}

                      for apos:=1 to 1024 do
                       begin
                       epsdata[apos]:=0;
                       if dot_array[8,apos] then
                        epsdata[apos]:=epsdata[apos]+1;
                       if dot_array[7,apos] then
                        epsdata[apos]:=epsdata[apos]+2;
                       if dot_array[6,apos] then
                        epsdata[apos]:=epsdata[apos]+4;
                       if dot_array[5,apos] then
                        epsdata[apos]:=epsdata[apos]+8;
                       if dot_array[4,apos] then
                        epsdata[apos]:=epsdata[apos]+16;
                       if dot_array[3,apos] then
                        epsdata[apos]:=epsdata[apos]+32;
                       if dot_array[2,apos] then
                        epsdata[apos]:=epsdata[apos]+64;
                       if dot_array[1,apos] then
                        epsdata[apos]:=epsdata[apos]+128;
                       if epsdata[apos]>0 then lastdata:=apos;
                      end;
                      if lastdata <> 0 then
                      begin
                        lastdata:=1024;
                        write(lst,chr(27),'*',chr(1));
                        write(lst,chr(lastdata MOD 256));
                        write(lst,chr(lastdata div 256));
                        for vpos:=1 to lastdata do
                         write(lst,chr(epsdata[vpos]));
                      end;
                      writeln(lst,'');
                      data_in_even:=FALSE;
                      FillChar(epsdata,sizeof(epsdata),0);
                      Fillchar(dot_array,sizeof(dot_array),0);
                    end; {of if 8 lines}
                  end;  {of 10 in case}
             else  begin        {Its ordinary data}
                      oddline[zpos]:=pdat;
                      zpos:=zpos+1;
                      if zpos>maxpos then maxpos:=zpos;
                   end;
            end; {of case within case}
          end;  {of 5 in main case}
     end; {of main case}
    end;
  end;
end; {of convert_to_epson}

Begin      { *************** Main Part ********************}
  clrscr;
  workdrive:='M:';
  gotoxy(26,1);lowvideo;
  writeln(' KENILWORTH LABEL PROCESSOR ');normvideo;
  gotoxy(1,7);writeln(conststr('*',79));
  gotoxy(1,9);writeln(conststr('*',79));
  gotoxy(26,2);lowvideo;write('Printronix Emulator 7 JAN 88');normvideo;
  clrframe(10,25);
   repeat
     gotoxy(1,8);lowvideo;
     write('Press RETURN when printer is ON LINE, or ESC to exit');
     normvideo;clreol;
     read(kbd,ans);
   until ans in[^M,#27];
   if ans=#27 then exit;
   assign(fname,workdrive+'DUMP6.DAT');
   reset(fname);
   writeln(lst,chr(27),chr(51),chr(24));
   Convert_to_Epson;
   write(lst,chr(12),chr(27),'2');
   clrframe(10,25);
   gotoxy(1,20);
end.