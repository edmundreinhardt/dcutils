     Hoption(*nodebugio:*srcstmt)
     Hdftactgrp(*no) actgrp('DCAG')
      ****************************************************************
      *                                                              *
      * Program....: DC251                                           *
      * Title......: Look for procedures in module mbr               *
      * Programmer.: Maggie Jacobs                                   *
      * Date.......: 10/04/2006                                      *
      *                                                              *
      *                                                              *
      * Description: Looks for procedures  and writes records to     *
      *              DCPROCP.                                        *
      *                                                              *
      *                                                              *
      ****************************************************************
      * Summary of Changes                                           *
      *                                                              *
      * Programmer    Date    Description                            *
      * ----------  --------  -------------------------------------- *
      *                                                              *
      ****************************************************************
      *
     Fqrpglesrc ip   f  132        disk
     Fdspmbrl2  if   e           k disk
     Fdcprocp   o    e           k disk
     D
      *==============================================================
      *  Data structures, arrays, constants...
      *==============================================================
      *
      *  Program data structure
      *
     D                SDS
     D  @pgmq                  1     10
     D  @parms                37     39  0
     D  @job                 244    253
     D  @user                254    263
     D  @job#                264    269  0
     D  @date                276    281  0
     D  @dyy                 276    277  0
     D  @time                282    285  0
     I
      *
      *  Source line
      *
     Iqrpglesrc ns  10
     I                                  1    6 2seq#
     I                                 13  112  srcdta
     I                                 18   18  pspec
     I                                 19   19  coment
     I                                 19   33  proc
     I                                 36   36  begin
     I                                 93  112  desc
     C
      *==============================================================
      *  Mainline
      *==============================================================
      *
     C     *entry        plist
     C                   parm                    p1name           10
     C                   parm                    p1text           50
     C                   parm                    p1file           10
     C                   parm                    p1lib            10
     C                   parm                    p1seu            10
MJ01  *
MJ01  *  Look for procedure "begin" statement
MJ01  *
     C                   if        (pspec = 'p' or pspec = 'P') and
     C                             (begin = 'b' or begin = 'B') and
     C                             coment <> '*'
     C
     C                   eval      prproc = %trim(proc)
     C                   eval      prmodl = p1name
     C                   eval      prmdds = p1text
     C
     C                   if        desc <> *blanks
     C                   eval      prprds = desc
     C                   else
     C                   eval      prprds = prmdds
     C                   endif
     C
     C                   write     dcproc
     C                   endif
      *==============================================================
