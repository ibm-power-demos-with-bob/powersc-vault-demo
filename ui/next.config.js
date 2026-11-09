/** @type {import('next').NextConfig} */
module.exports = {
  experimental: {
    instrumentationHook: true,
  },
  // Forward API calls to the Express backend running on port 3002
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: 'http://localhost:3002/api/:path*',
      },
    ];
  },
};
