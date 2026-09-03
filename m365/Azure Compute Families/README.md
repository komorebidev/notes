# Compute Families

## Cheapest non-burstable tier

* Absolute cheapest non-burstable AV2 (good for testing only)
* No bursting, throttled and consistent but not that much cheaper than D series
* But retiring in 2028 with no replacement
* https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/a-family

## Burstable (cheapest)

* Next cheapest tier (good for small test instances or VPN)
* B series (such as B2ats)
* AMD EPYC
* https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/basv2-series?tabs=sizebasic

### 📊 The Cheapest 4 GiB VM Options Compared

| VM Size | vCPUs / RAM | Monthly Cost (USD) | Monthly Cost (Yen) | Key Architectural Trait |
| :--- | :--- | :--- | :--- | :--- |
| **Standard_B2als_v2** (AMD) | 2 vCPUs / 4 GiB | ~\$17.96 | 約 2,840 円 | **Burstable Baseline:** Absolute cheapest path to 4 GiB of RAM. No local temp disk. |
| **Standard_B2ls_v2** (Intel) | 2 vCPUs / 4 GiB | ~\$17.96 | 約 2,840 円 | **Burstable Baseline:** Identical cost and RAM. Runs on Intel Xeon processors. No local temp disk. |
| **Standard_B2s** (Legacy B) | 2 vCPUs / 4 GiB | ~\$30.37 | 約 4,802 円 | Older generation burstable VM. Includes a local temporary disk, but costs ~70% more. |
| **Standard_A2_v2** (Legacy A) | 2 vCPUs / 4 GiB | ~\$65.92 | 約 10,423 円 | Flat-rate budget compute. Heavily discouraged because it is retiring in 2028. |

### 💻 Azure Standard_B2as_v2 Monthly Cost (2 vCPUs / 8 GiB RAM)

| Operating System | Hourly Price | Estimated Monthly (USD) | Estimated Monthly (Yen) |
| :--- | :--- | :--- | :--- |
| 🐧 **Linux (Ubuntu/Debian)** | \$0.0460 | ~\$33.58 | 約 5,310 円 |
| 🪟 **Windows Server** | \$0.1020 | ~\$74.46 | 約 11,774 円 |

## Production

* For enterprise deployments
* D series (such as Dasv7)
* There are both Intel and AMD SKU
* https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/d-family?tabs=dsv7%2Cdlsv7%2Cdasv7%2Cdalsv7%2Cdpsv6%2Cdpdsv6%2Cdasv6%2Cdalsv6%2Cdv5%2Cddv5%2Cdasv5%2Cdpsv5%2Cdplsv5%2Cdlsv5%2Cdv4%2Cdav4%2Cddv4%2Cdv3%2Cdv2

### Non-burstable Options Compared

| VM Size | Specs | Monthly Cost (USD) | Monthly Cost (Yen) |
| :--- | :--- | :--- | :--- |
| **Standard_D2as_v7** (Dasv7-series) | 2 vCPUs / 8 GiB RAM | \$66.28 | 約 10,480 円 |
| **Standard_A2_v2** (Av2-series) | 2 vCPUs / 4 GiB RAM | \$65.92 | 約 10,423 円 |
| **Standard_B2ats_v2** (B-series v2) | 2 vCPUs / 1 GiB RAM | \$13.58 | 約 2,147 円 |
