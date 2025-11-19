import { useCallback, useEffect, useMemo, useState } from 'react'

import type { DashboardApiResponse } from '@/lib/dashboard-types'

type DashboardState = {
  data: DashboardApiResponse | null
  loading: boolean
  error: string | null
  refresh: () => Promise<void>
  lastUpdated: string | null
}

const REFRESH_INTERVAL_MS = 60_000

export function useDashboardData(): DashboardState {
  const [data, setData] = useState<DashboardApiResponse | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchData = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)

      const response = await fetch('/api/dashboard', { cache: 'no-store' })

      if (!response.ok) {
        throw new Error(`Request failed with status ${response.status}`)
      }

      const payload = (await response.json()) as DashboardApiResponse
      setData(payload)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchData()
  }, [fetchData])

  useEffect(() => {
    const timer = setInterval(() => {
      fetchData().catch(() => {
        /* errors handled inside fetchData */
      })
    }, REFRESH_INTERVAL_MS)

    return () => clearInterval(timer)
  }, [fetchData])

  const lastUpdated = useMemo(() => data?.fetchedAt ?? null, [data])

  return {
    data,
    loading,
    error,
    refresh: fetchData,
    lastUpdated,
  }
}

