## Appendix C: Regulatory and Compliance References

### Industry-Specific Compliance Requirements

#### Healthcare
- **HIPAA (Health Insurance Portability and Accountability Act)**
  - Privacy Rule: Controls the use and disclosure of Protected Health Information (PHI)
  - Security Rule: Safeguards for electronic PHI including administrative, physical, and technical requirements
  - Breach Notification Rule: Reporting requirements for data breaches
  - Enforcement Rule: Investigations, penalties, and procedures for violations
  - HITECH Act: Expansion of privacy and security protections

#### Financial Services
- **GLBA (Gramm-Leach-Bliley Act)**
  - Financial Privacy Rule: Disclosure limits and notice requirements
  - Safeguards Rule: Information security program requirements
  
- **PCI DSS (Payment Card Industry Data Security Standard)**
  - Twelve core requirements covering network security, data protection, access control, and testing
  - Compliance levels based on transaction volume
  - Annual assessment and quarterly scan requirements

- **SOX (Sarbanes-Oxley Act)**
  - Section 404: Internal control requirements for financial reporting
  - IT controls related to financial data integrity

#### Government
- **FISMA (Federal Information Security Management Act)**
  - Security categorization of information systems
  - Security controls implementation
  - Risk assessment requirements
  - Continuous monitoring directives

- **FedRAMP (Federal Risk and Authorization Management Program)**
  - Cloud service provider security assessment framework
  - "Do once, use many times" authorization approach
  - Security baseline requirements

#### Critical Infrastructure
- **NERC CIP (North American Electric Reliability Corporation Critical Infrastructure Protection)**
  - Cybersecurity standards for bulk electric systems
  - Identification of critical cyber assets
  - Security management controls
  - Incident reporting requirements

- **TSA Pipeline Security Guidelines**
  - Security protocols for pipeline operators
  - Cybersecurity measures
  - Incident response requirements

#### Consumer Data Protection
- **GDPR (General Data Protection Regulation) - EU**
  - Data subject rights (access, erasure, portability)
  - Lawful basis for processing
  - Data protection by design and by default
  - Breach notification requirements
  - Extraterritorial scope affecting global operations

- **CCPA/CPRA (California Consumer Privacy Act/California Privacy Rights Act)**
  - Consumer rights regarding personal information
  - Business obligations for data handling
  - Disclosure requirements
  - Opt-out mechanisms for data sales

- **LGPD (Lei Geral de Proteção de Dados) - Brazil**
  - Rights of data subjects
  - Legal bases for data processing
  - Data protection officers
  - International data transfers

#### Industry-Specific Regulations
- **COPPA (Children's Online Privacy Protection Act)**
  - Requirements for collecting data from children under 13
  - Parental consent mechanisms
  - Data security obligations

- **FERPA (Family Educational Rights and Privacy Act)**
  - Protection of student educational records
  - Disclosure limitations
  - Access rights for students and parents

### International Standards and Frameworks

#### ISO Standards
- **ISO/IEC 27001**
  - Information Security Management System (ISMS) requirements
  - Risk assessment methodology
  - Control objectives and controls
  - Continuous improvement cycle

- **ISO/IEC 27002**
  - Code of practice for information security controls
  - Detailed guidance for implementing controls
  - Best practices for security management

- **ISO/IEC 27017**
  - Cloud-specific information security controls
  - Implementation guidance for cloud service providers and customers

- **ISO/IEC 27018**
  - Protection of personally identifiable information (PII) in public clouds
  - Additional controls for cloud service providers

- **ISO 22301**
  - Business continuity management systems
  - Requirements and guidance
  - Integration with risk management

- **ISO 31000**
  - Risk management principles and guidelines
  - Framework for managing risk
  - Integration with organizational governance

#### Other Frameworks
- **NIST Cybersecurity Framework**
  - Five core functions: Identify, Protect, Detect, Respond, Recover
  - Implementation tiers and profiles
  - Flexibility for cross-sector implementation

- **NIST Special Publications**
  - SP 800-53: Security and Privacy Controls
  - SP 800-171: Controlled Unclassified Information
  - SP 800-37: Risk Management Framework
  - SP 800-61: Incident Handling
  - SP 800-34: Contingency Planning

- **COBIT (Control Objectives for Information and Related Technologies)**
  - IT governance and management framework
  - Process reference model
  - Performance measurement
  - Alignment of IT with business objectives

- **ITIL (Information Technology Infrastructure Library)**
  - Service management framework
  - Service lifecycle approach
  - Process integration with security management

- **CIS Controls (Center for Internet Security)**
  - Prioritized set of actions to protect organizations
  - Implementation groups based on organizational complexity
  - Benchmarks for secure configuration

### Mapping Controls to Compliance Requirements

#### Cross-Framework Mapping

The following table illustrates how common security controls map to various regulatory frameworks. This mapping can help organizations implement a unified control set that addresses multiple compliance requirements simultaneously.

**Control Category Mappings Across Frameworks:**

**Risk Assessment**
- NIST CSF: ID.RA
- ISO 27001: A.8.2
- HIPAA: §164.308(a)(1)(ii)(A)
- PCI DSS: 12.2
- GDPR: Art. 35
- SOX: §404

**Access Control**
- NIST CSF: PR.AC
- ISO 27001: A.9
- HIPAA: §164.312(a)(1)
- PCI DSS: 7, 8, 9
- GDPR: Art. 25, 32
- SOX: §404

**Data Protection**
- NIST CSF: PR.DS
- ISO 27001: A.8, A.10, A.13, A.14
- HIPAA: §164.312(a)(2)(iv)
- PCI DSS: 3, 4
- GDPR: Art. 25, 32, 35
- SOX: §404

**Network Security**
- NIST CSF: PR.PT, PR.DS
- ISO 27001: A.13
- HIPAA: §164.312(e)(1)
- PCI DSS: 1, 2
- GDPR: Art. 32
- SOX: §404

**Incident Response**
- NIST CSF: RS.CO, RS.AN, RS.MI
- ISO 27001: A.16
- HIPAA: §164.308(a)(6)
- PCI DSS: 12.10
- GDPR: Art. 33, 34
- SOX: §404

**Business Continuity**
- NIST CSF: RC.RP, RC.IM
- ISO 27001: A.17
- HIPAA: §164.308(a)(7)
- PCI DSS: 12.10.1
- GDPR: Art. 32
- SOX: §404

**Audit & Monitoring**
- NIST CSF: DE.CM, ID.AM
- ISO 27001: A.12.4, A.12.7
- HIPAA: §164.308(a)(1)(ii)(D)
- PCI DSS: 10, 11
- GDPR: Art. 30, 32, 35
- SOX: §404

**Vendor Management**
- NIST CSF: ID.SC
- ISO 27001: A.15
- HIPAA: §164.308(b)
- PCI DSS: 12.8
- GDPR: Art. 28, 29
- SOX: §404

#### Implementation Guidance for Multiple Frameworks

When implementing controls to satisfy multiple frameworks:

1. **Conduct a gap analysis** comparing your current controls to required controls across all applicable frameworks
2. **Identify common controls** that satisfy multiple requirements
3. **Develop a unified control set** that addresses the most stringent requirements
4. **Document control mappings** to demonstrate compliance with each framework
5. **Implement a continuous compliance program** that monitors control effectiveness
6. **Develop framework-specific evidence repositories** that facilitate audits

#### Special Considerations for Overlapping Requirements

- **Documentation standards** may vary between frameworks; maintain comprehensive documentation that meets the most rigorous requirements
- **Testing frequencies** should follow the most demanding schedule across frameworks
- **Risk assessment methodologies** may need to be adapted to satisfy different framework approaches
- **Reporting requirements** vary significantly; develop a centralized reporting function
- **Continuous monitoring programs** should incorporate all framework-specific metrics

By understanding how controls map across frameworks, organizations can implement a streamlined compliance program that efficiently addresses multiple regulatory requirements while reducing duplication of effort and resources.