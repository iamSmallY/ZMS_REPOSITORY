# ZMS_REPOSITORY

## What is it

SharePoint has a great advantage for storing Word, PowerPoint and other documents, multi-person collaboration, etc. SAP Audit Management by default stores working paper in HANA DB.  This was an architecture decision to take advantage of full-text-index of HANA, so that unstructured files can be searched from enterprise search. But many of our customers still want to store them on SharePoint. With the abstract layer of file repository, this GitHub repository implements the existing programming interface to help you switch your file storage from HANA DB to SharePoint.

## Getting Started

### Prerequisites

* Microsoft 365 for Business which contains SharePoint licence.
* Refer to the [Guide](https://github.com/iamSmallY/ABAP-SDK-for-Azure/blob/master/ABAP%20SDK%20Implementation%20Guide%20for%20Azure%20Active%20%20Directory.pdf) to configure Azure Active Directory on Azure Portal and install the enhanced [ABAP SDK for Azure](https://github.com/iamSmallY/ABAP-SDK-for-Azure) on your system.

### Setup

* Install this repository on your system by [abapGit](https://github.com/abapGit/abapGit).
* Fill in the SharePoint client_id and the user_id of the SharePoint administrator account in the [zcl_grcaud_ms_repository.clas.abap](https://github.com/iamSmallY/ZMS_REPOSITORY/blob/main/src/zcl_grcaud_ms_repository.clas.abap#L78-L79).
