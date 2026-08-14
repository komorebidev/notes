# Developer Sandbox

* Microsoft offers free E5 licenses for companies partnered with them
* Sign up for a developer profile using your work email
* Note that they are only good for 90 days and will be deleted automatically on inactivity
* https://learn.microsoft.com/en-us/office/developer-program/microsoft-365-developer-program-get-started#troubleshooting


## Signing up for the sandbox

* After registering for a developer account, it will take you straight to sandbox setup
* Select the instant sandbox option
* It will ask you to setup a billing account and profile for your account (not related to company's tenant)
* Go through billing account setup and add credit card information
* If succesfull, it will say account is ready and prompt for closing window
* It is possible to get stuck at this point with billing account not populating
* In this case, it is needed to create both an Azure subscription and invoice plan on the Azure tenant created under the work email
* Can follow this guide: https://learn.microsoft.com/en-us/office/developer-program/microsoft-365-developer-program-get-started#troubleshooting
* It is not detailed well but it is required to setup an invoice plan first and then create a Azure subscription (Azure plan) to link to it
* This will allow the billing account and profile to populate on the sandbox signup prompt

## Removing test subscription

* After generating the dev sandbox, it will appear in the subscriptions
* Delete the test subscription created to proceed with sandbox setup if needed
* It will take three days for the cancellation to process and allow for detach of credit card