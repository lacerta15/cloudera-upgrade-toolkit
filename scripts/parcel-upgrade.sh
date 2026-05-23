#!/bin/bash
# Manage CDH parcel upgrade via CM API
CM_HOST="${CM_HOST:-localhost}"
CM_USER="${CM_USER:-admin}"
CM_PASS="${CM_PASS:-admin}"
CLUSTER="${1:?Usage: $0 <cluster_name> <parcel_product> <parcel_version>}"
PRODUCT="${2:-CDH}"
VERSION="${3:?Parcel version required}"
API="http://${CM_HOST}:7180/api/v51"

cm_cmd() {
    curl -s -u "${CM_USER}:${CM_PASS}" -X POST         "${API}/clusters/${CLUSTER}/parcels/products/${PRODUCT}/versions/${VERSION}/commands/$1"
}

echo "=== Parcel Upgrade: $PRODUCT $VERSION on $CLUSTER ==="

echo "Step 1: Downloading parcel..."
cm_cmd "startDownload" | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'  Command ID: {d.get("id")}  Active: {d.get("active")}')"
sleep 5

echo "Step 2: Distributing parcel..."
cm_cmd "startDistribution" | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'  Command ID: {d.get("id")}')"
sleep 5

echo "Step 3: Activating parcel..."
cm_cmd "activate" | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'  Success: {d.get("success")}')"

echo "Parcel $PRODUCT $VERSION activated. Proceed with rolling restart."
