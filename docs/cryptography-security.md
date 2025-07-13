---
sidebar_position: 5
---

# Cryptography & Security

## Symmetric vs Asymmetric Encryption

Understanding the fundamental differences between encryption methods:

```mermaid
graph TB
    subgraph "Symmetric Encryption"
        A[Same Key for Encryption & Decryption]
        A --> A1[Fast Performance]
        A --> A2[Key Distribution Problem]
        A --> A3[Examples: AES, DES, 3DES]
    end
    
    subgraph "Asymmetric Encryption"
        B[Public/Private Key Pair]
        B --> B1[Slower Performance]
        B --> B2[Solves Key Distribution]
        B --> B3[Examples: RSA, ECC, DSA]
    end
    
    subgraph "Hybrid Approach"
        C[Asymmetric + Symmetric]
        C --> C1[Use asymmetric for key exchange]
        C --> C2[Use symmetric for data encryption]
        C --> C3[Best of both worlds]
    end
```

### Encryption Comparison

| Aspect | Symmetric | Asymmetric |
|--------|-----------|------------|
| **Speed** | ✅ Fast | ❌ Slow |
| **Key Management** | ❌ Difficult | ✅ Easy |
| **Scalability** | ❌ Poor | ✅ Good |
| **Use Case** | Data encryption | Key exchange, digital signatures |
| **Key Size** | 128-256 bits | 2048-4096 bits |

## TLS/SSL Encryption Process

### How TLS Combines Both Encryption Types

```mermaid
sequenceDiagram
    participant C as Client
    participant S as Server
    
    Note over C,S: Asymmetric Phase (Key Exchange)
    C->>S: Client Hello
    S->>C: Server Hello + Certificate
    C->>C: Verify Certificate
    C->>S: Encrypted Pre-master Secret (RSA)
    
    Note over C,S: Symmetric Phase (Data Encryption)
    C->>C: Generate Session Key
    S->>S: Generate Session Key
    C->>S: Encrypted Data (AES)
    S->>C: Encrypted Response (AES)
    
    Note over C,S: Session Keys used for all communication
```

### Why TLS Uses Both Methods

1. **Asymmetric for Key Exchange**: Securely share session keys
2. **Symmetric for Data**: Fast encryption of actual data
3. **Performance**: Balance between security and speed
4. **Scalability**: Each session gets unique keys

## Authentication & Authorization

### Data Origin Authenticity vs Data Integrity

```mermaid
graph TB
    subgraph "Data Origin Authenticity"
        A[Verifies WHO sent the data]
        A --> A1[Digital Signatures]
        A --> A2[Message Authentication Codes]
        A --> A3[Certificates]
    end
    
    subgraph "Data Integrity"
        B[Verifies data HASN'T CHANGED]
        B --> B1[Hash Functions]
        B --> B2[Checksums]
        B --> B3[Digital Signatures]
    end
    
    subgraph "Relationship"
        C[Authenticity → Integrity?]
        C --> C1[❌ Not automatically!]
        C --> C2[Authentic but modified data]
        C --> C3[Need both mechanisms]
    end
```

### Key Question: Does Authenticity Imply Integrity?

**Answer: NO, not automatically!**

**Example Scenario:**
- Data is authentically from Alice (verified signature)
- But data was modified in transit after signing
- Authenticity confirmed, but integrity compromised

**Solution:** Use digital signatures that provide both:
- **Authenticity**: Verifies sender identity
- **Integrity**: Detects any modifications

## Nonces vs Salt

Understanding these cryptographic concepts:

```mermaid
graph TB
    subgraph "Nonce (Number Used Once)"
        A[Prevents Replay Attacks]
        A --> A1[Used once per session/transaction]
        A --> A2[Timestamp-based or random]
        A --> A3[Examples: TLS, OAuth]
    end
    
    subgraph "Salt (Random Value)"
        B[Prevents Rainbow Table Attacks]
        B --> B1[Unique per password/user]
        B --> B2[Stored with password hash]
        B --> B3[Examples: Password hashing]
    end
    
    subgraph "Common Properties"
        C[Both are random values]
        C --> C1[Increase security]
        C --> C2[Prevent precomputed attacks]
    end
```

### Use Cases Comparison

| Aspect | Nonce | Salt |
|--------|-------|------|
| **Purpose** | Prevent replay attacks | Prevent rainbow table attacks |
| **Usage** | Session/transaction based | Password hashing |
| **Storage** | Temporary | Permanent (with hash) |
| **Reuse** | Never (within time window) | Different per user |
| **Examples** | TLS handshake, OAuth | bcrypt, PBKDF2 |

### Practical Examples

```mermaid
graph TB
    subgraph "Nonce Example: TLS"
        A[Client Random: abc123]
        B[Server Random: def456]
        C[Combined for session key]
        A --> C
        B --> C
    end
    
    subgraph "Salt Example: Password"
        D[Password: mypassword]
        E[Salt: xyz789]
        F["Hash: bcrypt password + salt"]
        D --> F
        E --> F
    end
```

## PKI (Public Key Infrastructure)

### Why Companies Use PKI

```mermaid
graph TB
    subgraph "PKI Components"
        A[Certificate Authority<br/>CA]
        B[Registration Authority<br/>RA]
        C[Certificate Repository]
        D[Certificate Revocation List<br/>CRL]
    end
    
    subgraph "PKI Benefits"
        E[Identity Verification]
        F[Secure Communication]
        G[Digital Signatures]
        H[Non-repudiation]
        I[Key Management]
    end
    
    A --> E
    B --> F
    C --> G
    D --> H
    E --> I
```

### Corporate PKI Use Cases

1. **Employee Authentication**: Digital certificates for login
2. **Email Security**: S/MIME for encrypted/signed emails
3. **Document Signing**: Digital signatures for contracts
4. **VPN Access**: Certificate-based VPN authentication
5. **Code Signing**: Verify software integrity
6. **Web Security**: SSL/TLS certificates for internal sites

## Security Vulnerabilities Assessment

### CVE (Common Vulnerabilities and Exposures)

```mermaid
graph TB
    subgraph "CVE System"
        A[CVE-YYYY-NNNN]
        A --> A1[Year of disclosure]
        A --> A2[Sequential number]
        A --> A3[Unique identifier]
    end
    
    subgraph "CVSS Score"
        B[Common Vulnerability Scoring System]
        B --> B1[Base Score: 0-10]
        B --> B2[Temporal Score]
        B --> B3[Environmental Score]
    end
    
    subgraph "Severity Levels"
        C[Critical: 9.0-10.0]
        D[High: 7.0-8.9]
        E[Medium: 4.0-6.9]
        F[Low: 0.1-3.9]
    end
```

### CVSS Scoring Components

| Component | Description | Factors |
|-----------|-------------|---------|
| **Base Score** | Intrinsic vulnerability characteristics | Attack vector, complexity, privileges required |
| **Temporal Score** | Time-sensitive factors | Exploit availability, remediation level |
| **Environmental Score** | Organization-specific factors | Business impact, system exposure |

### Example: CVE Analysis

```mermaid
graph LR
    A[CVE-2021-44228<br/>Log4j RCE] --> B[CVSS 10.0<br/>Critical]
    B --> C[Remote Code Execution]
    C --> D[No authentication required]
    D --> E[Widespread impact]
    E --> F[Immediate patching required]
```

## Trust and Verification

### Software Installation Security

**Question**: How can you ensure OS installation media is genuine?

```mermaid
graph TB
    subgraph "Verification Chain"
        A[AlmaLinux ISO] --> B[SHA256 Checksum]
        B --> C[GPG Signature]
        C --> D[AlmaLinux Public Key]
        D --> E[Key Fingerprint Verification]
        E --> F[Trust Anchor]
    end
    
    subgraph "Potential Attacks"
        G[Malicious ISO] --> G1[Backdoors, rootkits]
        H[MITM Attack] --> H1[Compromised download]
        I[Compromised Mirror] --> I1[Replaced files]
    end
    
    subgraph "Countermeasures"
        J[Checksum Verification] --> J1[Detects corruption]
        K[Signature Verification] --> K1[Verifies authenticity]
        L[Secure Download] --> L1[HTTPS, official sources]
    end
```

### Trust Chain Process

1. **Download ISO**: From official AlmaLinux website
2. **Verify Checksum**: Compare SHA256 hash
3. **Verify Signature**: Check GPG signature
4. **Verify Key**: Confirm public key fingerprint
5. **Trust Anchor**: AlmaLinux's reputation and processes

### Update Security

```mermaid
graph TB
    subgraph "Package Update Security"
        A[Package Manager] --> B[Repository Signature]
        B --> C[Package Signature]
        C --> D[Checksum Verification]
        D --> E[Installation]
    end
    
    subgraph "YUM/DNF Security"
        F[GPG Key Import] --> G[Repository Metadata]
        G --> H[Package Verification]
        H --> I[Secure Installation]
    end
```

## Cryptographic Actors

### Alice, Bob, Eve, and Mallory

```mermaid
graph TB
    subgraph "Legitimate Parties"
        A[Alice<br/>Sender]
        B[Bob<br/>Receiver]
    end
    
    subgraph "Attackers"
        C[Eve<br/>Eavesdropper]
        D[Mallory<br/>Malicious Actor]
    end
    
    A <--> B
    C -.-> A
    C -.-> B
    D -.-> A
    D -.-> B
    
    A --> A1[Wants to send secure messages]
    B --> B1[Wants to receive secure messages]
    C --> C1[Passive attacker - listens only]
    D --> D1[Active attacker - modifies, injects]
```

### Why They Have "Streit" (Conflict)

**Eve's Capabilities:**
- **Passive Eavesdropping**: Intercepts communications
- **Traffic Analysis**: Analyzes patterns and metadata
- **Weakness**: Cannot modify messages

**Mallory's Capabilities:**
- **Active Attacks**: Modifies messages in transit
- **Man-in-the-Middle**: Intercepts and relays messages
- **Impersonation**: Pretends to be legitimate party
- **Replay Attacks**: Resends captured messages

## Power-of-Two Calculations

### Important Powers of Two

| Power | Decimal | Hexadecimal | Real-World Context |
|-------|---------|-------------|-------------------|
| 2^10 | 1,024 | 0x400 | ~1 KB |
| 2^11 | 2,048 | 0x800 | Common RSA key size |
| 2^12 | 4,096 | 0x1000 | Strong RSA key size |
| 2^13 | 8,192 | 0x2000 | Very strong RSA key |
| 2^14 | 16,384 | 0x4000 | |
| 2^15 | 32,768 | 0x8000 | |
| 2^16 | 65,536 | 0x10000 | Port number range |
| 2^20 | 1,048,576 | 0x100000 | ~1 MB |
| 2^24 | 16,777,216 | 0x1000000 | IPv4 Class A |
| 2^32 | 4,294,967,296 | 0x100000000 | IPv4 address space |

### Large Powers (Order of Magnitude)

- **2^64**: ~18 quintillion (18 × 10^18)
- **2^128**: ~340 undecillion (3.4 × 10^38) - AES-128 key space

```mermaid
graph TB
    A[2^64] --> A1[~18 billion billion]
    A --> A2[Current max file sizes]
    A --> A3[64-bit addressing]
    
    B[2^128] --> B1[~340 undecillion]
    B --> B2[AES-128 key space]
    B --> B3[Practically unbreakable]
```

## Test Preparation: Cryptography Checklist

### Key Concepts to Master

- [ ] Symmetric vs Asymmetric encryption differences
- [ ] How TLS combines both encryption types
- [ ] Authenticity vs Integrity relationship
- [ ] Nonce vs Salt use cases
- [ ] PKI components and benefits
- [ ] CVE and CVSS scoring system
- [ ] Trust chain verification process
- [ ] Cryptographic actors and attack types
- [ ] Powers of two and their significance

### Security Principles

1. **Defense in Depth**: Multiple security layers
2. **Least Privilege**: Minimal required access
3. **Fail Secure**: Secure defaults when systems fail
4. **Keep It Simple**: Complexity introduces vulnerabilities
5. **Regular Updates**: Patch known vulnerabilities
6. **Verify Everything**: Trust but verify principle
