# Azure CLI Basics

## Login and Account Management Commands
* Basic Interactive Login
* Opens your default browser to sign in interactively:

```powershell
az login
```

* Login with a Specific Tenant
* Specify the target tenant ID or domain if you belong to multiple organizations:

```powershell
az login --tenant
```

* Login via Device Code
* Useful for remote servers, SSH terminals, or environments without a local web browser:

```powershell
az login --use-device-code
```

* Login with a Service Principal
* Authenticate non-interactively using an app registration for scripts and automation:

```powershell
az login --service-principal -u  -p  --tenant
```

* Managing Subscriptions After Login
* List all accessible subscriptions:

```powershell
az account list --output table
```

* Change your active subscription:

```powershell
az account set --subscription ""
```

* View your currently active subscription:

```powershell
az account show
```

* Log out (clear local credentials):

```powershell
az logout
```
