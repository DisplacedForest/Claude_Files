# Development Guide for Claude - Astro + Strapi

## 🎯 Core Philosophy

**TEST-DRIVEN DEVELOPMENT IS NON-NEGOTIABLE.** Every single line of production code must be written in response to a failing test. No exceptions. This is not a suggestion or a preference - it is the fundamental practice that enables all other principles in this document.

### Quick Reference
- **Write tests first** (TDD - Red, Green, Refactor)
- **Test behavior, not implementation**
- **No `any` types** or type assertions
- **Immutable data only**
- **Small, pure functions**
- **TypeScript strict mode always**
- **100% behavior coverage** (not just line coverage)
- **Schema-first development** with runtime validation

## ⚡ Tech Stack Configuration

```yaml
Framework: Astro 4+ + Strapi 4+
Language: TypeScript (strict mode)
Testing: Vitest + Playwright + Astro Testing Library
Database: PostgreSQL (via Strapi)
CMS: Strapi Headless CMS
Validation: Zod (frontend) + Strapi validators (backend)
Styling: Tailwind CSS + Astro CSS
Package Manager: npm
Content: MDX + Strapi Content Types
Authentication: Strapi Auth + JWT
```

## 📁 Repository Structure

```
/
├── frontend/               # Astro application
│   ├── src/
│   │   ├── components/     # Astro components
│   │   │   ├── ui/         # Base UI components
│   │   │   ├── islands/    # Interactive islands
│   │   │   └── layout/     # Layout components
│   │   ├── content/        # Content collections (MDX)
│   │   │   ├── blog/       # Blog posts
│   │   │   ├── docs/       # Documentation
│   │   │   └── config.ts   # Content collection config
│   │   ├── layouts/        # Page layouts
│   │   ├── pages/          # File-based routing
│   │   │   ├── api/        # API endpoints
│   │   │   ├── blog/       # Blog pages
│   │   │   └── [...slug].astro # Dynamic routes
│   │   ├── lib/            # Utilities and helpers
│   │   │   ├── strapi.ts   # Strapi API client
│   │   │   ├── utils.ts    # General utilities
│   │   │   └── schemas/    # Zod schemas
│   │   ├── types/          # TypeScript definitions
│   │   └── env.d.ts        # Environment types
│   ├── public/             # Static assets
│   ├── astro.config.mjs    # Astro configuration
│   └── package.json
├── backend/                # Strapi CMS
│   ├── src/
│   │   ├── api/            # API collections
│   │   │   ├── blog-post/  # Blog post content type
│   │   │   ├── page/       # Page content type
│   │   │   └── author/     # Author content type
│   │   ├── components/     # Strapi components
│   │   ├── extensions/     # Strapi extensions
│   │   ├── middlewares/    # Custom middlewares
│   │   ├── plugins/        # Custom plugins
│   │   └── policies/       # Custom policies
│   ├── config/             # Strapi configuration
│   │   ├── database.ts     # Database config
│   │   ├── server.ts       # Server config
│   │   └── plugins.ts      # Plugin config
│   ├── database/
│   │   └── migrations/     # Database migrations
│   └── package.json
├── shared/                 # Shared code
│   ├── types/              # Shared TypeScript types
│   ├── schemas/            # Shared Zod schemas
│   └── constants/          # Shared constants
├── docs/                   # Documentation
│   ├── features/           # Feature specs
│   ├── content-types/      # Strapi content type docs
│   ├── api/               # API documentation
│   └── ADRs/              # Architectural Decision Records
└── .claude/               # AI assistant configuration
    └── commands/          # Custom AI commands
```

## 🗄️ Database Documentation (CRITICAL FOR AI)

### Overview Documentation Structure

```markdown
# docs/content-types/00_strapi_overview.md

## Architecture Philosophy
Content-first development with Strapi as headless CMS providing structured content

## Database Technology
- Platform: PostgreSQL 15+ (via Strapi)
- CMS: Strapi 4+ with custom content types
- Client: Strapi REST/GraphQL API
- Security: Strapi RBAC + content permissions
- Auth: Strapi Users & Permissions plugin
- Media: Strapi Media Library with cloud storage

## Content Organization Strategy
### Content Types
Core Content      → Blog Posts, Pages, Authors
Supporting Content → Tags, Categories, Media
User Content      → Comments, User Profiles

### Content Relationships
Authors -> Blog Posts (One-to-Many)
Posts -> Tags (Many-to-Many)
Posts -> Categories (Many-to-Many)

## Content Type Naming Conventions
- Content Types: kebab-case (blog-post, author-profile)
- API IDs: camelCase (blogPost, authorProfile)  
- Database tables: snake_case (blog_posts, author_profiles)

## Performance Guidelines
### Content Optimization
- Use Strapi's built-in caching
- Implement proper image optimization
- Leverage Astro's static generation

## Business Context
Content marketing website with blog, documentation, and landing pages
```

### Strapi Content Type Patterns

```typescript
// backend/src/api/blog-post/content-types/blog-post/schema.json
{
  "kind": "collectionType",
  "collectionName": "blog_posts",
  "info": {
    "singularName": "blog-post",
    "pluralName": "blog-posts",
    "displayName": "Blog Post",
    "description": "Blog post content with rich text and metadata"
  },
  "options": {
    "draftAndPublish": true
  },
  "pluginOptions": {},
  "attributes": {
    "title": {
      "type": "string",
      "required": true,
      "maxLength": 200
    },
    "slug": {
      "type": "uid",
      "targetField": "title",
      "required": true
    },
    "excerpt": {
      "type": "text",
      "required": true,
      "maxLength": 500
    },
    "content": {
      "type": "richtext",
      "required": true
    },
    "featuredImage": {
      "type": "media",
      "multiple": false,
      "required": false,
      "allowedTypes": ["images"]
    },
    "author": {
      "type": "relation",
      "relation": "manyToOne",
      "target": "api::author.author",
      "inversedBy": "blogPosts"
    },
    "tags": {
      "type": "relation",
      "relation": "manyToMany",
      "target": "api::tag.tag",
      "mappedBy": "blogPosts"
    },
    "publishedDate": {
      "type": "datetime",
      "required": true
    },
    "seo": {
      "type": "component",
      "repeatable": false,
      "component": "shared.seo"
    }
  }
}
```

## 🔄 Development Workflow

### Test-Driven Development Cycle

```typescript
// Step 1: RED - Write a failing test
import { describe, it, expect } from 'vitest';
import { getBlogPosts } from '../lib/strapi';

describe('Blog Post API', () => {
  it('should fetch published blog posts', async () => {
    const posts = await getBlogPosts();
    
    expect(posts).toBeDefined();
    expect(Array.isArray(posts)).toBe(true);
    expect(posts.length).toBeGreaterThan(0);
    expect(posts[0]).toHaveProperty('title');
    expect(posts[0]).toHaveProperty('slug');
    expect(posts[0]).toHaveProperty('publishedAt');
  });
});

// Step 2: GREEN - Minimal implementation
// frontend/src/lib/strapi.ts
import { BlogPostSchema, type BlogPost } from './schemas/blog-post';

const STRAPI_URL = import.meta.env.STRAPI_URL || 'http://localhost:1337';

export async function getBlogPosts(): Promise<BlogPost[]> {
  const response = await fetch(`${STRAPI_URL}/api/blog-posts?populate=*`);
  
  if (!response.ok) {
    throw new Error('Failed to fetch blog posts');
  }
  
  const { data } = await response.json();
  
  return data.map((item: any) => BlogPostSchema.parse({
    id: item.id,
    title: item.attributes.title,
    slug: item.attributes.slug,
    excerpt: item.attributes.excerpt,
    content: item.attributes.content,
    publishedAt: item.attributes.publishedAt,
    author: item.attributes.author?.data?.attributes,
    featuredImage: item.attributes.featuredImage?.data?.attributes,
  }));
}

// Step 3: REFACTOR - Assess improvements
// Only refactor if it adds value. If code is clean, move on.
```

### Astro Component TDD

```typescript
// Step 1: RED - Component test
import { describe, it, expect } from 'vitest';
import { experimental_AstroContainer as AstroContainer } from 'astro/container';
import BlogCard from '../components/BlogCard.astro';

describe('BlogCard', () => {
  it('should render blog post data correctly', async () => {
    const container = await AstroContainer.create();
    
    const mockPost = {
      id: 1,
      title: 'Test Blog Post',
      slug: 'test-blog-post',
      excerpt: 'This is a test excerpt',
      publishedAt: '2024-01-01T00:00:00.000Z',
      author: { name: 'John Doe' }
    };
    
    const result = await container.renderToString(BlogCard, {
      props: { post: mockPost }
    });
    
    expect(result).toContain('Test Blog Post');
    expect(result).toContain('This is a test excerpt');
    expect(result).toContain('John Doe');
  });
});
```

## 📐 Architecture Principles

### Schema-First Development with Zod

```typescript
// frontend/src/lib/schemas/blog-post.ts
import { z } from 'zod';

export const BlogPostSchema = z.object({
  id: z.number(),
  title: z.string().min(1).max(200),
  slug: z.string().min(1),
  excerpt: z.string().min(1).max(500),
  content: z.string().min(1),
  publishedAt: z.string().datetime(),
  author: z.object({
    name: z.string(),
    bio: z.string().optional(),
    avatar: z.object({
      url: z.string().url(),
      alternativeText: z.string().optional(),
    }).optional(),
  }).optional(),
  featuredImage: z.object({
    url: z.string().url(),
    alternativeText: z.string().optional(),
    width: z.number(),
    height: z.number(),
  }).optional(),
  tags: z.array(z.object({
    name: z.string(),
    slug: z.string(),
  })).optional(),
});

export type BlogPost = z.infer<typeof BlogPostSchema>;

// Usage in Astro components
// frontend/src/pages/blog/[slug].astro
---
import { getBlogPost } from '../../lib/strapi';
import { BlogPostSchema } from '../../lib/schemas/blog-post';
import Layout from '../../layouts/Layout.astro';

export async function getStaticPaths() {
  const posts = await getBlogPosts();
  return posts.map(post => ({ params: { slug: post.slug } }));
}

const { slug } = Astro.params;
const post = await getBlogPost(slug);
const validatedPost = BlogPostSchema.parse(post);
---

<Layout title={validatedPost.title}>
  <article>
    <h1>{validatedPost.title}</h1>
    <p>{validatedPost.excerpt}</p>
    <div set:html={validatedPost.content} />
  </article>
</Layout>
```

### Astro Island Architecture

```astro
<!-- frontend/src/components/islands/SearchWidget.astro -->
---
// This is an interactive island that will hydrate on the client
interface Props {
  placeholder?: string;
}

const { placeholder = "Search..." } = Astro.props;
---

<search-widget data-placeholder={placeholder}>
  <input type="search" placeholder={placeholder} />
  <div class="results" style="display: none;"></div>
</search-widget>

<script>
  class SearchWidget extends HTMLElement {
    private input: HTMLInputElement;
    private results: HTMLElement;

    constructor() {
      super();
      this.input = this.querySelector('input')!;
      this.results = this.querySelector('.results')!;
      this.setupEventListeners();
    }

    private setupEventListeners() {
      this.input.addEventListener('input', this.handleSearch.bind(this));
    }

    private async handleSearch(event: Event) {
      const query = (event.target as HTMLInputElement).value;
      
      if (query.length < 2) {
        this.results.style.display = 'none';
        return;
      }

      try {
        const response = await fetch(`/api/search?q=${encodeURIComponent(query)}`);
        const results = await response.json();
        this.displayResults(results);
      } catch (error) {
        console.error('Search failed:', error);
      }
    }

    private displayResults(results: any[]) {
      this.results.innerHTML = results.map(result => 
        `<a href="/blog/${result.slug}">${result.title}</a>`
      ).join('');
      this.results.style.display = 'block';
    }
  }

  customElements.define('search-widget', SearchWidget);
</script>

<!-- Usage in pages -->
<!-- frontend/src/pages/index.astro -->
---
import SearchWidget from '../components/islands/SearchWidget.astro';
---

<html>
  <body>
    <!-- This will be hydrated and interactive -->
    <SearchWidget client:load placeholder="Search blog posts..." />
  </body>
</html>
```

### Content Collections Pattern

```typescript
// frontend/src/content/config.ts
import { defineCollection, z } from 'astro:content';

const blogCollection = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    publishDate: z.date(),
    author: z.string(),
    tags: z.array(z.string()),
    featured: z.boolean().default(false),
  }),
});

const docsCollection = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    category: z.enum(['getting-started', 'guides', 'reference']),
    order: z.number(),
  }),
});

export const collections = {
  'blog': blogCollection,
  'docs': docsCollection,
};

// Usage in pages
// frontend/src/pages/blog/index.astro
---
import { getCollection } from 'astro:content';
import Layout from '../../layouts/Layout.astro';

const blogPosts = await getCollection('blog');
const sortedPosts = blogPosts.sort((a, b) => 
  b.data.publishDate.getTime() - a.data.publishDate.getTime()
);
---

<Layout title="Blog">
  <main>
    <h1>Blog Posts</h1>
    <ul>
      {sortedPosts.map(post => (
        <li>
          <a href={`/blog/${post.slug}/`}>
            <h2>{post.data.title}</h2>
            <p>{post.data.description}</p>
          </a>
        </li>
      ))}
    </ul>
  </main>
</Layout>
```

## 🧪 Testing Guidelines

### Strapi API Testing

```typescript
// backend/tests/blog-post/index.test.ts
import { test, expect } from '@playwright/test';

const STRAPI_URL = process.env.STRAPI_URL || 'http://localhost:1337';

test.describe('Blog Post API', () => {
  test('should create and retrieve blog post', async ({ request }) => {
    // Create a blog post
    const createResponse = await request.post(`${STRAPI_URL}/api/blog-posts`, {
      data: {
        data: {
          title: 'Test Blog Post',
          slug: 'test-blog-post',
          excerpt: 'This is a test excerpt',
          content: 'This is test content',
          publishedDate: new Date().toISOString(),
        }
      },
      headers: {
        'Authorization': `Bearer ${process.env.STRAPI_API_TOKEN}`,
        'Content-Type': 'application/json',
      }
    });

    expect(createResponse.ok()).toBeTruthy();
    const createdPost = await createResponse.json();
    
    // Retrieve the blog post
    const getResponse = await request.get(
      `${STRAPI_URL}/api/blog-posts/${createdPost.data.id}`
    );
    
    expect(getResponse.ok()).toBeTruthy();
    const retrievedPost = await getResponse.json();
    
    expect(retrievedPost.data.attributes.title).toBe('Test Blog Post');
    expect(retrievedPost.data.attributes.slug).toBe('test-blog-post');
  });
});
```

### Astro Component Testing

```typescript
// frontend/src/components/__tests__/BlogCard.test.ts
import { describe, it, expect } from 'vitest';
import { experimental_AstroContainer as AstroContainer } from 'astro/container';
import BlogCard from '../BlogCard.astro';

describe('BlogCard Component', () => {
  it('should render blog post with all data', async () => {
    const container = await AstroContainer.create();
    
    const mockPost = {
      id: 1,
      title: 'Sample Blog Post',
      slug: 'sample-blog-post',
      excerpt: 'This is a sample excerpt for testing',
      publishedAt: '2024-01-15T10:00:00.000Z',
      author: {
        name: 'Jane Smith',
        bio: 'Content writer and developer',
      },
      featuredImage: {
        url: '/images/sample.jpg',
        alternativeText: 'Sample image',
        width: 800,
        height: 600,
      },
      tags: [
        { name: 'Development', slug: 'development' },
        { name: 'Testing', slug: 'testing' }
      ]
    };
    
    const result = await container.renderToString(BlogCard, {
      props: { post: mockPost }
    });
    
    expect(result).toContain('Sample Blog Post');
    expect(result).toContain('This is a sample excerpt');
    expect(result).toContain('Jane Smith');
    expect(result).toContain('Development');
    expect(result).toContain('Testing');
    expect(result).toContain('/images/sample.jpg');
  });

  it('should handle missing optional data gracefully', async () => {
    const container = await AstroContainer.create();
    
    const minimalPost = {
      id: 2,
      title: 'Minimal Post',
      slug: 'minimal-post',
      excerpt: 'Minimal excerpt',
      publishedAt: '2024-01-15T10:00:00.000Z',
    };
    
    const result = await container.renderToString(BlogCard, {
      props: { post: minimalPost }
    });
    
    expect(result).toContain('Minimal Post');
    expect(result).toContain('Minimal excerpt');
    expect(result).not.toContain('undefined');
  });
});
```

## 🚀 Development Practices

### Error Handling

```typescript
// frontend/src/lib/strapi.ts
export class StrapiError extends Error {
  constructor(
    message: string,
    public statusCode?: number,
    public details?: any
  ) {
    super(message);
    this.name = 'StrapiError';
  }
}

export async function fetchFromStrapi<T>(
  endpoint: string,
  schema: z.ZodSchema<T>
): Promise<T> {
  try {
    const response = await fetch(`${STRAPI_URL}/api/${endpoint}`);
    
    if (!response.ok) {
      throw new StrapiError(
        `Failed to fetch ${endpoint}`,
        response.status,
        await response.text()
      );
    }
    
    const data = await response.json();
    return schema.parse(data);
    
  } catch (error) {
    if (error instanceof StrapiError) {
      throw error;
    }
    
    if (error instanceof z.ZodError) {
      throw new StrapiError(
        `Invalid data structure from ${endpoint}`,
        500,
        error.errors
      );
    }
    
    throw new StrapiError(
      `Unexpected error fetching ${endpoint}`,
      500,
      error
    );
  }
}

// frontend/src/pages/api/search.ts
import type { APIRoute } from 'astro';

export const GET: APIRoute = async ({ url }) => {
  try {
    const query = url.searchParams.get('q');
    
    if (!query || query.length < 2) {
      return new Response(JSON.stringify([]), {
        status: 200,
        headers: { 'Content-Type': 'application/json' }
      });
    }
    
    const results = await searchBlogPosts(query);
    
    return new Response(JSON.stringify(results), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });
    
  } catch (error) {
    console.error('Search API error:', error);
    
    return new Response(JSON.stringify({ error: 'Search failed' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
};
```

## ⚠️ Critical Instructions

### NEVER
- Use `any` types without justification
- Create files unless absolutely necessary
- Write production code without a failing test first
- Include AI/Claude mentions in commits
- Push to remote unless explicitly asked
- Remove from .env files (only add/comment)
- Update git config
- Create documentation unless requested

### ALWAYS
- Write tests first (TDD)
- Use TypeScript strict mode
- Use Zod for validation at API boundaries
- Import schemas from shared location in tests
- Prefer editing existing files
- Run tests after implementation
- Check Strapi content type documentation before queries
- Use conventional commits
- Validate Strapi API responses with Zod schemas
- Use Astro's island architecture for interactive components

## 📋 Custom Commands

### /audit
Performs comprehensive codebase analysis across:
- Code quality and duplication
- Security vulnerabilities
- Content type optimization
- Documentation gaps
- Dependency issues

### /plan [feature-name]
Creates detailed feature specification including:
- User stories and acceptance criteria
- Technical approach
- Strapi content type changes
- API endpoints
- Testing strategy (Vitest + Playwright)

### /add-feature [feature-name]
Adds feature to planning queue with strategic questions for consideration

## 📚 Resources

- [Astro Documentation](https://docs.astro.build/)
- [Strapi Documentation](https://docs.strapi.io/)
- [Zod Documentation](https://zod.dev/)
- [Vitest Documentation](https://vitest.dev/)
- [Playwright Documentation](https://playwright.dev/)
- Project-specific ADRs in `/docs/ADRs/`

---

**Remember**: The key is writing clean, testable, functional code that evolves through small, safe increments. Every change should be driven by a test that describes the desired behavior. When in doubt, favor simplicity and readability over cleverness.