Procedure FileCopy(sourcename,destname : str14);
const
  recsize  = 128;
  bufsize  =  10;
Var
  source, dest  : FILE;
  buffer  : array[1..recsize,1..bufsize] of byte;
  recsread : integer;
Begin
  assign(source,sourcename);
  {$I-} reset(source); {$I+}
  error:=ioresult;
  if error>0 then
  begin
    ermsg(error);
    exit;
  end;
  assign(dest,destname);
  rewrite(dest);
  repeat
    Blockread(source,buffer,bufsize,recsread);
    Blockwrite(dest,buffer,recsread);
  until recsread=0;
  close(source); close(dest);
End;


