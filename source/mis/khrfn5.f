      INTEGER FUNCTION KHRFN5 (WORD1,I,WORD2,J)
C
C     THIS FUNCTION IS SAME AS KHRFN1 EXECPT THAT THE BYTE (WORD1(1) ONL
C     IS IN REVERSE ORDER.  (THIS FUNCTION IS MAINLY USED BY VAX)
C
      INTEGER  WORD1(1), WORD2(1)
      COMMON /SYSTEM/ DUMMY(40), NCPW
      KHRFN5=KHRFN1(WORD1(1),NCPW-I+1,WORD2(1),J)
      RETURN
      END
