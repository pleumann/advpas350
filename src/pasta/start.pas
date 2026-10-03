{********>>>>>>>><<<<<<<<********

>>	MODULE:	START
		30-OCT-80

		This module contains the "wizardry" routines START and
	UNSAVE.  CHANGED: START has been simplified a lot.

********>>>>>>>><<<<<<<<********}


{ $C	.TITLE	START
	.IDENT /V0/   }

{  *************** DATA STRUCTURE ROUTINES  ******************  }

{ *************  I/O  SUBROUTINES   ********************}

{ ****************** MAGIC MODE PROCEDURES ********************* }

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

{  Procedure to restore a saved Adventure.  Var SAV tells us which of the 
storage locations to use.  The name for the saved game is wiped out so saved
games can only be restarted once.  }
OVERLAY PROCEDURE UNSAVE(SAV:INTEGER);
VAR SAVED,SAVET,I,PLAC,FIXD:INTEGER;

{  Local procedure to restore the value of a boolean.  }
PROCEDURE RDWIZB(VAR X:BOOLEAN);
VAR Z:INTEGER;
BEGIN
    RDWIZ(Z);
    IF Z=0 THEN X:=FALSE ELSE X:=TRUE

END;

BEGIN
    MSPEAK(40);
    { CHANGED: File buffer accesses replaced by READ, WRITE and SEEK.  }
    ASSIGN(ADVWIZ,'ADVWIZ.DTA');
    RESET(ADVWIZ);
    SEEK(ADVWIZ,40);
    READ(ADVWIZ,PLAC);
    PLAC:=PLAC-1;
    SEEK(ADVWIZ,40);
    WRITE(ADVWIZ,PLAC);
    SEEK(ADVWIZ,20*SAV+42);
    PLAC:=ORD(' ')-ORD('A');
    FOR I:=1 TO 20 DO BEGIN
	IF I=8 THEN MSPEAK(41);
	IF I=19 THEN MSPEAK(42);
	WRITE(ADVWIZ,PLAC);
	SEEK(ADVWIZ,20*SAV+42+I)
    END;
    SEEK(ADVWIZ,253*SAV+102);
    RDWIZ(SAVED);
    RDWIZ(SAVET);
    RDWIZ(LOCATION);
    RDWIZ(HOLDING);
    FOR I:=1 TO MAXTRS DO BEGIN
	IF I=25 THEN MSPEAK(43);
	RDWIZ(PLAC);
	RDWIZ(FIXD);
	RDWIZ(PROP[I]);
	MOVE(I,PLAC);
	IF (FIXD>0)OR((FIXD=0)AND(PLAC=0)) 
	THEN MOVE(I+100,FIXD) ELSE FIXED[I]:=FIXD
    END;
    MSPEAK(44);
    FOR I:=MAXTRS DOWNTO 1 DO JUGGLE(I);
    RDWIZ(TALLY);
    RDWIZ(TALLY2);
    RDWIZ(DFLAG);
    RDWIZ(TURNS);
    RDWIZ(IWEST);
    RDWIZ(KNFLOC);
    RDWIZ(NUMDIE);
    RDWIZ(DKILL);
    RDWIZ(CLOCK1);
    RDWIZ(CLOCK2);
    RDWIZ(LIMIT);
    FOR I:=1 TO 10 DO BEGIN
	RDWIZ(HINTLC[I]);
	RDWIZB(HINTED[I]);
    END;
    MSPEAK(45);
    FOR I:=1 TO 6 DO BEGIN
	RDWIZ(ODLOC[I]);
	RDWIZ(DLOC[I]);
	RDWIZB(DSEEN[I])
    END;
    RDWIZB(WZDARK);
    RDWIZB(LMWARN);
    RDWIZB(CLOSING);
    RDWIZB(PANIC);

    RDWIZB(CLOSED);
    RDWIZ(NEWLOC);
    RDWIZ(OLDLC2);
    RDWIZ(OLDLOC);
    CLOSE(ADVWIZ)
END;

{  This function is called after initialization at the beginning of the game
to check for "prime time" and suitable latency after saved games.  It returns a
value of true if a demonstration game is being allowed, otherwise always false.
Global variable DONE is set to true if play is disallowed for any reason.  }
{ CHANGED: Prime time, demonstration games and the latency check for saved games
are gone along with the rest of the wizardry.  What remains is the check for a
saved game, which is restored if the player knows its name.  }
OVERLAY FUNCTION START:BOOLEAN;

VAR SAV:INTEGER;
    FOUND:BOOLEAN;

{ Local procedure to check saved game names. }
PROCEDURE MATCH(WRD:WORD);
VAR J,K:INTEGER;
BEGIN
    FOR J:=1 TO 5 DO BEGIN
	RDWIZ(K);
	IF WRD[J]<>CHR(K+ORD('A')) THEN FOUND:=FALSE
    END
END;

BEGIN { Start }
    ASSIGN(ADVWIZ,'ADVWIZ.DTA');
    RESET(ADVWIZ);
    SEEK(ADVWIZ,40);
    RDWIZ(SAV);
    SETUP:=FALSE;
    FOUND:=FALSE;

    IF SAV<>0 THEN IF ASKM(31,7,7) THEN BEGIN
	MSPEAK(46);
	GETIN(WRD1,WRD1X,WRD2,WRD2X);
	SEEK(ADVWIZ,42);
	FOR SAV:=0 TO 2 DO BEGIN
	    FOUND:=TRUE;
	    MATCH(WRD1);
	    MATCH(WRD1X);
	    MATCH(WRD2);
	    MATCH(WRD2X);
	    IF FOUND THEN BREAK	{ CHANGED: OMSI EXIT leaves the loop. }
	END;
	IF NOT FOUND THEN MSPEAK(47) ELSE BEGIN
	    MSPEAK(48);
	    SETUP:=TRUE
	END
    END;
    CLOSE(ADVWIZ);
    START:=FALSE;
    IF SETUP THEN UNSAVE(SAV)
END;
