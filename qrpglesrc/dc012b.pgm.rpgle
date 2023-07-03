     Hoption(*nodebugio:*srcstmt)
     Hdftactgrp(*no) actgrp('DCAG')

     
     F****************************************************
     F*                                                  *
     F*  Look for QCMDEXC-Called Pgms in RPGLE Src Mbr   *
     F*                                                  *
     F****************************************************
     F*
     F*  Written:  3/22/00
     F*  Author:   M. Jacobs
     F*
     F*  Description:  This program reads an RPGLE src member and
     F*                looks for programs called via statements in
     F*                compile-time arrays. When one is found,
     F*                a record is written out to the DCPGPGP file.
     F*                This file will be used for a called-to-calling
     F*                program cross reference display.
     F*
     F*                This program was cloned from DC012A.
     F**************************************************************
MJ01 F* Changed 10/25/2004 by M. Jacobs to use correct desc and not
     F*   write multiple records for a pgm
     F* Converted to rpgle 3/27/2006 by M. Jacobs
     F**************************************************************
     Fqrpgsrc   ip   f  112        disk
     Fdspmbrl2  if   e           k disk
MJ01 Fdcpgpgp   if a e           k disk
     D
     D**************************************************************
     D*  These arrays will enable us to look for quotes in the
     D*    called pgm name and strip them out
     D*
     D ar1             s              1    dim(9)
     D ar2             s              1    dim(9)
     D*
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
MJ01 C     dpkey         klist
MJ01 C                   kfld                    dpcled
MJ01 C                   kfld                    dpclng
     C*
     C*  PLIST for DC800
     C*
     C     plist2        plist
     C                   parm                    srcdt1          120
     C                   parm                    pgm800           10
     C                   parm                    seu800           10
     C*
     C*  Look for lines beginning with '**'
     C*  When one is found, it means we have reached the first
     C*    compile-time array
     C*  Seton indicator to start looking for called pgms/procs
     C*
     C     star2         ifeq      '**'
     C                   move      'Y'           ready             1
     C                   endif
     C*
     C     ready         ifeq      'Y'
     C*
     C*  Call DC800 to look for pgm/proc names
     C*
     C                   movel     srcdta        srcdt1
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
MJ01 C   24              move      *blanks       dpdsc2
     C                   z-add     seq#          dpseq
     C*
MJ01 C     dpkey         chain     dcpgpgp                            25
MJ01 C  n25              write     dcpgpg
     C                   endif
     C*
     C                   endif
