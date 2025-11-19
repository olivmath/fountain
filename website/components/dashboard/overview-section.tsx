'use client'

import type { DashboardApiResponse } from '@/lib/dashboard-types'

type OverviewSectionProps = {
  data: DashboardApiResponse
}

export function OverviewSection({ data }: OverviewSectionProps) {
  const lastUpdated = data.fetchedAt ? new Date(data.fetchedAt).toLocaleTimeString() : 'N/A'
  
  return (
    <div className="mb-8">
      <p className="text-xs uppercase tracking-[0.3em] text-white/40">dashboard</p>
      <div className="mt-2 flex flex-wrap items-baseline justify-between gap-4">
        <h2 className="text-3xl font-semibold text-white">Operational overview</h2>
        <p className="text-sm text-white/50">Live data · Updated at {lastUpdated}</p>
      </div>
    </div>
  )
}

