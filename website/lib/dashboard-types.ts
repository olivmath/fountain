export type StablecoinStatus = 'registered' | 'deployed' | 'pending_review' | 'maintenance' | string

export type StablecoinRecord = {
  stablecoin_id: string
  client_id: string
  client_name: string
  client_wallet: string
  webhook_url: string
  symbol: string
  erc20_address: string | null
  status: StablecoinStatus
  created_at: string
  deployed_at: string | null
  updated_at: string
  [key: string]: unknown
}

export type OperationRecord = {
  operation_id: string
  stablecoin_id: string
  operation_type: 'deposit' | 'withdraw'
  amount: number | string
  status: string
  created_at: string
  updated_at: string
  tx_hash?: string | null
  burn_tx_hash?: string | null
  payment_confirmed_at?: string | null
  minted_at?: string | null
  burned_at?: string | null
  pix_transferred_at?: string | null
  notified_at?: string | null
  [key: string]: unknown
}

export type StablecoinStats = {
  stablecoin_id: string
  symbol: string
  erc20_address: string | null
  status: StablecoinStatus
  created_at: string
  deployed_at: string | null
  stats: {
    deposits: {
      total_count: number
      successful_count: number
      total_amount: number
    }
    withdrawals: {
      total_count: number
      successful_count: number
      total_amount: number
    }
    volume: {
      total_deposits: number
      total_withdrawals: number
      net_volume: number
    }
    status_breakdown: Record<string, number>
    latest_operation: null | {
      operation_id: string
      type: string
      amount: number
      status: string
      created_at: string
    }
  }
}

export type DashboardApiResponse = {
  stablecoins: StablecoinRecord[]
  operations: OperationRecord[]
  statsByStablecoin: Record<string, StablecoinStats>
  fetchedAt: string
}

