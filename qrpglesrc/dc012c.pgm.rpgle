     Hoption(*nodebugio:*srcstmt)
     Hdftactgrp(*no) actgrp('DCAG')
     F****************************************************
     F*                                                  *
     F*  Look for free-format calls in RPGLE src mbr     *
     F*                                                  *
     F****************************************************
     F*
     F*  Written:  8/04/2003
     F*  Author:   M. Jacobs
     F*
     F*  Description:  This program reads an RPGLE src member and
     F*                looks for programs called via free-format
     F*                calls in C-specs. When one is found,
     F*                a record is written out to the DCPGPGP file.
     F*                This file will be used for a called-to-calling
     F*                program cross reference listing.
     F*
     F*                This program was cloned from DC012B.
     F**************************************************************
MJ01 F*  Changed 8/4/2003 by M. Jacobs to modify the original
     F*    cloned source to locate free-format calls
     F*  Converted to rpgle 3/27/2006 by M. Jacobs
     F**************************************************************
     Fqrpgsrc   ip   f  112        disk
     Fdspmbrl2  if   e           k disk
     Fdcpgpgp   o    e             disk
     D
     D**************************************************************
     D*  Fields needed within the source record
     D*
     D                 ds
     D  srcdta                 1    100
     D  star2                  1      2
     D  c                      6      6
     D  star                   7      7
     D*
     D*  Constants
     D*
     D quote           c                   const('''')
     D*
     D lc              c                   const('abcdefghijklmnopqrst-
     D                                     uvwxyz')
     D uc              c                   const('ABCDEFGHIJKLMNOPQRST-
     D                                     UVWXYZ')
     I
     I**************************************************************
     Iqrpgsrc   ns  10
     I                                  1    6 2seq#
     I                                 13  112  srcdta
     C
     C**************************************************************
     C     *entry        plist
     C                   parm                    dpclng                         src mbr name
     C                   parm                    dpdsc                          description
     C                   parm                    mlfile           10            src file
     C                   parm                    mllib            10            src lib
     C                   parm                    dpseu            10            source type
     C*
     C*  PLIST for DC800
     C*
     C     plist2        plist
     C                   parm                    srcdt1          120
     C                   parm                    pgm800           10
     C                   parm                    seu800           10
     C*
     C*  Look for C-specs (non-comment ones)
     C*  When found, translate record to upper case to make scanning
     C*    easier
     C*  See if the word 'CALL' is found
     C*
MJ01 C     c             ifeq      'C'
MJ01 C     c             oreq      'c'
MJ01 C     star          ifne      '*'
     C*
MJ01 C     lc:uc         xlate     srcdta        srcdt2          120
MJ01 C     'CALL'        scan      srcdt2                                 33
MJ01 C     *in33         ifeq      *on
     C*
     C*  Call DC800 to look for pgm/proc names
     C*
MJ01 C                   movel     srcdt2        srcdt1
     C                   move      *blanks       pgm800
     C                   move      *blanks       seu800
     C                   call      'DC800'       plist2
     C*
     C*  If a pgm name is found, move the info in
     C*
     C     pgm800        ifne      *blanks
     C                   move      pgm800        dpcled
     C                   move      seu800        dpseu2
     C*
     C     dpcled        chain     dspmbrl2                           24
     C  n24              movel     mlmtxt        dpdsc2
     C                   z-add     seq#          dpseq
     C                   write     dcpgpg
     C                   endif
     C*
     C                   endif
     C*
MJ01 C                   endif
MJ01 C                   endif
