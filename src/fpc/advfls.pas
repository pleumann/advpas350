{********>>>>>>>><<<<<<<<********

>>	PROGRAM:   ADVFLS
		   29-OCT-80

		When built into a task, this program is invoked by the command
	RUN ADVFLS.   It reads in the  database  and  database  pointers  from
	ADVENTURE.DAT and creates  files  ADVTXT.DTA,  KATAB.DTA,  ADVDAT.DTA,
	and ADVENT.DTA for the normal (non-VT-100) use of ADVENTURE.TSK.

********>>>>>>>><<<<<<<<********}

{ CHANGED: Ported to PASTA/80.  The original was compiled together with ADVGBL
(PAS ADVFLS=ADVGBL,ADVFLS), so we include it here.  Changes:

	1) Turbo Pascal has no file buffer variables, GET and PUT.  Records
	are written via the buffer records from ADVGBL and WRITE.

	2) OMSI numbers file records from 1, Turbo Pascal from 0.  Each file
	gets a dummy record 0, so all record numbers stay the same.

	3) The Turbo Pascal runtime can't READ comma-separated integers or
	integers directly followed by text, so ADVENTURE.DAT is read line by
	line and split up by RDNUM, RDLINE and RDWORD.

	4) The initial wizardry file ADVWIZ.DTA (formerly created by the
	separate program POOF) is created here, too.  It only holds the saved
	games now.  }

PROGRAM ADVFLS;

{ CHANGED: Turbo Pascal mode, like the game itself.  }
{$MODE TP}

{$I advgbl.pas}

{ $C	.TITLE ADVFLS
	.IDENT /V0/  }

{  For a complete description of the database refer to the comments in
module ADVINI.  }

VAR TXTFILE:TEXT;
    ADVENT,ADVDAT:FILE OF INTEGER;
{ CHANGED: Current input line and position within it.  }
    TXTBUF:STRING[127];
    TXTPOS:INTEGER;

{ CHANGED: Reads the next integer from TXTFILE, skipping blanks, line ends
and a single comma following the number.  }
PROCEDURE RDNUM(VAR N:INTEGER);
VAR NEG:BOOLEAN;
BEGIN
    WHILE TXTPOS>LENGTH(TXTBUF) DO BEGIN
	READLN(TXTFILE,TXTBUF);
	TXTPOS:=1;
	WHILE (TXTPOS<=LENGTH(TXTBUF)) AND (TXTBUF[TXTPOS]=' ') DO
	    TXTPOS:=TXTPOS+1
    END;
    NEG:=TXTBUF[TXTPOS]='-';
    IF NEG THEN TXTPOS:=TXTPOS+1;
    N:=0;
    WHILE (TXTPOS<=LENGTH(TXTBUF)) AND (TXTBUF[TXTPOS] IN ['0'..'9']) DO BEGIN
	N:=N*10+ORD(TXTBUF[TXTPOS])-ORD('0');
	TXTPOS:=TXTPOS+1
    END;
    IF NEG THEN N:=-N;
    IF (TXTPOS<=LENGTH(TXTBUF)) AND (TXTBUF[TXTPOS]=',') THEN
	TXTPOS:=TXTPOS+1
END;

{ CHANGED: Returns the rest of the current line (at most 72 characters, like
the original READLN into an array of 72 characters) and skips to the next
line.  }
PROCEDURE RDLINE(VAR S:LINE);
BEGIN
    S:=COPY(TXTBUF,TXTPOS,72);
    TXTPOS:=LENGTH(TXTBUF)+1
END;

{ CHANGED: Like RDLINE, but for a five letter word, padded with blanks.  }
PROCEDURE RDWORD(VAR W:WORD);
BEGIN
    W:=COPY(TXTBUF,TXTPOS,5);
    WHILE LENGTH(W)<5 DO W:=W+' ';
    TXTPOS:=LENGTH(TXTBUF)+1
END;

{ This procedure transfers text records from ADVENTURE.DAT to ADVTXT.DTA and
keeps track of the record numbers.  }
PROCEDURE GETTEXT;
VAR REC,I,J,LOC,OLDLC:INTEGER;
    LINES:LINE;

PROCEDURE PUTTXT;
BEGIN
    OLDLC:=LOC;
    WHILE LOC=OLDLC DO BEGIN
	RDLINE(LINES);
	TXTREC.LOC:=LOC;
	TXTREC.TXT:=LINES;
	WRITE(ADVTXT,TXTREC);
	REC:=REC+1;
	SEEK(ADVTXT,REC);
	RDNUM(LOC)
    END
END;

BEGIN { gettxt }
    ASSIGN(ADVTXT,'ADVTXT.DTA');
    REWRITE(ADVTXT);
    TXTREC.LOC:=0;
    TXTREC.TXT:='';
    WRITE(ADVTXT,TXTREC);
    REC:=1;
    FOR I:=1 TO LOCSIZ DO BEGIN
	LTEXT[I]:=0;
	STEXT[I]:=0
    END;
    FOR I:=1 TO MAXTRS DO PTEXT[I]:=0;
    FOR I:=1 TO 300 DO RTEXT[I]:=0;
    CTEXT:=0;
    FOR I:=1 TO 100 DO MTEXT[I]:=0;
    WRITELN('Now loading section  1');
    SEEK(ADVTXT,REC);
    RDNUM(LOC);
    WHILE LOC<>-1 DO BEGIN
	LTEXT[LOC]:=REC;
	PUTTXT
    END;
    RDLINE(LINES);
    WRITELN('Now loading section  2');
    RDNUM(LOC);
    WHILE LOC<>-1 DO BEGIN
	STEXT[LOC]:=REC;
	PUTTXT
    END;
    RDLINE(LINES);
    WRITELN('Now loading section  3');
    RDNUM(LOC);

    WHILE LOC<>-1 DO BEGIN
	PTEXT[LOC]:=REC;
	PUTTXT;
	WHILE (LOC=0)OR(LOC>MAXTRS) DO PUTTXT
    END;
    RDLINE(LINES);
    WRITELN('Now loading section  4');
    RDNUM(LOC);
    WHILE LOC<>-1 DO BEGIN
	RTEXT[LOC]:=REC;
	PUTTXT
    END;
    RDLINE(LINES);
    WRITELN('Now loading section  5');
    RDNUM(LOC);
    CTEXT:=REC;
    WHILE LOC<>-1 DO PUTTXT;
    RDLINE(LINES);
    WRITELN('Now loading section  6');
    RDNUM(LOC);
    WHILE LOC<>-1 DO BEGIN
	MTEXT[LOC]:=REC;
	PUTTXT
    END;
    RDLINE(LINES);
    CLOSE(ADVTXT)
END;

{ This procedure reads the vocabulary section of ADVENTURE.DAT and creates
the tree structured version in KATAB.DTA }
PROCEDURE READVOCAB;
VAR LINES:WORD;
    LOC,I,J,K,L,M,N:INTEGER;
    LTR:CHAR;

{ CHANGED: Replaces SEEK(KATAB,N) with its implicit read into the file buffer.
The file stays positioned at record N, so a following PUTREC writes there.  }
PROCEDURE SEEKREC(N:INTEGER);
BEGIN
    SEEK(KATAB,N);
    IF N<FILESIZE(KATAB) THEN BEGIN
	READ(KATAB,KATREC);
	SEEK(KATAB,N)
    END
END;

{ CHANGED: Replaces PUT(KATAB).  }
PROCEDURE PUTREC;
BEGIN
    WRITE(KATAB,KATREC)
END;

PROCEDURE GETLTR;
BEGIN
    I:=I+1;
    IF I<=5 THEN LTR:=LINES[I] ELSE LTR:=' ';
    IF LTR='2' THEN LTR:='T' ELSE IF (LTR='?')OR(LTR='"') THEN LTR:='Q';
    K:=ORD(LTR)
END;

PROCEDURE NEWREC;
VAR J:INTEGER;	{ CHANGED: Turbo Pascal 5.5 and Free Pascal want local loop variables. }
BEGIN
    SEEKREC(L);
    FOR J:=65 TO 90 DO KATREC.NXT[J]:=0;
    FOR J:=1 TO 2 DO KATREC.VAL[J]:=-1;
    L:=L+1;
    GETLTR
END;

BEGIN { readvocab }
    WRITELN('Now loading section  7');
    FOR I:=65 TO 90 DO KTAB[I]:=0;
    ASSIGN(KATAB,'KATAB.DTA');
    REWRITE(KATAB);
    FOR J:=65 TO 90 DO KATREC.NXT[J]:=0;
    FOR J:=1 TO 2 DO KATREC.VAL[J]:=-1;
    PUTREC;
    L:=1;

    RDNUM(LOC);
    WHILE LOC<>-1 DO BEGIN
	RDWORD(LINES);
	I:=0;
	GETLTR;
	M:=KTAB[K];
	IF M<>0 THEN BEGIN
	    SEEKREC(M);
	    GETLTR;
	    IF LTR<>' ' THEN WHILE KATREC.NXT[K]<>0 DO BEGIN
		N:=KATREC.NXT[K];
		SEEKREC(N);
		GETLTR;
		IF LTR=' ' THEN BREAK	{ CHANGED: OMSI EXIT leaves the loop. }
	    END;
	END ELSE BEGIN
	    KTAB[K]:=L;
	    NEWREC
	END;
	WHILE LTR<>' ' DO BEGIN
	    KATREC.NXT[K]:=L;
	    PUTREC;
	    NEWREC
	END;
	IF KATREC.VAL[1]=-1 THEN KATREC.VAL[1]:=LOC
	ELSE KATREC.VAL[2]:=LOC;
	PUTREC;
	RDNUM(LOC)
    END;
    CLOSE(KATAB)
END;

{ This procedure saves all the record pointer arrays created as the text and
vocabulary were transferred.  }
PROCEDURE SAVPTR;
VAR REC,I:INTEGER;

PROCEDURE PUTPTR(X:INTEGER);
BEGIN
    WRITE(ADVDAT,X);
    REC:=REC+1;
    SEEK(ADVDAT,REC)
END;

BEGIN
    ASSIGN(ADVDAT,'ADVDAT.DTA');
    REWRITE(ADVDAT);
    REC:=0;
    PUTPTR(0);
    FOR I:=1 TO LOCSIZ DO PUTPTR(LTEXT[I]);
    FOR I:=1 TO LOCSIZ DO PUTPTR(STEXT[I]);
    FOR I:=1 TO MAXTRS DO PUTPTR(PTEXT[I]);
    FOR I:=1 TO 300 DO PUTPTR(RTEXT[I]);
    FOR I:=1 TO 100 DO PUTPTR(MTEXT[I]);
    PUTPTR(CTEXT);
    FOR I:=ORD('A') TO ORD('Z') DO PUTPTR(KTAB[I]);
    CLOSE(ADVDAT)

END;

PROCEDURE SAVADV;
VAR I,SEC,REC,X:INTEGER;
BEGIN
    ASSIGN(ADVENT,'ADVENT.DTA');
    REWRITE(ADVENT);
    X:=0;
    WRITE(ADVENT,X);
    REC:=1;
    WRITELN('Now loading section  8');
    RDNUM(X);
    WHILE X<>-1 DO BEGIN
	WRITE(ADVENT,X);
	REC:=REC+1;
	SEEK(ADVENT,REC);
	RDNUM(X)
    END;
    WRITELN('Now loading section  9');
    WRITE(ADVENT,X);
    REC:=REC+1;
    SEEK(ADVENT,REC);
    RDNUM(X);
    WHILE X<>-1 DO FOR I:=1 TO 3 DO BEGIN
	WRITE(ADVENT,X);
	REC:=REC+1;
	SEEK(ADVENT,REC);
	RDNUM(X)
    END;
    WRITE(ADVENT,X);
    REC:=REC+1;
    SEEK(ADVENT,REC);
    FOR SEC:=10 TO 12 DO BEGIN
	WRITELN('Now loading section',SEC:3);
	RDNUM(X);
	WHILE X<>-1 DO BEGIN
	    WRITE(ADVENT,X);
	    REC:=REC+1;
	    SEEK(ADVENT,REC);
	    RDNUM(X)
	END;
	WRITE(ADVENT,X);
	REC:=REC+1;
	IF SEC<>12 THEN SEEK(ADVENT,REC)
    END;
    CLOSE(ADVENT)
END;

{ CHANGED: Creates the initial wizardry file, like POOF did.  The record usage
assignments are documented in module SAVNAM.  Only the parts still needed for
saved games are written, the magic word and number, cave hours, holidays and
message of the day are gone.  }
PROCEDURE SAVWIZ;
VAR I:INTEGER;

PROCEDURE PUTWIZ(X:INTEGER);
BEGIN
    WRITE(ADVWIZ,X)
END;

BEGIN
    WRITELN('Now creating saved games file');
    ASSIGN(ADVWIZ,'ADVWIZ.DTA');
    REWRITE(ADVWIZ);
    {  Records 0..39 are not used anymore.  }
    FOR I:=0 TO 39 DO PUTWIZ(0);
    {  Set count of saved games to zero. }
    PUTWIZ(0);
    {  Set latency to zero (no longer used).  }
    PUTWIZ(0);
    {  Fill the saved game names with blanks.  }
    FOR I:=42 TO 101 DO PUTWIZ(ORD(' ')-ORD('A'));
    {  Fill saved game area with zeroes.  }
    FOR I:=102 TO 860 DO PUTWIZ(0);
    CLOSE(ADVWIZ)
END;

BEGIN	{ FILES INITIALIZATION PROGRAM }
    WRITELN('Files Creation for Adventure');
    WRITELN('Be patient, it takes a while to do this.....');
    ASSIGN(TXTFILE,'ADVENTUR.DAT');	{ CHANGED: CP/M needs 8.3 names. }
    RESET(TXTFILE);
    TXTBUF:='';
    TXTPOS:=1;
    GETTEXT;
    READVOCAB;
    SAVPTR;
    SAVADV;
    CLOSE(TXTFILE);
    SAVWIZ;
    WRITELN('....done!')
END.
