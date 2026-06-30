export default function Home() {
  return (
    <div className="flex flex-col flex-1 items-center justify-center bg-gradient-to-b from-zinc-50 to-white font-sans dark:from-black dark:to-zinc-900">
      <main className="flex flex-1 w-full max-w-6xl flex-col items-center justify-center py-16 px-8 sm:px-16">
        {/* Hero Section */}
        <div className="text-center mb-16">
          <h1 className="text-5xl sm:text-6xl font-bold tracking-tight text-black dark:text-white mb-6">
            Cloudflare Network Diagnostic Tool
          </h1>
          <p className="text-xl text-zinc-600 dark:text-zinc-400 max-w-2xl mx-auto mb-8">
            High-precision, privacy-first diagnostic engine designed to give you real insight into your network performance.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <a
              href="https://github.com/hyrated117-svg/Cloudflare-Network-Diagnostic-Tool-v1.0"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center justify-center h-12 px-8 rounded-full bg-black text-white dark:bg-white dark:text-black font-medium transition-colors hover:bg-zinc-800 dark:hover:bg-zinc-200"
            >
              View on GitHub
            </a>
            <a
              href="#features"
              className="inline-flex items-center justify-center h-12 px-8 rounded-full border-2 border-black/10 dark:border-white/20 font-medium transition-colors hover:border-black/20 dark:hover:border-white/40"
            >
              Learn More
            </a>
          </div>
        </div>

        {/* Features Grid */}
        <div id="features" className="w-full grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-16">
          <FeatureCard
            title="DNS Benchmarking"
            description="Measure DNS response times across multiple resolvers including Cloudflare, Google, Quad9, and NextDNS."
            icon="🔍"
          />
          <FeatureCard
            title="DoH Performance"
            description="Test encrypted DNS-over-HTTPS performance for enhanced privacy and security."
            icon="🔒"
          />
          <FeatureCard
            title="WARP Detection"
            description="Detect if Cloudflare WARP is active and identify its current mode."
            icon="🛡️"
          />
          <FeatureCard
            title="Network Health Score"
            description="Get a weighted scoring system for overall network quality assessment."
            icon="📊"
          />
          <FeatureCard
            title="Privacy First"
            description="All processing happens on-device. No tracking, no analytics, no data collection."
            icon="✅"
          />
          <FeatureCard
            title="Multiple Export Formats"
            description="Export results in JSON, JSONL, minified, or pretty-printed formats."
            icon="📦"
          />
        </div>

        {/* Platform Support */}
        <div className="w-full bg-zinc-100 dark:bg-zinc-900 rounded-2xl p-8 mb-16">
          <h2 className="text-3xl font-bold text-center mb-8 text-black dark:text-white">
            Available On
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="bg-white dark:bg-black rounded-lg p-6">
              <h3 className="text-xl font-semibold mb-2 text-black dark:text-white">iOS Shortcut</h3>
              <p className="text-zinc-600 dark:text-zinc-400 mb-4">
                Quick and easy installation via Apple Shortcuts. Works on iOS 15+
              </p>
              <span className="text-sm text-zinc-500 dark:text-zinc-500">No coding required</span>
            </div>
            <div className="bg-white dark:bg-black rounded-lg p-6">
              <h3 className="text-xl font-semibold mb-2 text-black dark:text-white">SwiftUI App</h3>
              <p className="text-zinc-600 dark:text-zinc-400 mb-4">
                Full-featured native app for iOS and macOS with advanced diagnostics
              </p>
              <span className="text-sm text-zinc-500 dark:text-zinc-500">macOS 12+ | iOS 15+</span>
            </div>
          </div>
        </div>

        {/* Privacy Promise */}
        <div className="text-center max-w-3xl">
          <h2 className="text-3xl font-bold mb-4 text-black dark:text-white">Privacy Promise</h2>
          <p className="text-lg text-zinc-600 dark:text-zinc-400 mb-6">
            Built with absolute privacy as a core principle. Your data never leaves your device.
          </p>
          <div className="flex flex-wrap justify-center gap-3">
            <Badge text="No Tracking" />
            <Badge text="No Analytics" />
            <Badge text="No External Servers" />
            <Badge text="No Data Collection" />
            <Badge text="100% On-Device" />
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="w-full border-t border-zinc-200 dark:border-zinc-800 py-8">
        <div className="max-w-6xl mx-auto px-8 text-center text-sm text-zinc-600 dark:text-zinc-400">
          <p>
            Made with ❤️ by the community | v1.0 (Pre-release) |{" "}
            <a
              href="https://github.com/hyrated117-svg/Cloudflare-Network-Diagnostic-Tool-v1.0/blob/main/LICENSE"
              className="hover:text-black dark:hover:text-white transition-colors"
              target="_blank"
              rel="noopener noreferrer"
            >
              MIT License
            </a>
          </p>
        </div>
      </footer>
    </div>
  );
}

function FeatureCard({ title, description, icon }: { title: string; description: string; icon: string }) {
  return (
    <div className="bg-white dark:bg-zinc-900 rounded-xl p-6 shadow-sm hover:shadow-md transition-shadow border border-zinc-200 dark:border-zinc-800">
      <div className="text-4xl mb-3">{icon}</div>
      <h3 className="text-xl font-semibold mb-2 text-black dark:text-white">{title}</h3>
      <p className="text-zinc-600 dark:text-zinc-400">{description}</p>
    </div>
  );
}

function Badge({ text }: { text: string }) {
  return (
    <span className="inline-flex items-center px-4 py-2 rounded-full bg-zinc-200 dark:bg-zinc-800 text-sm font-medium text-zinc-800 dark:text-zinc-200">
      {text}
    </span>
  );
}
