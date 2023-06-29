**FREE

Ctl-Opt dftactgrp(*no) actgrp('DCAG');
CTL-Opt debug(*Yes);
CTL-Opt option(*SrcStmt : *NoDebugIO : *NoShowCpy);

/include 'qrpgleref/rpg_pr.rpgleinc'


// ********************************************
//                                           *
//  Read List of Modules                     *
//                                           *
// ********************************************
//  Description:  This program reads a list of source members from
//                DSPFD *ALL *MBRLIST command for PROCEDURES src
//                files and calls DC251CL to read the actual mbr.
// ***************************************************************
// ***************************************************************
Dcl-F dspmod; 

Dcl-Ds dspmodDs extname('DSPMOD': *INPUT) Alias Qualified;
End-Ds;

// This is a new comment
// Loop through all the modules and call dc251cl for each
Setll *start dspmod;
Dou (%Eof(dspmod));
  Read dspmod dspmodDs;
  If (%Eof(dspmod)); 
    Iter;
  Endif;

  //  Call processing pgm
  dc251cl(mlname:mlmtxt:mlfile:mllib:mlseu2);
Enddo;

*inlr = *on;

