import type { OperationRecord, StablecoinRecord, StablecoinStats } from './dashboard-types'

const PENDING_KEYWORDS = ['pending', 'processing', 'initiated', 'in_progress', 'hold', 'review']
const SUCCESS_STATUSES = ['minted', 'withdraw_successful', 'withdraw_completed', 'client_notified']
const FAILURE_KEYWORDS = ['failed', 'error', 'cancelled', 'rejected']

const RELATIVE_TIME_FORMATTER = new Intl.RelativeTimeFormat('pt-BR', { numeric: 'auto' })
const DATE_LABEL_FORMATTER = new Intl.DateTimeFormat('pt-BR', { month: 'short', day: '2-digit' })
const CURRENCY_FORMATTERS: Record<number, Intl.NumberFormat> = {
  0: new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL', maximumFractionDigits: 0 }),
  2: new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL', maximumFractionDigits: 2 }),
}
const NUMBER_FORMATTER = new Intl.NumberFormat('pt-BR')
const PERCENT_FORMATTER = new Intl.NumberFormat('pt-BR', { style: 'percent', maximumFractionDigits: 1 })

export function toNumber(value: number | string | null | undefined): number {
  if (typeof value === 'number') return value
  if (typeof value === 'string') {
    const parsed = Number(value)
    return Number.isFinite(parsed) ? parsed : 0
  }
  return 0
}

export function formatCurrencyBRL(value: number, fractionDigits: 0 | 2 = 0) {
  const formatter = CURRENCY_FORMATTERS[fractionDigits] ?? CURRENCY_FORMATTERS[0]
  return formatter.format(value || 0)
}

export function formatNumber(value: number) {
  return NUMBER_FORMATTER.format(value || 0)
}

export function formatPercent(value: number) {
  return PERCENT_FORMATTER.format(value || 0)
}

export function formatRelativeTime(input?: string | null) {
  if (!input) return 'Sem atividades recentes'

  const target = new Date(input)
  if (Number.isNaN(target.getTime())) return 'Data indisponível'

  const diffMs = target.getTime() - Date.now()
  const diffMinutes = Math.round(diffMs / (60 * 1000))
  const diffHours = Math.round(diffMinutes / 60)
  const diffDays = Math.round(diffHours / 24)

  if (Math.abs(diffMinutes) < 60) {
    return RELATIVE_TIME_FORMATTER.format(diffMinutes, 'minute')
  }
  if (Math.abs(diffHours) < 24) {
    return RELATIVE_TIME_FORMATTER.format(diffHours, 'hour')
  }
  return RELATIVE_TIME_FORMATTER.format(diffDays, 'day')
}

export function isSuccessStatus(status: string) {
  const normalized = status?.toLowerCase()
  return SUCCESS_STATUSES.some((value) => normalized?.includes(value))
}

export function isPendingStatus(status: string) {
  const normalized = status?.toLowerCase()
  return (
    PENDING_KEYWORDS.some((value) => normalized?.includes(value)) &&
    !isSuccessStatus(status) &&
    !FAILURE_KEYWORDS.some((value) => normalized?.includes(value))
  )
}

export function buildOperationsMetrics(operations: OperationRecord[]) {
  const deposits = operations.filter((op) => op.operation_type === 'deposit')
  const withdrawals = operations.filter((op) => op.operation_type === 'withdraw')

  const depositVolume = deposits.reduce((acc, op) => acc + toNumber(op.amount), 0)
  const withdrawVolume = withdrawals.reduce((acc, op) => acc + toNumber(op.amount), 0)
  const pendingCount = operations.filter((op) => isPendingStatus(op.status)).length
  const successfulCount = operations.filter((op) => isSuccessStatus(op.status)).length

  return {
    depositVolume,
    withdrawVolume,
    netVolume: depositVolume - withdrawVolume,
    pendingCount,
    total: operations.length,
    successRate: operations.length ? successfulCount / operations.length : 0,
  }
}

export function buildTimelinePoints(operations: OperationRecord[], days = 10) {
  const timeline = new Map<
    string,
    {
      deposits: number
      withdrawals: number
    }
  >()

  operations.forEach((op) => {
    const dateKey = new Date(op.created_at).toISOString().slice(0, 10)
    const bucket = timeline.get(dateKey) ?? { deposits: 0, withdrawals: 0 }

    if (op.operation_type === 'deposit') {
      bucket.deposits += toNumber(op.amount)
    } else {
      bucket.withdrawals += toNumber(op.amount)
    }

    timeline.set(dateKey, bucket)
  })

  const today = new Date()
  const points: { label: string; deposits: number; withdrawals: number; net: number }[] = []

  for (let i = days - 1; i >= 0; i -= 1) {
    const date = new Date(today)
    date.setDate(today.getDate() - i)
    const key = date.toISOString().slice(0, 10)
    const bucket = timeline.get(key) ?? { deposits: 0, withdrawals: 0 }

    points.push({
      label: DATE_LABEL_FORMATTER.format(date),
      deposits: bucket.deposits,
      withdrawals: bucket.withdrawals,
      net: bucket.deposits - bucket.withdrawals,
    })
  }

  return points
}

export function buildStablecoinSummary(
  stablecoin: StablecoinRecord,
  stats?: StablecoinStats,
  operations: OperationRecord[] = [],
) {
  const opsForCoin = operations.filter((op) => op.stablecoin_id === stablecoin.stablecoin_id)
  const pendingRequests = opsForCoin.filter((op) => isPendingStatus(op.status)).length
  const mintedLast24h = opsForCoin
    .filter((op) => {
      if (op.operation_type !== 'deposit') return false
      const created = new Date(op.created_at)
      const diffHours = (Date.now() - created.getTime()) / (1000 * 60 * 60)
      return diffHours <= 24
    })
    .reduce((acc, op) => acc + toNumber(op.amount), 0)

  const lastActivity =
    stats?.stats.latest_operation?.created_at ?? opsForCoin[0]?.created_at ?? stablecoin.updated_at ?? stablecoin.created_at

  const circulatingSupply = stats?.stats.volume.net_volume ?? 0

  return {
    pendingRequests,
    mintedLast24h,
    lastActivity,
    circulatingSupply,
  }
}

