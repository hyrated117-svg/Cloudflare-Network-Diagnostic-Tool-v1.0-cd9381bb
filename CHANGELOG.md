# CHANGELOG.md
All notable changes to this project will be documented in this file.

The format is based on **Keep a Changelog**, and this project adheres to **Semantic Versioning 2.0.0**.

---

## [Unreleased]
### Added
- New Cloudflare API modules (DNSSEC, Firewall Events, Radar, Zero Trust)
- Additional SwiftUI templates for App‑Maker
- Plugin manifest validation system
- Distributed node agent prototype (Go/Rust)
- Predictive routing engine (initial scaffolding)

### Changed
- Improved error‑handling pipeline across CLI + SwiftUI
- Updated diagnostic engine to support parallel execution
- Refined UI components for better accessibility and responsiveness

### Fixed
- Resolved intermittent Cloudflare API timeout handling
- Fixed CLI JSON output formatting inconsistencies

---

## [1.1.0] – 2026‑06‑17
### Added
- Extended Cloudflare API coverage (DNSSEC, WAF analytics, Firewall events)
- New CLI flags: `--json`, `--fast`, `--verbose`
- SwiftUI UI/UX improvements:  
  - Real‑time diagnostic indicators  
  - Animated progress bar  
  - Summary results screen  
- Performance optimisations:  
  - Metadata caching  
  - Parallelised checks  
  - Reduced API latency  
- New documentation:  
  - `Architecture.md`  
  - `Performance.md`  
  - `Modules.md`  
  - `AppMaker.md`

### Changed
- Refactored diagnostic engine for modularity
- Updated Cloudflare request layer for improved reliability
- Improved SwiftUI theming and dark‑mode consistency

### Fixed
- Corrected Cloudflare zone parsing issues
- Fixed SwiftUI navigation edge‑case crashes
- Resolved CLI exit‑code mismatch on failed diagnostics

---

## [1.0.0] – 2026‑06‑10
### Added
- Initial release of the **Cloudflare Network Diagnostic Tool (CNDT)**
- Core diagnostic engine (DNS, WAF, Firewall, Analytics)
- Cloudflare API integration with authentication layer
- Full CLI tool (`cndt`) with base commands
- SwiftUI app with results dashboard
- App‑Maker platform (initial version)  
  - SwiftUI template generator  
  - Project scaffolding system  
- Documentation suite:  
  - `README.md`  
  - `SECURITY.md`  
  - `CONTRIBUTING.md`  
  - `IMPLEMENTATION-CHECKLIST.md`  
- Release packaging for macOS + Linux

---

## [0.1.0] – 2026‑05‑30
### Added
- Prototype diagnostic engine
- Early Cloudflare API wrappers
- Basic CLI interface
- Initial SwiftUI proof‑of‑concept UI
- Early App‑Maker scaffolding logic

---

