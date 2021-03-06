      SUBROUTINE BGRID
C
C     THIS ROUTINE COMPUTES PROBLEM SIZE, INTEGER PACKING FACTOR, AND
C     MAXGRD AND MAXDEG CONSTANTS.
C     THIS ROUTINE IS USED ONLY IN BANDIT MODULE
C
      EXTERNAL        ANDF
      INTEGER         GRID(2),  SEQGP,    GEOM1,    TWO,      ANDF,
     1                GEOM2,    GEOM4,    SCR1,     REW,      SUB(2),
     2                ITRL(8)
      CHARACTER       UFM*23,   UWM*25,   UIM*29
      COMMON /XMSSG / UFM,      UWM,      UIM
      COMMON /MACHIN/ MACHX
      COMMON /BANDA / IBUF1,    NOMPC,    NODEP,    NOPCH,    NORUN,
     1                METHOD,   ICRIT,    NGPTS(2)
      COMMON /BANDB / NBITIN,   KOR,      DUM,      NGRID,    IPASS,
     1                NW,       KDIM,     NBPW,     IREPT
      COMMON /BANDD / IDUM5D(5),NZERO,    NEL,      NEQ,      NEQR
      COMMON /BANDS / NN,       MM,       DUM2S(2), MAXGRD,   MAXDEG,
     1                KMOD,     MACH,     MINDEG,   NEDGE,    MASK
      COMMON /BANDW / DUM4W(4), I77
      COMMON /GEOMX / GEOM1,    GEOM2,    GEOM4,    SCR1
      COMMON /SYSTEM/ ISYS(100)
      COMMON /TWO   / TWO(1)
      COMMON /NAMES / RDUM(4),  REW,      NOREW
      COMMON /ZZZZZZ/ Z(1)
      EQUIVALENCE     (NOUT,ISYS(2))
      DATA            IGEOM1,   IGEOM2,   IGEOM4,   ISCR1   /
     1                201,      208,      210,      301     /
      DATA            KDIMX,    NELX,     NEQX,     NEQRX   /
     1                150,      0,        0,        0       /
      DATA            GRID,     SEQGP,    SUB               /
     1                4501,45,  53,       4HBGRI,4HD        /
C
      IF (IREPT .EQ. 2) GO TO 100
      GEOM1 = IGEOM1
      GEOM2 = IGEOM2
      GEOM4 = IGEOM4
      SCR1  = ISCR1
      NEL   = NELX
      NEQ   = NEQX
      NEQR  = NEQRX
      NGRID = 0
C
C     BANDIT QUITS IF DMI CARDS ARE PRESENT. (CHK WAS DONE IN IFS2P)
C     RE-SET PROGRAM PARAMETERS IF USER REQUESTED VIA NASTRAN CARD.
C
      K = ISYS(I77)
      IF (K) 250,30,10
   10 IF (K .EQ. +9) GO TO 230
      DO 20 I = 1,7
      ITRL(I) = MOD(K,10)
      K = K/10
   20 CONTINUE
      IF (ITRL(1).GT.0 .AND. ITRL(1).LE.4) ICRIT  = ITRL(1)
      IF (ITRL(2).GT.0 .AND. ITRL(2).LE.3) METHOD = ITRL(2) - 2
      NOMPC = ITRL(3)
      IF (ITRL(4) .EQ. 1) NODEP = -NODEP
      IF (ITRL(5) .EQ. 1) NOPCH = -NOPCH
      IF (ITRL(5) .EQ. 9) NOPCH = +9
      IF (ITRL(6) .EQ. 1) NORUN = -NORUN
      IF (ITRL(7).GE.2 .AND. ITRL(7).LE.9) KDIM = ITRL(7)
C
   30 IF (NORUN .EQ. +1) GO TO 40
C
C     OPEN GEOM1 FILE AND CHECK THE PRESENCE OF ANY SEQGP CARD.  IF
C     ONE OR MORE IS PRESENT, ABORT BANDIT JOB.  OTHERWISE CONTINUE TO
C     COUNT HOW MANY GRID POINTS IN THE PROBLEM.
C     RESET GEOM1 TO THE BEGINNING OF GRID DATA FOR BSEQGP, AND CLOSE
C     GEOM1 WITHOUT REWINDING THE FILE
C
C     COMMENT FROM G.CHAN/SPERRY
C     IF TIME AND $ ALLOW, WE SHOULD MAKE USE OF THE SORTED GRID DATA
C     FROM GEOM1 FILE AND GET RID OF INV, INT, NORIG, ILD ARRAYS LATER.
C     THE SCATTERING TECHNEQUE (REALLY A HASHING METHOD) CAN BE REPLACED
C     BY A SIMPLE BINARY SEARCH. ROUTINES SCAT, BRIGIT, AND INTERN
C     COULD BE ELIMINATED.
C
      ITRL(1) = GEOM1
      CALL RDTRL (ITRL)
      J  = ITRL(2) + ITRL(3) + ITRL(4) + ITRL(5) + ITRL(6) + ITRL(7)
      IF (ITRL(1).LT.0 .OR. J.EQ.0) GO TO 250
      K  = SEQGP
      K1 = (K-1)/16
      K2 = K - 16*K1
      K  = ANDF(ITRL(K1+2),TWO(K2+16))
      IF (K .NE. 0) GO TO 210
C
C     WE ASSUME THAT THE GRID POINT DATA IN GEOM1 AT THIS TIME IS NOT
C     SORTED. IF IT IS, WE CAN BLAST READ THE GRID POINT RECORD AND
C     TAKE THE LAST GRID POINT TO BE THE LARGEST GRID EXTERNAL NUMBER.
C
   40 CALL PRELOC (*170,Z(IBUF1),GEOM1)
      CALL LOCATE (*70,Z(IBUF1),GRID,K)
      MAX = 0
   50 CALL READ (*60,*60,GEOM1,ITRL,8,0,K)
      NGRID = NGRID + 1
      IF (ITRL(1) .GT. MAX) MAX = ITRL(1)
      GO TO 50
   60 CALL BCKREC (GEOM1)
   70 CALL CLOSE (GEOM1,NOREW)
C
C     IF SPOINTS ARE PRESENT, ADD THEM TO THE GRID COUNT
C
      N = 0
      CALL PRELOC (*90,Z(IBUF1),GEOM2)
      NGPTS(1) = 5551
      NGPTS(2) = 49
      CALL LOCATE (*80,Z(IBUF1),NGPTS,K)
      CALL READ (*80,*80,GEOM2,Z(1),IBUF1,1,N)
   80 CALL CLOSE (GEOM2,REW)
   90 NGPTS(1) = NGRID
      NGPTS(2) = N
      NGRID = NGRID + N
C
      IF (NOPCH.EQ.9 .AND. NGRID.EQ.1) NGRID = MAX
  100 IF (NGRID .LE.  0) GO TO 180
      IF (NGRID .LT. 15) GO TO 160
C
C     SET WORD PACKING CONSTANT, NW - (NUMBER OF INTEGERS PER WORD)
C     MACHX =  1 DUMMY,   =  2 IBM 360/370, =  3 UNIVAC 1100, =  4 CDC,
C           =  5 VAX 780, =  6 DEC ULTRIX,  =  7 SUN,         =  8 AIX,
C           =  9 HP,      = 10 SILIC.GRAPH  = 11 MAC,         = 12 CRAY,
C           = 13 CONVEX,  = 14 NEC          = 15 FUJITSU,     = 16 DG,
C           = 17 AMDAHL   = 18 PRIME        = 19 486,         = 20 DUMMY
C           = 21 ALPHA    = 22 RESERVED
C
      GO TO (130,120,130,110,120,120,120,120,120,120,
     1       120,135,120,110,110,120,120,120,120,120,
     2       120,120), MACHX
  110 NW = 6
      IF (NGRID .GT.   510) NW = 5
      IF (NGRID .GT.  2045) NW = 4
      IF (NGRID .GT. 16380) NW = 3
      IF (NGRID .GT.524288) NW = 2
      GO TO 140
  120 NW = 2
      GO TO 140
  130 NW = 4
      IF (NGRID .GT. 508) NW = 3
      IF (NGRID .GT.4095) NW = 2
      GO TO 140
  135 NW = 8
      IF (NGRID.GT.255) NW = 4
C
  140 NBITIN = NBPW/NW
      MASK   = 2**NBITIN - 1
C
C     KDIM IS THE ARRAY DIMENSNION OF A SCRATCH ARRAY USED ONLY BY GPS
C     METHOD. IT IS 150 WORDS OR 10% OF TOTAL GRID POINT NUMBER. IF
C     USER SPECIFIED BANDTDIM = N, (WHERE N IS FROM 1 THRU 9), THE ARRAY
C     DIMENSION WILL BE N*10 PERCENT INSTEAD OF THE DEFAULT OF 10%.
C
      KDIM = NGRID*KDIM/10
      IF (METHOD .NE. -1) KDIM = MAX0(KDIM,KDIMX,NGRID/10)
      IF (METHOD .EQ. -1) KDIM = MIN0(KDIM,KDIMX,NGRID/10)
      N = NGRID
      IF (N .LT. 10) N = 10
C
C     CALCULATE WIDTH MAXDEG AND EFFECTIVE LENGTH MAXGRD OF IG MATRIX.
C
      MAXGRD = N
      KORE   = KOR
  150 MAXDEG = ((((KORE-4*KDIM-8*MAXGRD-5)*NW)/(MAXGRD+NW))/NW)*NW
      MAXDEG = MIN0(MAXDEG,MAXGRD-1)
      IF (MAXDEG .LE. 0) GO TO 200
      J      = MAXDEG*2.2
      KORE   = KORE - J
      IF (KOR-J .EQ. KORE) GO TO 150
C
C     INITIALIZE VARIABLES
C
      NN     = 0
      MM     = 0
      NEDGE  = 0
      IPASS  = 0
      KMOD   = 2*MAXGRD - IFIX(2.3715*SQRT(FLOAT(MAXGRD)))
      MINDEG = 500000
      RETURN
C
C     ERROR OR QUIT
C
  160 WRITE  (NOUT,280) UIM
      WRITE  (NOUT,270)
      GO TO  250
  170 CALL MESAGE (-1,GEOM1,SUB)
  180 WRITE  (NOUT,280) UIM
      WRITE  (NOUT,190)
  190 FORMAT (5X,25HTHE ABSENCE OF GRID CARDS)
      CALL CLOSE (GEOM1,REW)
      GO TO  250
  200 CALL MESAGE (-8,0,SUB)
  210 WRITE  (NOUT,280) UIM
      WRITE  (NOUT,220)
  220 FORMAT (5X,27HTHE PRESENCE OF SEQGP CARDS)
      GO TO  250
  230 WRITE  (NOUT,280) UIM
      WRITE  (NOUT,240)
  240 FORMAT (5X,25HTHE PRESENCE OF DMI CARDS)
  250 ISYS(I77) = 0
      IF (NOPCH .GT. 0) ISYS(I77) = -2
      IF (ISYS(I77) .NE. -2) WRITE (NOUT,260)
  260 FORMAT (1H0,10X,'**NO ERRORS FOUND - EXECUTE NASTRAN PROGRAM**')
  270 FORMAT (5X,'SMALL PROBLEM SIZE')
  280 FORMAT (A29,' -  GRID-POINT RESEQUENCING PROCESSOR BANDIT IS ',
     1       'NOT USED DUE TO')
      RETURN
      END
