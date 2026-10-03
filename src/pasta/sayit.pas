{********>>>>>>>><<<<<<<<********

>>	MODULE:	SAYIT
		13-OCT-80

		This module contains the procedure SAYIT.

********>>>>>>>><<<<<<<<********}


{ $C	.TITLE	SAYIT
	.IDENT	/V0/    }

{*********************   VERB SAY  *****************************}

{  "Say" -- Echo WRD2-WRD2X, unless input in response to "Say what?", in which
case we echo the entire input: "drop keys" .  Magic words override..  }
OVERLAY PROCEDURE SAYIT;
BEGIN 
    { Check for magic words...  }
    IF MAGIC THEN PARSE
    { Otherwise, say it....  }
    ELSE ECHO
END;
