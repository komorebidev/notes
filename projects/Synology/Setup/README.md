# Setup

* Noted for DS925+ but applicable for other models

## Admin page

* http://finds.synology.com/
* Will detect NAS on the network
* Or use local program, Synology Assistant
* https://www.synology.com/en-global/support/download/DS925+?version=7.4#utilities
* https://www.synology.com/support/download

## Joining to Microsoft Entra Domain Services

* Pricy, use if it is already there
* https://kb.synology.com/en-global/DSM/tutorial/How_to_join_NAS_to_Azure_AD_Domain#:~:text=DNS%20Server%3A%20Enter%20the%20Entra%20ID%20managed,the%20status%20%22Connected%22%20at%20the%20Domain%20tab.

| Tier / SKU | Approximate Monthly Cost (USD) | Object / Auth Capacity Limits |
| :--- | :--- | :--- |
| Standard | ~$110/month (~$0.15/hour) | Up to 25,000 objects, 3,000 auth loads/hour |
| Enterprise | ~$292/month (~$0.40/hour) | Up to 100,000 objects, 10,000 auth loads/hour |
| Premium | ~$1,168/month (~$1.60/hour) | Up to 500,000 objects, 70,000 auth loads/hour |

## Joining to Entra ID for authentication

* Cheaper option that most orgs already have enabled

Configuring Microsoft Entra ID (Azure AD) login for your Synology NAS using OpenID Connect (OIDC) involves registering an application in Microsoft Entra and mapping those details in DSM. 

* https://kb.synology.com/en-global/DSM/help/DSM/AdminCenter/file_directory_service_sso_Azure?version=7

### Step 1: Register an App in Microsoft Entra
1. Sign in to the [Microsoft Entra admin center](https://entra.microsoft.com/).
2. Go to **Microsoft Entra ID** > **App registrations** > **New registration**.
3. Enter a display **Name** (e.g., `Synology NAS`).
4. Under *Supported account types*, select **Accounts in this organizational directory only**.
5. Leave the *Redirect URI* blank for now and click **Register**.

### Step 2: Generate Credentials and Retrieve IDs
1. Once registered, on the application's **Overview** page, copy and save:
   * **Application (client) ID**
   * **Directory (tenant) ID**
2. Go to **Manage** > **Certificates & secrets** > **New client secret**. 
3. Add a description, choose an expiration period, and click **Add**. 
4. **Immediately copy the Secret Value** (it will disappear once you leave the page).

### Step 3: Configure the Redirect URI
1. In your Entra app registration, go to **Manage** > **Authentication**.
2. Click **Add a platform** and select **Web**.
3. Under *Redirect URIs*, input your Synology login URL using this exact format:
   `https://your-nas-domain-or-ip:5001/` (or port `5000` for HTTP, though HTTPS is strongly recommended).
4. Click **Configure**.

### Step 4: Configure Synology DSM
1. Log in to your Synology DSM as an administrator.
2. Go to **Control Panel** > **Domain/LDAP** > **SSO Client**.
3. Check the box for **Enable OpenID Connect SSO service** and click **OpenID Connect SSO Settings**.
4. In the pop-up window, fill out the fields:
   * **Profile:** Select `Microsoft Entra ID`
   * **Application ID:** Paste the *Application (client) ID* from Step 2.
   * **Application Secret (Keys):** Paste the *Client Secret* value from Step 2.
   * **Directory ID:** Paste the *Directory (tenant) ID* from Step 2.
   * **Redirect URI:** Paste your NAS redirect URL from Step 3.
5. Click **Save** and then **Apply** on the main Control Panel page.

Users can now select **SSO Authentication** on the DSM login screen to sign in using their Microsoft Entra credentials.

1. Log in to your Synology DSM as an administrator. Go to **Control Panel** > **Domain/LDAP** > **SSO Client**.
2. Check the box for **Enable OpenID Connect SSO service** and click the **OpenID Connect SSO Settings** button.
3. From the **Profile** drop-down menu, select **Microsoft Entra ID**.
4. Fill out the corresponding fields using the values from your Microsoft Entra app registration:
   * **Application ID:** Enter your Entra *Application (client) ID*.
   * **Application Secret (Keys):** Enter your Entra *Client Secret* value.
   * **Directory ID:** Enter your Entra *Directory (tenant) ID*.
   * **Redirect URI:** Enter your NAS login URL (e.g., `https://your-nas-ip-or-domain:5001/`).
5. Click **Save** to close the pop-up window, and then click **Apply** on the main Control Panel page.

## Remote access 

* Use built-in QuickConnect
* https://kb.synology.com/en-global/DSM/tutorial/Which_services_support_QuickConnect
* Not all packages can be accessed by QuickConnect

### Accessible packages on QuickConnect

| Type | Items |
| :--- | :--- |
| Web applications 2 | Active Backup for Business, Active Backup for Google Workspace, Active Backup for Microsoft 365, Active Insight, Application Portal, Audio Station, Bitdefender for MailPlus, Download Station, File Station, Log Center, Moments, Note Station, PDF Viewer, Photo Station, Surveillance Station, Synology AI Console, Synology Calendar, Synology Chat, Synology Contacts, Synology Drive, Synology MailPlus, Synology MailPlus Server, Synology Office, Synology Photos, Text Editor, Video Station, Virtual Machine Manager, WebDAV |
| Mobile applications | DS audio, DS cam, DS cloud, DS file, DS finder, DS get, DS note, DS photo, DS router, DS video, Secure SignIn, Synology Chat, Synology Drive, Synology LiveCam, Synology MailPlus, Synology Moments, Synology Photos |
| Desktop utilities | Cloud Station Backup, Cloud Station Drive, Synology Chat Client, Synology Drive Client, Synology Image Assistant, Synology Note Station Client, Synology Surveillance Station Client, Synology Web Clipper |
| DSM services | Central Management System (CMS), gofile.me sharing links |

### QuickConnect troubleshooting

* Check status page
* https://www.synology.com/en-global/support/synology_service
* Sign in to Synology online account to check external access status
* http://account.synology.com/en-global

## Backing up Office 365

* This plugin
* https://www.synology.com/ja-jp/dsm/feature/active_backup_office365