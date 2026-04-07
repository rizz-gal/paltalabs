# Paltalabs API Documentation

## 📚 Overview

The Paltalabs API provides comprehensive access to DeFi functionalities on the Stellar blockchain, including yield farming, staking, liquidity management, and governance features.

## 🔗 Base URL

```
Production: https://api.paltalabs.io
Staging: https://staging-api.paltalabs.io
Development: http://localhost:3000
```

## 🔐 Authentication

### API Key Authentication
```http
Authorization: Bearer YOUR_API_KEY
```

### JWT Authentication (for authenticated endpoints)
```http
Authorization: JWT YOUR_JWT_TOKEN
```

## 📊 Response Format

All API responses follow this standard format:

```json
{
  "success": true,
  "data": {},
  "message": "Operation successful",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "requestId": "req_123456789"
}
```

### Error Response Format
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input parameters",
    "details": {}
  },
  "timestamp": "2024-01-01T00:00:00.000Z",
  "requestId": "req_123456789"
}
```

## 🚀 Rate Limiting

- **Standard**: 100 requests per minute
- **Premium**: 1000 requests per minute
- **Enterprise**: Unlimited

Rate limit headers are included in responses:
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 99
X-RateLimit-Reset: 1640995200
```

## 📋 Endpoints

### Health Check

#### GET /health
Check API health status.

**Response:**
```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "version": "1.0.0",
    "uptime": 3600,
    "timestamp": "2024-01-01T00:00:00.000Z"
  }
}
```

---

## 💰 Yield Farming Endpoints

### GET /api/yield/pools
Get all available yield farming pools.

**Query Parameters:**
- `active` (optional): Filter by active status (default: true)
- `minApy` (optional): Minimum APY filter
- `maxRisk` (optional): Maximum risk score filter

**Response:**
```json
{
  "success": true,
  "data": {
    "pools": [
      {
        "poolId": "pool_123",
        "name": "Stellar Yield Pool",
        "token": "XLM",
        "apy": 12.5,
        "tvl": 50000000,
        "riskScore": 3,
        "isActive": true,
        "lastUpdated": "2024-01-01T00:00:00.000Z"
      }
    ]
  }
}
```

### POST /api/yield/stake
Stake tokens in a yield pool.

**Request Body:**
```json
{
  "poolId": "pool_123",
  "amount": 1000,
  "userAddress": "GD..."
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "stakeId": "stake_456",
    "poolId": "pool_123",
    "amount": 1000,
    "userAddress": "GD...",
    "timestamp": "2024-01-01T00:00:00.000Z"
  }
}
```

### POST /api/yield/unstake
Unstake tokens from a yield pool.

**Request Body:**
```json
{
  "stakeId": "stake_456",
  "amount": 500
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "unstakeId": "unstake_789",
    "amount": 500,
    "rewards": 25.5,
    "timestamp": "2024-01-01T00:00:00.000Z"
  }
}
```

---

## 🎯 Staking Endpoints

### GET /api/staking/info
Get staking information.

**Response:**
```json
{
  "success": true,
  "data": {
    "totalStaked": 100000000,
    "totalRewards": 5000000,
    "rewardRate": 5.0,
    "activeStakers": 1500
  }
}
```

### POST /api/staking/stake
Stake tokens for rewards.

**Request Body:**
```json
{
  "amount": 1000,
  "duration": 30,
  "userAddress": "GD..."
}
```

### POST /api/staking/claim
Claim staking rewards.

**Request Body:**
```json
{
  "stakeId": "stake_123",
  "userAddress": "GD..."
}
```

---

## 💧 Liquidity Pool Endpoints

### GET /api/liquidity/pools
Get all liquidity pools.

**Response:**
```json
{
  "success": true,
  "data": {
    "pools": [
      {
        "poolId": "pool_abc",
        "tokenA": "XLM",
        "tokenB": "USDC",
        "reserveA": 1000000,
        "reserveB": 500000,
        "totalLiquidity": 1500000,
        "fee": 0.003
      }
    ]
  }
}
```

### POST /api/liquidity/add
Add liquidity to a pool.

**Request Body:**
```json
{
  "poolId": "pool_abc",
  "amountA": 1000,
  "amountB": 500,
  "userAddress": "GD..."
}
```

### POST /api/liquidity/remove
Remove liquidity from a pool.

**Request Body:**
```json
{
  "poolId": "pool_abc",
  "liquidityTokens": 100,
  "userAddress": "GD..."
}
```

---

## 🏛️ Governance Endpoints

### GET /api/governance/proposals
Get governance proposals.

**Response:**
```json
{
  "success": true,
  "data": {
    "proposals": [
      {
        "proposalId": "prop_123",
        "title": "Increase Reward Rate",
        "description": "Proposal to increase staking reward rate",
        "status": "active",
        "votesFor": 150,
        "votesAgainst": 25,
        "deadline": "2024-01-15T00:00:00.000Z",
        "createdBy": "GD..."
      }
    ]
  }
}
```

### POST /api/governance/proposal
Create a new governance proposal.

**Request Body:**
```json
{
  "title": "New Feature Proposal",
  "description": "Description of the proposal",
  "type": "parameter_change",
  "proposerAddress": "GD..."
}
```

### POST /api/governance/vote
Vote on a proposal.

**Request Body:**
```json
{
  "proposalId": "prop_123",
  "vote": "for",
  "voterAddress": "GD..."
}
```

---

## 🧪 SDK Examples

### JavaScript/TypeScript

```typescript
import { PaltalabsAPI } from '@paltalabs/sdk';

const api = new PaltalabsAPI({
  baseURL: 'https://api.paltalabs.io',
  apiKey: 'YOUR_API_KEY'
});

// Get yield pools
const pools = await api.yield.getPools();
console.log(pools.data.pools);

// Stake in yield pool
const stake = await api.yield.stake({
  poolId: 'pool_123',
  amount: 1000,
  userAddress: 'GD...'
});
console.log(stake.data);
```

### Python

```python
from paltalabs_sdk import PaltalabsAPI

api = PaltalabsAPI(
    base_url='https://api.paltalabs.io',
    api_key='YOUR_API_KEY'
)

# Get yield pools
pools = api.yield.get_pools()
print(pools['data']['pools'])

# Stake in yield pool
stake = api.yield.stake({
    'pool_id': 'pool_123',
    'amount': 1000,
    'user_address': 'GD...'
})
print(stake['data'])
```

### cURL

```bash
# Get yield pools
curl -X GET "https://api.paltalabs.io/api/yield/pools" \
  -H "Authorization: Bearer YOUR_API_KEY"

# Stake in yield pool
curl -X POST "https://api.paltalabs.io/api/yield/stake" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "poolId": "pool_123",
    "amount": 1000,
    "userAddress": "GD..."
  }'
```

---

## 🔄 Webhooks

### Setup Webhooks

Configure webhooks to receive real-time updates:

```json
{
  "webhookUrl": "https://your-app.com/webhook",
  "events": [
    "yield.staked",
    "yield.unstaked",
    "staking.rewards_claimed",
    "liquidity.added",
    "liquidity.removed"
  ],
  "secret": "YOUR_WEBHOOK_SECRET"
}
```

### Webhook Events

#### yield.staked
```json
{
  "event": "yield.staked",
  "data": {
    "stakeId": "stake_456",
    "poolId": "pool_123",
    "amount": 1000,
    "userAddress": "GD...",
    "timestamp": "2024-01-01T00:00:00.000Z"
  }
}
```

---

## 🚨 Error Codes

| Code | Description |
|------|-------------|
| 400 | Bad Request - Invalid input parameters |
| 401 | Unauthorized - Invalid authentication |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource not found |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error - Server error |
| 503 | Service Unavailable - Maintenance |

---

## 📞 Support

- **Documentation**: https://docs.paltalabs.io
- **API Status**: https://status.paltalabs.io
- **Support**: api-support@paltalabs.io
- **Discord**: https://discord.gg/paltalabs

---

This API documentation provides comprehensive information for integrating with the Paltalabs platform. For more detailed examples and advanced usage, please refer to our SDK documentation.
