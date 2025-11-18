# Rayls Website

**Frontend** for Rayls payment gateway - Marketing site, payment dashboard, and analytics.

## Status

🚧 **Coming Soon** - Planning phase

## Planned Features

### Landing Page
- Product overview
- Features showcase
- Integration guides
- API documentation
- Pricing plans

### Payment Dashboard
- Real-time payment monitoring
- Transaction history
- Payment status tracking
- Webhook event viewer
- Analytics charts

### Analytics Dashboard
- Payment volume metrics
- Success/failure rates
- Blockchain transaction status
- Event sourcing timeline
- Performance metrics

## Technology Stack (Planned)

Options under consideration:

### Option 1: Next.js
- **Framework**: Next.js 14+
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **UI Components**: shadcn/ui
- **Charts**: Recharts or Chart.js
- **State**: React Query + Zustand
- **Deployment**: Vercel

### Option 2: React + Vite
- **Framework**: React 18+ with Vite
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **UI Components**: shadcn/ui or Mantine
- **Charts**: Recharts
- **State**: React Query + Zustand
- **Deployment**: Vercel or Netlify

### Option 3: Astro (Marketing Site Only)
- **Framework**: Astro 4+
- **Islands**: React for interactive components
- **Styling**: Tailwind CSS
- **Deployment**: Vercel or Netlify

## Project Structure (Planned)

```
website/
├── src/
│   ├── app/              # Next.js app directory (if Next.js)
│   ├── components/       # React components
│   │   ├── ui/          # shadcn/ui components
│   │   ├── dashboard/   # Dashboard components
│   │   └── landing/     # Landing page components
│   │
│   ├── lib/             # Utilities and helpers
│   ├── hooks/           # Custom React hooks
│   ├── styles/          # Global styles
│   └── types/           # TypeScript types
│
├── public/              # Static assets
├── docs/                # Website-specific documentation
├── package.json
├── tsconfig.json
└── README.md            # This file
```

## Integration with Backend

The website will integrate with the Rayls backend API:

```typescript
// Example API integration
import { useQuery } from '@tanstack/react-query';

// Fetch payments
const { data: payments } = useQuery({
  queryKey: ['payments'],
  queryFn: () => fetch('/api/payments').then(r => r.json())
});

// Subscribe to real-time events via Supabase Realtime
const supabase = createClient(supabaseUrl, supabaseAnonKey);
supabase
  .channel('payments')
  .on('payment.received', (payload) => {
    // Update UI in real-time
  })
  .subscribe();
```

## Roadmap

### Phase 1: Planning (Current)
- [ ] Choose technology stack
- [ ] Design system setup
- [ ] Wireframes
- [ ] API integration planning

### Phase 2: Landing Page
- [ ] Homepage
- [ ] Features page
- [ ] Documentation page
- [ ] Contact/Support

### Phase 3: Dashboard (MVP)
- [ ] Authentication
- [ ] Payment list view
- [ ] Payment detail view
- [ ] Basic charts

### Phase 4: Advanced Dashboard
- [ ] Real-time updates
- [ ] Event sourcing timeline
- [ ] Blockchain transaction viewer
- [ ] Advanced analytics

### Phase 5: Production
- [ ] Performance optimization
- [ ] SEO optimization
- [ ] Monitoring & analytics
- [ ] Deploy to production

## Development (When Ready)

```bash
# Install dependencies
npm install  # or pnpm install

# Run development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Run tests
npm run test

# Lint
npm run lint
```

## Environment Variables (Planned)

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key

# API
NEXT_PUBLIC_API_URL=https://your-api.com

# Analytics (optional)
NEXT_PUBLIC_GA_ID=G-XXXXXXXXXX
```

## Design System (Planned)

Will use a modern, clean design with:
- **Colors**: Primary (blue), accent (green), neutral (gray)
- **Typography**: Inter or Geist for UI, mono for code
- **Components**: shadcn/ui for consistency
- **Icons**: Lucide React
- **Animations**: Framer Motion (sparingly)

## Contributing

This package is not yet started. Contributions welcome once development begins.

## Links

- [Main README](../README.md)
- [Backend README](../backend/README.md)
- [Backend API Documentation](../backend/docs/)

## Contact

For questions about the website roadmap, please open an issue in the main repository.

## License

ISC
