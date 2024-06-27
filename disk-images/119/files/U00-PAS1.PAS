     PROGRAM list (input,output);

     VAR
              source: text;
              name: string[10];
              filename: string[14];
              line: string[120];
              linecount: 0..9999;

     BEGIN

              linecount := 0;
              write('Source name - '); readln(name);
              WHILE(length(name) >0) AND (name[1] = ' ') DO
                delete(name,1,1);
              filename :=concat(name,'.for');
              assign(source,filename);  reset(source);

              WHILE NOT eof(source) DO
                BEGIN
                  linecount := linecount +1;
                  writeln(output, linecount:4, ':  ',line);
                end;
      END.
