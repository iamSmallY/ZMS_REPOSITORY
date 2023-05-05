CLASS zcl_grcaud_ms_folder DEFINITION
  PUBLIC
  INHERITING FROM cl_grcaud_folder
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        !iv_path       TYPE string
        !iv_name       TYPE string OPTIONAL
        !iv_aad_token TYPE string
        !iv_user_id TYPE string.

    METHODS if_grcaud_folder~create_file
        REDEFINITION .
    METHODS if_grcaud_folder~create_folder
        REDEFINITION .
    METHODS if_grcaud_folder~get_child
        REDEFINITION .
    METHODS if_grcaud_folder~get_children
        REDEFINITION .
    METHODS if_grcaud_node~rename
        REDEFINITION .
  PROTECTED SECTION.

  PRIVATE SECTION.
  DATA ms_aad_token TYPE string.
  DATA ms_user_id TYPE string.
ENDCLASS.



CLASS ZCL_GRCAUD_MS_FOLDER IMPLEMENTATION.


  METHOD constructor.

    CALL METHOD super->constructor
      EXPORTING
        iv_name = iv_name
        iv_path = iv_path.

    ms_aad_token = iv_aad_token.
    ms_user_id = iv_user_id.
  ENDMETHOD.


  METHOD if_grcaud_folder~create_file.

    DATA: lo_file TYPE REF TO if_grcaud_file,
          filter         TYPE zbusinessid,
          lv_http_status TYPE i,
          oref_graph     TYPE REF TO zcl_adf_service_graph.

    TRY.

        oref_graph ?= zcl_adf_service_factory=>create( iv_interface_id = 'GRAPH_PUT' iv_business_identifier = filter ).
        DATA(lo_ms_file) = oref_graph->zif_adf_service_graph~upload_file_by_path(
            EXPORTING
                iv_aad_token = ms_aad_token
                iv_user_id = ms_user_id
                iv_path = iv_path
                iv_content_type = iv_mime_type
                iv_content = iv_content
            IMPORTING
                ev_http_status = lv_http_status
        ).
        CREATE OBJECT ro_file TYPE zcl_grcaud_ms_file
          EXPORTING
            iv_path = iv_path
            iv_name = iv_name
            io_ms_file = lo_ms_file
            iv_aad_token = ms_aad_token
            iv_user_id = ms_user_id.

      CATCH CX_STATIC_CHECK INTO DATA(cx_static_check).
        RAISE EXCEPTION TYPE CX_GRCAUD_FILE_REPO
            EXPORTING
                PREVIOUS = cx_static_check.
    ENDTRY.
  ENDMETHOD.


  METHOD if_grcaud_folder~create_folder.

    DATA: filter         TYPE zbusinessid,
          oref_graph     TYPE REF TO zcl_adf_service_graph,
          lv_http_status TYPE i.

    TRY.

        oref_graph ?= zcl_adf_service_factory=>create( iv_interface_id = 'GRAPH_GET' iv_business_identifier = filter ).
        DATA(ls_parent_folder) = oref_graph->zif_adf_service_graph~get_file_by_path(
          EXPORTING
            iv_aad_token = ms_aad_token
            iv_user_id = ms_user_id
            iv_file_path = mv_path
        ).

        oref_graph ?= zcl_adf_service_factory=>create( iv_interface_id = 'GRAPH_POST' iv_business_identifier = filter ).
        oref_graph->zif_adf_service_graph~create_folder(
          EXPORTING
            iv_aad_token = ms_aad_token
            iv_user_id = ms_user_id
            iv_parent_id = ls_parent_folder-id
            iv_folder_name = iv_name
            iv_conflict_behavior = 'rename'
          IMPORTING
            ev_http_status = lv_http_status
        ).

      CREATE OBJECT ro_folder TYPE zcl_grcaud_ms_folder
          EXPORTING
            iv_name = iv_name
            iv_path = mv_path && iv_name
            iv_aad_token = ms_aad_token
            iv_user_id = ms_user_id.

      CATCH CX_STATIC_CHECK INTO DATA(cx_static_check).
        RAISE EXCEPTION TYPE CX_GRCAUD_FILE_REPO
            EXPORTING
                PREVIOUS = cx_static_check.
    ENDTRY.

  ENDMETHOD.


  METHOD if_grcaud_folder~get_child.
*CALL METHOD SUPER->IF_GRCAUD_FOLDER~GET_CHILD
*  EXPORTING
*    IV_NAME  =
**    iv_id    =
*  RECEIVING
*    RO_CHILD =
*    .
  ENDMETHOD.


  METHOD if_grcaud_folder~get_children.
*CALL METHOD SUPER->IF_GRCAUD_FOLDER~GET_CHILDREN
*  RECEIVING
*    RT_CHILD =
*    .
  ENDMETHOD.


  METHOD if_grcaud_node~rename.
**TRY.
*CALL METHOD SUPER->IF_GRCAUD_NODE~RENAME
*  EXPORTING
*    IV_NEW_NAME =
*    .
** CATCH cx_grcaud_file_repo .
**ENDTRY.
  ENDMETHOD.
ENDCLASS.
