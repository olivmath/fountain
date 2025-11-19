'use client'

import { useMemo } from 'react'
import type { DashboardApiResponse } from '@/lib/dashboard-types'

const currency = new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL', maximumFractionDigits: 0 })

type StablecoinKpisProps = {
  data: DashboardApiResponse
}

export function StablecoinKpis({ data }: StablecoinKpisProps) {
  const cards = useMemo(() => {
    const active = data.stablecoins.filter((coin) => coin.status === 'deployed').length
    const pending = data.stablecoins.filter((coin) => coin.status === 'registered').length
    
    // Calculate total supply from stats
    const totalSupply = Object.values(data.statsByStablecoin).reduce((acc, stats) => {
      return acc + (stats.stats.volume.net_volume || 0)
    }, 0)

    return [
      {
        label: 'Active stablecoins',
        value: active,
        hint: 'Deployed and operational',
      },
      {
        label: 'Pending stablecoins',
        value: pending,
        hint: 'Awaiting deployment',
      },
      {
        label: 'Total net volume',
        value: currency.format(totalSupply),
        hint: 'Net deposits - withdrawals',
      },
    ]
  }, [data])

  return (
    <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
      {cards.map((card) => (
        <div key={card.label} className="rounded-xl border border-white/5 bg-[#111726] p-5">
          <p className="text-xs uppercase tracking-[0.35em] text-white/40">{card.label}</p>
          <p className="mt-3 text-3xl font-semibold text-white">{card.value}</p>
          <p className="mt-2 text-sm text-white/50">{card.hint}</p>
        </div>
      ))}
    </div>
  )
}

