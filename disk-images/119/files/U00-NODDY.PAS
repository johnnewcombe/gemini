program autogen;
var outputfile: text;
    fred: string[32];
    begin
     assign( outputfile, '$$$.SUB' ); rewrite( outputfile );
     write( 'Enter command: ' );
     readln( fred );
     write( fred );
     write( outputfile, ' ', fred, ^@ );
     close( outputfile );
end.

