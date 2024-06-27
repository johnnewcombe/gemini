Procedure Display_pluto_screen;
begin
 sccol(blue);
 top:=Lgtop; bottom:=Lgbottom;
 left:=Lgleft; right:=Lgright;
 moveto(Lgleft,Lgtop);
 lto(Lgright,Lgtop);
 lto(Lgright,Lgbottom);
 lto(Lgleft,Lgbottom);
 lto(Lgleft,Lgtop);
 left:=Smleft; right:=Smright;
 moveto(Smleft,Smtop);
 lto(Smright,Smtop);
 lto(Smright,Smbottom);
 lto(Smleft,Smbottom);
 lto(Smleft,Smtop);
 left:=Lgleft; right:=Lgright;
end;  {of display_pluto_screen}

Procedure drawsmall(sx2,sy2,cx2,cy2,col : integer);
var
  ssx,ssy,scx,scy : integer;
begin
  ssx:=round((sx2-xoff)*scl)+xoffs;
  ssy:=round((sy2-yoff)*scl)+yoffs;
  scx:=round((cx2-xoff)*scl)+xoffs;
  scy:=round((cy2-yoff)*scl)+yoffs;
  if vector.status=1 then
  begin
    sccol(col);
    left:=Smleft; right:=Smright;
    moveto(ssx,ssy);
    lto(scx,scy);
  end;
  if vector.status=2 then
  begin
   left:=Smleft; right:=Smright;
   moveto(ssx,ssy);
   sccol(col);
   ffill;
  end;
  left:=Lgleft; right:=Lgright;
end;

Procedure write_vector_to_file;
begin
  case penup of
  TRUE : begin
           sx:=cx;
           sy:=cy;
         end;
  False: begin
          remove_cursor;
          sccol(green);
          sstle(0);
          cx:=cx+cx1;
          if cx<=left then cx:=left+1;
          if cx>=right then cx:=right-1;
          cy:=cy+cy1;
          if cy<=top then cy:=top+1;
          if cy>=bottom then cy:=bottom-1;
          moveto(sx,sy);
          lto(cx,cy);
          sstle(0);
          with vector do
          begin
            status:=1;
            startx:=sx-xoff;
            starty:=sy-yoff;
            endx:=cx-xoff;
            endy:=cy-yoff;
          end;
          drawsmall(sx,sy,cx,cy,green);
          seek(tf,filesize(tf));
          write(tf,vector);
          sx:=cx;
          sy:=cy;
         end;
  end;  {of case}

end;  {of write_vector_to_file}

Procedure draw_on_pluto;
begin
  if vector.status=1 then
  with vector do
  begin
    moveto(startx+xoff,starty+yoff);
    lto(endx+xoff,endy+yoff);
    drawsmall(startx+xoff,starty+yoff,endx+xoff,endy+yoff,green);
  end;
  if vector.status=2 then
  with vector do
  begin
    sccol(yellow);
    moveto(startx+xoff,starty+yoff);
    bfill;
    drawsmall(startx+xoff,starty+yoff,endx+xoff,endy+yoff,green);
  end;
end;  {of draw_on_pluto}

Procedure Repack_file;
var
  zf : FILE of vecrec;
begin
  flush(tf);
  reset(tf);
  assign(zf,labeldrive+'COPY.$$$');
  rewrite(zf);
  while not eof(tf) do
  begin
    read(tf,vector);
    if vector.status<>0 then
     write(zf,vector);
  end;
  close(tf);
  close(zf);
  erase(tf);
  rename(zf,'TEMP.$$$');
  assign(tf,labeldrive+'TEMP.$$$');
  reset(tf);
end;  {of repack_file}


Procedure deleteline(sx1,sy1,ex1,ey1 : integer);
var
   savepos : integer;
begin
   if vector.status =1 then
      begin
        moveto(sx1,sy1);
        sccol(black);
        sstle(0);
        lto(ex1,ey1);
        drawsmall(sx1,sy1,ex1,ey1,black);
        vector.status:=0;
        seek(tf,filepos(tf)-1);
        savepos:=filepos(tf);
        write(tf,vector);
        flush(tf);
        delt:=TRUE;
        repack_file;
      end;
   if vector.status=2 then
      begin
        sccol(black);
        ffill;
        sccol(green);
        drawsmall(sx1,sy1,ex1,ey1,black);
        vector.status:=0;
        if filepos(tf)>0 then
         seek(tf,filepos(tf)-1);
        savepos:=filepos(tf);
        write(tf,vector);
        flush(tf);
        delt:=TRUE;
        sccol(green);
        spcol(green);
      end;
    reset(tf);
    sccol(green);
    while not eof(tf) do
    begin
      read(tf,vector);
      draw_on_pluto;
    end;
    seek(tf,savepos);
end;


PROCEDURE move_through_vectab;
var
   direction : integer;
   sp : integer;

procedure redline(sx,sy,ex,ey : integer);
begin
    moveto(sx,sy);
    sccol(red);
    sstle(0);
    lto(ex,ey);
end;
procedure greenline(sx,sy,ex,ey : integer);
begin
    moveto(sx,sy);
    sccol(green);
    sstle(0);
    lto(ex,ey);
end;


begin
  delt:=FALSE;
  gotoxy(1,8);clreol;
  write('Use Left & Right cursor keys to scan or <ESC> to exit:');
  repeat
   gotoxy(54,8);read(kbd,command);
   case command of
    #28 : begin seek(tf,filesize(tf)-1);direction:=-1; end;
    #29 : begin seek(tf,0);direction:=1; end;
   end; {of case}
  until command in [#28,#29,esc];
  if command=esc then exit;
  read(tf,vector);
  if vector.status=1 then
  with vector do
   redline(startx+xoff,starty+yoff,endx+xoff,endy+yoff);
  if vector.status=2 then
  with vector do
  begin
   sccol(red);
   moveto(startx+xoff,starty+yoff);
   bfill;
  end;
  gotoxy(1,8);clreol;
  write('Use Left & Right cursor keys to continue to scan: ');
  repeat
    gotoxy(50,8);read(kbd,command);
    case command of
    #28 : begin
            direction:=-1;
            if delt=TRUE then
            begin
              with vector do
              greenline(startx+xoff,starty+yoff,endx+xoff,endy+yoff);
              delt:=FALSE;
            end
            else
            begin
             seek(tf,filepos(tf)-1);
             read(tf,vector);
             if vector.status=1 then
             with vector do
              greenline(startx+xoff,starty+yoff,endx+xoff,endy+yoff);
             if vector.status=2 then
             with vector do
             begin
              moveto(startx+xoff,starty+yoff);
              sccol(yellow);
              spcol(green);
              bfill;
             end;
            end;
            repeat
              if filepos(tf)>=2 then
               seek(tf,filepos(tf)-2)
              else
               seek(tf,0);
              read(tf,vector);
            until (vector.status<>0) or (filesize(tf)=1);
             if vector.status=1 then
             with vector do
              redline(startx+xoff,starty+yoff,endx+xoff,endy+yoff);
             if vector.status=2 then
             with vector do
             begin
              sccol(red);spcol(green);
              moveto(startx+xoff,starty+yoff);
              bfill;
              spcol(green);
             end;
             cx:=vector.startx+xoff;
             cy:=vector.starty+yoff;
          end;
    #29 : begin
            direction:=1;
            if delt=TRUE then
            begin
              with vector do
              greenline(startx+xoff,starty+yoff,endx+xoff,endy+yoff);
              delt:=FALSE;
            end
            else
            begin
             seek(tf,filepos(tf)-1);
             read(tf,vector);
             if vector.status=1 then
             with vector do
              greenline(startx+xoff,starty+yoff,endx+xoff,endy+yoff);
             if vector.status=2 then
             with vector do
             begin
              sccol(yellow);spcol(green);
              moveto(startx+xoff,starty+yoff);
              bfill;
             end;
            end;
             if eof(tf)  then
              seek(tf,filesize(tf)-1);
             repeat
              read(tf,vector);
             until (vector.status<>0) or (eof(tf)=TRUE);
             if vector.status=1 then
             with vector do
              redline(startx+xoff,starty+yoff,endx+xoff,endy+yoff);
             if vector.status=2 then
             with vector do
             begin
               sccol(red); spcol(green);
               moveto(startx+xoff,starty+yoff);
               bfill;
               spcol(green);
             end;
             cx:=vector.startx+xoff;
             cy:=vector.starty+yoff;
          end;
    'F' : begin
          end;
    'A' : begin
            sp:=filepos(tf)-1;
            with vector do
            deleteline(startx+xoff,starty+yoff,endx+xoff,endy+yoff);
             repeat
              sp:=sp+direction;
              if sp<0 then sp:=0;
              if sp>=filesize(tf) then sp:=filesize(tf)-1;
              seek(tf,sp);
              gotoxy(9,8);write(filepos(tf),'  ');
              if (eof(tf)=TRUE) or (filepos(tf)=0) then
               direction:=direction*(-1);
              read(tf,vector);
             until (vector.status<>0) or (eof(tf)=TRUE) or (filepos(tf)=0);
             if vector.status=1 then
             with vector do
              redline(startx+xoff,starty+yoff,endx+xoff,endy+yoff);
             if vector.status=2 then
             with vector do
             begin
               sccol(red); spcol(green);
               moveto(startx+xoff,starty+yoff);
               bfill;
               spcol(green);
             end;
          end;
    end;  {of case}
  until command='Q';
    if vector.status=1 then
    with vector do
     greenline(startx+xoff,starty+yoff,endx+xoff,endy+yoff);
    if vector.status=2 then
    with vector do
    begin
      sccol(yellow);spcol(green);
      moveto(startx+xoff,starty+yoff);
      bfill;
    end;
end;  {of move_through_vectab}

