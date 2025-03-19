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

### Deploy to Salesforce
- **Clone repo in vscode (if public access)** : git clone https://github.com/EleoPn/glief-integration-api
- cd glief-integration-api
- cd GliefIntegration

- **Authenticate to org** : sfdx auth:web:login -a MyOrgAlias
  
- **Deploy to org** : sf project deploy start --source-dir force-app --target-org MyOrgAlias

- **Run tests**
- **apex** : sf apex run test --result-format human --target-org leboncoin-dev-ed.develop 
- **lwc** : npm run test:unit legalEntityFetcher.test.js


### To test in org, create and Assign Named Credentials
- Authorize endpoint: https://api.gleif.org/api/v1
- Create an External Credential (GLEIF_API) and a Named Credential (GLEIF_API) for URL https://api.gleif.org/api/v1, with credential principal.
- Create a Permission Set for Callout in the org, assign credential principal to the Permission Set, and assign the Permission Set to the user.
- Verify access and permissions for test users (classes, fields, objects).
- LWC: add custom lwc component to a record page (Account for example), activate and save.



### Git Branching Strategy
- Feature 1 (feature/legal-entity-apex-api) → Develop and submit a pull request.
- Feature 2 (feature/legal-entity-lwc-ui) → Branch from feature/legal-entity-apex-api, develop, and submit a pull request.
- Merge into main main after both features are complete. (or deploy to intermediate develop branch for testing)
