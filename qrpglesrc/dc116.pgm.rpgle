     Hoption(*nodebugio:*srcstmt)
     Hdftactgrp(*no) actgrp('DCAG')
      ****************************************************************
      *                                                              *
      * Programmer.: Maggie Jacobs                                   *
      * Title......: Determine line# for CLP's called programs       *
      * Date.......: 04/28/00                                        *
      *                                                              *
      *                                                              *
      * Description: Called from DC110 for CLP calling programs.     *
      *              Receives called pgm name and returns the line   *
      *              number it occurs on.                            *
      *                                                              *
      ****************************************************************
      * Summary of Changes                                           *
      *                                                              *
      * Programmer    Date    Description                            *
      * ----------  --------  -------------------------------------- *
MJ01  * M. Jacobs   11/17/03  Change all lowercase to uppercase      *
MJ02  * M. Jacobs   04/20/04  Make input file internally described   *
      *                       so we can accommodate different format *
      *                       names                                  *
      *                                                              *
      ****************************************************************
      *
MJ02 Fqclsrc    ip   f   92        disk
      *
      *  This DS allows us to check the input record position
      *    by position
     D                 ds
     D  srcdta                 1     80
     D  ara                    1     80
     D                                     dim(80)                              input record
      *
      *  This DS allows us to blank out the unused spaces in the
      *    field being checked for the called pgm name, so we can
      *    do a good compare
     D                 ds
     D  chek10                 1     10
     D  chk                    1     10
     D                                     dim(10)                              called pgm name
MJ01  *
MJ01  *  These constants allow us to translate lower to upper case
MJ01  *
     D lwr             c                   const('abcdefghijklmnopqrst-
     D                                     uvwxyz')
     D upr             c                   const('ABCDEFGHIJKLMNOPQRST-
     D                                     UVWXYZ')
MJ02  *
MJ02  *  Input specs for QCLSRC
MJ02  *
MJ02 Iqclsrc    ns  10
MJ02 I                                  1    6 2srcseq
MJ02 I                                  7   12 0srcdat
MJ02 I                                 13   92  srcdta
      *
      *  Receive the called pgm name; pass back the source seq
      *    line#
     C     *entry        plist
     C                   parm                    dpcled           10
     C                   parm                    seq               6
MJ01  *
MJ01  *  Change lower to upper case so case differences don't cause
MJ01  *    us to not find the pgm
MJ01  *
MJ01 C                   move      srcdta        fld80            80
MJ01 C     lwr:upr       xlate     fld80         srcdta
      *
      *  Look for beginning and ending of comments; if 55 is on,
      *    that means we are in comment status and will not bother
      *    to look for pgm name.  Comment status can extend across
      *    multiple lines.
      *
     C     1             do        80            x                 3 0
     C                   movea     ara(x)        check2            2
     C*
     C     check2        ifeq      '/*'
     C                   seton                                        55
     C                   endif
     C*
     C     check2        ifeq      '*/'
     C                   setoff                                           55
     C                   endif
      *
      *  If 55 is now off, move the next 10 bytes into the checking
      *     field CHEK10
      *  Note that the actual length of the called pgm name has
      *     been figured out, and spaces past that point will be
      *     blanked out so that the compare can work if the name
      *     is found
      *  However, spaces will only be blanked out if we determine
      *     that the name is ending here (delimited by a space,
      *     end parenthesis, or comma). This restriction is to
      *     avoid the situation of looking for CALL DC111 and
      *     locating CALL DC111CL.  If the CL is blanked out,
      *     it looks like we've found the call when we actually
      *     haven't.
      *
     C     *in55         ifeq      *off
     C                   movea     ara(x)        chek10
     C     y             ifle      10
     C     chk(y)        ifeq      ' '
     C     chk(y)        oreq      ')'
     C     chk(y)        oreq      ','
     C                   movea     *blanks       chk(y)
     C                   endif
     C                   endif
      *
      *  If the name is found, return the source line number to
      *     DC110
      *
     C     chek10        ifeq      dpcled
     C                   move      srcseq        seq
     C                   seton                                        lr
     C                   return
     C                   endif
      *
     C                   endif
     C                   enddo
      *
      *****************************************************************
      *
     C     *inzsr        begsr
      *
      *  Find length of called pgm name; then add 1 to it to get
      *    the place where we should start blanking out CHEK10
      *
     C     ' '           checkr    dpcled        y                 3 0
      *
     C     y             ifne      0
     C                   add       1             y
     C                   else
     C                   z-add     11            y
     C                   endif
     C*
     C                   endsr
      *
      *****************************************************************
