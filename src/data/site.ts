// Everything personal about the site lives here.
// Empty strings are fine: any button or link whose value is empty is hidden,
// so the live site never shows a broken link. Fill them in as you decide.

export const site = {
  name: 'Arshdeep Singh',
  role: 'GenAI and backend engineer', // a description of the work, never a job title
  location: 'Noida or remote',
  availability: 'Open to GenAI and backend roles',
  description:
    "I build AI systems that don't make things up, on backends that don't fall over. Java and Python, RAG, agent workflows and evaluation, with measured results.",

  headline: { lead: 'I build AI that', accent: "doesn't make things up." },
  sub: "On backends that don't fall over. I work in Java and Python with RAG, agent workflows and evaluation, and every number on this page is one I measured.",

  // TODO(you): fill these in. Leave a value empty to hide its button.
  email: 'arshdeep.si.3010@gmail.com', // shown as text and a mailto link
  github: 'https://github.com/arshdeep3010',
  linkedin: 'https://www.linkedin.com/in/arshdeep-singh30/',
  cvPath: '/cv.pdf', // drop the public CV (no phone, no title) at public/cv.pdf; buttons appear by themselves

  employer: 'TCS',
};

// The proof strip. Every number here must be measured; each links to where it's explained.
export const proof = [
  { value: '0', unit: ' / 500', label: 'runs lost while 435 workers were killed at random', href: '/projects/agentops/#results' },
  { value: '100', unit: '%', label: 'FitCheck accuracy on 25 labelled requirements (keyword baseline: 52%)', href: '/projects/fitcheck/#results' },
  { value: '0', unit: '%', label: 'false claims, against 54% for the keyword baseline', href: '/projects/fitcheck/#results' },
  { value: '5.5', unit: ' min', label: 'from a coding task to merged code through 9 quality gates', href: '/projects/agentops/#results' },
];
export const proofNote = 'Measured Nov 2026. Each number links to how it was measured.';

export const principles = [
  {
    title: 'AI proposes, code decides',
    body: 'In the Health Claim Agent, seven rules run before any model, and every rejection is rule-driven. In FitCheck, proof must be retrieved code, or the requirement is marked unverified.',
    href: '/projects/health-claim-agent/',
  },
  {
    title: 'Break it on purpose',
    body: "AgentOps ran 500 workflows while workers were killed at random, 435 times. Nothing was lost and no side effect ran twice. Measured, not assumed.",
    href: '/projects/agentops/#results',
  },
  {
    title: 'Measure, then claim',
    body: 'FitCheck is scored against a keyword baseline on 25 labelled requirements. If a number is not measured yet, it is not on this site.',
    href: '/projects/fitcheck/#results',
  },
];

// Every skill group points at the projects that prove it.
export const skills = [
  { group: 'Backend', items: ['Java 21', 'Spring Boot 3', 'Virtual threads', 'Spring Security (JWT)', 'JPA', 'FastAPI', 'REST', 'SSE'], proof: ['llm-gateway', 'health-claim-agent', 'vibe-audit', 'agentops'] },
  { group: 'GenAI', items: ['RAG', 'pgvector', 'Embeddings', 'Structured outputs', 'LangGraph', 'Evals', 'Grounding'], proof: ['fitcheck', 'health-claim-agent'] },
  { group: 'Agents and reliability', items: ['Durable workflows', 'Leases and fencing', 'Idempotency', 'Circuit breakers and fallback', 'Rate limiting', 'Human in the loop', 'Sandboxing'], proof: ['agentops', 'llm-gateway'] },
  { group: 'Data', items: ['PostgreSQL (SKIP LOCKED, LISTEN/NOTIFY)', 'pgvector', 'DynamoDB'], proof: ['agentops', 'fitcheck'] },
  { group: 'Cloud and DevOps', items: ['Docker', 'GitHub Actions', 'AWS Lambda', 'EventBridge', 'Terraform', 'S3 + CloudFront'], proof: ['agentops', 'health-claim-agent', 'llm-gateway'] },
];

export const experience = {
  what: 'GenAI Developer, for a US healthcare client',
  when: 'Feb 2026 – present',
  where: 'Noida',
  bullets: [
    'Build agentic AI for insurance claim workflows: agents that read claim information, retrieve the relevant policy knowledge and recommend a decision with its reasons.',
    'Work with LLMs, RAG, LangChain and LangGraph, and connect AI services to Java and Spring Boot backends with structured, validated output.',
    'Investigate production issues through Java logs, SQL data and backend behaviour, with development and business teams.',
  ],
};

export const education = { degree: 'B.E. Computer Science', school: 'Chandigarh University', when: '2021 – 2025' };

export const publication = {
  title: 'Automated Network Vulnerability Assessment with Nmap: A Comprehensive Approach',
  venue: 'IEEE ICACCTech 2024 · first author',
  href: 'https://ieeexplore.ieee.org/document/10918528',
};

export const certifications = ['Claude Certified Architect', 'Claude Certified Developer Foundations','Certified Ethical Hacker (CEHV12)'];
