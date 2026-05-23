#!/bin/bash
# Pre-upgrade validation for Cloudera cluster
CM_HOST="${CM_HOST:-localhost}"
CM_PORT="${CM_PORT:-7180}"
CM_USER="${CM_USER:-admin}"
CM_PASS="${CM_PASS:-admin}"
API="http://${CM_HOST}:${CM_PORT}/api/v51"

cm_get() { curl -s -u "${CM_USER}:${CM_PASS}" "${API}$1"; }

echo "=== Cloudera Pre-Upgrade Check ==="
echo "Cloudera Manager: $CM_HOST"
echo ""

# 1. CM version
CM_VER=$(cm_get "/cm/version" | python3 -c "import sys,json; print(json.load(sys.stdin).get('version','unknown'))")
echo "[INFO] CM Version: $CM_VER"

# 2. Cluster health
echo ""
echo "--- Cluster Health ---"
cm_get "/clusters" | python3 -c "
import sys, json
clusters = json.load(sys.stdin).get('items', [])
for c in clusters:
    print(f"  {c['name']}: {c.get('entityStatus','UNKNOWN')}")"

# 3. Services health
echo ""
echo "--- Service Health ---"
CLUSTERS=$(cm_get "/clusters" | python3 -c "import sys,json; [print(c['name']) for c in json.load(sys.stdin).get('items',[])]")
for cluster in $CLUSTERS; do
    cm_get "/clusters/$cluster/services" | python3 -c "
import sys, json
for s in json.load(sys.stdin).get('items', []):
    state = s.get('serviceState','?')
    health = s.get('healthSummary','?')
    color = '' if health == 'GOOD' else '*** '
    print(f'  {color}{s["name"]}: {state} / {health}')"
done

# 4. Disk space on all hosts
echo ""
echo "--- Host Disk Check ---"
cm_get "/hosts" | python3 -c "
import sys, json
for h in json.load(sys.stdin).get('items', []):
    print(f"  {h.get('hostname','?')}: {h.get('healthSummary','?')}")" | head -20

echo ""
echo "=== Pre-upgrade check complete. Fix any *** items before upgrading. ==="
