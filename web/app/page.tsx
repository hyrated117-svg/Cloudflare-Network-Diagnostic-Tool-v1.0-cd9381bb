export default function Home() {
  return (
    <div className="flex flex-col flex-1 items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100 dark:from-gray-900 dark:to-gray-800 font-sans">
      <main className="flex flex-1 w-full max-w-5xl flex-col items-center justify-center py-16 px-8">
        <div className="text-center space-y-8">
          <h1 className="text-5xl md:text-6xl font-bold tracking-tight text-gray-900 dark:text-white">
            Cloudflare Network Diagnostic Tool
          </h1>
          <p className="text-xl md:text-2xl text-gray-700 dark:text-gray-300 max-w-3xl mx-auto">
            High-precision, privacy-first network diagnostic engine
          </p>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mt-12">
            <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow-lg">
              <div className="text-3xl mb-3">🔍</div>
              <h3 className="text-lg font-semibold mb-2 text-gray-900 dark:text-white">DNS Benchmarking</h3>
              <p className="text-gray-600 dark:text-gray-400">
                Measure DNS response times across multiple resolvers
              </p>
            </div>
            
            <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow-lg">
              <div className="text-3xl mb-3">🔒</div>
              <h3 className="text-lg font-semibold mb-2 text-gray-900 dark:text-white">Privacy First</h3>
              <p className="text-gray-600 dark:text-gray-400">
                All processing happens on-device. No tracking or data collection
              </p>
            </div>
            
            <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow-lg">
              <div className="text-3xl mb-3">⚡</div>
              <h3 className="text-lg font-semibold mb-2 text-gray-900 dark:text-white">WARP Detection</h3>
              <p className="text-gray-600 dark:text-gray-400">
                Detect Cloudflare WARP status and connection mode
              </p>
            </div>
            
            <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow-lg">
              <div className="text-3xl mb-3">📊</div>
              <h3 className="text-lg font-semibold mb-2 text-gray-900 dark:text-white">Health Scoring</h3>
              <p className="text-gray-600 dark:text-gray-400">
                Comprehensive network quality assessment with weighted scoring
              </p>
            </div>
            
            <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow-lg">
              <div className="text-3xl mb-3">📦</div>
              <h3 className="text-lg font-semibold mb-2 text-gray-900 dark:text-white">Multiple Formats</h3>
              <p className="text-gray-600 dark:text-gray-400">
                Export results in JSON, JSONL, minified, or pretty-printed formats
              </p>
            </div>
            
            <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow-lg">
              <div className="text-3xl mb-3">🛠️</div>
              <h3 className="text-lg font-semibold mb-2 text-gray-900 dark:text-white">Cross-Platform</h3>
              <p className="text-gray-600 dark:text-gray-400">
                Available for iOS, macOS, and as an Apple Shortcut
              </p>
            </div>
          </div>
          
          <div className="flex flex-col sm:flex-row gap-4 justify-center mt-12">
            <a
              className="flex h-12 items-center justify-center gap-2 rounded-lg bg-blue-600 px-8 text-white font-semibold transition-colors hover:bg-blue-700"
              href="https://github.com/hyrated117-svg/Cloudflare-Network-Diagnostic-Tool-v1.0"
              target="_blank"
              rel="noopener noreferrer"
            >
              View on GitHub
            </a>
            <a
              className="flex h-12 items-center justify-center rounded-lg border-2 border-blue-600 px-8 text-blue-600 dark:text-blue-400 font-semibold transition-colors hover:bg-blue-50 dark:hover:bg-gray-700"
              href="https://github.com/hyrated117-svg/Cloudflare-Network-Diagnostic-Tool-v1.0#readme"
              target="_blank"
              rel="noopener noreferrer"
            >
              Documentation
            </a>
          </div>
        </div>
      </main>
      
      <footer className="w-full py-6 text-center text-gray-600 dark:text-gray-400">
        <p>Made with ❤️ by the community | v1.0 (Pre-release)</p>
      </footer>
    </div>
  );
}
