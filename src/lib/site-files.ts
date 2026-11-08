import fs from 'node:fs';
import path from 'node:path';
import { getCollection, type CollectionEntry } from 'astro:content';
import { site } from '../data/site';

/** True once public/cv.pdf exists. CV buttons render only then, so they never 404. */
export const hasCv = fs.existsSync(path.join(process.cwd(), 'public', site.cvPath.replace(/^\//, '')));

export type Project = CollectionEntry<'projects'>;

/** Visible projects: featured first, then by `order`. */
export async function getProjects(): Promise<Project[]> {
  const all = await getCollection('projects', (p) => !p.data.draft);
  return all.sort(
    (a, b) => Number(b.data.featured) - Number(a.data.featured) || a.data.order - b.data.order,
  );
}

const ICON_LIVE = '<svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true"><path d="M6 3H3v10h10v-3M9 3h4v4M13 3 7 9"/></svg>';
const ICON_GITHUB = '<svg viewBox="0 0 16 16" fill="currentColor" aria-hidden="true"><path d="M8 0a8 8 0 0 0-2.53 15.59c.4.07.55-.17.55-.38v-1.33c-2.23.48-2.7-1.07-2.7-1.07-.36-.92-.89-1.17-.89-1.17-.73-.5.06-.49.06-.49.8.06 1.23.83 1.23.83.71 1.23 1.87.87 2.33.67.07-.52.28-.87.5-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82a7.6 7.6 0 0 1 4 0c1.53-1.03 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.28.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48v2.2c0 .21.15.46.55.38A8 8 0 0 0 8 0Z"/></svg>';

/** The two buttons every project shows. An empty url renders as a disabled "soon" pill, never a dead link. */
export function projectButtons(links: { demo: string; code: string }) {
  return [
    { label: 'Live demo', url: links.demo, icon: ICON_LIVE },
    { label: 'GitHub', url: links.code, icon: ICON_GITHUB },
  ];
}

export const statusLabel: Record<string, string> = {
  live: 'Live demo',
  building: 'Now building',
  code: '',
};
