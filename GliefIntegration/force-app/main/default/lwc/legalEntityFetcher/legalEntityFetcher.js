import { LightningElement, track } from 'lwc';
import getLegalEntityDetails from '@salesforce/apex/LegalEntityController.getLegalEntityDetails';
import SEARCH_LABEL from '@salesforce/label/c.TXT_BTN_SEARCH'; // Import system label
import LEI_EMPTY from '@salesforce/label/c.TXT_ERR_LEI_EMPTY'; 
import LEI_TOOLONG from '@salesforce/label/c.TXT_ERR_LEI_TOO_LONG'; 


export default class LegalEntityFetcher extends LightningElement {
    @track lei = '';
    @track entity;
    @track error;
    @track isLoading = false;

    label = {
        search: SEARCH_LABEL
    };

    // Handle user input
    handleInputChange(event) {
        this.lei = event.target.value;
    }

    // Handle search button click
    handleSearch() {
        if (!this.lei || this.lei.length !== 20) {
            this.error = !this.lei ? LEI_EMPTY : LEI_TOOLONG;
            this.entity = null;
            return;
        }

        this.isLoading = true;
        this.error = null;
        this.entity = null;

        getLegalEntityDetails({ lei: this.lei })
            .then(result => {
                // Convert date fields to the user's local timezone format
                this.entity = {
                    ...result,
                    InitialRegistrationDate__c: this.formatDateToUserTimeZone(result.InitialRegistrationDate__c),
                    LastUpdateDate__c: this.formatDateToUserTimeZone(result.LastUpdateDate__c),
                    NextRenewalDate__c: this.formatDateToUserTimeZone(result.NextRenewalDate__c)
                };
            })
            .catch(error => {
                this.error = error.body?.message || error.message || 'Error fetching data.';
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    /**
     * Converts a UTC date to the user's local timezone and formats it.
     * @param {string} dateStr - The date string from Salesforce (ISO format, UTC)
     * @returns {string} - Formatted date in user's timezone or empty string if invalid
     */
    formatDateToUserTimeZone(dateStr) {
        if (!dateStr) return ''; // Handle null dates
        const date = new Date(dateStr);
        return date.toLocaleString('en-US', {
            day: '2-digit',   // Example: 18
            month: 'short',   // Example: Mar
            year: 'numeric',  // Example: 2025
        });
    }
}
