{********>>>>>>>><<<<<<<<********

>>	MODULE:	COMPAT

		CHANGED: This module is new.  It contains helper routines that
	emulate OMSI's file buffer semantics for the text and vocabulary
	files.  In OMSI, SEEK(F,N) positions to record N and loads it into
	the buffer variable F^, GET(F) advances and loads the next record.
	Turbo Pascal has no buffer variables, so the records TXTREC and
	KATREC (see ADVGBL) take their place.

********>>>>>>>><<<<<<<<********}

{  Equivalent of SEEK(ADVTXT,REC), loads the record into TXTREC.  }
PROCEDURE SEEKTXT(REC:INTEGER);
BEGIN
    SEEK(ADVTXT,REC);
    READ(ADVTXT,TXTREC)
END;

{  Equivalent of GET(ADVTXT), loads the next record into TXTREC.  At the end
of the file, LOC is set to -1 so that message loops terminate.  }
PROCEDURE GETTXT;
BEGIN
    IF EOF(ADVTXT) THEN TXTREC.LOC:=-1
    ELSE READ(ADVTXT,TXTREC)
END;

{  Equivalent of SEEK(KATAB,N), loads the record into KATREC.  }
PROCEDURE SEEKKAT(N:INTEGER);
BEGIN
    SEEK(KATAB,N);
    READ(KATAB,KATREC)
END;

{  Outputs one line of message text.  }
PROCEDURE SAYLINE(VAR S:LINE);
BEGIN
{$IFDEF SYS_ZX}
    { CHANGED: Set the ROM's scroll counter (SCR_CT), so long messages never
    stop with "Scroll?".  }
    MEM[23692]:=255;
{$ENDIF}
    WRITELN(S)
END;
