procedure set_area_boundries;
begin
 seek(paramf,areanum);
 read(paramf,param);
 with param do
 begin
   if partition=2 then
   begin
    tx:=tx+rightone;
    bx:=bx+rightone;
   end;
        top:=ty+1;
     bottom:=by-1;
       left:=tx+1;
      right:=bx-1;
      sctop:=round(ty*yscal)+1;
   scbottom:=round(by*yscal)-1;
     scleft:=round(tx/xscal)+1;
    scright:=round(bx/xscal)-1;
 end;
end; {of set_area_boundries}


Procedure Display_label_area;
begin
 rightone:=0;
 twoscreens:=FALSE;
 sstle(4);
 reset(paramf);
 read(paramf,param);
 labeldrop:=param.label_drop;
 seek(paramf,1);
 while not eof(paramf) do
 begin
   read(paramf,param);
   if param.partition=1 then
    if param.bx>rightone then rightone:=param.bx;
 end;
 seek(paramf,1);
 while not eof(paramf) do
 begin
   read(paramf,param);
   if param.partition<>0 then
   with param do
   begin
     if partition=2 then
     begin
       tx:=tx+rightone;
       bx:=bx+rightone;
     end;
     case areatype of
      Line : begin
              sccol(green);
              moveto(round(tx/xscal),round(ty*yscal));
              lto(round(bx/xscal),round(by*yscal));
             end;
       Box : begin
              if Noprint=TRUE then sccol(blue)
              else
              sccol(green);
              moveto(round(tx/xscal),round(ty*yscal));
              lto(round(bx/xscal),round(ty*yscal));
              lto(round(bx/xscal),round(by*yscal));
              lto(round(tx/xscal),round(by*yscal));
              lto(round(tx/xscal),round(ty*yscal));
             end;
      end;  {of case}
   end;  {of with param}
 end; {eof}
end; {display_label_area}

Procedure write_it(s : str255);
var
  xp,yp : integer;
  xo : integer;

procedure print;
var
   xl, yl : integer;
begin
   ac:=charsize; dn:=0;
   if ord(s[1])-31>0 then
   for l:=1 to length(s) do
   begin
     vector:=vecary[ord(s[l])-31];
     num:=lo(vector[0]);
     xl:=round(cx/xscal);
     yl:=round(cy*yscal);
     for j:=1 to num do
     begin
        inp:=vector[j];
        ac:=hi(inp); dn:=lo(inp);
        if ac>127 then
        begin
          ac:=ac-128;
          moveto(xl+round((ac-xo)/xscal)+xo+xp
                ,yl-round(dn*yscal)+yp);
        end
        else
          lto(xl+round((ac-xo)/xscal)+xo+xp
             ,yl-round(dn*yscal)+yp);

     end;
     cx:=cx+ac+penwidth;
   end;
   cx:=tx; cy:=ty+scalbase;

end;  {of print in write_it}

begin
   xo:=round(7*Scl);
   cy:=cy+scalbase;
   case curpen of
   1 : begin
          xp:=0; yp:=0; print;
       end;
   2 : begin
        xp:=0; yp:=0; print;
        xp:=1; print;
        xp:=2; print;
        xp:=1; yp:=-1; print;
       end;
   3 : begin
        xp:=0; yp:=0; print;
        xp:=1; print;
        yp:=-1; print;
        xp:=0; print;
       end;
   4 : begin
        xp:=0; yp:=0; print;
        xp:=1; print;
        xp:=2; print;
       end;
   end; {of case}
end; {of write_it}


Procedure breakline(ll : str255);
var
  last, numchar : integer;
  ts : str125;  {temp string}
begin
   error:=0; breaknum:=1;
   sx:=cx; sy:=cy;{Start pos of first line}
   tx:=cx; ty:=cy;{Temporary Vars for line start}
   charsize:=round(16*scl)+penwidth;
   repeat
        {Get number of possible chars on line}
     numchar:=round((right-cx+round(scl))/charsize);

     if numchar<length(ll) then   {Are there too many?}
     begin                       {Yes, so split line up}
       last:=numchar;
       breaknum:=breaknum+1;
       while ll[last]<>' ' do
       begin
         last:=last-1;
        if last<1 then
        begin
         gotoxy(1,8);
         if length(ll)<59 then
         begin
          lowvideo; write(ll,' is too long for line.');normvideo;
         end
         else
         begin
          lowvideo; write('This is too long for the line.');normvideo;
         end;
         clreol;
         delay(3000);
         error:=1;
         cx:=sx; cy:=sy;
         ll:=copy(tl,1,length(tl)-length(ll));
        { breakline(ll);}
         exit;
        end;
       end;
       ts:=copy(ll,1,last);
       write_it(ts);
       cx:=left+5;
       tx:=cx;
       cy:=ty+round(20*scl);
       ty:=cy;
       ll:=copy(ll,last+1,length(ll))
     end
     else                        {No. So do whole line}
     begin
       write_it(ll);
       ll:='';
     end;
   until length(ll)=0;
   cx:=sx; cy:=sy;  {Restore start of line}
   moveto(round(cx/yscal),round(cy*yscal));   {and move to it}
end;  {of breakline}

Procedure put_symbol(sn : str14);
begin
   assign(sf,labeldrive+sn+'.SYM');
   {$I-} reset(sf); {$I+}
   if ioresult>0 then
   begin
     gotoxy(1,8);
     write('File for Symbol ',sn,' not on current drive');
     delay(3000);exit;
   end;
   while not eof(sf) do
   begin
     read(sf,symvec);
     if symvec.status<>0 then
     with symvec do
      draw_vector(startx,starty,endx,endy,green);
Procedure draw_vector(sx2,sy2,cx2,cy2,col : integer);
var
  ssx,ssy,scx,scy : integer;
  sysclx, syscly : real;
begin
  set_area_boundries;
  sysclx:=(right-left)/symbol_sizex;
  syscly:=(bottom-top)/symbol_sizey;
  ssx:=round(sx2*sysclx)+xoffs;
  ssy:=round(sy2*syscly)+yoffs;
  scx:=round(cx2*sysclx)+xoffs;
  scy:=round(cy2*syscly)+yoffs;
  if symvec.status=1 then
  begin
    sccol(col);
    moveto(round(ssx/xscal),round(ssy*yscal));
    lto(round(scx/xscal),round(scy*yscal));
  end;
  if symvec.status=2 then
  begin
   moveto(round(ssx/xscal),round(ssy*yscal));
   sccol(col);
   ffill;
  end;
end;  {of draw_vector}

   end;
   close(sf);
end;

procedure setup;
begin
 initialise;
 sbcol(6);
 sccol(blue);
 sstle(0);
 fontname:='NONE';
 labname:='NONE';
 areanum:=0;
 cx1:=0; cy1:=0;
 scl:=0.5; curpen:=1;
 scleft:=0; scright:=767;
 sctop:=0; scbottom:=575;
 tl:='';
 penwidth:=1;
 txtmode:='F';
 inst:=TRUE;
end;
