# 🚀 Quick Start Guide - Fountain Dashboard

## Prerequisites

- Node.js 18+ installed
- npm or yarn installed
- Backend API running (Supabase Functions)

---

## 1️⃣ Installation

```bash
cd website
npm install
```

---

## 2️⃣ Configuration (Optional)

The dashboard works out-of-the-box with hardcoded credentials, but you can override them:

Create `.env.local` in the `website/` folder:

```bash
RAYLS_FUNCTIONS_BASE_URL=https://bzxdqkttnkxqaecaiekt.supabase.co/functions/v1
RAYLS_FUNCTIONS_API_KEY=sk_93d392d426debe7edaebb78d534e60b33e935ebd99d653b5
```

---

## 3️⃣ Run Development Server

```bash
npm run dev
```

Dashboard will be available at: **http://localhost:3000/dashboard**

---

## 4️⃣ Navigate the Dashboard

### **Overview Tab**
Shows real-time platform metrics:
- Total volume across all stablecoins
- Deposits and withdrawals
- Operations chart over time
- Status breakdown pie chart
- Full operations table with filters

### **Stablecoins Tab**
Shows stablecoin management:
- KPI cards (active, pending, volume)
- Client performance analytics
- Stablecoins list with details
- Recent operations per stablecoin

---

## 5️⃣ Test with Real Data

The dashboard automatically fetches data from:
- `list-client-stablecoins` endpoint
- `list-client-operations` endpoint  
- `get-stablecoin-stats` endpoint

Data refreshes every **60 seconds** automatically.

---

## 6️⃣ Verify Integration

Open the browser console and check:

```javascript
// Should see API calls like:
GET /api/dashboard
  ↓ Returns:
  {
    stablecoins: [...],
    operations: [...],
    statsByStablecoin: {...},
    fetchedAt: "2025-11-19T..."
  }
```

---

## 🎯 Expected Behavior

### Loading State
When you first open the dashboard, you'll see:
```
Loading dashboard data...
```

### Success State
After ~1-2 seconds, you'll see:
- ✅ Metrics populated with real numbers
- ✅ Charts showing actual data
- ✅ Tables with your operations
- ✅ "Last updated at HH:MM:SS"

### Error State
If the API fails, you'll see:
```
Error loading dashboard: [error message]
```

---

## 🔍 Troubleshooting

### Dashboard shows "Loading..." forever

**Cause**: Backend API not responding

**Fix**:
```bash
# Check if Supabase Functions are running
curl https://bzxdqkttnkxqaecaiekt.supabase.co/functions/v1/list-client-stablecoins \
  -H "x-api-key: sk_93d392d426debe7edaebb78d534e60b33e935ebd99d653b5"
```

### Dashboard shows "Error loading dashboard"

**Cause**: Invalid API key or network issue

**Fix**:
1. Check API key is correct
2. Verify backend is accessible
3. Check browser console for detailed error

### Dashboard shows empty data

**Cause**: No stablecoins or operations in database

**Expected**: This is normal for new setups. Create a stablecoin first:

```bash
curl -X POST https://bzxdqkttnkxqaecaiekt.supabase.co/functions/v1/stablecoin-create \
  -H "x-api-key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "client_name": "Test Client",
    "symbol": "TESTBRL",
    "client_wallet": "0x1234567890123456789012345678901234567890",
    "webhook": "https://webhook.example.com",
    "total_supply": 1000000
  }'
```

---

## 📊 Features Checklist

After setup, verify these features work:

### Overview Tab
- [ ] Platform metrics show numbers (not "Loading...")
- [ ] Transactions chart displays line graph
- [ ] Status breakdown shows pie chart
- [ ] Operations table has rows (if data exists)
- [ ] Filters work (All/Deposits/Withdrawals)

### Stablecoins Tab
- [ ] KPI cards show numbers
- [ ] Client analytics displays cards
- [ ] Stablecoins list shows your coins
- [ ] Clicking a stablecoin shows details
- [ ] Recent operations appear in right panel

### General
- [ ] Dashboard auto-refreshes every 60s
- [ ] No console errors
- [ ] No linting errors
- [ ] Responsive on mobile

---

## 🎨 Customization

### Change Refresh Interval

Edit `website/hooks/use-dashboard-data.ts`:

```typescript
const REFRESH_INTERVAL_MS = 60_000  // Change this (milliseconds)
```

### Change Max Records

Edit `website/app/api/dashboard/route.ts`:

```typescript
const MAX_STABLECOINS = 100  // Change this
const MAX_OPERATIONS = 200   // Change this
```

### Add New Tab

1. Edit `website/app/dashboard/page.tsx`
2. Add tab to `tabDescriptions`
3. Add tab button in Sidebar component
4. Add tab content in main render

---

## 📦 Build for Production

```bash
npm run build
npm start
```

Or deploy to Vercel:

```bash
npx vercel
```

---

## 🔗 API Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/list-client-stablecoins` | GET | Get all stablecoins |
| `/list-client-operations` | GET | Get all operations |
| `/get-stablecoin-stats` | GET | Get stats per coin |

All use:
- **Base URL**: `https://bzxdqkttnkxqaecaiekt.supabase.co/functions/v1`
- **Header**: `x-api-key: sk_93d392d426debe7edaebb78d534e60b33e935ebd99d653b5`

---

## 📝 Development Tips

### Hot Reload
Changes to components auto-reload in dev mode. No restart needed!

### TypeScript Errors
Run type check:
```bash
npm run build
```

### Linting
Check code quality:
```bash
npm run lint
```

---

## 🎯 Next Steps

1. ✅ Dashboard is running with real data
2. Create some test operations (deposits/withdrawals)
3. Watch metrics update in real-time
4. Explore different tabs and features
5. Customize styling to match your brand
6. Deploy to production!

---

## 📚 Documentation

- **Full Implementation**: See `DASHBOARD_IMPLEMENTATION.md`
- **Architecture**: See `ARCHITECTURE.md`
- **Summary**: See `DASHBOARD_SUMMARY.md`
- **Backend Docs**: See `back-end/CLAUDE.md`

---

## 💡 Need Help?

Common questions:

**Q: Can I use a different API key?**  
A: Yes, set `RAYLS_FUNCTIONS_API_KEY` in `.env.local`

**Q: How do I add more charts?**  
A: Create a new component in `components/dashboard/` and add to page

**Q: Can I filter by date range?**  
A: Not yet, but you can add query params to the API calls

**Q: How do I export data?**  
A: Add CSV export functionality to OperationsTable component

---

## ✅ Success!

If you see the dashboard with live data, you're all set! 🎉

**Your Fountain dashboard is production-ready!** 🚀

