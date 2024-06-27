(*  UpcaseStr converts a string to upper case *)

function UpcaseStr(S : Str80) : Str80;
var
  P : Integer;
begin
  for P := 1 to Length(S) do
    S[P] := Upcase(S[P]);
  UpcaseStr := S;
end;

(*  ConstStr returns a string with N characters of value C *)

function ConstStr(C : Char; N : Integer) : Str132;
var
  S : string[132];
begin
  if N < 0 then 
    N := 0; 
  S[0] := Chr(N); 
  FillChar(S[1],N,C);
  ConstStr := S;
end;

(*  Beep sounds the terminal bell or beeper *)

procedure Beep;
begin
  Write(^G);
end;


procedure InputStr(var S     : AnyStr;
                       L,X,Y : Integer;
                       Term  : CharSet;
                   var TC    : Char    );
const
  UnderScore  =  '_';
var
  P : Integer;
  Ch : Char;
begin
  GotoXY(X + 1,Y + 1); Write(S,ConstStr(UnderScore,L - Length(S)));
  P := 0;
  repeat
    GotoXY(X + P + 1,Y + 1); Read(Kbd,Ch);
    Ch:=Upcase(Ch);
    case Ch of
      #32..#126 : if P < L then
                  begin
                    if Length(S) = L then
                      Delete(S,L,1);
                    P := P + 1;
                    Insert(Ch,S,P);
                    Write(Copy(S,P,L));
                  end
                  else Beep;
      ^S        : if P > 0 then
                    P := P - 1
                  else Beep;
      ^D        : if P < Length(S) then
                    P := P + 1
                  else Beep;
      ^A        : P := 0;
      ^F        : P := Length(S);
      ^G        : if P < Length(S) then
                  begin
                    Delete(S,P + 1,1);
                    Write(Copy(S,P + 1,L),UnderScore);
                  end;
      ^H,#127   : if P > 0 then
                  begin
                    Delete(S,P,1);
                    Write(^H,Copy(S,P,L),UnderScore);
                    P := P - 1;
                  end
                  else Beep;
      ^Y        : begin
                    Write(ConstStr(UnderScore,Length(S) - P));
                    Delete(S,P + 1,L);
                  end;
    else
      if not (Ch in Term) then Beep;
    end;  {of case}
  until Ch in Term;
  P := Length(S);
  GotoXY(X + P + 1,Y + 1);
  Write('' :L - P);
  TC := Ch;
end;


procedure Select(    Prompt : Str80;
                     Term   : CharSet;
                 var TC     : Char    );
var
  Ch : Char;
begin
  GotoXY(1,23); Write(Prompt,'? ' ); ClrEol;
  repeat
    Read(Kbd,Ch);
    TC := Upcase(Ch);
    if not (TC in Term) then
      Beep;
  until TC in Term;
  Write(Ch);
end;

(*  ClearFrame clears the display frame, I.E. Lines 3 to 20 *)

procedure ClearFrame;
var
  I : Integer;
begin
  for I := 3 to 20 do
  begin
    GotoXY(1,I + 1); ClrEol ;
  end;
end;

(*  OutForm displays the entry form on the screen *)

procedure OutForm;
begin
  GotoXY(3,6);  write('Product Code: ');
  GotoXY(24,6); write('PIP Code: ');
  GotoXY(3,8);  write('Description: ');
  GotoXY(3,10); write('Size: ');
  GotoXY(19,10);write('Variety: ');
  GotoXY(38,10);write('Quantity: ');
  GotoXY(3,12); write('Supplier Code: ');
  GotoXY(24,12);write('VAT  Type: ');
  GotoXY(3,14); write('Case Cost: ');
  GotoXY(23,14);write('Case Quantity: ');
  GotoXY(46,14);write('Retail Price each: ');
end;

(*  ClearForm clears all fields in the entry form *)

procedure ClearForm;
begin
  GotoXY(17,6); write('':5);
  GotoXY(34,6); clreol;
  GotoXY(16,8); clreol;
  GotoXY(9,10); write('':8);
  GotoXY(28,10);write('':8);
  GotoXY(48,10);clreol;
  GotoXY(18,12);write('':3);
  GotoXY(35,12);clreol;
  GotoXY(14,14);write('':7);
  GotoXY(38,14);write('':5);
  GotoXY(65,14);clreol;
  GotoXY(3,16);clreol;
end;


procedure InputCust(var Stock : StockRec);
const
  Term : CharSet  =  [^E,^I,^M,^X,^Z,#27];
var
  L, j, i : Integer;
  va : real;
  TC : Char;
  SQty,
  SCaseQty : string[5];

begin
  L := 1; Rcp:=0.0; Rrp:=0.0;
  str(Stock.Qty,SQty);
  if SQty='0' then SQty:='';
  str(Stock.CaseQty,SCaseQty);
  if SCaseQty='0' then SCaseQty:='';
  with Stock do
  repeat
    case L of
      1 : begin
           fin:=false;
           InputStr(ProdCode,5,16,5,Term,TC);
           if TC=#27 then begin fin:=true;exit;end;
          end;
      2 : begin
           fin:=false;
           InputStr(PipCode,6,33,5,Term,TC);
           if TC=#27 then begin fin:=true;exit;end;
          end;
      3 : begin
           fin:=false;
           InputStr(Descript,25,15,7,Term,TC);
           if TC=#27 then begin fin:=true;exit;end;
          end;
      4 : begin
           fin:=false;
           InputStr(Size,8,8,9,Term,TC);
           if TC=#27 then begin fin:=true;exit;end;
          end;
      5 : begin
           fin:=false;
           InputStr(Variety,8,27,9,Term,TC);
           if TC=#27 then begin fin:=true;exit;end;
          end;
      6 : repeat
            fin:=false;
            InputStr(SQty,5,47,9,Term,TC);
            if TC=#27 then begin fin:=true; exit;end;
            val(SQty,Qty,j);
          until j=0;
      7 : begin
           fin:=false;
           InputStr(SupCode,3,17,11,Term,TC);
           if TC=#27 then begin fin:=true;exit;end;
          end;
      8 : begin
           fin:=false;
           InputStr(VatCode,1,35,11,Term,TC);
           if TC=#27 then begin fin:=true;exit;end;
          end;
      9 : repeat
            fin:=false;
            InputStr(Cost,7,13,13,Term,TC);
            if TC=#27 then begin fin:=true;exit;end;
            val(Cost,Rcp,j);
          until j=0;
      10 : repeat
            fin:=false;
            InputStr(SCaseQty,5,37,13,Term,TC);
            if TC=#27 then begin fin:=true;exit;end;
            val(ScaseQty,CaseQty,j);
           until j=0;
      11 : Begin
             repeat
              fin:=false;
              InputStr(RetailPrice,5,64,13,Term,TC);
              if TC=#27 then begin fin:=true;exit;end;
              val(RetailPrice,Rrp,j);
             until j=0;
             if (VatCode>' ') and (Rcp>0.0) and (Rrp>0.0) and (CaseQty>0) then
             begin
               i:=0; va:=0.0; j:=0;
               while (i<10) and (Vatrates[i,0]<>Vatcode) do
               i:=i+1;
               val(VatRates[i,1],va,j);
               if j<>0 then va:=0.0;
               GotoXY(3,16);write('% on Cost: ');
               Rcp:=Rcp/CaseQty;
               write(((Rrp-Rcp-Rcp*va)/Rrp)*100:5:2);
               clreol;
             end;
           end;
    end;

    if (TC = ^I) or (TC = ^M) or (TC = ^X) then
      if L = 11 then
      begin
        L := 1;
        gotoxy(1,23);
        write('Press Ctrl Z to finish');
        clreol;
      end
      else L := L + 1
    else
      if TC = ^E then
        if L = 1 then
          L := 11
        else L := L - 1;
  until TC = ^Z;
end;

(*  OutCust displays the customer data contained in Cust *)

procedure OutCust(var Stock : StockRec);
var
  j, i : integer;

begin
  with Stock do
  begin
    Rcp:=0.0; Rrp:=0.0;
    GotoXY(17,6); Write(ProdCode,'' :5 - Length(ProdCode));
    GotoXY(34,6); write(PipCode); clreol;
    GotoXY(16,8); write(Descript);clreol;
    GotoXY(9,10); write(Size,'':8-Length(Size));
    GotoXY(28,10);write(Variety,'':8-Length(Variety));
    GotoXY(48,10);write(Qty:5); clreol;
    GotoXY(18,12);write(SupCode,'':3-length(SupCode));
    GotoXY(36,12);write(VatCode:1); clreol;
    val(Cost,Rcp,j);
    GotoXY(14,14);write(Rcp:7:2);
    GotoXY(38,14);write(CaseQty:5);
    val(RetailPrice,Rrp,j);
    GotoXY(65,14);write(Rrp:5:2);clreol;
    GotoXY(3,16);clreol;
    if (VatCode>' ') and (Rcp>0.0) and (Rrp>0.0) and (CaseQty>0) then
    begin
      i:=0; va:=0.0; j:=0;
      while (i<10) and (Vatrates[i,0]<>Vatcode) do
      begin
        i:=i+1;
        val(VatRates[i,1],va,j);
        if j<>0 then va:=0.0;
      end;
      write('% on Cost: ');
      Rcp:=Rcp/CaseQty;
      write(((Rrp-Rcp-Rcp*va)/Rrp)*100:5:2);
    end;
  end;
end;
