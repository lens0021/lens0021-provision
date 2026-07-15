#!/usr/bin/env bash
# claude-usage-limit-gate.sh — PreToolUse hook that asks for confirmation
# once a usage limit (5-hour session OR weekly) is exhausted AND pay-as-you-go
# overage is enabled (i.e. continuing costs extra money).
#
# Only the work account has extra_usage enabled, so this stays silent on
# the personal account automatically — no email hardcoding needed.
#
# Behaviour:
#   * Reads OAuth usage from the same API the status line uses, with a
#     short local cache so per-tool overhead is negligible.
#   * When extra_usage.is_enabled is true and five_hour.utilization >= 100
#     OR seven_day.utilization >= 100, it emits a PreToolUse "ask" decision
#     so Claude Code pauses and lets the user approve/deny, showing which
#     window is over and when each resets.
#   * After surfacing the dialog it records a timestamp and stays quiet for
#     COOLDOWN seconds (~1h). After that it re-checks: if a window reset,
#     its utilization drops below 100; if any window is still over it asks
#     again.
#   * Fails open on any error (missing creds, API down, non-work account) so
#     it never blocks the workflow.
#
# Registered in ~/.claude/settings.json as a synchronous PreToolUse hook:
#   "command": "bash ~/git/port/leslie-kit/scripts/claude-usage-limit-gate.sh"

CRED="${USAGE_GATE_CRED:-$HOME/.claude/.credentials.json}"
CACHE="${USAGE_GATE_CACHE:-$HOME/.claude/usage-gate-cache.json}"
ACK="${USAGE_GATE_ACK:-$HOME/.claude/usage-gate-ack.json}"
API_URL="https://api.anthropic.com/api/oauth/usage"
CACHE_TTL=90       # seconds a cached usage response is reused
COOLDOWN=3600      # seconds to stay quiet after surfacing the dialog

# Drain the hook payload from stdin (unused) so nothing blocks.
cat >/dev/null 2>&1 || true

# allow: exit without a decision, letting the tool run normally.
allow() { exit 0; }

# human_reset ISO_TIMESTAMP -> "MM-DD HH:MM (약 N시간 Nm 후)"; uses global $now.
human_reset() {
    local iso="$1" epoch at diff rel
    [ -n "$iso" ] || { echo "알 수 없음"; return; }
    epoch=$(date -d "$iso" +%s 2>/dev/null || echo 0)
    case "$epoch" in ''|*[!0-9]*) epoch=0 ;; esac
    [ "$epoch" -gt 0 ] || { echo "알 수 없음"; return; }
    at=$(date -d "$iso" +"%m-%d %H:%M" 2>/dev/null || echo "")
    diff=$((epoch - now))
    if [ "$diff" -lt 0 ]; then
        rel="곧 리셋"
    elif [ "$diff" -lt 3600 ]; then
        rel="약 $((diff / 60))분 후"
    elif [ "$diff" -lt 86400 ]; then
        rel="약 $((diff / 3600))시간 $(((diff % 3600) / 60))분 후"
    else
        rel="약 $((diff / 86400))일 $(((diff % 86400) / 3600))시간 후"
    fi
    echo "$at ($rel)"
}

command -v jq >/dev/null 2>&1 || allow
command -v curl >/dev/null 2>&1 || allow
[ -f "$CRED" ] || allow

now=$(date +%s 2>/dev/null || echo 0)
[ "$now" -gt 0 ] 2>/dev/null || allow

# --- Fetch usage (cache first, API on miss) ---------------------------------
usage=""
if [ -f "$CACHE" ]; then
    ts=$(jq -r '.timestamp // 0' "$CACHE" 2>/dev/null || echo 0)
    case "$ts" in ''|*[!0-9]*) ts=0 ;; esac
    if [ $((now - ts)) -lt "$CACHE_TTL" ]; then
        usage=$(jq -c '.response' "$CACHE" 2>/dev/null || echo "")
        [ "$usage" = "null" ] && usage=""
    fi
fi

if [ -z "$usage" ]; then
    token=$(jq -r '.claudeAiOauth.accessToken // empty' "$CRED" 2>/dev/null || echo "")
    [ -n "$token" ] || allow
    usage=$(curl -s --max-time 3 \
        -H "Authorization: Bearer $token" \
        -H "anthropic-beta: oauth-2025-04-20" \
        "$API_URL" 2>/dev/null || echo "")
    [ -n "$usage" ] || allow
    echo "$usage" | jq -e . >/dev/null 2>&1 || allow
    jq -n --argjson r "$usage" --arg t "$now" \
        '{timestamp: ($t|tonumber), response: $r}' > "$CACHE" 2>/dev/null || true
fi

# --- Gate conditions --------------------------------------------------------
# Only the work account (overage enabled) should ever prompt.
enabled=$(echo "$usage" | jq -r '.extra_usage.is_enabled // false' 2>/dev/null || echo false)
[ "$enabled" = "true" ] || allow

util_5h=$(echo "$usage" | jq -r '.five_hour.utilization // 0' 2>/dev/null || echo 0)
util_7d=$(echo "$usage" | jq -r '.seven_day.utilization // 0' 2>/dev/null || echo 0)
over_5h=$(awk -v u="$util_5h" 'BEGIN { print (u + 0 >= 100) ? "yes" : "no" }' 2>/dev/null || echo no)
over_7d=$(awk -v u="$util_7d" 'BEGIN { print (u + 0 >= 100) ? "yes" : "no" }' 2>/dev/null || echo no)
[ "$over_5h" = "yes" ] || [ "$over_7d" = "yes" ] || allow

# Within cooldown after a recent dialog: stay quiet.
if [ -f "$ACK" ]; then
    acked=$(jq -r '.acked_at // 0' "$ACK" 2>/dev/null || echo 0)
    case "$acked" in ''|*[!0-9]*) acked=0 ;; esac
    if [ $((now - acked)) -lt "$COOLDOWN" ]; then
        allow
    fi
fi

# --- Ask ---------------------------------------------------------------------
resets_5h=$(echo "$usage" | jq -r '.five_hour.resets_at // empty' 2>/dev/null || echo "")
resets_7d=$(echo "$usage" | jq -r '.seven_day.resets_at // empty' 2>/dev/null || echo "")

# Record that we surfaced the dialog so we don't nag every tool call.
jq -n --arg t "$now" --arg r5 "$resets_5h" --arg r7 "$resets_7d" \
    '{acked_at: ($t|tonumber), resets_5h: $r5, resets_7d: $r7}' > "$ACK" 2>/dev/null || true

parts=""
if [ "$over_5h" = "yes" ]; then
    p5=$(awk -v u="$util_5h" 'BEGIN { printf "%d", u + 0 }' 2>/dev/null || echo 100)
    parts="5시간 한도 ${p5}% (리셋: $(human_reset "$resets_5h"))"
fi
if [ "$over_7d" = "yes" ]; then
    p7=$(awk -v u="$util_7d" 'BEGIN { printf "%d", u + 0 }' 2>/dev/null || echo 100)
    seg="주간(7일) 한도 ${p7}% (리셋: $(human_reset "$resets_7d"))"
    if [ -n "$parts" ]; then parts="$parts, $seg"; else parts="$seg"; fi
fi

reason="⚠️ 회사 계정 ${parts} 초과 — 지금부터 추가 과금이 발생합니다. 계속하려면 승인, 중단하려면 거부하세요."

jq -n --arg r "$reason" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $r}}'
exit 0
