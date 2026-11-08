import { defineConfig } from 'astro/config';

// Set SITE_URL (e.g. https://arshdeepsingh.dev) once the domain is known.
// It turns on canonical URLs and absolute Open Graph links.
export default defineConfig({
  site: process.env.SITE_URL || undefined,
  build: { format: 'directory' }, // /projects/agentops/index.html, served by the CloudFront function
  trailingSlash: 'ignore',
  devToolbar: { enabled: false },
});
