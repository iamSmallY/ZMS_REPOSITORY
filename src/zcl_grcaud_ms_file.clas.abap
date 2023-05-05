class ZCL_GRCAUD_MS_FILE definition
  public
  inheriting from CL_GRCAUD_FILE
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IV_PATH type STRING optional
      !IV_NAME type STRING optional
      !IO_MS_FILE type ZIF_ADF_SERVICE_GRAPH=>ITEM
      !IV_AAD_TOKEN type STRING
      !IV_USER_ID type STRING.

  methods IF_GRCAUD_FILE~GET_CONTENT
    redefinition .
  methods IF_GRCAUD_FILE~GET_CONTENT_URL
    redefinition .
  methods IF_GRCAUD_FILE~GET_ENCODING
    redefinition .
  methods IF_GRCAUD_FILE~GET_MIME_TYPE
    redefinition .
  methods IF_GRCAUD_FILE~GET_SIZE
    redefinition .
  methods IF_GRCAUD_FILE~UPDATE_CONTENT
    redefinition .
  methods IF_GRCAUD_NODE~DELETE
    redefinition .
  methods IF_GRCAUD_NODE~GET_ID
    redefinition .
  methods IF_GRCAUD_NODE~GET_NAME
    redefinition .
  methods IF_GRCAUD_NODE~GET_PATH
    redefinition .
  methods IF_GRCAUD_NODE~RENAME
    redefinition .
protected section.

  DATA: mo_ms_file TYPE zif_adf_service_graph=>item,
        ms_aad_token TYPE string,
        ms_user_id TYPE string.
private section.
ENDCLASS.



CLASS ZCL_GRCAUD_MS_FILE IMPLEMENTATION.


  method CONSTRUCTOR.
     CALL METHOD super->constructor
      EXPORTING
        iv_name   = iv_name
        iv_path   = iv_path.

    DATA: filter         TYPE zbusinessid,
          lv_http_status TYPE i,
          oref_graph     TYPE REF TO zcl_adf_service_graph.

    ms_aad_token = iv_aad_token.
    ms_user_id = iv_user_id.

    IF io_ms_file IS INITIAL.
        TRY.
            oref_graph ?= zcl_adf_service_factory=>create( iv_interface_id = 'GRAPH_GET' iv_business_identifier = filter ).
            mo_ms_file = oref_graph->zif_adf_service_graph~get_file_by_path(
                EXPORTING
                    iv_aad_token = ms_aad_token
                    iv_user_id = ms_user_id
                    iv_file_path = iv_path
                IMPORTING
                    ev_http_status = lv_http_status
            ).

          CATCH CX_STATIC_CHECK INTO DATA(cx_static_check).
            DATA(lv_string) = cx_static_check->get_text(  ).
            MESSAGE lv_string TYPE 'E'.
        ENDTRY.
    ELSE.
        mo_ms_file = io_ms_file.
    ENDIF.

  endmethod.


  METHOD IF_GRCAUD_FILE~GET_CONTENT.

  ENDMETHOD.


  method IF_GRCAUD_FILE~GET_CONTENT_URL.
    DATA: filter         TYPE zbusinessid,
          oref_graph     TYPE REF TO zcl_adf_service_graph,
          lv_http_status TYPE i.

    TRY.
        oref_graph ?= zcl_adf_service_factory=>create( iv_interface_id = 'GRAPH_GET' iv_business_identifier = filter ).
        rv_url = oref_graph->zif_adf_service_graph~get_file_download_url(
            EXPORTING
                iv_aad_token = ms_aad_token
                iv_user_id = ms_user_id
                iv_file_id = IF_GRCAUD_NODE~GET_ID( )
            IMPORTING
                ev_http_status = lv_http_status
        ).


        CATCH CX_STATIC_CHECK INTO DATA(cx_static_check).
            DATA(lv_string) = cx_static_check->get_text(  ).
            MESSAGE lv_string TYPE 'E'.
    ENDTRY.
  endmethod.


  method IF_GRCAUD_FILE~GET_ENCODING.
*CALL METHOD SUPER->IF_GRCAUD_FILE~GET_ENCODING
*  RECEIVING
*    RV_ENCODING =
*    .
  endmethod.


  method IF_GRCAUD_FILE~GET_MIME_TYPE.
    rv_type = mo_ms_file-file-mimetype.
  endmethod.


  method IF_GRCAUD_FILE~GET_SIZE.
    rv_size = mo_ms_file-size.
  endmethod.


  METHOD IF_GRCAUD_FILE~UPDATE_CONTENT.

    DATA: lo_file TYPE REF TO if_grcaud_file,
          filter         TYPE zbusinessid,
          lv_http_status TYPE i,
          oref_graph     TYPE REF TO zcl_adf_service_graph.

    TRY.
        oref_graph ?= zcl_adf_service_factory=>create( iv_interface_id = 'GRAPH_PUT' iv_business_identifier = filter ).
        oref_graph->zif_adf_service_graph~upload_file_by_id(
            EXPORTING
                iv_aad_token = ms_aad_token
                iv_user_id = ms_user_id
                iv_file_id = IF_GRCAUD_NODE~GET_ID( )
                iv_content_type = iv_mime_type
                iv_content = iv_content
            IMPORTING
                ev_http_status = lv_http_status
        ).


      CATCH CX_STATIC_CHECK INTO DATA(cx_static_check).
        RAISE EXCEPTION TYPE CX_GRCAUD_FILE_REPO
            EXPORTING
                PREVIOUS = cx_static_check.
    ENDTRY.

  ENDMETHOD.


  METHOD IF_GRCAUD_NODE~DELETE.

    DATA: filter         TYPE zbusinessid,
          oref_graph     TYPE REF TO zcl_adf_service_graph,
          lv_http_status TYPE i.

    TRY.
        oref_graph ?= zcl_adf_service_factory=>create( iv_interface_id = 'GRAPH_DEL' iv_business_identifier = filter ).
        oref_graph->zif_adf_service_graph~delete_file(
            EXPORTING
                iv_aad_token = ms_aad_token
                iv_user_id = ms_user_id
                iv_file_id = IF_GRCAUD_NODE~GET_ID( )
            IMPORTING
                ev_http_status = lv_http_status
        ).


        CATCH CX_STATIC_CHECK INTO DATA(cx_static_check).
        RAISE EXCEPTION TYPE CX_GRCAUD_FILE_REPO
            EXPORTING
                PREVIOUS = cx_static_check.
    ENDTRY.

  ENDMETHOD.


  method IF_GRCAUD_NODE~GET_ID.
    rv_id = mo_ms_file-id.
  endmethod.


  method IF_GRCAUD_NODE~GET_NAME.
    rv_name = mo_ms_file-name.
  endmethod.


  METHOD IF_GRCAUD_NODE~GET_PATH.
    DATA ls_path TYPE string.

    ls_path = CL_HTTP_UTILITY=>IF_HTTP_UTILITY~UNESCAPE_URL( mo_ms_file-parentreference-path ).
    ls_path = substring_after( val = ls_path sub = 'root:' ).
    rv_path = ls_path && '/' && IF_GRCAUD_NODE~GET_NAME(  ).

  ENDMETHOD.


  METHOD IF_GRCAUD_NODE~RENAME.
    DATA: filter         TYPE zbusinessid,
          oref_graph     TYPE REF TO zcl_adf_service_graph,
          lv_http_status TYPE i.

    TRY.
        oref_graph ?= zcl_adf_service_factory=>create( iv_interface_id = 'GRAPH_PTCH' iv_business_identifier = filter ).
        oref_graph->zif_adf_service_graph~update_file(
          EXPORTING
            iv_aad_token    = ms_aad_token
            iv_user_id = ms_user_id
            iv_file_id  = IF_GRCAUD_NODE~GET_ID( )
            iv_new_name = iv_new_name
          IMPORTING
            ev_http_status  = lv_http_status
        ).

        mo_ms_file-name = iv_new_name.

        CATCH CX_STATIC_CHECK INTO DATA(cx_static_check).
        RAISE EXCEPTION TYPE CX_GRCAUD_FILE_REPO
            EXPORTING
                PREVIOUS = cx_static_check.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
