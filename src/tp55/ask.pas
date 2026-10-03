{********>>>>>>>><<<<<<<<********

>>	MODULE:	ASK
		29-OCT-80

		This module contains the procedures ASK, ASKR, ASKM, and
	WIZARD (CHANGED: removed).
	
********>>>>>>>><<<<<<<<********}


{ $C	.TITLE ASK
	.IDENT /V0/   }

{ ****************** I/O SUBROUTINES ****************** }

{  This function asks question I using output procedure SPK (which could
be RSPEAK or MSPEAK) and returns a value true for a 'yes' and outputs
message J or returns a value false for a 'no' and outputs message K.  }
{ CHANGED: Turbo Pascal has no procedure parameters, so a flag MAGICMSG now
selects between MSPEAK and RSPEAK inside the local procedure SPK.  }
FUNCTION ASK(I,J,K: INTEGER; MAGICMSG: BOOLEAN): BOOLEAN;

PROCEDURE SPK(MSG:INTEGER);
BEGIN
    IF MAGICMSG THEN MSPEAK(MSG) ELSE RSPEAK(MSG)
END;

BEGIN
    REPEAT  { Until question answered, WRD1[1]= 'Y' OR 'N' }
	{ Ask the question }
	SPK(I);
	{ Get the player's response }
	GETIN(WRD1,WRD1X,WRD2,WRD2X);
	CASE WRD1[1] OF
		{ Player responded yes }
		'Y': BEGIN
			SPK(J);
			ASK:=TRUE
		END;
		{ Player responded no }
		'N': BEGIN
			SPK(K);
			ASK:=FALSE
		END;
		{ Avoiding the question is not allowed! }
		ELSE RSPEAK(202)
	END
    UNTIL (WRD1[1]='Y')OR(WRD1[1]='N')
END;

{  Ask a question and respond from random messages.  }
FUNCTION ASKR(I,J,K: INTEGER): BOOLEAN;
BEGIN
	ASKR:=ASK(I,J,K,FALSE)
END;

{  Ask a question and respond from magic messages.  }
FUNCTION ASKM(I,J,K: INTEGER): BOOLEAN;
BEGIN
	ASKM:=ASK(I,J,K,TRUE)
END;

{ CHANGED: The function WIZARD has been removed along with the rest of the
wizardry.  }
