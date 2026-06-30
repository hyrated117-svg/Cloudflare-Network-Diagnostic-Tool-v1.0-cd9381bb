# Cloudflare Network Diagnostic Tool - Web Interface

This is the web landing page for the Cloudflare Network Diagnostic Tool, built with Next.js and TypeScript.

## Features

- 🎨 Modern, responsive design with Tailwind CSS
- 📊 Vercel Web Analytics integration for tracking
- 🌙 Dark mode support
- ⚡ Static site generation for optimal performance
- 🔒 Privacy-focused analytics

## Getting Started

### Prerequisites

- Node.js 18+ or later
- pnpm (recommended) or npm/yarn

### Installation

```bash
cd web
pnpm install
```

### Development

```bash
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000) to view the site in development mode.

### Build

```bash
pnpm build
```

This builds the application for production to the `.next` directory.

### Lint

```bash
pnpm lint
```

Runs ESLint to check for code quality issues.

## Vercel Analytics

This project includes Vercel Web Analytics configured according to the [official documentation](https://vercel.com/docs/analytics/quickstart).

The Analytics component is integrated in `app/layout.tsx` and will automatically track page views when deployed to Vercel.

### Configuration

Analytics is configured using the Next.js App Router pattern:

```typescript
import { Analytics } from "@vercel/analytics/next";

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Analytics />
      </body>
    </html>
  );
}
```

### Viewing Analytics

Once deployed to Vercel:
1. Navigate to your project dashboard on Vercel
2. Click on the "Analytics" tab
3. View real-time and historical visitor data

## Deployment

### Deploy to Vercel

The easiest way to deploy this Next.js app is to use the [Vercel Platform](https://vercel.com/new).

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/hyrated117-svg/Cloudflare-Network-Diagnostic-Tool-v1.0)

### Manual Deployment

```bash
# Install Vercel CLI
pnpm add -g vercel

# Deploy
cd web
vercel
```

## Tech Stack

- **Framework**: [Next.js 16](https://nextjs.org/)
- **Language**: [TypeScript](https://www.typescriptlang.org/)
- **Styling**: [Tailwind CSS 4](https://tailwindcss.com/)
- **Analytics**: [Vercel Analytics](https://vercel.com/analytics)
- **Fonts**: [Geist Font Family](https://vercel.com/font)

## Project Structure

```
web/
├── app/
│   ├── layout.tsx         # Root layout with Analytics
│   ├── page.tsx           # Landing page
│   └── globals.css        # Global styles
├── public/                # Static assets
├── package.json           # Dependencies
└── README.md             # This file
```

## Contributing

This is part of the main Cloudflare Network Diagnostic Tool project. Please see the main repository for contribution guidelines.

## License

MIT License - see the main repository for full license details.
