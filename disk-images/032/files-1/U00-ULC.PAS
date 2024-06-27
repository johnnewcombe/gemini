program ULC;  {Universal Label Creation  6/10/86}

{ Label Creation program based on WLC & ULP }

{$R-}
{$V-}
{$I header.ulc}
{$I pluto.ulc}
{$I disp.ulc}
{$I utils1.ulc}
{$I utils2.ulc}
{$I enter.ulc}
{$I edit.ulc}
{$I utils3.ulc}

begin    { main part }
 clrscr;
 labeldrive:='B:'; workdrive:='M:';
 gotoxy(26,1);lowvideo;
 writeln(' KENILWORTH LABEL PROCESSOR ');
 normvideo;
 gotoxy(1,7);writeln(conststr('*',79));
 gotoxy(1,9);writeln(conststr('*',79));
 FillChar(Rec.Key,SizeOf(Rec.Key),0);
 gotoxy(29,8);write(version); delay(2000);
 get_design;
 if fin=TRUE then goto out;
 clrframe(10,25);
 setup;
 setkeys;
 FillChar(KList,SizeOf(KList),0);
 MakeIndex;
 show_function_line;
 labname:='NONE';
 Key_info(6,CurrentLb);
 REPEAT
  REPEAT
    if opmode<>Move then
    begin
      Key_use(Move);
      for ifnm:=CurrentAr to CurrentPn do
       Key_info(5,ifnm);
    end;
    cx1:=0; cy1:=0;
    options;
    if labname='NONE' then
     ans:=^L
    else
     read(kbd,ans);
    wait;
   CASE ans of
   #28 : begin
          if cx>left then cx1:=-1;
          remove_cursor;
          put_cursor;
         end;
   #22 : begin
          if cx>left then cx1:=-jumpx;
          remove_cursor;
          put_cursor;
         end;
   #29 : begin
          if cx<right then cx1:=1;
          remove_cursor;
          put_cursor;
         end;
   #23 : begin
          if cx<right then cx1:=jumpx;
          remove_cursor;
          put_cursor;
         end;
   #30 : begin
          if cy>top then cy1:=-1;
          remove_cursor;
          put_cursor;
         end;
   #11 : begin
          if cy>top then cy1:=-jumpy;
          remove_cursor;
          put_cursor;
         end;
   #31 : begin
          if cy<bottom then cy1:=1;
          remove_cursor;
          put_cursor;
         end;
   #14 : begin
          if cy<bottom then cy1:=jumpy;
          remove_cursor;
          put_cursor;
         end;
   ^T  : begin          {Text}
          if param.contents=SymbolArea then
          begin
           Key_use(EntSy);
           load_symbol
          end
          else
          begin
           curmode:='T';
           enter_text;
          end;
         end;
   ^E  : begin
          if labname<>'NONE' then
           edit_label
          ELSE
          begin
            gotoxy(1,8);lowvideo;
            write('Select Label to edit first. Function F0. ');
            normvideo;clreol;
            delay(3000);
          end;
         end;
   ^F  : begin
          fontchange;
         end;
   ^S  : begin
          loadfont;
          remove_cursor;
          cy:=cy-scalbase;
          scalechange;
          cy:=cy+scalbase;
          put_cursor;
         end;
   ^P  : begin
          penchange;
         end;
   ^L  : begin
          if labname<>'NONE' then
          begin
            gotoxy(1,8);lowvideo;
            write('Do you wish to add a second label to ',labname,' ? Y/N ');
            normvideo; clreol;
            repeat
             read(kbd,ans);
            until ans in ['Y','y','N','n'];
            if ans in['N','n'] then
            begin
              gotoxy(1,8);lowvideo;
              write('Exit current label ',labname,' first. (F7) ');
              normvideo; clreol;
              delay(4000);
              exit;
            end
            else
            begin
             oldname:=labname;
             close(lf);
             display_files('L'+labext,11,labeldrive[1]);
             gotoxy(1,8); write('Label Name: ');clreol;
             labname:='';
             getinput(8,13,8,labname,'c',fin,1);
             assign(lf,labeldrive+labname+'.L'+labext);
             {$I-} reset(lf); {$I+}
             error:=ioresult;
             if error=0 then
             begin
              Key_info(6,CurrentLb);
              wait;
              display_lab_conts;
              close(lf);
              labname:=oldname;
              assign(lf,labeldrive+labname+'.L'+labext);
              reset(lf);
              Key_info(6,CurrentLb);
              options;
             end
            end;
          end
          else
          begin
           clrframe(10,25);
           assign(tempf,workdrive+'TEMP.LBL');
           rewrite(tempf);
           display_files('L'+labext,11,labeldrive[1]);
           gotoxy(1,8); write('Label Name: ');clreol;
           labname:='';
           getinput(8,13,8,labname,'c',fin,1);
           assign(lf,labeldrive+labname+'.L'+labext);
           {$I-} reset(lf); {$I+}
           oldname:=labname;
           error:=ioresult;
           if error=0 then
           begin
              Key_info(6,CurrentLb);
              wait;
              display_lab_conts;
              options;
           end
           else
           begin
             if error in [144,153] then
             begin
              erase(lf);
              assign(lf,labeldrive+labname);
             end;
             rewrite(lf);
             key_info(5,CurrentLb);
             gotoxy(1,8);write('NEW FILE BEING CREATED');
             delay(3000);
             options;
           end;
          end;
          clrframe(10,25);
         end;
   ^A :  begin
           if areanum>0 then remove_cursor;
           sstle(4); {or}
           sccol(blue);
           do_area_numbers;
           clrframe(10,25);
           gotoxy(10,12);
           write('Area Numbers are indicated in blue on colour screen.');
           if twoscreens=TRUE then
           begin
             gotoxy(10,13);
             write('Press ESC to see other part of label.');
           end;
           repeat
            gotoxy(1,8); write('Select Area: ');clreol;
            tempstr:='';
            getinput(1,14,8,tempstr,'n',fin,1);
            if (fin=TRUE) and (twoscreens=TRUE) then
            begin
             if curdp=1 then
             begin
              curdp:=2;
              setcdp(2);
             end
             else
             begin
              curdp:=1;
              setcdp(1);
             end;
            end;
           val(tempstr,areanum,j);
           until (areanum IN [1..6]) and (fin=FALSE) and (j=0);
           sstle(6); {and}
           sccol(yellow);
           do_area_numbers;
           scalefont;
           set_area_boundries;
           Key_use(Move);
           Key_info(5,CurrentAr);
           remove_cursor;
           cx1:=0; cy1:=0;
           cx:=left+5; cy:=top+round(20*scl);
           put_cursor;
           if param.contents=SymbolArea then
           begin
            xoffs:=left;
            yoffs:=top;
           end;
           clrframe(10,25);
         end;
   ^Q :  begin
           Key_use(Save);
           repeat
             gotoxy(10,8);read(kbd,ans);
           until ans in [^Q,^X,'a',esc];
           wait;
           case ans of
         ^Q  : begin
                if labname<>'NONE' then
                begin
                 {$I-} close(lf);{$I+}
                 if ioresult<>0 then
                 begin
                   gotoxy(1,8);write('No File ',labname,' to close'); clreol;
                 end;
                 assign(nf,labeldrive+labname+'.B'+labext);
                 {$I-} erase(nf); {$I+}
                 if ioresult>0 then begin end;
                 {$I-} rename(lf,labname+'.B'+labext); {$I+}
                 if ioresult<>0 then
                 begin
                   gotoxy(1,8);write('No File ',labname,' to rename');clreol;
                 end;
                 {$I-} close(tempf); {$I+}
                 if ioresult<>0 then
                 begin
                   gotoxy(1,8);write('No TEMP file to close');clreol;
                 end;
                 assign(lf,labeldrive+labname+'.L'+labext);
                 rewrite(lf);
                 reset(tempf);
                 while not eof(tempf) do
                 begin
                   read(tempf,lab);
                   if lab.stat=TRUE then
                    write(lf,lab);
                 end;
                 close(lf); close(tempf);
                 {$I-} erase(tempf); {$I+}
                 if ioresult<>0 then
                 begin
                   gotoxy(1,8);write('No TEMP file to erase');clreol;
                 end;
                end;
                ans:=^Q;
               end;
          ^X : begin
               if labname<>'NONE' then
                begin
                 gotoxy(1,8);write('New name: ');
                 newname:='';
                 getinput(8,11,8,newname,'c',fin,1);
                 clrframe(20,23);
                 {$I-} close(lf);{$I+}
                 if ioresult<>0 then
                 begin
                   gotoxy(1,8);write('No File ',labname,' to close');clreol;
                 end;
                 {$I-} close(tempf);{$I+}
                 if ioresult<>0 then
                 begin
                   gotoxy(1,8);write('No TEMP File to close');clreol;
                 end;
                 assign(lf,labeldrive+newname+'.L'+labext);
                 rewrite(lf);
                 reset(tempf);
                 while not eof(tempf) do
                 begin
                   read(tempf,lab);
                   if lab.stat= TRUE then
                    write(lf,lab);
                 end;
                 close(lf); close(tempf);
                 {$I-} erase(tempf); {$I+}
                 if ioresult<>0 then
                 begin
                   gotoxy(1,8);write('No TEMP file to erase');clreol;
                 end;

                 {$I-} rename(tempf,newname+'.L'+labext);{$I+}
                 if ioresult<>0 then
                 begin
                   gotoxy(1,8);write('No TEMP File to rename');clreol;
                 end;
                end;
                ans:=^Q;
               end;
         'a' : begin
                if labname<>'NONE' then
                begin
                 {$I-} reset(lf); {$I+}
                 if ioresult=0 then
                  if FileSize(lf)=0 then
                  begin
                   close(lf);erase(lf);
                  end
                  else
                  close(lf);
                 {$I-} reset(tempf);{$I+}
                 if ioresult=0 then
                 begin
                   close(tempf);
                   erase(tempf);
                 end;
                end;
                ans:=^Q;
               end;
           end; {of case}
         labname:='NONE';
         Key_info(6,CurrentLb);
         end; {of ^Q}

   ^X :  begin       {Variable}
          curmode:='V';
          enter_text;
         end;  {of ^X}
   end; {of case}
  UNTIL ans=^Q;         {Exit}


  repeat
   gotoxy(1,8);clreol;
   write('Another Label ? Y/N ');
   read(kbd,ans);
  until ans in ['Y','y','N','n'];
  wait;
  if ans in ['Y','y'] then
  begin
    close(cf);
    setup;
  end;
 UNTIL ans in ['N','n'];
 close(Dfile);
out:
 assign(f,'MENU.COM');
 {$I-} execute(f); {$I+}
 if ioresult>0 then
  write('MENU program not found.');
END.
