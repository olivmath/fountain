'use client'

import { Info, TrendingDown, TrendingUp } from 'lucide-react'

type MetricCardProps = {
  label: string
  value: string
  change?: string | null
  changeType?: 'up' | 'down'
  hint?: string
}

export function MetricCard({ label, value, change, changeType = 'up', hint }: MetricCardProps) {
  const showChange = change !== undefined && change !== null

  return (
    <div className="rounded-xl border border-white/5 bg-[#111726] p-6">
      <div className="mb-4 flex items-center justify-between">
        <h4 className="text-sm text-white/70">{label}</h4>
        <Info className="h-4 w-4 text-white/30" />
      </div>
      <p className="mb-3 text-2xl font-semibold text-white">{value}</p>

      {showChange ? (
        <div className="flex items-center gap-2">
          {changeType === 'up' ? (
            <TrendingUp className="h-4 w-4 text-emerald-400" />
          ) : (
            <TrendingDown className="h-4 w-4 text-rose-400" />
          )}
          <span className={`text-sm font-medium ${changeType === 'up' ? 'text-emerald-400' : 'text-rose-400'}`}>
            {change}
          </span>
          <span className="text-sm text-white/40">{hint ?? 'vs. período anterior'}</span>
        </div>
      ) : (
        hint && <p className="text-sm text-white/40">{hint}</p>
      )}
    </div>
  )
}

