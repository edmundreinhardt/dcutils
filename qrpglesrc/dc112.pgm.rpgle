     Hoption(*nodebugio:*srcstmt)
     hdftactgrp(*no) actgrp('DCAG')
     F***************************************
     F*                                     *
     F*  Get QCMDEXC Calls for RPG Programs *
     F*                                     *
     F***************************************
     F*
     F*  WRITTEN:  3/25/99
     F*  AUTHOR:   M. Jacobs
     F*
     F*  DESCRIPTION:
     F*  ------------
     F*  This program searches for QCMDEXC calls from RPG programs to
     F*  other programs and procedures.  This is done in 3 steps:
     F*
     F*  1. Read all DCPGPGP records where called pgm is QCMDEXC. For
     F*     each one, call DC012ACL, which calls DC012A, which looks
     F*     for compile-time array records with relevant commands
     F*     (STRS36PRC, CALL, etc.).  DC012A calls DC800 to search
     F*     for the called pgms.  Anything found will be written out
     F*     to DCPGPGP.
     F*
     F*  2. After all of these have been read, read FTPSRVP, which is
     F*     a file containing commands and/or pgms executed by FT0100.
     F*     Search for called pgms/procs, using DC800 for the command
     F*     field. This search will only be done on SFOFFICE, not on
     F*     CHEROKEE.
     F*
     F*  3. After analysing the FTPSRVP records, read SPSWPP, which is
     F*     a file containing commands and/or pgms executed by SP0500.
     F*     Search for called pgms/procs, using DC800 for the command
     F*     field.
     F****************************************************************
MJ01 F*  Changed 3/22/00 by M. Jacobs to include RPGLE pgms
MJ02 F*  Changed 10/25/2004 by M. Jacobs to use a work file as input
     F*    to avoid conflict with records being written to DCPGPGP
     F*    at the same time we are reading it (causes loop)
     F*  Changed 6/26/2021 by Steve T to omit dc012acl which doesn't exist
     F*    on Comanche
     F*
MJ02 Fdc112wp   if   e           k disk    rename(dcpgpg:dc112w)
     Fdspmbrl2  if   e           k disk
MJ02 Fdcpgpgp   o    e             disk
     C*
     C*  *Entry plist - machine serial# so we can condition the
     C*     Ftpsrvp read to occur for sfoffice only
     C*
     C     *entry        plist
     C                   parm                    srlnbr            8            machine serial#
     C*
     C*  List of parms to pass to dc012acl
     C*
     C     plist         plist
     C                   parm                    dpclng                         src mbr name
     C                   parm                    dpdsc                          description
     C                   parm                    mlfile           10            src file
     C                   parm                    mllib            10            src lib
     C                   parm                    dpseu                          source type
     C*
     C*  List of parms to pass to dc800
     C*
     C     plist2        plist
     C                   parm                    srcdta          120
     C                   parm                    pgm800           10
     C                   parm                    seu800           10
     C*
     C*  Read dcpgpgp for all 'qcmdexc' pgm calls; for rpg pgms,
     C*    Call dc012acl to search for actual called pgm names
     C*
     C                   movel     'QCMDEXC'     callqc           10
MJ02 C     callqc        setll     dc112wp
MJ02 C     callqc        reade     dc112wp                                22
     C     *in22         doweq     '0'
     C*
     C*
MJ01 C     dpseu         ifeq      'RPGLE   '
MJ01 C     dpclng        chain     dspmbrl2                           79
MJ01 C  n79              call      'DC012BCL'    plist
MJ01 C                   endif
     C*
MJ02 C     callqc        reade     dc112wp                                22
     C                   enddo
     C*
     C*************************************************************
     C*
     C*************************************************************
     C*
     C*  Now read spswpp and look for called pgms
     C*
     C*  1. fill out the calling pgm fields
     C*     N.b. if 'sp0500' not found, don't execute this code
     C*
     C                   movel(p)  'SP0500'      dpclng
     C     dpclng        chain     dspmbrl2                           79
     C     *in79         ifeq      '0'
     C*
     C                   move      mlmtxt        dpdsc
     C                   movel     mlseu2        dpseu
     C                   z-add     0             dpseq
     C*
     C*  2. read an spswpp record
     C*
     C                   read      spswpp                                 23
     C     *in23         doweq     '0'
     C*
     C*  3. if pgm name filled out, output a dcpgpgp record
     C*
     C     spspgm        ifne      *blanks
     C                   movel(p)  spspgm        dpcled
     C     dpcled        chain     dspmbrl2                           79
     C     *in79         ifeq      '0'
     C                   movel     mlmtxt        dpdsc2
     C                   movel     mlseu2        dpseu2
     C                   else
     C                   move      *blanks       dpdsc2
     C                   move      *blanks       dpseu2
     C                   endif
     C*
     C                   write     dcpgpg
     C                   endif
     C*
     C*  4. if command field filled out, call dc800 to see if it's
     C*     A pgm/proc call
     C*
     C     spspcm        ifne      *blanks
     C                   movel(p)  spspcm        srcdta
     C                   move      *blanks       pgm800
     C                   move      *blanks       seu800
     C                   call      'DC800'       plist2
     C     pgm800        ifne      *blanks
     C                   movel     pgm800        dpcled
     C                   movel     seu800        dpseu2
     C     dpcled        chain     dspmbrl2                           79
     C     *in79         ifeq      '0'
     C                   movel     mlmtxt        dpdsc2
     C                   else
     C                   move      *blanks       dpdsc2
     C                   endif
     C*
     C                   write     dcpgpg
     C                   endif
     C*
     C                   endif
     C*
     C*  5. read another spswpp record
     C*
     C                   read      spswpp                                 23
     C                   enddo
     C*
     C                   endif
     C*
     C**************************************************************
     C*
     C*  We are done now
     C*
     C                   seton                                        lr
     C                   return
