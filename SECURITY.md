# 🔐 Security Policy  
Cloudflare Network Diagnostic Tool • MCP Server • AppMaker Generator

This document defines the security expectations, reporting process, and hardening guidelines for this repository.  
The goal is to ensure safe execution of diagnostics, secure MCP server behavior, and protection of user systems.

---

## 📣 Reporting a Vulnerability

If you discover a security issue, **DO NOT** open a public GitHub Issue.

Instead, please report it privately:

**Email:** security@yourdomain.com  
**Subject:** `Security Report – Cloudflare Diagnostic Tool`

Please include:

- A clear description of the issue  
- Steps to reproduce  
- Impact assessment  
- Proof‑of‑concept (if applicable)  
- Suggested remediation (optional)

You will receive an acknowledgment within **48 hours** and a full response within **7 days**.

---

## 🧩 Supported Components

Security coverage applies to:

- **SwiftUI Diagnostic App**
- **Python MCP Server**
- **Node MCP Server**
- **AppMaker Generator**
- **Installer Pack (macOS/Linux/Windows/NPM)**
- **Templates, Docs, and Tools**

---

## 🛠️ MCP Server Security Model

The MCP server is designed with a **restricted execution model**:

### ✔ Sandboxed Execution  
- No network access beyond diagnostic endpoints  
- No arbitrary file system writes outside allowed directories  
- No privileged system calls  
- No remote code execution pathways  

### ✔ Tools Are Explicitly Whitelisted  
Only the following tools are exposed:

- `runDiagnostics`
- `runEngine`
- `exportResults`
- `generateProject`
- `injectModule`

### ✔ Resource Access Is Read‑Only  
`templates/`, `docs/`, and `tools/` are exposed as **read‑only resources**.

### ✔ No User Data Retention  
The MCP server does **not** store:

- personal data  
- diagnostic history  
- IP addresses  
- logs outside the local session  

---

## 📱 SwiftUI App Security

The diagnostic app:

- Performs **local‑only** operations  
- Does **not** transmit data to external servers  
- Uses **no analytics**, **no telemetry**, **no tracking**  
- Stores no persistent logs unless explicitly exported  
- Uses Swift’s type‑safe APIs to prevent injection vulnerabilities  

---

## 🧰 Installer Security

All installers (shell, PowerShell, Python, NPM):

- Perform **local installation only**  
- Do **not** elevate privileges  
- Do **not** modify system files  
- Verify required dependencies (Swift, Python)  
- Register MCP configs in user‑scoped directories only  

### Integrity Verification  
Each release includes:

- `mcp-installer-pack.tar.gz`
- `SHA256SUMS`

Users should verify:

```bash
sha256sum -c SHA256SUMS
