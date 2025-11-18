# Fountain - Rayls Payment Gateway

**Monorepo** for Rayls, an event-driven, serverless payment gateway combining Asaas PIX integration with blockchain transactions.

## 🏗️ Project Structure

```
fountain-raylshack/
├── backend/              # NestJS backend + Supabase Edge Functions
│   ├── src/             # TypeScript source code
│   ├── supabase/        # Edge Functions + Migrations
│   ├── docs/            # Technical documentation
│   └── README.md        # Backend-specific guide
│
├── website/             # Frontend (Coming soon)
│   └── README.md        # Website-specific guide
│
├── CLAUDE.md            # Instructions for Claude Code
└── README.md            # This file
```

## 📦 Packages

### Backend

**Rayls** - Event-driven payment gateway

- **Tech**: NestJS, TypeScript, Supabase, viem.js
- **Features**: PIX payments, blockchain recording, event sourcing
- **Deployment**: Supabase Edge Functions (Deno runtime)
- **Status**: Foundation complete, ready for deployment

[→ Backend README](./backend/README.md)

[→ Backend Documentation](./backend/docs/)

### Website

**Marketing & Dashboard** (Coming soon)

- **Tech**: TBD (Next.js, React, etc.)
- **Purpose**: Landing page, payment dashboard, analytics

[→ Website README](./website/README.md)

## 🚀 Quick Start

### Prerequisites

- Node.js 18+
- pnpm 10+
- Docker (for local Supabase)
- Supabase CLI
- Git

### Get Started

```bash
# Clone the repository
git clone https://github.com/olivmath/fountain-raylshack.git
cd fountain-raylshack

# Set up backend
cd backend
pnpm install
cp .env.example .env
# Edit .env with your credentials

# Start local Supabase
supabase start

# Build and run
pnpm run build
pnpm run start:dev
```

## 📚 Documentation

### Backend Documentation

Located in [`backend/docs/`](./backend/docs/):

- [START_HERE.md](./backend/docs/START_HERE.md) - First steps guide
- [ARCHITECTURE.md](./backend/docs/ARCHITECTURE.md) - System design & patterns
- [DEPLOYMENT_ROADMAP.md](./backend/docs/DEPLOYMENT_ROADMAP.md) - Phase-by-phase deployment
- [SETUP_GUIDE.md](./backend/docs/SETUP_GUIDE.md) - Development environment
- [CHECKPOINT_STATUS.md](./backend/docs/CHECKPOINT_STATUS.md) - Current status
- [PROJECT_SUMMARY.md](./backend/docs/PROJECT_SUMMARY.md) - Overview & features
- [HELLO_WORLD_DEPLOY.md](./backend/docs/HELLO_WORLD_DEPLOY.md) - First deployment

[→ Full Backend Documentation](./backend/docs/README.md)

## 🎯 Current Status

**Phase**: Foundation Complete ✅

**Next Steps**:
1. Deploy hello-world Edge Function (15 min)
2. Phase 0 - Database setup (4 hours)
3. Phase 1 - Asaas webhook integration (4 hours)

See [CHECKPOINT_STATUS.md](./backend/docs/CHECKPOINT_STATUS.md) for details.

## 🔧 Technology Stack

### Backend
- **Framework**: NestJS 11
- **Language**: TypeScript 5.9 (strict mode)
- **Database**: Supabase PostgreSQL
- **Blockchain**: viem.js 2.39
- **Deployment**: Supabase Edge Functions
- **Logging**: Pino
- **Validation**: Zod

### Website (Planned)
- TBD

## 🏛️ Architecture

**Event-Driven** architecture with:
- Event sourcing for complete audit trail
- Repository pattern for clean data access
- Serverless Edge Functions deployment
- Real-time event processing via Supabase Realtime

See [ARCHITECTURE.md](./backend/docs/ARCHITECTURE.md) for details.

## 📋 Available Scripts

```bash
# Backend
cd backend
pnpm install              # Install dependencies
pnpm run build            # Build TypeScript
pnpm run start:dev        # Run with watch mode
pnpm run lint             # Lint code
pnpm run format           # Format code

# Supabase
supabase start            # Start local Supabase
supabase functions serve  # Test Edge Functions locally
supabase functions deploy # Deploy to production
```

## 🗺️ Roadmap

### Backend (4-5 weeks)
- [x] Foundation & Core Services
- [x] Documentation
- [ ] Phase 0: Database Setup
- [ ] Phase 1: Asaas Webhook Integration
- [ ] Phase 2: Payment Processing
- [ ] Phase 3: API Endpoints
- [ ] Phase 4: Blockchain Integration
- [ ] Phase 5: Production Hardening

### Website
- [ ] Planning & Design
- [ ] Landing Page
- [ ] Payment Dashboard
- [ ] Analytics Dashboard

## 🤝 Contributing

This is a monorepo. Each package has its own development workflow.

**Backend**: See [backend/README.md](./backend/README.md)

**Website**: See [website/README.md](./website/README.md)

## 📄 License

ISC

## 🔗 Links

- [Supabase Project](https://supabase.com)
- [Asaas Dashboard](https://www.asaas.com)
- [Backend Documentation](./backend/docs/)

## 💡 For Claude Code

See [CLAUDE.md](./CLAUDE.md) for project context and guidelines when working with this codebase.
