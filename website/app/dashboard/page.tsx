'use client'

import { useState } from 'react'

import { Sidebar } from '@/components/dashboard/sidebar'
import { Header } from '@/components/dashboard/header'
import { OverviewSection } from '@/components/dashboard/overview-section'
import { FirstStepsCard } from '@/components/dashboard/first-steps-card'
import { PlatformActivity } from '@/components/dashboard/platform-activity'
import { StablecoinKpis } from '@/components/dashboard/stablecoin-kpis'
import { StablecoinsPanel } from '@/components/dashboard/stablecoins-panel'
import { OperationsTable } from '@/components/dashboard/operations-table'
import { StatusBreakdown } from '@/components/dashboard/status-breakdown'
import { ClientAnalytics } from '@/components/dashboard/client-analytics'
import { useDashboardData } from '@/hooks/use-dashboard-data'

const tabDescriptions: Record<string, { title: string; description: string }> = {
  Overview: {
    title: 'All systems nominal',
    description: 'Monitor issuance, liquidity and developer activity in real time.',
  },
  Stablecoins: {
    title: 'Stablecoin programs',
    description: 'Configure assets, float limits and funding operations for BRL programs.',
  },
  Developer: {
    title: 'Developer workspace',
    description: 'Manage API keys, webhooks, SDKs and sandbox credentials.',
  },
  Settings: {
    title: 'Organization settings',
    description: 'Control access, security policies and production environments.',
  },
}

export default function Dashboard() {
  const [activeTab, setActiveTab] = useState<string>('Overview')
  const { title, description } = tabDescriptions[activeTab]
  const { data, loading, error } = useDashboardData()

  return (
    <div className="flex h-screen bg-[#0B0E14] text-white">
      <Sidebar activeTab={activeTab} onTabChange={setActiveTab} />
      <div className="flex-1 flex flex-col overflow-hidden">
        <Header section={activeTab} />
        <main className="flex-1 overflow-auto bg-[#0F131C]">
          <div className="p-8 space-y-6">
            {loading && (
              <div className="flex items-center justify-center py-12">
                <div className="text-white/60">Loading dashboard data...</div>
              </div>
            )}

            {error && (
              <div className="rounded-2xl border border-red-500/20 bg-red-500/10 p-6">
                <p className="text-red-400">Error loading dashboard: {error}</p>
              </div>
            )}

            {!loading && !error && data && (
              <>
                {activeTab === 'Overview' && (
                  <>
                    <OverviewSection data={data} />
                    <PlatformActivity data={data} />
                    <StatusBreakdown data={data} />
                    <OperationsTable data={data} />
                  </>
                )}

                {activeTab === 'Stablecoins' && (
                  <>
                    <StablecoinKpis data={data} />
                    <ClientAnalytics data={data} />
                    <StablecoinsPanel data={data} />
                  </>
                )}

                {activeTab !== 'Overview' && activeTab !== 'Stablecoins' && (
                  <SectionPlaceholder title={title} description={description} />
                )}
              </>
            )}
          </div>
        </main>
      </div>
    </div>
  )
}

function SectionPlaceholder({ title, description }: { title: string; description: string }) {
  return (
    <div className="rounded-2xl border border-dashed border-white/10 bg-[#111726] p-12">
      <p className="text-xs uppercase tracking-[0.4em] text-white/30">coming soon</p>
      <h2 className="mt-3 text-3xl font-semibold text-white">{title}</h2>
      <p className="mt-3 text-white/60 max-w-2xl">{description}</p>
      <div className="mt-8 flex flex-wrap gap-3">
        <button className="rounded-full border border-white/15 px-4 py-2 text-sm text-white/70 hover:text-white hover:border-white/40 transition">
          Request early access
        </button>
        <button className="text-sm text-white/50 hover:text-white">View documentation →</button>
      </div>
    </div>
  )
}
