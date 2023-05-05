class ZCL_GRCAUD_MS_REPOSITORY definition
  public
  inheriting from CL_GRCAUD_FILE_REPOSITORY
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IS_FLREPO_INFO type GRCAUD_S_FLREPO
    raising
      CX_GRCAUD_FILE_REPO .

  methods IF_GRCAUD_FILE_REPOSITORY~GET_FILE
    redefinition .
  methods IF_GRCAUD_FILE_REPOSITORY~GET_FOLDER
    redefinition .
protected section.

  data MO_SESSION type ref to IF_NWECM_SESSION .

  methods CREATE_FILE_INSTANCE
    importing
      !IV_PATH type STRING
      !IO_MS_FILE type ZIF_ADF_SERVICE_GRAPH=>ITEM optional
    returning
      value(RO_FILE) type ref to IF_GRCAUD_FILE .

  methods CREATE_FOLDER_INSTANCE
    redefinition .
private section.
  DATA: ms_authorization_code TYPE string,
        ms_aad_token TYPE string,
        ms_client_id TYPE string,
        ms_user_id TYPE string.

  methods GET_AAD_TOKEN
    returning
      value(RS_TOKEN) type STRING
    raising
      CX_STATIC_CHECK.

  methods GET_ITEM_EXIST
    importing
      !IV_TOKEN type STRING
      !IV_PATH type STRING
    returning
      value(RS_EXIST) type STRING
    raising
        CX_STATIC_CHECK.
ENDCLASS.



CLASS ZCL_GRCAUD_MS_REPOSITORY IMPLEMENTATION.


  METHOD CONSTRUCTOR.
    DATA: lo_repos_config     TYPE REF TO cl_grcaud_file_repos_config.

    DATA: lv_namespace TYPE string,
          lv_name      TYPE string.

    CALL METHOD super->constructor
      EXPORTING
        is_flrepo_info = is_flrepo_info.

    CREATE OBJECT lo_repos_config.

    lv_namespace = lo_repos_config->read_value_by_name(
                                                     EXPORTING iv_name = if_grcaud_file_repository=>sc_config_name-namespace
                                                               iv_id   = 'ZMS' ).
    lv_name = lo_repos_config->read_value_by_name(
                                                     EXPORTING iv_name = if_grcaud_file_repository=>sc_config_name-name
                                                               iv_id   = 'ZMS' ).

    ms_client_id = ''.
    ms_user_id = ''.

    TRY.
        ms_aad_token = GET_AAD_TOKEN( ).

        CATCH cx_static_check INTO DATA(cx_static_check).
            DATA(lv_text) = cx_static_check->get_text(  ).
            MESSAGE lv_text TYPE 'E'.
    ENDTRY.

  ENDMETHOD.


  method CREATE_FILE_INSTANCE.
    create OBJECT ro_file TYPE zcl_grcaud_ms_file
      EXPORTING
        iv_path = iv_path
        io_ms_file = io_ms_file
        iv_aad_token = ms_aad_token
        iv_user_id = ms_user_id.
  endmethod.


  METHOD CREATE_FOLDER_INSTANCE.
    CREATE OBJECT ro_folder TYPE zcl_grcaud_ms_folder
      EXPORTING
        iv_name    = iv_name
        iv_path    = iv_path
        iv_aad_token = ms_aad_token
        iv_user_id = ms_user_id.
  ENDMETHOD.


  METHOD GET_AAD_TOKEN.
    DATA: filter         TYPE zbusinessid,
          lv_http_status TYPE i,
          oref_aad_token TYPE REF TO zcl_adf_service_aad.

    oref_aad_token ?= zcl_adf_service_factory=>create( iv_interface_id = 'AAD_TOKEN' iv_business_identifier = filter ).

    oref_aad_token->get_aad_token(
      EXPORTING
        iv_client_id = ms_client_id " Input client id as per implementation guide for AAD
      IMPORTING
        ev_aad_token = rs_token
        ev_response = DATA(lv_response)
    ).

  ENDMETHOD.


  METHOD GET_ITEM_EXIST.
    DATA: filter         TYPE zbusinessid,
          lv_http_status TYPE i,
          oref_graph     TYPE REF TO zcl_adf_service_graph.

    oref_graph ?= zcl_adf_service_factory=>create( iv_interface_id = 'GRAPH_GET' iv_business_identifier = filter ).
    oref_graph->zif_adf_service_graph~get_file_by_path(
        EXPORTING
            iv_aad_token = iv_token
            iv_user_id = ms_user_id
            iv_file_path = iv_path
        IMPORTING
            ev_http_status = lv_http_status
    ).

    IF lv_http_status EQ 404.
        rs_exist = abap_false.
    ELSE.
        rs_exist = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD IF_GRCAUD_FILE_REPOSITORY~GET_FILE.
    DATA: lv_http_status TYPE i,
          lr_path       TYPE REF TO cl_nwecm_path,
          lr_ecm_node   TYPE REF TO if_nwecm_node,
          lr_ecm_folder TYPE REF TO if_nwecm_folder,
          lr_ecm_file   TYPE REF TO if_nwecm_file.
    DATA: lv_current_path TYPE string.

    TRY.
        DATA(ls_exist) = GET_ITEM_EXIST(
            EXPORTING
                iv_token = ms_aad_token
                iv_path = iv_path
        ).

        IF ls_exist EQ abap_true.
          ro_file = create_file_instance( iv_path = iv_path ).
        ENDIF.

        CATCH CX_STATIC_CHECK INTO DATA(cx_static_check).
            RAISE EXCEPTION TYPE CX_GRCAUD_FILE_REPO
                EXPORTING
                    PREVIOUS = cx_static_check.
    ENDTRY.
  ENDMETHOD.


  METHOD IF_GRCAUD_FILE_REPOSITORY~GET_FOLDER.

    DATA: filter         TYPE zbusinessid,
          oref_graph     TYPE REF TO zcl_adf_service_graph,
          lv_http_status TYPE i.


    TRY.
        DATA(ls_exist) = GET_ITEM_EXIST(
            EXPORTING
                iv_token = ms_aad_token
                iv_path = iv_path
        ).

        IF ls_exist EQ abap_true.
            CALL METHOD super->if_grcaud_file_repository~get_folder
                EXPORTING
                  iv_path   = iv_path
                RECEIVING
                  ro_folder = ro_folder.
        ENDIF.

        CATCH CX_STATIC_CHECK INTO DATA(cx_static_check).
        RAISE EXCEPTION TYPE CX_GRCAUD_FILE_REPO
            EXPORTING
                PREVIOUS = cx_static_check.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
