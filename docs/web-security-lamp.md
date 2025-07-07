---
sidebar_position: 4
---

# Web Security & LAMP Stack

## Information Security Triad (CIA)

The three fundamental security goals that every system must address:

```mermaid
graph TB
    subgraph "CIA Triad"
        A[Confidentiality<br/>]
        B[Integrity<br/>]
        C[Availability<br/>]
    end
    
    A --> A1[Data privacy<br/>Access control<br/>Encryption]
    B --> B1[Data accuracy<br/>Tamper detection<br/>Checksums]
    C --> C1[System uptime<br/>Disaster recovery<br/>Redundancy]
    
    A -.-> B
    B -.-> C
    C -.-> A
```

### Practical Example: Online Banking

| CIA Aspect | Banking Application | Security Measures |
|------------|-------------------|-------------------|
| **Confidentiality** | Account numbers, balances must be private | HTTPS encryption, access controls |
| **Integrity** | Transaction amounts must be accurate | Digital signatures, checksums |
| **Availability** | System must be accessible 24/7 | Load balancing, redundancy |

## LAMP Stack Architecture

LAMP (Linux, Apache, MySQL, PHP) is a popular web development stack:

```mermaid
graph TB
    subgraph "LAMP Stack"
        L[Linux<br/>Operating System]
        A[Apache<br/>Web Server]
        M[MySQL<br/>Database]
        P[PHP<br/>Scripting Language]
    end
    
    subgraph "Web Request Flow"
        U[User Browser] --> A
        A --> P
        P --> M
        M --> P
        P --> A
        A --> U
    end
    
    subgraph "Security Layers"
        S1[OS Security<br/>Firewall, Users]
        S2[Web Server Security<br/>SSL, Headers]
        S3[Database Security<br/>SQL Injection Prevention]
        S4[Application Security<br/>Input Validation]
    end
    
    L --- S1
    A --- S2
    M --- S3
    P --- S4
```

### LAMP Security Considerations

**Why LAMP is needed:**
- Dynamic web applications
- Database-driven content
- Server-side processing
- User authentication systems

**Security challenges:**
- Multiple attack vectors
- Complex interactions between components
- Regular security updates required

## HTTP vs HTTPS Security

### HTTP (Insecure)

```mermaid
sequenceDiagram
    participant B as Browser
    participant S as Server
    participant A as Attacker
    
    B->>S: HTTP Request (Port 80)
    Note over B,S: ❌ Plaintext transmission
    A->>A: Intercepts traffic
    S->>B: HTTP Response
    A->>A: Reads sensitive data
    
    Note over A: Man-in-the-middle attack successful
```

### HTTPS (Secure)

```mermaid
sequenceDiagram
    participant B as Browser
    participant S as Server
    participant A as Attacker
    
    B->>S: HTTPS Request (Port 443)
    S->>B: SSL Certificate
    B->>S: Encrypted Session Key
    Note over B,S: ✅ TLS Encrypted Communication
    A->>A: Intercepts encrypted traffic
    Note over A: ❌ Cannot decrypt without private key
    
    B->>S: Encrypted Application Data
    S->>B: Encrypted Response
```

### Security Comparison

| Aspect | HTTP | HTTPS |
|--------|------|--------|
| **Encryption** | ❌ None | ✅ TLS/SSL |
| **Data Integrity** | ❌ No protection | ✅ Checksum verification |
| **Authentication** | ❌ No server verification | ✅ Certificate validation |
| **Port** | 80 | 443 |
| **Performance** | Faster | Slight overhead |

## SSH vs HTTPS Security Comparison

### SSH (Secure Shell)

```mermaid
graph TB
    subgraph "SSH Security Features"
        A[Host Key Verification]
        B[Public Key Authentication]
        C[Password Authentication]
        D[Encrypted Channel]
        E[Port Forwarding]
        F[Command Execution]
    end
    
    A --> A1[Prevents MITM attacks]
    B --> B1[Strong authentication]
    C --> C1[Fallback method]
    D --> D1[All traffic encrypted]
    E --> E1[Secure tunneling]
    F --> F1[Remote administration]
```

### HTTPS vs SSH Security Analysis

| Security Aspect | SSH | HTTPS |
|-----------------|-----|--------|
| **Confidentiality** | ✅ Full encryption | ✅ Full encryption |
| **Integrity** | ✅ MAC verification | ✅ TLS integrity |
| **Authentication** | ✅ Host + User auth | ✅ Server auth only |
| **Use Case** | Remote shell access | Web communication |
| **Key Exchange** | Diffie-Hellman | TLS key exchange |
| **Port** | 22 | 443 |

### CIA Implementation

```mermaid
graph TB
    subgraph "SSH CIA"
        SSH_C[Confidentiality<br/>Encryption algorithms]
        SSH_I[Integrity<br/>MAC codes]
        SSH_A[Availability<br/>Connection reliability]
    end
    
    subgraph "HTTPS CIA"
        HTTPS_C[Confidentiality<br/>TLS encryption]
        HTTPS_I[Integrity<br/>Message authentication]
        HTTPS_A[Availability<br/>HTTP/2, load balancing]
    end
```

## Web Application Vulnerabilities

### SQL Injection

SQL Injection occurs when user input is directly inserted into SQL queries:

```mermaid
graph TB
    subgraph "Vulnerable Code"
        A[User Input: ' OR '1'='1]
        B[SQL Query: SELECT * FROM users WHERE id = '$input']
        C[Result: SELECT * FROM users WHERE id = '' OR '1'='1']
        D[Effect: Returns all users]
    end
    
    subgraph "Secure Code"
        E[User Input: ' OR '1'='1]
        F[Prepared Statement: SELECT * FROM users WHERE id = ?]
        G[Result: Input treated as literal string]
        H[Effect: No injection possible]
    end
    
    A --> B --> C --> D
    E --> F --> G --> H
```

### Prevention Methods

```mermaid
graph TB
    A[SQL Injection Prevention] --> B[Prepared Statements]
    A --> C[Input Validation]
    A --> D[Parameterized Queries]
    A --> E[Stored Procedures]
    A --> F[Least Privilege Database Access]
    
    B --> B1[Parameters separated from code]
    C --> C1[Whitelist validation]
    D --> D1[Parameters bound separately]
    E --> E1[Predefined SQL logic]
    F --> F1[Limited database permissions]
```

### Cross-Site Scripting (XSS)

XSS allows attackers to inject malicious scripts into web pages:

```mermaid
graph TB
    subgraph "XSS Attack Flow"
        A[Attacker injects script]
        B[Web application displays unfiltered input]
        C[Victim's browser executes script]
        D[Script steals cookies/session data]
        E[Attacker gains access]
    end
    
    A --> B --> C --> D --> E
    
    subgraph "XSS Prevention"
        F[Input Validation]
        G[Output Encoding]
        H[Content Security Policy]
        I[HTTP-Only Cookies]
        J[Secure Session Management]
    end
```

### XSS vs SQL Injection Comparison

| Aspect | SQL Injection | Cross-Site Scripting |
|--------|---------------|---------------------|
| **Target** | Database | Web browser |
| **Impact** | Data theft, modification | Session hijacking, defacement |
| **Prevention** | Prepared statements | Input validation, output encoding |
| **Scope** | Server-side | Client-side |
| **Detection** | Database logs | Web application logs |

## CMS Security Issues

### Why CMS Sites Are More Vulnerable

```mermaid
graph TB
    subgraph "Static Website"
        A[HTML Files] --> A1[Limited attack surface]
        B[CSS/JS Files] --> B1[Client-side only]
        C[Images] --> C1[No server processing]
    end
    
    subgraph "CMS Website"
        D[Dynamic Content] --> D1[Server-side processing]
        E[Database] --> E1[SQL injection risks]
        F[User Input] --> F1[XSS vulnerabilities]
        G[Plugins/Themes] --> G1[Third-party code risks]
        H[Admin Interface] --> H1[Authentication bypass]
        I[File Uploads] --> I1[Malware uploads]
    end
    
    J[Attack Vectors] --> J1[More complex = more vulnerabilities]
    J --> J2[Regular updates required]
    J --> J3[Configuration errors]
```

### CMS Security Characteristics

**What makes a standard CMS:**
1. **Dynamic Content Generation**: Server-side processing
2. **Database Integration**: Content stored in database
3. **User Management**: Authentication and authorization
4. **Plugin/Theme System**: Extensible architecture
5. **Admin Interface**: Web-based management

**Why it facilitates attacks:**
- **Larger Attack Surface**: More code means more vulnerabilities
- **Third-party Dependencies**: Plugins and themes may have security flaws
- **Configuration Complexity**: Many settings can be misconfigured
- **Update Lag**: Sites often run outdated versions

## PHP vs JavaScript Security

### Server-Side Security Comparison

```mermaid
graph TB
    subgraph "PHP (Server-Side)"
        A[PHP Code] --> A1[Executed on server]
        A --> A2[Source code hidden]
        A --> A3[Direct database access]
        A --> A4[File system access]
    end
    
    subgraph "JavaScript (Client-Side)"
        B[JavaScript Code] --> B1[Executed in browser]
        B --> B2[Source code visible]
        B --> B3[Limited server access]
        B --> B4[Sandboxed environment]
    end
    
    subgraph "Node.js (Server-Side JS)"
        C[Node.js] --> C1[JavaScript on server]
        C --> C2[Similar capabilities to PHP]
        C --> C3[Package management risks]
    end
```

### Security Analysis: PHP vs JavaScript

**JavaScript is generally more secure for the following reasons:**

1. **Sandboxing**: Browsers sandbox JavaScript execution
2. **No Direct File Access**: Cannot access local file system
3. **Same-Origin Policy**: Restricts cross-domain requests
4. **Limited Server Access**: Cannot directly access server resources

**Why we still need PHP (or server-side languages):**
- **Database Operations**: Secure server-side database access
- **Authentication**: Server-side session management
- **File Operations**: Server file system access
- **Business Logic**: Sensitive operations hidden from client

### Best Practices

```mermaid
graph TB
    A[Secure Web Development] --> B[Use HTTPS everywhere]
    A --> C[Validate all inputs]
    A --> D[Parameterized queries]
    A --> E[Output encoding]
    A --> F[Secure session management]
    A --> G[Regular security updates]
    A --> H[Security headers]
    A --> I[Error handling]
```

## Virtual Machine vs Physical Server Security

### Architecture Comparison

```mermaid
graph TB
    subgraph "Physical Server LAMP"
        A[Physical Hardware]
        B[Linux OS]
        C[Apache + MySQL + PHP]
        D[Your Application]
        
        A --> B --> C --> D
    end
    
    subgraph "VM-based LAMP"
        E[Physical Hardware]
        F[Host OS]
        G[Hypervisor]
        H[Guest Linux VM]
        I[Apache + MySQL + PHP]
        J[Your Application]
        
        E --> F --> G --> H --> I --> J
    end
```

### Security Pros and Cons

| Aspect | Physical Server | Virtual Machine |
|--------|-----------------|-----------------|
| **Isolation** | ❌ Single point of failure | ✅ Better isolation |
| **Resource Control** | ✅ Full hardware access | ⚠️ Shared resources |
| **Attack Surface** | ✅ Smaller | ❌ Larger (hypervisor) |
| **Backup/Recovery** | ❌ Complex | ✅ Snapshot-based |
| **Scalability** | ❌ Limited | ✅ Easy scaling |
| **Cost** | ❌ Higher | ✅ Lower |
| **Performance** | ✅ Native performance | ⚠️ Slight overhead |
| **Security Updates** | ✅ Direct control | ❌ Multiple layers |

### CIA Analysis: Physical vs VM

```mermaid
graph TB
    subgraph "Physical Server CIA"
        P_C[Confidentiality<br/>Hardware isolation]
        P_I[Integrity<br/>Direct hardware control]
        P_A[Availability<br/>Single point of failure]
    end
    
    subgraph "VM-based CIA"
        V_C[Confidentiality<br/>VM isolation + encryption]
        V_I[Integrity<br/>Snapshots + rollback]
        V_A[Availability<br/>Migration + redundancy]
    end
```

## Test Preparation Summary

### Key Web Security Concepts

1. **CIA Triad**: Confidentiality, Integrity, Availability
2. **LAMP Stack**: Linux, Apache, MySQL, PHP architecture
3. **HTTP vs HTTPS**: Encryption and security differences
4. **Web Vulnerabilities**: SQL injection, XSS prevention
5. **CMS Security**: Why dynamic sites are more vulnerable
6. **Language Security**: PHP vs JavaScript security implications
7. **Infrastructure**: Physical vs virtual server security trade-offs

### Critical Security Measures

- Always use HTTPS for web applications
- Implement proper input validation and output encoding
- Use prepared statements for database queries
- Keep all software components updated
- Implement proper authentication and session management
- Use security headers and CSP
- Regular security audits and penetration testing
