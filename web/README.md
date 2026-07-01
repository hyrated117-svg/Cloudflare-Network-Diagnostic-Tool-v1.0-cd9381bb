# Cloudflare Network Diagnostic Tool - Web Landing Page

This is the web landing page for the Cloudflare Network Diagnostic Tool, built with Next.js and configured with Vercel Speed Insights.

## Features

- **Next.js 16** - Latest version with App Router and Turbopack
- **TypeScript** - Full type safety
- **Tailwind CSS** - Utility-first CSS framework
- **Vercel Speed Insights** - Real-time performance monitoring

## Getting Started

Install dependencies:

```bash
npm install
```

Run the development server:

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view the landing page.

## Build

Build for production:

```bash
npm run build
```

Start production server:

```bash
npm start
```

## Vercel Speed Insights

This project includes Vercel Speed Insights for monitoring web performance. The `<SpeedInsights />` component is integrated in `app/layout.tsx` and will automatically collect performance metrics when deployed to Vercel.

To enable Speed Insights on Vercel:
1. Deploy this project to Vercel
2. Navigate to your project dashboard
3. Go to Speed Insights section
4. Click "Enable" to start collecting metrics

## Deployment

This project is optimized for deployment on [Vercel](https://vercel.com):

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/hyrated117-svg/Cloudflare-Network-Diagnostic-Tool-v1.0)

## Project Structure

```
web/
├── app/
│   ├── layout.tsx      # Root layout with SpeedInsights component
│   ├── page.tsx        # Landing page
│   └── globals.css     # Global styles
├── public/             # Static assets
└── package.json        # Dependencies and scripts
```

## License

MIT License - See the main repository LICENSE file for details.
