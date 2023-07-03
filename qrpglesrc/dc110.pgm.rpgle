     Hoption(*nodebugio:*srcstmt)
     Hdftactgrp(*no) actgrp('DCAG')
      ****************************************************************
      *                                                              *
      * Programmer.: Maggie Jacobs                                   *
      * Title......: Output to DCPGPGP from DSPPGMRF file            *
      * Date.......: 03/04/99                                        *
      *                                                              *
      *                                                              *
      * Description: Reads the DSPPGMRF file and outputs records to  *
      *              DCPGPGP after getting source description and    *
      *              SEU type.  For CLP's, calls DC116 to get the    *
      *              correct line#. For CLLE, calls DC117.           *
      *                                                              *
      ****************************************************************
      * Summary of Changes                                           *
      *                                                              *
      * Programmer    Date    Description                            *
      * ----------  --------  -------------------------------------- *
MJ01  * M. Jacobs   04/28/00  Call DC116 to get line# for CLP's.     *
MJ02  * M. Jacobs   11/26/01  Call DC117 to get line# for CLLE's.    *
MJ03  * M. Jacobs   10/20/03  Bypass DC pgms in QGPL2 (duplicates)   *
MJ04  * M. Jacobs   01/12/04  Remove MJ03 (QGPL2 pgms are gone)      *
MJ05  * M. Jacobs   10/25/04  Stop writing duplicate records         *
MJ06  * M. Jacobs   04/07/06  Include called service pgms            *
      *                                                              *
      ****************************************************************
      *
     Fdsppgmrf  ip   e             disk
     Fdspmbrl2  if   e           k disk
MJ05 Fdcpgpgp   if a e           k disk
MJ06 Fdspobjl1  if   e           k disk
     Iqwhdrppr
     I                                          whpnam        l1
MJ05 C     dpkey         klist
MJ05 C                   kfld                    dpcled
MJ05 C                   kfld                    dpclng
     C*
     C*  Restart sequence# for new pgm
     C*
     C   l1              z-add     0             seq               5 0
     C*
     C*  Select only program references
MJ06 C*  Include non-IBM service programs
     C*
     C     whobjt        ifeq      'P'
MJ06 C     whotyp        oreq      '*SRVPGM'
MJ06 C     whlnam        andne     'QSYS'
     C                   clear                   dcpgpg
     C*
     C                   move      whpnam        dpclng
     C                   movel     whfnam        dpcled
     C*
     C*  Get calling pgm text/SEU type
     C*
     C     dpclng        chain     dspmbrl2                           79
     C     *in79         ifeq      '0'
     C                   move      mlmtxt        dpdsc
     C                   move      mlseu2        dpseu
     C                   endif
MJ01 C*
MJ01 C*  If calling pgm is a CLP, call DC116 to find out the
MJ01 C*     right line#, because DSPPGMREF doesn't tell you
MJ01 C*     line numbers
MJ01 C*
MJ01 C     dpseu         ifeq      'CLP'
MJ01 C                   move      *blanks       seqnbr            6
     C*
MJ02 C     mlfile        ifeq      'QCLLESRC'
MJ02 C                   call      'DC117CL'
MJ02 C                   parm                    dpclng
MJ02 C                   parm                    mlfile
MJ02 C                   parm                    mllib
MJ02 C                   parm                    dpcled
MJ02 C                   parm                    seqnbr
MJ02 C*
MJ02 C                   else
MJ01 C                   call      'DC116CL'
MJ01 C                   parm                    dpclng
MJ01 C                   parm                    mlfile
MJ01 C                   parm                    mllib
MJ01 C                   parm                    dpcled
MJ01 C                   parm                    seqnbr
MJ02 C                   endif
MJ01 C*
MJ01 C                   endif
     C*
     C*  Get called pgm text/SEU type
     C*
MJ06 C     whotyp        ifne      '*SRVPGM'
     C
     C     dpcled        chain     dspmbrl2                           79
     C     *in79         ifeq      '0'
     C                   move      mlmtxt        dpdsc2
     C                   move      mlseu2        dpseu2
     C                   endif
     C
MJ06 C                   else
MJ06 C     dpcled        chain     dspobjl1
MJ06 C                   if        %found
MJ06 C                   movel     odobtx        dpdsc2
MJ06 C                   endif
MJ06 C                   movel     'SRVPGM'      dpseu2
MJ06 C                   endif
     C*
     C                   add       1             seq
     C                   z-add     seq           dpseq
MJ01 C*
MJ01 C*  If calling pgm is a CLP and if we were successful at
MJ01 C*     finding a line#, use that line#
MJ01 C*
MJ01 C     dpseu         ifeq      'CLP'
MJ01 C     seqnbr        andne     *blanks
MJ01 C                   move      seqnbr        dpseq
MJ01 C                   endif
     C*
MJ05 C     dpkey         chain     dcpgpgp                            79
MJ05 C   79              write     dcpgpg
     C                   endif
     C*
MJ03 C     end           tag
