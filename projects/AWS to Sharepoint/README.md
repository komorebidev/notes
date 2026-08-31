# AWS to Sharepoint

* EC2 Windows file server will be retired
* Contents to be synced to Sharepoint site
* First, destination sharepoint site will need to be erased

## Tools

* Sharepoint Migration Tool
* Installed on the ec2 instance
* No effect on ec2 performance (SSD backed)
* No effect on customer circuit (AWS hosted)

## Permissions

* Groups and users are already migrated on destination Sharepoint
* Need to manually check and compare the ACL from Windows side and Sharepoint side

## Testing

* After the sync completes, need to test Intune policies
* Checking how long the Sharepoint items take to sync (estimate 数時間)
* Informing the customer to start the sync proactively (they have two PC for each employee)

## Backup

* Synology NAS is planned as onsite backup
* Nightly incrementals at 22pm
* Use Microsoft active backup plugin