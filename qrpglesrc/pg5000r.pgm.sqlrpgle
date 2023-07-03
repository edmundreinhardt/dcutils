PG5000R
      ****************************************************************
     Hoption(*nodebugio:*srcstmt) bnddir('COMBND')
     Hdftactgrp(*no) actgrp(*new)

     Fdspffd    if   e             disk    extfile('QTEMP/DSPFFD')
     Fcmpfsqlp  o    e             disk    rename(cmpfsqlr:cmpfile)
     F
     d cmpfsqlr        pr                  extpgm('CMPFSQLR')
     d                               10a   const
     d                               10a   const
     d                               10a   const
     d                               10a   const
     d                               10a   const
     d                               10a   const
     d                               10a   const
     d                               10a   const
     d
     d cmpfsqlr        pi
     d  file                         10a   const
     d  oldlib                       10a   const
     d  newlib                       10a   const
     d  join1                        10a   const
     d  join2                        10a   const
     d  join3                        10a   const
     d  join4                        10a   const
     d  join5                        10a   const

      /free
        // Set the SQL environment
        Exec SQL
          SET OPTION COMMIT=*none, DYNUSRPRF=*owner, NAMING=*sys,
             DLYPRP=*yes, CLOSQLCSR=*endmod;
        Exec sql
          DELETE FROM cmpfsqlp WHERE file = :file;

        Setll *start dspffd;
        Read dspffd;
        Dow not %Eof();
          seq += 1;
          Select;
            When seq = 1;
              sql_stmt = 'SELECT';
              seq = seq;
              Write cmpfile;
              seq += 1;
              // o.ISRECD,n.ISRECD,
              sql_stmt = ' o.' + %Trim(whfldi) + ', n.' + %Trim(whfldi)   ;
              seq = seq;
              Write cmpfile;
              sql_stmt = ', case when ' + 'o.' + %Trim(whfldi) + '<> n.' +
                   %Trim(whfldi) + ' Then ''   #####'' else '' '' end'   ;
              seq += 1;
            Other;
              sql_stmt = ',o.' + %Trim(whfldi) + ', n.' + %Trim(whfldi)  ;
              seq = seq;
              Write cmpfile;
              sql_stmt = ', case when ' + 'o.' + %Trim(whfldi) + '<> n.' +
                   %Trim(whfldi) + ' Then ''   #####'' else '' '' end'   ;
              seq += 1;
          Endsl;
          seq = seq;
          Write cmpfile;

          Read dspffd;
        Enddo;

        // from tyhhold.inacrsp o
        seq += 1;
        sql_stmt = '  FROM ' + %Trim(oldlib) + '.' + %Trim(file) + ' o';
        Write cmpfile;
        // join tyhhnew.inacrsp n
        seq += 1;
        sql_stmt = '  FULL OUTER JOIN ' + %Trim(newlib) + '.'
                                        + %Trim(file) + ' n';
        Write cmpfile;
        // on o.isinv#=n.isinv# and o.isstr=n.isstr and o.iswhs=n.iswhs
        seq += 1;
        If join1 = *blanks;
          sql_stmt = '    ON rrn(o) = rrn(n)';
          Write cmpfile;
        Else;
          sql_stmt = '    ON ' + ' o.' + %Trim(join1) + ' = n.' + %Trim(join1);
          Write cmpfile;
          If join2 <> *blanks;
            seq += 1;
            sql_stmt = '   AND ' + ' o.' + %Trim(join2) +
                                   ' = n.' + %Trim(join2);
            Write cmpfile;
            If join3 <> *blanks;
              seq += 1;
              sql_stmt = '   AND ' + ' o.' + %Trim(join3) +
                                     ' = n.' + %Trim(join3);
              Write cmpfile;
              If join4 <> *blanks;
                seq += 1;
                sql_stmt = '   AND ' + ' o.' + %Trim(join4) +
                                       ' = n.' + %Trim(join4);
                Write cmpfile;
                If join5 <> *blanks;
                  seq += 1;
                  sql_stmt = '   AND ' + ' o.' + %Trim(join5) +
                                         ' = n.' + %Trim(join5);
                  Write cmpfile;
                Endif;
              Endif;
            Endif;
          Endif;
        Endif;
        // where
        seq += 1;
        sql_stmt = ' WHERE ';
        Write cmpfile;

        Setll *start dspffd;
        Read dspffd;
        If not %Eof;
          seq += 1;
          sql_stmt = '    o.' + %Trim(whfldi) + ' is null or n.'
                              + %Trim(whfldi) + ' is null or (' ;
          Write cmpfile;
          // o.ISRECD<>n.ISRECD or
          seq += 1;
          sql_stmt = '    o.' + %Trim(whfldi) + ' <> n.' + %Trim(whfldi)  ;
          Write cmpfile;
        Endif;
        Dow not %Eof();
          // o.ISRECD<>n.ISRECD or
          seq += 1;
          sql_stmt = ' OR o.' + %Trim(whfldi) + ' <> n.' + %Trim(whfldi)  ;
          Write cmpfile;

          Read dspffd;
        Enddo;
        seq += 1;
        sql_stmt = ' );';
        Write cmpfile;
        Return;
      /end-free