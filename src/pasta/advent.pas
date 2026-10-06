{********>>>>>>>><<<<<<<<********

>>	MODULE:	MAIN
		28-OCT-80

		This module contains the main program block.

********>>>>>>>><<<<<<<<********}


{ CHANGED: The original modules were compiled separately and linked into an
overlaid task (see ADVBLD.ODL).  PASTA/80 compiles everything from source, so
this main program includes all modules.  The order follows the call
dependencies, since there are no EXTERNAL declarations anymore.  }

PROGRAM ADVENTURE;

{ CHANGED: Local variables on the stack, like in OMSI Pascal.  Needed for the
recursion SAYIT -> PARSE and for overlays calling other overlays (on the Agon,
static locals of an overlay would be reset when it is reloaded).  }
{$A-}

{ CHANGED: 2K of stack are plenty (checked with $K+ during the walkthrough) and
leave more room for the heap on the Spectrum Next.  }
{$M 2048}

{$I advgbl.pas}
{$I compat.pas}

{ CHANGED: Overlays (Spectrum 128K/Next and Agon only, with --ovr).  The
grouping loosely follows ADVBLD.ODL.  All consecutive OVERLAY procedures go
into the same overlay, so the groups are separated by dummy declarations.
Overlays are limited to 8K each.  }

{  *************** DATA STRUCTURE ROUTINES  ******************  }

{$I rdwiz.pas}
{$I subs0.pas}
{$I subs1.pas}
{$I hours.pas}

{ *************  I/O  SUBROUTINES   ********************}

{$I speak.pas}
{$I getin.pas}
{$I ask.pas}

{  *****************  OVERLAY 1: CAVE CLOSING, SCORING  ****************  }

{$I calsco.pas}
{$I finish.pas}
{$I loop1.pas}

TYPE OVERLAY2=INTEGER;	{ CHANGED: Overlay separator }

{  *****************  OVERLAY 2: VERBS  ****************  }

{$I verbs3.pas}
{$I dropob.pas}
{$I dumpwd.pas}
{$I killit.pas}
{$I throwo.pas}
{$I magicw.pas}

TYPE OVERLAY3=INTEGER;	{ CHANGED: Overlay separator }

{  *****************  OVERLAY 3: MORE VERBS  ****************  }

{$I verbs0.pas}
{$I verbs1.pas}
{$I verbs2.pas}
{$I fillit.pas}
{$I getit.pas}
{$I take.pas}

TYPE OVERLAY4=INTEGER;	{ CHANGED: Overlay separator }

{  *****************  OVERLAY 4: TRAVEL  ****************  }

{$I backup.pas}
{$I noway.pas}
{$I plover.pas}
{$I trollb.pas}
{$I travel.pas}

TYPE OVERLAY5=INTEGER;	{ CHANGED: Overlay separator }

{  *****************  OVERLAY 5: SUSPEND AND MISC VERBS  ****************  }

{$I verbs4.pas}
{$I savnam.pas}
{$I savvar.pas}
{$I verbs5.pas}

TYPE OVERLAY6=INTEGER;	{ CHANGED: Overlay separator }

{  *****************  OVERLAY 6: INPUT PARSING  ****************  }

{ CHANGED: SAYIT calls PARSE recursively.  }
OVERLAY PROCEDURE PARSE;FORWARD;

{$I sayit.pas}
{$I transi.pas}
{$I parse.pas}
{$I respon.pas}

TYPE OVERLAY7=INTEGER;	{ CHANGED: Overlay separator }

{  *****************  OVERLAY 7: MAIN LOOP  ****************  }

{$I loop0.pas}

TYPE OVERLAY8=INTEGER;	{ CHANGED: Overlay separator }

{  *****************  OVERLAY 8: INITIALIZATION  ****************  }

{$I start.pas}
{$I advini.pas}

{ *****************  MAIN PROGRAM  ******************}

{  The structure of the main program block roughly follows the  F4P  version but
the spaghetti has been somewhat straightened out.   It  was  very  difficult  to 
preserve the exact flow without using massive random "goto"'s  as  was  done  in
the original.  The way I got around this problem was adding a few  program  flow 
control booleans which, in essence, cause repeat loops to exit and jump back  to 
a lower nesting level under certain conditions (check out  DRAGFLG,  which  pops 
you back from KILLOBJ to the middle of RESPONSE).   As  a  result  this  program 
probably only rates a B- for structure but  from  the  player's  standpoint,  at 
least, it appears to operate exactly as the original with a few minor changes.  
   You may argue that the thing is overly overlaid, but it does run in less than 
12Kwords  despite the size of OMSI's runtime stuff.  In the  future  I  plan  to 
investigate shrinking the OMSI  stuff  further  and  possibly  reorganizing  the 
order of things so that it will run even smaller.  The  time  required  to  swap 
out overlays is presently only slightly noticable by the player.  }

BEGIN {MAIN PROGRAM}
{$IFDEF SYS_ZXNEXT}
    SETCPUSPEED(3);	{ CHANGED: Run the Next at 28 MHz.  }
{$ENDIF}

    {  Initialize everything.  }
{$IFDEF HEAPINFO}
    WRITELN('PASTA: Heap before INITIALIZE: ',MEMAVAIL);
{$ENDIF}
    INITIALIZE;
{$IFDEF HEAPINFO}
    WRITELN('PASTA: Heap after INITIALIZE: ',MEMAVAIL);
{$ENDIF}

    { CHANGED: No "message of the day" anymore.  }
    {  Start-up, check for "prime time", saved games, etc.  }
    DEMO:=START;
    {  If allowed to start, then go....  }
    IF NOT DONE THEN BEGIN
	{  Do this only at the beginning of a new game....  }
	IF NOT SETUP THEN BEGIN
	    {  Welcome the player and (optionally) give "instructions".  
	    If he accepts it will cost him points.  }
	    HINTED[3]:=ASKR(65,1,0);
	    {  If he asked for instructions, then give him some extra lamp time.  }
	    IF HINTED[3] THEN LIMIT:=1000 ELSE LIMIT:=330;
	END;
	REPEAT {Until DONE is true}
	    MOVED:=FALSE;
	    {The beginning of this loop is repeated every time the player
	    has moved to a new location, which is indicated by MOVED 
	    becoming true. 
		First check to see if the new location is outside the cave and
	    it's closing or if a dwarf's blocking his way  (either case
	    returns with NEWLOC=LOCATION). }
	    BLOCKED;
	    {  Move to the new location.  }
	    LOCATION:=NEWLOC;
	    { Go do the dwarf stuff.  }
	    DWARFSTUFF;
	    {  Go see if this guy's still alive or not, returns with MOVED
	    true if he dies and is reincarnated or with MOVED and DONE true
	    if he's dead and that's it..   }
	    ALIVE;
	    IF NOT (MOVED OR DONE) THEN { Give him another turn..} BEGIN
		{ Tell him where he is.    }
		WHEREAREWE;
		{  If location has forced motion, do it.  }
		IF FORCED(LOCATION) THEN TRAVEL
		ELSE
		{  Otherwise, tell him what's here and respond to his
		instructions until he moves again.  }
		BEGIN
		    WHATSHERE;
		    REPEAT RESPONSE UNTIL MOVED;
		END
	    END
	UNTIL DONE;
    END;
    {  Set VT-100's back to VT-52 mode.  }
    IF VT100 THEN WRITE(#27,'[?2l')	{ CHANGED: was CHR(33B) }
END.
