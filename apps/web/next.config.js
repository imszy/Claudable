/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  productionBrowserSourceMaps: false,
  // Disable critters optimizeCss to avoid missing module during build
  experimental: {
    optimizeCss: false,
    scrollRestoration: true,
  },
  async rewrites() {
    // Allow deploying Web and API on different domains without changing code paths
    // by proxying browser calls like `/api/...` to the API service.
    const apiBase =
      process.env.API_BASE ||
      process.env.NEXT_PUBLIC_API_BASE ||
      'http://localhost:8080';

    return [
      {
        source: '/api/:path*',
        destination: `${apiBase}/api/:path*`
      },
      {
        source: '/health',
        destination: `${apiBase}/health`
      }
    ];
  }
};

module.exports = nextConfig;