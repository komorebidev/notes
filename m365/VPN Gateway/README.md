# VPN Gateway

## Pricing

### Basic SKU

- Cost: approximately **USD $26.28/month**
- Throughput: **100 Mbps**
- Site-to-Site tunnels: up to **10**
- Point-to-Site connections: up to **128**
- BGP: **Not supported**
- Microsoft Entra ID authentication: **Not supported**

Source: Azure VPN Gateway Pricing and Gateway SKU documentation. 【1-176be5】【2-0f9371】

### VpnGw1AZ SKU

- Cost: approximately **USD $150/month**
- Throughput: **650 Mbps**
- Site-to-Site tunnels: up to **30**
- Point-to-Site connections: up to **250**
- BGP: **Supported**
- Zone redundant: **Yes**
- Microsoft Entra ID authentication: **Supported**

Source: Azure VPN Gateway Pricing and Gateway SKU documentation. 【1-176be5】【2-0f9371】

---

## What Happens Without BGP?

BGP (Border Gateway Protocol) automatically exchanges routes between Azure and your network.

Without BGP:

- Routes must be configured manually.
- New subnets require manual updates.
- Multi-site and hub-and-spoke designs are harder to manage.
- Automatic route failover is limited.

For a simple home network with a single VPN connection, BGP is usually unnecessary. For multiple sites or enterprise networking, BGP is highly recommended. 【2-0f9371】

---

## Connecting from a Home Network Without Port Forwarding

### Recommended: Point-to-Site (P2S) VPN

Architecture:

```text
Laptop/Desktop
      |
      v
Azure VPN Client
      |
      v
Azure VPN Gateway
```

Benefits:

- No port forwarding required
- Works behind NAT and most CGNAT environments
- Easy to set up
- Supported by Azure VPN Gateway

---

## Point-to-Site VPN Cost

### Basic SKU

```text
VPN Gateway Basic    $26.28/month
P2S User             Included
Total                ~$26.28/month
```

The first 128 P2S connections are included with the Basic SKU. 

---

## Microsoft Entra ID Authentication

### Supported?

| Gateway SKU | Microsoft Entra ID |
|-------------|-------------------|
| Basic | ❌ No |
| VpnGw1AZ | ✅ Yes |
| VpnGw2AZ+ | ✅ Yes |

Important requirements:

- OpenVPN protocol
- Azure VPN Client
- Compatible VPN Gateway SKU (not Basic)

Microsoft explicitly states that Microsoft Entra ID authentication is not supported on the Basic VPN Gateway SKU. 

---

## Home Lab Recommendation

### Lowest Cost Option

Use:

- Azure VPN Gateway Basic
- Point-to-Site VPN
- Certificate authentication

Estimated recurring cost:

```text
~$26/month
```

Good for:

- Home labs
- Personal Azure environments
- Single-user access

---

### Enterprise-Style Option

Use:

- Azure VPN Gateway VpnGw1AZ
- Point-to-Site VPN
- Microsoft Entra ID authentication
- MFA and Conditional Access

Estimated recurring cost:

```text
~$150/month
```

Good for:

- Production environments
- Microsoft 365 integration
- Entra authentication and security policies

---

## Alternative Solutions

If the only goal is secure access from home to Azure, consider:

- Tailscale
- ZeroTier
- Cloudflare Zero Trust
- Azure Bastion (for VM access only)

These options often work without port forwarding and can be significantly cheaper than running a VPN Gateway continuously.

---

## Conclusion

For a personal or home-lab setup:

- Use **Azure VPN Gateway Basic**
- Configure **Point-to-Site VPN**
- Use **certificate-based authentication**
- Cost is approximately **$26/month**

If you require:

- Microsoft Entra ID sign-in
- MFA
- Conditional Access
- Dynamic routing (BGP)

then use **VpnGw1AZ** or higher, at approximately **$150/month**.