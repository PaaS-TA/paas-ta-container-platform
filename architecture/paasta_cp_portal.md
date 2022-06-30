### [Index](https://github.com/PaaS-TA/Guide/blob/master/README.md) > [CP Architecture](../README.md) > Portal

## Purpose
This document provides an architecture for portal services on the PaaS-TA Container Platform (CP)..
<br><br>

## Contaier  Configuration Diagram
![image](https://user-images.githubusercontent.com/67575226/147046843-e7dd3c3d-c8d5-442c-bc9b-9469cba3e67c.png)



| Container Name  | Role |
|-------|----|
| Admin-Portal | Container Platform Manager Portal UI |
| User-Portal | Container Platform User Portal UI |
| Portal-API | Provides the REST API required for container platform portal service control |
| Common-API | Provides Database API for metadata control required for service management |
| Service-Broker | Application for relay role between PaaS-TA and container platform portal service |
| MariaDB | Container Platform Portal Service Database for Data Management |


## Description
The PaaS-TA container platform portal service provides a UI for managing workloads in deployed Kubernetes clusters and controlling container deployment and management by tenant.


### [Index](https://github.com/PaaS-TA/Guide/blob/master/README.md) > [CP Architecture](../README.md) > Portal
