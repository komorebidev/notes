# On-prem compute to Azure

## For new VM
* Requirement is to move a PC-based workload to Azure
* Azure tenant is empty, no networking no nothing
* The customer office also has no hookup to Azure yet (because their network is managed by others)

## Discovery

### Specs

* What are the specs of the current development machine? (CPU, memory, storage)
* Does the machine run 24/7?
* How are releases maintained?

### Application
* What does the application do?
* Is it a client/server application or completely standalone?
* How many users?
* Are users in one office or multiple locations?
* What version of Windows does it currently require?
* How is the application currently installed and updated?

### Authentication
* Is there any need to restrict the app from other employees?
* How is authentication configured at the moment (if any)?

### Network
* How do users connect? (by IP? by local DNS hostname?)
* What protocols are needed? (HTTP, HTTPS?, etc)

### Data
* What database does it use? SQL Server, Access, MySQL, proprietary DB, files, etc.?
    * Python
    * MySQL
* Where is the application's data currently stored?
* Does it use Windows file shares?

### Backup
* Are there any data backup configured now?
* What is the current design? (such as for backup and restore of the database)

### Integrations
* Does it integrate with email, printers, scanners, ERP, Active Directory, APIs, etc.?
* Does it require local administrator privileges?
* Does it require a particular hostname/IP address?
* Does it rely on mapped drives?
* Does it use hard-coded IP addresses or server names?

### Monitoring
* Who will receive notifications?
* Who will take action for recovery if needed or patching/reboots?

### Cost
* What is the expected monthly budget?
* Is a single VM okay?
* Is there a need for redundancy?

## Desired user experience
* Will users continue using their existing office PCs?
* Will they connect to the application offsite?
* Can the application run on Windows Server?
* Is it compatible with Remote Desktop Services?
* Do users need to print to local office printers?
* Do they need to access local files?
* Is the application latency-sensitive?
* How many concurrent users are expected?

## Migration
* How much data needs to be migrated?
* How large is the database?
* Can the application be offline during migration?
* Who validates the migrated data?
* Who performs application testing?
* Can the old PC/server remain available during the transition?
* Who signs off that the migration was successful?

### Handover
Who will be helping with the below admin tasks?

#### Day-to-day

* Start/stop/restart services
* Check application status
* Check server health
* Check disk space
* Manage users
* Handle basic troubleshooting

#### Administration

* Windows patching
* Azure VM management
* Storage management
* Backup management
* Restore operations
* Monitoring
* Security updates

### Meeting Notes

* HTML page
* Is a dashboard
* Intranet only
* Want RDP access to the server
* Not confident to setup web server
* So just want people to remote directly into the server
* Because concerned about cybersecurity