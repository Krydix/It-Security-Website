---
sidebar_position: 3
---

# Operating System Security

## UNIX/Linux Architecture Security Model

Understanding the layered security model of UNIX/Linux systems is crucial for system security:

```mermaid
graph TB
    subgraph "User Space"
        A[User Applications]
        B[System Libraries]
        C[System Calls Interface]
    end
    
    subgraph "Kernel Space"
        D[Kernel]
        E[Device Drivers]
        F[File System]
        G[Memory Management]
        H[Process Management]
        I[Network Stack]
    end
    
    subgraph "Hardware"
        J[CPU]
        K[Memory]
        L[Storage]
        M[Network Interface]
    end
    
    A --> B
    B --> C
    C --> D
    D --> E
    D --> F
    D --> G
    D --> H
    D --> I
    E --> J
    F --> L
    G --> K
    I --> M
```

### Security at Each Layer

| Layer | Security Mechanisms | Examples |
|-------|-------------------|----------|
| **User Applications** | Input validation, secure coding | Web browsers, text editors |
| **System Libraries** | Buffer overflow protection, ASLR | libc, OpenSSL |
| **System Calls** | Permission checks, parameter validation | open(), read(), write() |
| **Kernel** | Process isolation, memory protection | Kernel modules, system calls |
| **Device Drivers** | Hardware abstraction, access control | Network drivers, storage drivers |
| **Hardware** | Hardware-based security features | CPU rings, MMU, TPM |

## File System Security

### File Permissions Example

```bash
# ls -l /dev/sda3
brw-rw-r--. 1 root disk 8, 3 Jun 11  8:57 /dev/sda3
```

Let's break down this listing:

```mermaid
graph LR
    A[brw-rw-r--] --> B[File Type: b = Block Device]
    A --> C[Owner: rw- = Read/Write]
    A --> D[Group: rw- = Read/Write]
    A --> E[Others: r-- = Read Only]
    
    F[root disk] --> G[Owner: root user]
    F --> H[Group: disk group]
    
    I[8, 3] --> J[Major: 8 = SCSI disk]
    I --> K[Minor: 3 = Third partition]
```

### Security Implications

- **Block device** with read/write access for root and disk group
- **Potential risk**: Members of disk group can read raw disk data
- **Mitigation**: Limit disk group membership, use device encryption

## SELinux Security

SELinux (Security-Enhanced Linux) provides mandatory access control:

```mermaid
graph TB
    subgraph "Traditional Linux Security"
        A[Discretionary Access Control<br/>DAC]
        A --> A1[Owner sets permissions]
        A --> A2[root can override]
    end
    
    subgraph "SELinux Enhanced Security"
        B[Mandatory Access Control<br/>MAC]
        B --> B1[System policy enforced]
        B --> B2[Even root is restricted]
        B --> B3[Type Enforcement]
        B --> B4[Role-Based Access]
        B --> B5[Multi-Level Security]
    end
    
    A -.-> B
```

### SELinux Security Benefits

1. **Principle of Least Privilege**: Processes run with minimal required permissions
2. **Containment**: Compromised processes are limited in damage scope
3. **Policy-Based**: Security policies define allowed interactions
4. **Audit Trail**: All access attempts are logged

### SELinux Modes

```mermaid
stateDiagram-v2
    [*] --> Disabled
    Disabled --> Permissive: Enable SELinux
    Permissive --> Enforcing: Activate policies
    Enforcing --> Permissive: Troubleshooting
    Permissive --> Disabled: Disable SELinux
    
    note right of Disabled: No SELinux protection
    note right of Permissive: Logs violations, allows access
    note right of Enforcing: Blocks violations, full protection
```

## File System Security Features

### Journaling File Systems (ext4)

```mermaid
graph TB
    A[File System Transaction] --> B[Journal Write]
    B --> C[Metadata Update]
    C --> D[Journal Clear]
    
    E[System Crash] --> F[Recovery Process]
    F --> G[Read Journal]
    G --> H[Replay Transactions]
    H --> I[File System Consistent]
    
    J[Security Benefits] --> J1[Data Integrity]
    J --> J2[Faster Recovery]
    J --> J3[Reduced Corruption]
    
    K[Security Risks] --> K1[Journal Analysis]
    K --> K2[Metadata Exposure]
```

### Is Journaling Good for Security?

**✅ Positive Aspects:**
- **Data Integrity**: Reduces corruption from unexpected shutdowns
- **Fast Recovery**: System boots faster after crashes
- **Consistency**: File system structure remains intact

**⚠️ Potential Risks:**
- **Forensic Analysis**: Journal may contain sensitive metadata
- **Performance**: Slight overhead from journaling operations

**Overall Assessment**: **Good for security** - integrity benefits outweigh risks

## Device Security

### Device Types and Security

```mermaid
graph TB
    subgraph "Device Types"
        A[Character Devices<br/>c---------]
        B[Block Devices<br/>b---------]
        C[Regular Files<br/>----------]
        D[Directories<br/>d---------]
        E[Symbolic Links<br/>l---------]
        F[Named Pipes<br/>p---------]
        G[Sockets<br/>s---------]
    end
    
    A --> A1[Serial interfaces, terminals]
    B --> B1[Hard drives, partitions]
    C --> C1[Regular data files]
    D --> D1[Directory entries]
    E --> E1[File shortcuts]
    F --> F1[Process communication]
    G --> G1[Network communication]
```

### Device Security Best Practices

1. **Restrict Device Access**: Limit who can access device files
2. **Use Groups Properly**: Don't add users to powerful groups unnecessarily
3. **Monitor Device Access**: Log access to sensitive devices
4. **Encrypt Block Devices**: Use dm-crypt/LUKS for disk encryption

## Memory Protection

### Virtual Memory Security

```mermaid
graph TB
    subgraph "Process A"
        A[Virtual Memory A]
        A --> A1[Code Segment]
        A --> A2[Data Segment]
        A --> A3[Stack]
        A --> A4[Heap]
    end
    
    subgraph "Process B"
        B[Virtual Memory B]
        B --> B1[Code Segment]
        B --> B2[Data Segment]
        B --> B3[Stack]
        B --> B4[Heap]
    end
    
    subgraph "Kernel"
        C[Physical Memory Manager]
        C --> C1[Page Tables]
        C --> C2[Memory Mapping]
    end
    
    A --> C
    B --> C
    
    D[Security Features] --> D1[Address Space Layout Randomization]
    D --> D2[Non-Executable Stack]
    D --> D3[Stack Canaries]
    D --> D4[Process Isolation]
```

### Memory Protection Mechanisms

- **ASLR (Address Space Layout Randomization)**: Randomizes memory layout
- **DEP (Data Execution Prevention)**: Prevents code execution in data segments
- **Stack Canaries**: Detect stack buffer overflows
- **Process Isolation**: Each process has separate memory space

## User and Group Security

### User Account Security Model

```mermaid
graph TB
    subgraph "User Types"
        A[Root User<br/>UID 0]
        B[System Users<br/>UID 1-999]
        C[Regular Users<br/>UID 1000+]
    end
    
    subgraph "Group Management"
        D[Primary Group]
        E[Secondary Groups]
        F[Special Groups<br/>wheel, sudo, disk]
    end
    
    A --> A1[Complete system access]
    B --> B1[Service accounts]
    C --> C1[Human users]
    
    D --> D1[User's default group]
    E --> E1[Additional permissions]
    F --> F1[Administrative privileges]
```

### Security Best Practices

1. **Principle of Least Privilege**: Grant minimum required permissions
2. **Regular Audits**: Review user accounts and group memberships
3. **Strong Authentication**: Use strong passwords, multi-factor authentication
4. **Account Monitoring**: Log and monitor user activities

## System Call Security

### System Call Interface

```mermaid
sequenceDiagram
    participant U as User Process
    participant K as Kernel
    participant H as Hardware
    
    U->>K: System Call (open file)
    K->>K: Validate parameters
    K->>K: Check permissions
    K->>K: Perform operation
    K->>H: Hardware access
    H->>K: Result
    K->>U: Return result
    
    Note over K: Security checks at every step
```

### Security Checks in System Calls

1. **Parameter Validation**: Check for buffer overflows, invalid pointers
2. **Permission Checks**: Verify user has required access rights
3. **Resource Limits**: Enforce quotas and limits
4. **Audit Logging**: Record security-relevant events

## Test Preparation: Key Points

### Operating System Security Checklist

- [ ] Understand UNIX layered architecture
- [ ] Know file permission interpretation
- [ ] Understand SELinux benefits and modes
- [ ] Recognize device security implications
- [ ] Know memory protection mechanisms
- [ ] Understand user/group security model
- [ ] Recognize system call security checks

### Common Security Issues

1. **Privilege Escalation**: Gaining higher privileges than intended
2. **Buffer Overflows**: Memory corruption attacks
3. **Race Conditions**: Timing-based security vulnerabilities
4. **Information Disclosure**: Unintended data exposure
5. **Denial of Service**: Resource exhaustion attacks
