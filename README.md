# Legal Entity Management - Salesforce Project

## Overview  
This project provides a **Legal Entity management system** in Salesforce, allowing users to **search for legal entities** using their **LEI (Legal Entity Identifier)**. It consists of:  
- **Apex Controller** to fetch Legal Entity details from an external API.  
- **LWC (Lightning Web Component)** for the user interface to enter and display entity details.  

---


## Feature 1: Fetch Legal Entity Details (Apex)  
### Description  
This feature retrieves a Legal Entity record from Salesforce or an external API based on the **LEI (Legal Entity Identifier)**.  
[Feature Documentation (APEX) - Legal Entity Upsert & API Synchronization.pdf](https://github.com/user-attachments/files/19339311/Feature.Documentation.APEX.-.Legal.Entity.Upsert.API.Synchronization.pdf)


---

## Feature 2: Lightning Web Component (LWC) for Search & Display  
### Description  
This LWC component allows users to search for a **Legal Entity by entering an LEI** and displays the entity details.  
[Legal Entity Fetcher (LWC) - Documentation.pdf](https://github.com/user-attachments/files/19339327/Legal.Entity.Fetcher.LWC.-.Documentation.pdf)

End user guide [Legal Entity Fetcher - How it works.pdf](https://github.com/user-attachments/files/19339388/Legal.Entity.Fetcher.-.How.it.works.pdf)

---

## Deployment Guide  

### Prerequisites  
- Salesforce CLI  
- Authorized Dev Hub  
- Connected Salesforce Org  

### Retrieve Metadata  
sfdx force:source:retrieve -m ApexClass,LightningComponentBundle,CustomObject,CustomLabels,ApexTrigger

### Create and Assign Named Credentials
- Authorize endpoint: https://api.gleif.org/api/v1
- Create an External Credential (GLEIF_API) and a Named Credential (GLEIF_API) for URL https://api.gleif.org/api/v1, with credential principal.
- Create a Permission Set for Callout in the org, assign credential principal to the Permission Set, and assign the Permission Set to the user.
- Verify access and permissions for test users (classes, fields, objects).

### Deploy to Salesforce
sfdx force:source:deploy -p force-app

### Git Branching Strategy
- Feature 1 (feature/legal-entity-apex-api) → Develop and submit a pull request.
- Feature 2 (feature/legal-entity-lwc-ui) → Branch from feature/legal-entity-apex-api, develop, and submit a pull request.
- Merge into main after both features are complete.
