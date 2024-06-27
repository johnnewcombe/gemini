procedure setscreen(title : str80);

begin
  clrscr;
  gotoxy(26,1);
  lowvideo; write('KENILWORTH LABEL PROCESSOR');
  normvideo;
  gotoxy(trunc((78-length(title))/2),2);
  write(title);
  gotoxy(1,7);writeln(conststr('*',79));
  gotoxy(1,9);writeln(conststr('*',79));
end;

