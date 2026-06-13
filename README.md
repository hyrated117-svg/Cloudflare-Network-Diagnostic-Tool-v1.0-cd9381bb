# Cloudflare Network Diagnostic Tool v1.0 (Pre-release)

---

## 🚀 **Overview**

The **Cloudflare Network Diagnostic Tool** is a high-precision, privacy-first diagnostic engine designed to give users **real insight** into their network performance.

**Built for:**
- 🔧 Network engineers  
- ⚡ Power users  
- 👨‍💻 Developers  
- 🔒 Security analysts  
- 👥 Everyday users who want clarity  

### Privacy Promise
✅ All processing happens **on-device**  
✅ No tracking  
✅ No analytics  
✅ No external servers  
✅ No data collection  

---

## ⚡ **Features**

- **DNS Latency Benchmarking** — Measure DNS response times across resolvers
- **DoH (DNS-over-HTTPS) Performance Testing** — Encrypted DNS performance analysis
- **Cloudflare Trace Analysis** — View your PoP location and connection details
- **WARP Detection & Mode Identification** — Detect if WARP is active and its mode
- **Resolver Benchmarking** — Compare performance: Cloudflare, Google, Quad9, NextDNS
- **Network Health Scoring** — Weighted scoring system for overall network quality
- **Developer Console Mode** — Advanced diagnostics for technical users
- **Multiple Export Formats** — JSON, JSONL, Minified, Pretty-printed output
- **Local Log Storage** — All logs stored locally with encryption-style encoding
- **Automatic Log Cleanup** — Manage storage with automated cleanup
- **Cross-Platform Output** — Compatible across iOS and macOS
- **Error-Resilient Fallback Logic** — Graceful degradation on network issues

---

## 🏗️ **Architecture**

The tool is built on a modular diagnostic engine with clear separation of concerns:

| Layer | Purpose | Implementation |
|-------|---------|-----------------|
| **Network Layer** | Core connectivity tests | URLSession-based requests |
| **Trace Layer** | Cloudflare metadata parsing | PoP + WARP detection |
| **Benchmark Layer** | Multi-resolver performance | Timed DNS/DoH tests |
| **Health Layer** | Network quality assessment | Weighted scoring algorithm |
| **Export Layer** | Multiple output formats | JSON encoder with format options |
| **Logging Layer** | Secure local storage | Base64-encoded encrypted-style logs |

---

## 📦 **Output Formats**

Export your diagnostic results in multiple formats:

- **JSON** — Standard JSON format
- **JSONL** — JSON Lines (one object per line)
- **Minified JSON** — Compact, no whitespace
- **Pretty JSON** — Human-readable with formatting
- **MasterDict** — Structured dictionary output
- **Developer Console** — Formatted terminal output

---

## 🔐 **Privacy & Security**

This tool is designed with **absolute privacy** as a core principle:

✅ **No data collection**
- No analytics tracking
- No remote logging servers
- No external data transmission
- No unique identifiers

✅ **Complete control**
- All logs stored locally on your device
- Export only what you choose
- Delete logs anytime
- No cloud sync

✅ **Transparent**
- Open-source design
- Auditable code paths
- No hidden network requests

---

## 📋 **System Requirements**

### iOS Version
- **Minimum:** iOS 15.0 or later
- **Recommended:** iOS 16.0+ for best performance
- Device: iPhone or iPad

### SwiftUI App Version (macOS)
- **Minimum:** macOS 12.0 Monterey or later
- **Recommended:** macOS 13.0+ (Ventura or later)
- Architecture: Apple Silicon or Intel

### Development Requirements
- Xcode 14.0 or later
- Swift 5.7+
- CocoaPods (for dependencies)

---

## 🛠️ **Installation**

### Option 1: iOS Shortcut (Fastest)

1. Download the `.shortcut` file from the repository
2. Open Apple Shortcuts app
3. Tap **"+"** → **"Add Shortcut"**
4. Select **"Import"** and choose the `.shortcut` file
5. Run immediately or add to your home screen

**No coding required. Works on iOS 15+**

---

### Option 2: SwiftUI App (Full Features)

#### Clone the Repository
```bash
git clone https://github.com/hyrated117-svg/Cloudflare-Network-Diagnostic-Tool-v1.0.git
cd Cloudflare-Network-Diagnostic-Tool-v1.0
```

#### Install Dependencies
```bash
pod install
```

#### Open in Xcode
```bash
open *.xcworkspace
```

Or directly open `Cloudflare Network Diagnostic Tool.xcodeproj` in Xcode.

#### Build & Run
1. Select your target device (iPhone simulator or connected device)
2. Press **Cmd + R** to build and run
3. The app will launch automatically

---

## 🚀 **Quick Start**

### Using the iOS Shortcut

1. Open the Shortcuts app
2. Find "Cloudflare Network Diagnostic"
3. Tap to run
4. View results in the output panel
5. Tap **Export** to save or share results

### Using the SwiftUI App

1. Launch the app from your home screen or Xcode
2. Tap **"Run Diagnostics"**
3. Wait for tests to complete (typically 10-30 seconds)
4. Review results in the dashboard
5. Export results via the **"Export"** button

---

## 📊 **Example Output**

### Shortcut/Console Output
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  CLOUDFLARE NETWORK DIAGNOSTIC REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 TRACE INFORMATION
   IP Address: 203.0.113.42
   Country: United States
   Cloudflare PoP: LAX
   Timezone: America/Los_Angeles

🔍 DNS BENCHMARKS
   Cloudflare: 12ms
   Google: 18ms
   Quad9: 15ms
   NextDNS: 22ms

🛡️ WARP Status: Connected (WARP+)

📊 HEALTH SCORE: 8.5/10 ✅

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### JSON Export Example
```json
{
  "timestamp": "2025-06-13T14:32:00Z",
  "trace": {
    "ip": "203.0.113.42",
    "country": "United States",
    "cloudflare_pop": "LAX",
    "warp_enabled": true,
    "warp_mode": "WARP+"
  },
  "benchmarks": {
    "cloudflare_dns": 12,
    "google_dns": 18,
    "quad9_dns": 15,
    "nextdns": 22
  },
  "health_score": 8.5
}
```

---

## ⚙️ **Configuration**

### Export Settings
- Choose format: JSON, JSONL, Minified, or Pretty
- Automatic filename with timestamp
- Share via AirDrop, email, or cloud storage

### Log Management
- Logs stored in app's local Documents directory
- Automatic cleanup after 30 days (configurable)
- Manual deletion available anytime

### Diagnostic Options (Developer Mode)
- Enable verbose logging
- Custom resolver list
- Extended trace analysis
- Performance metrics

---

## 🐛 **Troubleshooting**

### Issue: "Cannot connect to network"
- **Solution:** Check your internet connection
- Ensure WiFi or cellular is enabled
- Try again in a few seconds

### Issue: "DNS tests timing out"
- **Solution:** Normal on slow networks
- Try reducing the number of resolvers tested
- Check if your ISP blocks DNS queries

### Issue: "App crashes on startup"
- **Solution:** Reinstall the app
- Delete app from device, then re-download
- Ensure you're on iOS 15+ or macOS 12+

### Issue: "Cannot export results"
- **Solution:** Check available storage
- Try a different export format
- Restart the app

For additional support, check the [Issues](https://github.com/hyrated117-svg/Cloudflare-Network-Diagnostic-Tool-v1.0/issues) page.

---

## 🤝 **Contributing**

We welcome contributions! Here's how:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Guidelines
- Follow Swift style conventions
- Add comments for complex logic
- Test thoroughly before submitting
- Keep PRs focused on a single feature
- Update documentation as needed

---

## 🗺️ **Roadmap**

### v1.0 (Current)
✅ DNS benchmarking
✅ DoH performance testing
✅ Cloudflare Trace integration
✅ WARP detection
✅ Network health scoring
✅ Multi-format export

### v1.1 (Planned)
- [ ] Packet loss detection
- [ ] Latency variance analysis
- [ ] Historical trend tracking
- [ ] Scheduled automated tests
- [ ] Custom resolver support

### v2.0 (Future)
- [ ] Web dashboard
- [ ] Real-time monitoring
- [ ] Network anomaly alerts
- [ ] Comparative reports
- [ ] API integration

---

## 📄 **License**

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

You are free to use, modify, and distribute this software, provided you include the original license and copyright notice.

---

## 📞 **Support**

- **Issues & Bugs:** [GitHub Issues](https://github.com/hyrated117-svg/Cloudflare-Network-Diagnostic-Tool-v1.0/issues)
- **Discussions:** [GitHub Discussions](https://github.com/hyrated117-svg/Cloudflare-Network-Diagnostic-Tool-v1.0/discussions)
- **Email:** Include your issue details when reporting

---

## ❤️ **Acknowledgments**

- Built with **Swift** and **SwiftUI**
- Powered by **Cloudflare** DNS and Trace APIs
- Inspired by network diagnostic best practices

---

**Cloudflare Network Diagnostic Tool** — *Transparent. Private. Powerful.*

Made with ❤️ by the community | v1.0 (Pre-release) | Last updated: June 2025
