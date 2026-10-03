{********>>>>>>>><<<<<<<<********

>>	MODULE:	SUBS0
		15-OCT-80

		This module contains the data structure functions TOTING, 
	HERE, BITSET, FORCED, DARK, RAN, and PCT.

********>>>>>>>><<<<<<<<********}


{ $C	.TITLE SUBS0
	.IDENT /V0/   }

{  *************** DATA STRUCTURE ROUTINES  ******************  }

{  True if player is carrying object.  }
FUNCTION TOTING(OBJ:INTEGER):BOOLEAN;
BEGIN
	TOTING:=(PLACE[OBJ]=-1)
END;

{ This function is true if an object is at the player's current location or
being carried.  }
FUNCTION HERE(OBJ:INTEGER):BOOLEAN;
BEGIN
	HERE:=(PLACE[OBJ]=LOCATION) OR TOTING(OBJ)
END;

{  This function is true if argument location has bit n set in CONDI.  }
FUNCTION BITSET(LOC,N:INTEGER):BOOLEAN;
BEGIN
    BITSET:=((CONDI[LOC] AND BIT(N))<>0)
END;

{  This function is true if loc has forced motion.  }
FUNCTION FORCED(LOC:INTEGER):BOOLEAN;
BEGIN
	FORCED:=(CONDI[LOC]=2)
END;

{  This function is true if the current LOCATION has no source of light.  }
FUNCTION DARK:BOOLEAN;
BEGIN
	DARK:= NOT BITSET(LOCATION,0) AND ((PROP[LAMP]=0) OR (NOT HERE(LAMP)))
END;

{  Random number function is a hybrid developed from the one in the F4P version 
and the one supplied as a demo program with OMSI.  It is seeded from the time
of day an returns an integer value from 1 to RANGE. }
{ CHANGED: The seed comes from the command line (any integer), so a game can be
replayed exactly, e.g. for testing.  Without a parameter, it comes from the
runtime's random number generator.  The original used the time of day.  }
FUNCTION NEWSEED:INTEGER;
VAR S,E:INTEGER;
BEGIN
	E:=1;
	IF PARAMCOUNT>0 THEN VAL(PARAMSTR(1),S,E);
	IF E<>0 THEN BEGIN
		RANDOMIZE;
		S:=RANDOM(32767)
	END;
	NEWSEED:=S
END;

FUNCTION RAN(RANGE:INTEGER):INTEGER;
FUNCTION RANDOM:REAL;
BEGIN
	{ CHANGED: AND 32767 instead of MOD 32768, since SEED is a signed integer
	now.  Gives the same results as OMSI's unsigned arithmetic.  }
	SEED:=(SEED*13077+6925)AND 32767;
	RANDOM:=SEED/32768.0
END;
BEGIN
	IF STRTRAN THEN
	BEGIN
		SEED:=NEWSEED;	{ CHANGED: was SEED:=TRUNC(TIME*1000.0) }
		STRTRAN:=FALSE
	END;
	RAN:=TRUNC(RANDOM*RANGE)+1
END;

{  This function is true n percent of the time.  }

FUNCTION PCT(N:INTEGER):BOOLEAN;
VAR	I:INTEGER;
BEGIN
	I:=RAN(100);
	PCT:=(I<N)
END;
