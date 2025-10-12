#!/bin/bash

# Simple EAE Version Tester
# Quick test to find available EAE versions
# Usage: ./test_eae_simple.sh [start] [end]

START=${1:-2001}
END=${2:-2100}
ARCH="linux-x86_64-standard"
PLEX_VERSION="1.42.2.10156"

echo "Testing EAE versions ${START} to ${END}"
echo "Architecture: ${ARCH}"
echo "Plex version: ${PLEX_VERSION}"
echo ""

# Test versions in parallel
for version in $(seq $START $END); do
    (
        device_id="test_$(date +%s)_${version}_$$"
        url="https://plex.tv/api/codecs/easyaudioencoder?build=${ARCH}&deviceId=${device_id}&oldestPreviousVersion=${PLEX_VERSION}&version=${version}"
        
        # Small delay to avoid rate limiting
        sleep 0.1
        
        response=$(curl -s "$url" 2>/dev/null)
        
        if echo "$response" | grep -q '<Codec url='; then
            echo "✅ Version ${version}: AVAILABLE"
        else
            echo "❌ Version ${version}: Not found"
        fi
    ) &
    
    # Limit concurrent processes
    if (( $(jobs -r | wc -l) >= 20 )); then
        wait -n
    fi
done

wait
echo ""
echo "Testing completed!"
