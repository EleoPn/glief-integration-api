import { createElement } from 'lwc';
import LegalEntityFetcher from 'c/legalEntityFetcher';
import getLegalEntityDetails from '@salesforce/apex/LegalEntityController.getLegalEntityDetails';

// Mock a successful Apex call
jest.mock('@salesforce/apex/LegalEntityController.getLegalEntityDetails', () => ({
    default: jest.fn()
}));

function flushPromises() {
    return new Promise(resolve => setTimeout(resolve, 0));
}

describe('c-legal-entity-fetcher', () => {
    afterEach(() => {
        // Clean up the DOM after each test
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('displays an error if the LEI is invalid', async () => {
        const element = createElement('c-legal-entity-fetcher', {
            is: LegalEntityFetcher
        });
        document.body.appendChild(element);

        // Simulate incorrect input
        const input = element.shadowRoot.querySelector('lightning-input');
        input.value = '123';
        input.dispatchEvent(new Event('change'));

        // Trigger the search
        const button = element.shadowRoot.querySelector('lightning-button');
        button.click();

        await Promise.resolve(); // Wait for the DOM update

        // Verify that the error message is displayed
        const errorMessage = element.shadowRoot.querySelector('.slds-text-color_error');
        expect(errorMessage).not.toBeNull();
        expect(errorMessage.textContent).toBe('c.TXT_ERR_LEI_TOO_LONG');
    });

    it('displays the legal entity details after a successful search', async () => {
        const mockEntity = {
            LegalName__c: 'Test Corp',
            LEI__c: '12345678901234567890',
            Status__c: 'Active',
            RegistrationStatus__c: 'Registered',
            Category__c: 'Financial',
            InitialRegistrationDate__c: '2024-01-01T00:00:00.000Z',
            LastUpdateDate__c: '2025-03-18T12:00:00.000Z',
            NextRenewalDate__c: '2026-01-01T00:00:00.000Z',
            LegalAddress__c: '123 Legal Street',
            LegalCity__c: 'Paris',
            LegalPostalCode__c: '75001',
            LegalCountry__c: 'FR',
            Jurisdiction__c: 'France'
        };
    
        getLegalEntityDetails.mockResolvedValue(mockEntity);
    
        const element = createElement('c-legal-entity-fetcher', {
            is: LegalEntityFetcher
        });
        document.body.appendChild(element);
    
        // Simulate correct input
        const input = element.shadowRoot.querySelector('lightning-input');
        input.value = '12345678901234567890';
        input.dispatchEvent(new Event('change'));
    
        // Simulate clicking the search button
        const button = element.shadowRoot.querySelector('lightning-button');
        button.click();
    
        await flushPromises(); // ✅ Wait for the DOM update
    
        // Verify that the details are displayed
        const details = element.shadowRoot.querySelectorAll('.slds-item');
        expect(details.length).toBeGreaterThan(0);
        expect(details[0].textContent).toContain('Test Corp');
        expect(details[1].textContent).toContain('Status: Active');
    });

    it('displays an error if the Apex call fails', async () => {
        getLegalEntityDetails.mockRejectedValue(new Error('Apex error'));

        const element = createElement('c-legal-entity-fetcher', {
            is: LegalEntityFetcher
        });
        document.body.appendChild(element);

        // Simulate correct input
        const input = element.shadowRoot.querySelector('lightning-input');
        input.value = '12345678901234567890';
        input.dispatchEvent(new Event('change'));

        // Simulate clicking the search button
        const button = element.shadowRoot.querySelector('lightning-button');
        button.click();

        await flushPromises(); // Wait for the mocked response

        // Verify that the error message is displayed
        const errorMessage = element.shadowRoot.querySelector('.slds-text-color_error');
        expect(errorMessage).not.toBeNull();
        expect(errorMessage.textContent).toBe('Apex error');
    });
});
