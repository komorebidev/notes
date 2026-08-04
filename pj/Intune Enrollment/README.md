# Intune Enrollment

## For new PC

* Will need to create local admin before Intune enrollment
* Get from 1Pass and refer to new PC guide

## Before enrolling

### Microsoft 365 Admin Portal
* Add licenses to user
1. Enterprise Mobility and Security E3
1. Microsoft Defender for Endpoint P2
1. Office 365 E3

### Intune

* Add to groups
1. Windows_Intune_SG
1. Windows_Updates_SG
1. Defender_Deployment_SG 

### When enrolling

* Sometimes, URL is needed
* https://enrollment.manage.microsoft.com/enrollmentserver/discovery.svc

### For existing PC

* Download company portal
* Enroll with tenant account
* After enrollment, Ninja RMM tool will install (check and wait for install if it takes long)
* Change PC name to tr008tempxx (there is a tracker file somewhere)
* Uninstall Teamviewer after confirming Ninja tool function

### The Row

* Local accounts
* Passwords not synced
* Sometimes users get removed from the Users group due to IT script (add them back, but need local admin)
* For now, all are local admins and will use the existing accounts to work 

#### Stores

* Need to make appointment with the stores
* By Teams chat
* Retail locations so replies won't be fast
* POS system is on iPad (already enrolled Intune)
* Each store has one PC or so (Teamviewer access)
* Each staff has a phone (with Teams and Outlook)
* Printers
