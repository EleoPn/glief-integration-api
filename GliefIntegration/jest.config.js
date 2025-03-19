const { jestConfig } = require('@salesforce/sfdx-lwc-jest/config');

module.exports = {
    ...jestConfig,
    moduleNameMapper: {
        '^@salesforce/apex/(.*)$': '<rootDir>/force-app/main/default/lwc/legalEntityFetcher/__tests__/jest-mocks/apex.js'
    },
    modulePathIgnorePatterns: ['<rootDir>/.localdevserver']
};
