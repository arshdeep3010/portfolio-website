import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

// One Markdown file in src/content/projects/ = one project on the site.
// A file that breaks these rules fails the build, so it can't go live.
const url = z.union([z.string().url(), z.literal('')]).default('');

const projects = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/projects' }),
  schema: z
    .object({
      title: z.string(),
      pitch: z.string().max(140, 'Keep the pitch to one short sentence.'),
      order: z.number().int(),
      featured: z.boolean().default(true),
      draft: z.boolean().default(false), // true = built but not shown
      status: z.enum(['live', 'code', 'building']).default('code'),
      tags: z.array(z.string()).min(1),
      stack: z.array(z.string()).min(1),
      metric: z.string().default(''), // one measured line; HTML <b> allowed for emphasis
      metricDate: z.string().default(''), // when it was measured, e.g. 2026-11
      demo: z.enum(['chaos', 'fit', 'health', 'vibe', 'none']).default('none'),
      image: z.string().default(''), // /media/<file> for projects without a live demo
      links: z.object({ code: url, demo: url, video: url }).default({}),
    })
    .superRefine((p, ctx) => {
      if (p.metric && !p.metricDate) {
        ctx.addIssue({ code: z.ZodIssueCode.custom, message: 'A metric needs a metricDate: every number on the site is dated.', path: ['metricDate'] });
      }
    }),
});

export const collections = { projects };
