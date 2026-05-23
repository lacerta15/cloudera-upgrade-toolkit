#!/bin/bash
# Post-upgrade verification
CM_HOST="${CM_HOST:-localhost}"
CM_USER="${CM_USER:-admin}"
CM_PASS="${CM_PASS:-admin}"
API="http://${CM_HOST}:7180/api/v51"

cm_get() { curl -s -u "${CM_USER}:${CM_PASS}" "${API}$1"; }

echo "=== Post-Upgrade Verification ==="

# 1. All services STARTED
echo ""
echo "--- Service States ---"
CLUSTERS=$(cm_get "/clusters" | python3 -c "import sys,json; [print(c['name']) for c in json.load(sys.stdin).get('items',[])]")
FAIL=0
for cluster in $CLUSTERS; do
    cm_get "/clusters/$cluster/services" | python3 -c "
import sys, json
for s in json.load(sys.stdin).get('items', []):
    state = s['serviceState']
    ok = 'OK' if state == 'STARTED' else 'FAIL'
    print(f'  [{ok}] {s["name"]}: {state}')
    if state != 'STARTED':
        exit(1)"
    [ $? -ne 0 ] && FAIL=$((FAIL+1))
done

# 2. HDFS health
echo ""
echo "--- HDFS Checks ---"
hdfs dfsadmin -report 2>/dev/null | grep -E "Live datanodes|Dead datanodes|DFS Used"

# 3. YARN
echo ""
echo "--- YARN Nodes ---"
yarn node -list 2>/dev/null | grep -E "Total Nodes|RUNNING"

[ "$FAIL" -eq 0 ] && echo "" && echo "[PASS] All services running." || echo "" && echo "[WARN] $FAIL services not in STARTED state."
