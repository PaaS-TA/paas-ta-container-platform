### [Index](https://github.com/PaaS-TA/Guide/blob/master/README.md) > [CP Architecture](../README.md) > Pipeline

## Purpose
This document provides an architecture of PaaS-TA Container Platform Pipeline.
<br><br>

## Container Configuration Diagram
![image](https://user-images.githubusercontent.com/80228983/146350860-3722c081-7338-438d-b7ec-1fdac09160c4.png)



| Container Name  | Role |
|-------|-----|
| Pipeline-API | Provides REST API required for pipeline control of the pipeline |
| Common-API | Provides Database API for metadata control required for service management |
| Pipeline-UI | Pipeline Service Web UI |
| Inspection -API | Provide REST APIs for quality control and results |
| Pipeline-Broker | Intermediate role applications between PaaS-TA and deployment pipeline services |
| Inspection-Svr | SonarQube Server Delivers Quality Management and Static Analytics |
| Ci-Server | Jenkins Server Build Process Management |
| Config-Server | Spring Cloud Config Server Application Configuration Management |
| PostgresSQL | Database for Quality Management Data Management |



## Description
The PaaS-TA container platform pipeline service provides the ability to build, test, static analysis and distribute, and pipelining applications to be developed, and provides a UI for managing environmental information of the applications being deployed.   


### [Index](https://github.com/PaaS-TA/Guide/blob/master/README.md) > [CP Architecture](../README.md) > Pipeline
