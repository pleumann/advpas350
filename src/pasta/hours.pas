{********>>>>>>>><<<<<<<<********

>>	MODULE:	HOURS
		21-OCT-80

		This module contains the "wizardry" routine HOURS (CHANGED: much
	simplified) and the function LIQLOC.
	
********>>>>>>>><<<<<<<<********}


{ $C	.TITLE	HOURS
	.IDENT /V0/    }

{  *************** DATA STRUCTURE ROUTINES  ******************  }

{  This function returns the object value of the liquid (if any) present
at the argument location.  If there is none, the value zero is returned.  }
FUNCTION LIQLOC(LOC:INTEGER):INTEGER;
BEGIN
    IF BITSET(LOC,2) THEN
	IF BITSET(LOC,1) THEN LIQLOC:=OIL
	ELSE LIQLOC:=WATER
    ELSE LIQLOC:=0
END;

{ CHANGED: The procedure HOURS has been replaced along with the rest of the
wizardry.  This version prints what the original would have printed with the
initial settings created by POOF: open all hours, no holidays.  Tabs have been
replaced by blanks, since not all targets handle them.  }
PROCEDURE HOURS;
BEGIN
    WRITELN;
    WRITELN('        Mon-Fri:    Open All Day');
    WRITELN;
    WRITELN('        Sat-Sun:    Open All Day');
    WRITELN;
    WRITELN('        Holidays    Open All Day')
END;
