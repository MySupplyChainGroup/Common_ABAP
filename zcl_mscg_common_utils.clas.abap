class ZCL_MSCG_COMMON_UTILS definition
  public
  final
  create public .

public section.

  class-methods GET_CONFIGURATION
    importing
      !IV_CONFIG_APPLICATION type ZMSCG_CONFIG_APPLICATION
      !IV_CONFIG_TYPE type ZMSCG_CONFIG_TYPE
    returning
      value(RT_CONFIGURATION) type ZMSCG_CONFIGURATION_TT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MSCG_COMMON_UTILS IMPLEMENTATION.


  METHOD GET_CONFIGURATION.
    SELECT application type config_key value FROM zmscg_config
      INTO TABLE rt_configuration
      WHERE application EQ iv_config_application AND type EQ iv_config_type.
  ENDMETHOD.
ENDCLASS.
