program epgraph;
{Test of graphics speed for the KENILWORTH label processor}
Var
   dot_number, n1, n2, c1, c2, lines, inchacross, inchdown : Integer;
begin
writeln(chr(26),'Enter number of inches across the page');
readln(inchacross);
dot_number := inchacross * 120;
writeln('Enter number of inches down the page');
readln(inchdown);
lines := inchdown * 9;
n1:=dot_number MOD 256;
n2:=dot_number DIV 256;
write(lst,chr(27),'3',chr(24));
for c1 := 1 to lines do
begin
     write(lst,chr(27),'L',chr(n1),chr(n2));
     for c2 := 1 to dot_number DIV 2 do
     begin
          write(lst,chr(85),chr(170));
     end;
writeln(lst);
end;
end.


