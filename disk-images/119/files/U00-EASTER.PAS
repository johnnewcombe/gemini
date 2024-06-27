PROGRAM easter;

CONST   fyr = 1976;  lyr = 2000;
TYPE    yr  = 1583..4200;
        mn  = (march,april);
        dy  = 1..31;
VAR     year: yr;  month: mn;  day: dy;

PROCEDURE dateofeaster(y: yr;  VAR d: dy;  VAR m: mn);

       {This procedure calculates the date of Easter in year y,
        and returns the day d and month m.  The algorithm is
        taken from Knuth's "Fumdamental Algorithms", where in
        turn there is acknowledgement to the Neapolitan Aloysius
        Lillius and the German Jesuit mathematician Christopher
        Clavius.  It applies for any year from 1582 to 4200.}

  VAR   gold: 1..19;      {the "golden number"}
        cent: 16..43;     {century}
        epact: -29..30;   {the "epact" specifies full moon}
        sun:  1950..3750; {March (-sun)MOD 7 is a Sunday}
        full: 14..55;     {date of full moon}
        x:    2..11;      {correction for years divisible by 4
                           but not leap years, e.g. 1900}
        z:    1..10;      {synchronisation with moon's orbit}

  BEGIN
    gold := y MOD 19 + 1;
    cent := y DIV 100 +1;
    x := 3 * cent DIV 4 - 12;
    Z := (8 * cent + 5) DIV 25 - 5;
    sun := 5 * y DIV 4 - x - 10;
    epact := (11 * gold + 20 + Z - X) MOD 30;
    IF epact < 0 THEN epact := epact + 30;
    IF (epact = 25) AND (gold > 11) OR
       (epact = 24) THEN epact := epact + 1;
    full := 44 - epact;
    IF full < 21 THEN full := full + 30;
                          {Easter is the "first Sunday following
                           the first full moon which occurs on
                           or after March 21st".}
    full := full + 7 - (sun + full) MOD 7;
    IF full > 31 THEN
      BEGIN  m := april;
        d := full - 31;
      END
    ELSE
      BEGIN  m := march;
        d := full;
      END;
    END  {dateofeaster};

  BEGIN  {program}
    page(output);  writeln('Dates of Easter:');  writeln;
    FOR year := fyr TO lyr DO
      BEGIN
        dateofeaster(year,day,month);
        write(year:4);
        IF month = march THEN write('March':7) ELSE write('April':7);
        writeln(day:4);
      END;
  END.
