�# 💹 AlgoTrade & Pine Script Grimoire

> **Owner:** AlgoTrade Specialist
> **Purpose:** Trading strategies, risk management, and Pine Script syntax.

## 📜 Pine Script V5 Patterns

### 1. Repaint Protection (Golden Rule)
*   **Issue:** Strategy looks perfect on history but fails live.
*   **Cause:** Determining entry based on the *current* (moving) candle.
*   **Fix:** `barstate.isconfirmed`. Only calculate on the closed candle.
    ```pine
    if barstate.isconfirmed and crossover(rsi, 30)
        strategy.entry("Long", strategy.long)
    ```

### 2. Multi-Timeframe Analysis (MTF)
*   **Technique:** `request.security()`.
*   **Risk:** Looking into the future.
*   **Fix:** `lookahead=barmerge.lookahead_on` ONLY on historical offset.

## 🧠 Trading Strategies (Proven)

### 1. RSI Divergence
*   **Bullish:** Price makes Lower Low, RSI makes Higher Low. -> Reversal imminent.
*   **Bearish:** Price makes Higher High, RSI makes Lower High. -> Crash imminent.

### 2. Liquidity Sweeps (SMC)
*   **Concept:** Price wick goes barely below a previous low to trigger Stop Losses, then rockets up.
*   **Entry:** Enter on the reclaim of the level.

## ⚖️ Risk Management (The math of survival)
*   **The 1% Rule:** Never risk more than 1% of account equity on a single trade.
*   **Position Sizing Formula:** `Size = (Equity * 0.01) / (Dist_to_StopLoss)`
*   **R:R (Risk:Reward):** Minimum 1:2. If Stop Loss is $10 away, Take Profit must be $20+ away.
�*cascade082?file:///C:/Users/Abdullah/.gemini/knowledge/trading_patterns.md