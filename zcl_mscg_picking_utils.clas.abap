class ZCL_MSCG_PICKING_UTILS definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IV_WAREHOUSE_NUMBER type /SCWM/LGNUM .
  methods WAVE_PICKING_COMPLETE
    importing
      !IV_WAVE type /SCWM/DE_WAVE
    exporting
      !ET_DOCID type /SCWM/DLV_DOCID_ITEM_TAB
      value(EV_COMPLETE) type BOOLEAN .
protected section.

  data GV_WAREHOUSE_NUMBER type /SCWM/LGNUM .
private section.
ENDCLASS.



CLASS ZCL_MSCG_PICKING_UTILS IMPLEMENTATION.


  METHOD constructor.
    " Set global variables.
    gv_warehouse_number = iv_warehouse_number.
  ENDMETHOD.


  METHOD wave_picking_complete.
    TYPES : BEGIN OF ty_docid,
              rdocid TYPE /scwm/de_docid,
              doccat TYPE /scdl/dl_doccat,
            END OF ty_docid.

    DATA: ls_docid     TYPE /scwm/dlv_docid_item_str,
          lt_status    TYPE TABLE OF /scdl/db_status,
          ls_status    TYPE  /scdl/db_status,
          lt_docid_tmp TYPE TABLE OF ty_docid,
          ls_docid_tmp TYPE  ty_docid.

    FIELD-SYMBOLS:  <lfs_docid> TYPE /scwm/dlv_docid_item_str.

    " Default complete.
    ev_complete = abap_true.

    SELECT a~rdocid b~doccat FROM /scwm/waveitm AS a
      INNER JOIN /scdl/db_proch_o AS b ON b~docid = a~rdocid
      INTO TABLE lt_docid_tmp WHERE a~lgnum = gv_warehouse_number AND a~wave = iv_wave.

    IF lt_docid_tmp IS NOT INITIAL.
      SORT lt_docid_tmp BY rdocid.
      DELETE ADJACENT DUPLICATES FROM lt_docid_tmp.

      LOOP AT lt_docid_tmp INTO ls_docid_tmp.
        ls_docid-docid =  ls_docid_tmp-rdocid.
        ls_docid-doccat =  ls_docid_tmp-doccat.
        APPEND ls_docid TO et_docid.
      ENDLOOP.

      IF et_docid IS NOT INITIAL.
        SELECT * FROM (/scdl/if_dbal_db_c=>db_status)
          APPENDING CORRESPONDING FIELDS OF TABLE lt_status
          FOR ALL ENTRIES IN et_docid
          WHERE docid = et_docid-docid AND status_type = /scdl/if_dl_status_c=>sc_t_picking.

        DELETE lt_status WHERE status_value EQ /scdl/if_dl_status_c=>sc_v_not_relevant.
        LOOP AT et_docid ASSIGNING <lfs_docid>.
          LOOP AT lt_status INTO ls_status WHERE docid = <lfs_docid>-docid AND
                                                 status_value NE /scdl/if_dl_status_c=>sc_v_confirmed.
            ev_complete = abap_false.
            RETURN.
          ENDLOOP.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
