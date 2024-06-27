procedure show_function_line;
begin
  gotoxy(1,5);clreol;gotoxy(1,6);clreol;
  lowvideo;
  gotoxy(4,5);write(' F0 ');
  gotoxy(12,5);write(' F1 ');
  gotoxy(20,5);write(' F2 ');
  gotoxy(28,5);write(' F3 ');
  gotoxy(36,5);write(' F4 ');
  gotoxy(44,5);write(' F5 ');
  gotoxy(52,5);write(' F6 ');
  gotoxy(60,5);write(' F7 ');
  gotoxy(68,5);write(' F8 ');
  gotoxy(76,5);write(' F9 ');
  normvideo;
end; {show_function_line}

procedure show_basic_options;
begin
  gotoxy(2,6);
  penup:=TRUE;
  write('  Draw             Set    Edit    Fast    Slow    Quit          ');
  write('  Fill         ');clreol;
end;

procedure show_edit_options;
begin
  gotoxy(2,6);
  write('                 Delete           Find            Quit          ');
  write('               ');clreol;
end;  {of show_edit_options}

procedure display_quit_options;
begin
  gotoxy(2,6);
  write('                                                          Save  ');
  write(' Rename   Abort');clreol;
end;  {of display_quit_options}

procedure dispose_of(filname : str14);
var
  fil : file;
begin
  assign(fil,filname);
  {$I-} reset(fil); {$I+}
  if ioresult=0 then
   begin
    close(fil); erase(fil);
   end;
end;

procedure get_quit_option;
begin
 repeat
   gotoxy(1,8);write('Option: ');clreol;
   read(kbd,command);
 until command in quitset;
 case command of
 'S' : begin
        if filesize(sf)>0 then
        begin
          dispose_of(labeldrive+':'+symname+'.BAK');
          close(sf);
          rename(sf,labeldrive+':'+symname+'.BAK');
          assign(sf,labeldrive+':'+symname+'.SYM');
        end;
        rewrite(sf); reset(tf);
        while not eof(tf) do
        begin
          read(tf,vector);
          if vector.status<>0 then
           write(sf,vector);
        end;
        close(sf);
        close(tf);
        erase(tf);
       end;
 'R' : begin
        gotoxy(1,8);write('New File Name: ');clreol;
        display_edit_options;
        newname:='';
        getinput(10,16,8,newname,'c',fin,1);
        kill_edit_options;
        close(sf);
        assign(nf,newname+'.SYM');
        rewrite(nf); reset(tf);
        while not eof(tf) do
        begin
          read(tf,vector);
          if vector.status<>0 then
           write(nf,vector);
        end;
        close(nf);
        close(tf);
        erase(tf);
       end;
 'a' : begin
        close(sf);
        if filesize(sf)=0 then
         erase(sf);
        close(tf);
        erase(tf);
       end;
 end; {of case}
end;  {of get_quit_option}
