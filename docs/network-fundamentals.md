---
sidebar_position: 2
---

# Network Fundamentals & Security

## OSI Model (7 Layers)

The OSI model is fundamental to understanding network security. Each layer has specific security considerations:

```mermaid
graph TB
    A[Application Layer 7] --> B[Presentation Layer 6]
    B --> C[Session Layer 5]
    C --> D[Transport Layer 4]
    D --> E[Network Layer 3]
    E --> F[Data Link Layer 2]
    F --> G[Physical Layer 1]
    
    A -.-> A1[HTTP/HTTPS, SSH, DNS]
    B -.-> B1[TLS/SSL Encryption]
    C -.-> C1[Session Management]
    D -.-> D1[TCP/UDP, Port Security]
    E -.-> E1[IP, Routing, Firewalls]
    F -.-> F1[MAC Addresses, Switches]
    G -.-> G1[Physical Security]
```

### Security at Each Layer

| Layer | Security Focus | Examples |
|-------|----------------|----------|
| **Layer 7 (Application)** | Application security, input validation | HTTPS, SSH authentication |
| **Layer 6 (Presentation)** | **Encryption/Decryption** | TLS/SSL encryption |
| **Layer 5 (Session)** | Session management, authentication | Session tokens, Kerberos |
| **Layer 4 (Transport)** | **Port security, secure protocols** | TCP/UDP security, firewalls |
| **Layer 3 (Network)** | IP security, routing security | IPSec, network firewalls |
| **Layer 2 (Data Link)** | Switch security, MAC filtering | 802.1X, VLAN security |
| **Layer 1 (Physical)** | Physical access control | Cable security, facility access |

### Where Encryption Occurs

```mermaid
graph LR
    subgraph "Application Layer"
        A[HTTPS/TLS]
        B[SSH]
    end
    
    subgraph "Presentation Layer"
        C[SSL/TLS Encryption]
        D[Data Compression]
    end
    
    subgraph "Network Layer"
        E[IPSec]
        F[VPN Tunnels]
    end
    
    A --> C
    B --> C
    E --> F
```

## IP Communication Types

Understanding different IP communication methods is crucial for network security:

```mermaid
graph TB
    subgraph "IP Communication Types"
        A[Unicast<br/>1:1 Communication]
        B[Multicast<br/>1:Many Communication]
        C[Broadcast<br/>1:All Communication]
        D[Anycast<br/>1:Nearest Communication]
    end
    
    A --> A1[Example: Web browsing<br/>Client → Server]
    B --> B1[Example: Video streaming<br/>IPTV, conferencing]
    C --> C1[Example: ARP requests<br/>DHCP discovery]
    D --> D1[Example: CDN<br/>DNS root servers]
```

### Security Implications

- **Unicast**: Standard communication, easier to secure
- **Multicast**: Can be exploited for DDoS amplification
- **Broadcast**: Security risk in switching networks
- **Anycast**: Used by CDNs, helps with DDoS mitigation

## Network Addressing & Subnetting

### Example: Network Calculation

**Question**: Is 10.42.143.12 in network 10.42.140.0/22?

```mermaid
graph LR
    A[10.42.143.12] --> B[Convert to Binary]
    B --> C[Apply /22 Mask]
    C --> D[Compare with 10.42.140.0]
    
    D --> E[Result: YES<br/>Both in 10.42.140.0/22]
```

**Calculation**:
- /22 = 255.255.252.0
- 10.42.143.12 & 255.255.252.0 = 10.42.140.0
- Match! ✓

### Another Example: Network Comparison

**Question**: Are 10.42.25.17 and 10.42.23.19 in the same network with netmask 255.255.252.0?

```mermaid
graph TB
    A[10.42.25.17] --> A1[10.42.24.0/22]
    B[10.42.23.19] --> B1[10.42.20.0/22]
    A1 --> C[Different Networks]
    B1 --> C
    C --> D[Answer: NO]
```

## TCP States & Security

```mermaid
stateDiagram-v2
    [*] --> CLOSED
    CLOSED --> LISTEN: Server opens port
    LISTEN --> SYN_RCVD: Client connects
    SYN_RCVD --> ESTABLISHED: Handshake complete
    ESTABLISHED --> CLOSE_WAIT: Client closes
    CLOSE_WAIT --> LAST_ACK: Server closes
    LAST_ACK --> CLOSED: Connection closed
    
    note right of LISTEN: Server waiting for connections<br/>Vulnerable to SYN flood attacks
    note right of ESTABLISHED: Active connection<br/>Data can be transmitted
```

### Security Considerations

- **LISTEN**: Server is waiting for connections - vulnerable to SYN flood attacks
- **ESTABLISHED**: Active connection - data transmission possible, requires monitoring

## DHCP Process

```mermaid
sequenceDiagram
    participant C as Client
    participant S as DHCP Server
    
    C->>S: 1. DISCOVER (Broadcast)
    S->>C: 2. OFFER (IP + Config)
    C->>S: 3. REQUEST (Accepts offer)
    S->>C: 4. ACK (Confirms lease)
    
    Note over C,S: DORA Process
    Note over C,S: Security: DHCP Snooping, MAC filtering
```

### Security Implications

- **DHCP Spoofing**: Rogue DHCP servers can redirect traffic
- **DHCP Starvation**: Exhaust IP pool with fake requests
- **Protection**: DHCP snooping, port security, MAC filtering

## DNS Security

```mermaid
graph TB
    A[Client Query] --> B[Recursive Resolver]
    B --> C[Root Server]
    C --> D[TLD Server]
    D --> E[Authoritative Server]
    E --> D
    D --> C
    C --> B
    B --> A
    
    F[Security Threats] --> F1[DNS Spoofing]
    F --> F2[DNS Cache Poisoning]
    F --> F3[DNS Tunneling]
    F --> F4[DDoS on DNS]
```

### DNS Security Measures

- **DNSSEC**: Cryptographic signatures for DNS responses
- **DNS over HTTPS (DoH)**: Encrypted DNS queries
- **DNS Filtering**: Block malicious domains

## Port Security

### Important Ports & Their Security Assessment

| Port | Service | Protocol | Security Assessment |
|------|---------|----------|-------------------|
| **22** | SSH | TCP | ✅ **Secure** - Encrypted, key-based auth |
| **25** | SMTP | TCP | ⚠️ **Medium** - Can be encrypted (STARTTLS) |
| **53** | DNS | UDP/TCP | ⚠️ **Medium** - Use DNSSEC, filter queries |
| **80** | HTTP | TCP | ❌ **Insecure** - Plaintext, use HTTPS |
| **443** | HTTPS | TCP | ✅ **Secure** - TLS encrypted |

```mermaid
graph TB
    subgraph "Secure Services"
        A[SSH :22]
        B[HTTPS :443]
    end
    
    subgraph "Medium Risk"
        C[DNS :53]
        D[SMTP :25]
    end
    
    subgraph "Insecure"
        E[HTTP :80]
        F[FTP :21]
    end
    
    A --> A1[Encrypted, Key Auth]
    B --> B1[TLS Encryption]
    C --> C1[Use DNSSEC]
    D --> D1[Use STARTTLS]
    E --> E1[Plaintext - Avoid]
    F --> F1[Plaintext - Use SFTP]
```

## Routing Security

### When Routing Tables Change

```mermaid
graph TB
    A[System Boot] --> B[DHCP Configuration]
    B --> C[Manual IP Configuration]
    C --> D[Network Interface Changes]
    D --> E[VPN Connection]
    E --> F[Route Commands]
    
    A --> G[Routing Table Updated]
    B --> G
    C --> G
    D --> G
    E --> G
    F --> G
    
    G --> H[DNS Configuration]
    G --> I[Default Gateway]
    G --> J[Network Interfaces]
```

### Security Considerations

- **Route Hijacking**: Malicious route advertisements
- **BGP Security**: Route filtering, authentication
- **VPN Security**: Encrypted tunnels for remote access

## Test Preparation Summary

### Key Security Concepts to Remember

1. **Layered Security**: Each OSI layer has specific security measures
2. **Encryption Placement**: Primarily at Presentation (TLS/SSL) and Network (IPSec) layers
3. **Network Segmentation**: Proper subnetting improves security
4. **Protocol Security**: Choose secure protocols (SSH vs Telnet, HTTPS vs HTTP)
5. **Monitoring**: Track connection states and network traffic
