*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 15.11.2017 at 10:58:26
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZMSCG_CONFIG....................................*
DATA:  BEGIN OF STATUS_ZMSCG_CONFIG                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMSCG_CONFIG                  .
CONTROLS: TCTRL_ZMSCG_CONFIG
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZMSCG_CONFIG                  .
TABLES: ZMSCG_CONFIG                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
