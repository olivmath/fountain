import { NextResponse } from 'next/server'

import type { OperationRecord, StablecoinRecord, StablecoinStats } from '@/lib/dashboard-types'

const API_BASE = process.env.RAYLS_FUNCTIONS_BASE_URL || 'https://bzxdqkttnkxqaecaiekt.supabase.co/functions/v1'
const API_KEY = process.env.RAYLS_FUNCTIONS_API_KEY || 'sk_93d392d426debe7edaebb78d534e60b33e935ebd99d653b5'
const MAX_STABLECOINS = 100
const MAX_OPERATIONS = 200

type PaginatedResponse<T> = {
  data?: T[]
  pagination?: {
    limit: number
    offset: number
    total: number
    has_more: boolean
  }
  [key: string]: unknown
}

async function fetchFromBackend<T>(path: string, searchParams?: Record<string, string | number | undefined>) {
  if (!API_BASE || !API_KEY) {
    throw new Error('Missing RAYLS_FUNCTIONS_BASE_URL or RAYLS_FUNCTIONS_API_KEY environment variables')
  }

  const url = new URL(`${API_BASE.replace(/\/$/, '')}/${path}`)

  if (searchParams) {
    Object.entries(searchParams).forEach(([key, value]) => {
      if (value !== undefined && value !== null && value !== '') {
        url.searchParams.set(key, String(value))
      }
    })
  }

  const response = await fetch(url.toString(), {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': API_KEY,
    },
    cache: 'no-store',
  })

  if (!response.ok) {
    const body = await response.text().catch(() => '')
    throw new Error(`Backend request to ${path} failed: ${response.status} ${response.statusText} ${body}`)
  }

  return (await response.json()) as T
}

export const dynamic = 'force-dynamic'

export async function GET() {
  try {
    const [stablecoinPayload, operationPayload] = await Promise.all([
      fetchFromBackend<PaginatedResponse<StablecoinRecord>>('list-client-stablecoins', { limit: MAX_STABLECOINS }),
      fetchFromBackend<PaginatedResponse<OperationRecord>>('list-client-operations', { limit: MAX_OPERATIONS }),
    ])

    const stablecoins = stablecoinPayload.data ?? []
    const operations = operationPayload.data ?? []

    const statsEntries = await Promise.all(
      stablecoins.map(async (coin) => {
        try {
          const stats = await fetchFromBackend<StablecoinStats>('get-stablecoin-stats', {
            stablecoin_id: coin.stablecoin_id,
          })
          return [coin.stablecoin_id, stats] as const
        } catch (error) {
          console.error(`Failed to get stats for ${coin.stablecoin_id}`, error)
          return null
        }
      }),
    )

    const statsByStablecoin = Object.fromEntries(
      statsEntries.filter((entry): entry is readonly [string, StablecoinStats] => entry !== null),
    )

    return NextResponse.json({
      stablecoins,
      operations,
      statsByStablecoin,
      fetchedAt: new Date().toISOString(),
    })
  } catch (error) {
    console.error('Dashboard API error', error)

    return NextResponse.json(
      {
        error: 'Failed to load dashboard data',
        details: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 500 },
    )
  }
}

