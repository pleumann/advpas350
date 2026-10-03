{********>>>>>>>><<<<<<<<********

>>	MODULE:	SAVNAM
		29-OCT-80

		This module contains the procedure SAVNAME, which is used by
	SAVE to record the name under which a game is being saved in ADVWIZ.DTA.

********>>>>>>>><<<<<<<<********}


{ $C	.TITLE	SAVNAM 
	.IDENT /V0/  }

{ *************  I/O  SUBROUTINES   ********************}

{ ****************** SUSPEND PROCEDURE *********************** }

{  All of the data required for the wizardry routines, including saving games,
is stored encoded in one random access file of integers: ADVWIZ.
The current record usage assignments for this file are as follows,
	1..5	  --	MAGICWORD
	6..10	  --	MAGICNUMBER
	11..12	  --	WKDAY
	13..14	  --	WKEND
	15..16	  --	HOLID
	17	  --	HBEGIN
	18	  --	HEND
	19..38	  --	HNAME
	39	  --	SHORT
	40	  --	Count of saved games.
	41	  --	LATENCY
	42..61	  --	Name of saved game 1.
	62..81	  --	Name of saved game 2.
	82..101	  --	Name of saved game 3.
	102..354  --	Saved game 1.
	355..607  -- 	Saved game 2.
	608..860  --  	Saved game 3.
	861..1560 --	Message of the day.      }

{  Procedure to save the player's name for a saved game.  Variable SAV is
returned as an index into which of the save areas we used.  Global variable
I is used as a record pointer into ADVWIZ; refer to commment in WRWIZ. }
PROCEDURE SAVNAME{(VAR SAV:INTEGER)};	{ CHANGED: declared FORWARD in VERBS4. }
VAR J,Z,S:INTEGER;
    WRD:WORD;
BEGIN
    { CHANGED: File buffer accesses replaced by READ, WRITE and SEEK.  }
    SEEK(ADVWIZ,40);
    READ(ADVWIZ,Z);
    Z:=Z+1;
    SEEK(ADVWIZ,40);
    WRITE(ADVWIZ,Z);
    SEEK(ADVWIZ,42);
    { CHANGED: Turbo Pascal doesn't allow a VAR parameter as loop variable, so
    S is used instead and assigned to SAV after the loop.  }
    FOR S:=1 TO 3 DO BEGIN
	WRD:='     ';
	FOR J:=1 TO 5 DO BEGIN
	    READ(ADVWIZ,Z);
	    WRD[J]:=CHR(Z+ORD('A'))
	END;
	FOR J:=6 TO 20 DO READ(ADVWIZ,Z);
	IF WRD='     ' THEN BREAK	{ CHANGED: OMSI EXIT leaves the loop. }
    END;
    SAV:=S;
    I:=20*(SAV-1)+42;
    SEEK(ADVWIZ,I);
    MSPEAK(38);

    GETIN(WRD1,WRD1X,WRD2,WRD2X);
    MSPEAK(39);
    WRWRD(WRD1,WRD1X,WRD2,WRD2X)
END;
