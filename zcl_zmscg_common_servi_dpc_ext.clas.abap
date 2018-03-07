class ZCL_ZMSCG_COMMON_SERVI_DPC_EXT definition
  public
  inheriting from ZCL_ZMSCG_COMMON_SERVI_DPC
  create public .

public section.
protected section.

  methods CONFIGURATIONSET_GET_ENTITYSET
    redefinition .
  methods WAREHOUSENUMBERS_GET_ENTITYSET
    redefinition .
  methods PRODUCTLOOKUPSET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZMSCG_COMMON_SERVI_DPC_EXT IMPLEMENTATION.


  METHOD configurationset_get_entityset.
    DATA: lo_message_container TYPE REF TO /iwbep/if_message_container,
          ls_entry             TYPE zmscg_configuration,
          lt_configuration     TYPE zmscg_configuration_tt,
          lv_application       TYPE zmscg_config_application,
          lv_type              TYPE zmscg_config_type,
          lv_worst_msg_type    TYPE symsgty.

    FIELD-SYMBOLS: <lfs_application_filter> TYPE /iwbep/s_mgw_select_option,
                   <lfs_appl_select_option> TYPE /iwbep/s_cod_select_option,
                   <lfs_type_filter>        TYPE /iwbep/s_mgw_select_option,
                   <lfs_type_select_option> TYPE /iwbep/s_cod_select_option,
                   <fs_entity>              LIKE LINE OF et_entityset.

    lo_message_container = mo_context->get_message_container( ).

    " Need to make sure they pass the filter value of application, it is required.
    READ TABLE it_filter_select_options WITH TABLE KEY property = 'application' ASSIGNING <lfs_application_filter>.
    IF <lfs_application_filter> IS NOT ASSIGNED.
      " Not assigned, throw a message and exit.  Means the filter was not supplied.
      CALL METHOD lo_message_container->add_message
        EXPORTING
          iv_msg_type   = 'E'
          iv_msg_id     = 'ZMSCG_COMMON_MSGS'
          iv_msg_number = '000'
          iv_msg_v1     = 'application'.
    ENDIF.

    " Need to make sure they pass the filter value of type, it is required.
    READ TABLE it_filter_select_options WITH TABLE KEY property = 'type' ASSIGNING <lfs_type_filter>.
    IF <lfs_type_filter> IS NOT ASSIGNED.
      " Not assigned, throw a message and exit.  Means the filter was not supplied.
      CALL METHOD lo_message_container->add_message
        EXPORTING
          iv_msg_type   = 'E'
          iv_msg_id     = 'ZMSCG_COMMON_MSGS'
          iv_msg_number = '000'
          iv_msg_v1     = 'type'.
    ENDIF.

    " Check for errors.
    lv_worst_msg_type = lo_message_container->get_worst_message_type( ).
    IF lv_worst_msg_type EQ 'E'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_message_container.
    ENDIF.

    " Read the first record of the application select options.  Should only be one if used normally.
    READ TABLE <lfs_application_filter>-select_options INDEX 1 ASSIGNING <lfs_appl_select_option>.
    MOVE <lfs_appl_select_option>-low TO lv_application.

    " Read the first record of the type select options.  Should only be one if used normally.
    READ TABLE <lfs_type_filter>-select_options INDEX 1 ASSIGNING <lfs_type_select_option>.
    MOVE <lfs_type_select_option>-low TO lv_type.

    CALL METHOD zcl_mscg_common_utils=>get_configuration
      EXPORTING
        iv_config_application = lv_application
        iv_config_type        = lv_type
      RECEIVING
        rt_configuration      = et_entityset.

    " Need to add the default warehouse for the user.
    " Currently hard coded until we figure out how we want to store it.
    ls_entry-config_key = 'user.defaults.warehouseNumber'.
    GET PARAMETER ID '/SCWM/LGN' FIELD ls_entry-config_value.
    APPEND ls_entry TO et_entityset.
  ENDMETHOD.


  METHOD productlookupset_get_entityset.

  ENDMETHOD.


  METHOD warehousenumbers_get_entityset.
    SELECT d~lgnum, t~lnumt
      FROM /scwm/t300 AS d LEFT OUTER JOIN /scwm/t300t AS t ON d~lgnum = t~lgnum
      INTO TABLE @et_entityset
      WHERE t~spras = 'EN'
      ORDER BY d~lgnum.
  ENDMETHOD.
ENDCLASS.
