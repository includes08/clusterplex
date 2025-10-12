#!/bin/bash

# EAE Version Tester Script
# Tests EAE versions systematically to find available versions
# Usage: ./test_eae_versions.sh [start_version] [end_version] [parallel_jobs]

# Default values
START_VERSION=${1:-2001}
END_VERSION=${2:-3000}
PARALLEL_JOBS=${3:-10}
ARCH="linux-x86_64-standard"
PLEX_VERSION="1.42.2.10156"
BASE_URL="https://plex.tv/api/codecs/easyaudioencoder"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Results tracking
AVAILABLE_VERSIONS=()
FAILED_VERSIONS=()

# Function to test a single version
test_version() {
    local version=$1
    local device_id="test_$(date +%s)_${version}_$$"
    local url="${BASE_URL}?build=${ARCH}&deviceId=${device_id}&oldestPreviousVersion=${PLEX_VERSION}&version=${version}"
    
    # Small delay to avoid rate limiting
    sleep 0.1
    
    # Test the version
    local response=$(curl -s -w "%{http_code}" -o /tmp/eae_test_${version}.xml "$url" 2>/dev/null)
    local http_code="${response: -3}"
    
    if [ "$http_code" = "200" ]; then
        # Check if response contains valid XML with Codec element
        if grep -q '<Codec url=' /tmp/eae_test_${version}.xml 2>/dev/null; then
            echo -e "${GREEN}✅ Version ${version}: AVAILABLE${NC}"
            echo "${version}" >> /tmp/available_versions.txt
            return 0
        else
            echo -e "${RED}❌ Version ${version}: Invalid response${NC}"
            echo "${version}" >> /tmp/failed_versions.txt
            return 1
        fi
    else
        echo -e "${RED}❌ Version ${version}: HTTP ${http_code}${NC}"
        echo "${version}" >> /tmp/failed_versions.txt
        return 1
    fi
}

# Function to test a batch of versions in parallel
test_batch() {
    local start=$1
    local end=$2
    local batch_num=$3
    
    echo -e "${BLUE}Testing batch ${batch_num}: versions ${start}-${end}${NC}"
    
    # Create arrays to store PIDs
    local pids=()
    
    # Start parallel tests
    for ((version=start; version<=end; version++)); do
        test_version $version &
        pids+=($!)
    done
    
    # Wait for all tests in this batch to complete
    for pid in "${pids[@]}"; do
        wait $pid
    done
    
    echo -e "${YELLOW}Batch ${batch_num} completed${NC}"
}

# Main execution
echo -e "${BLUE}EAE Version Tester${NC}"
echo -e "${BLUE}=================${NC}"
echo "Testing versions: ${START_VERSION} to ${END_VERSION}"
echo "Parallel jobs: ${PARALLEL_JOBS}"
echo "Architecture: ${ARCH}"
echo "Plex version: ${PLEX_VERSION}"
echo ""

# Initialize result files
> /tmp/available_versions.txt
> /tmp/failed_versions.txt

# Calculate batch size
TOTAL_VERSIONS=$((END_VERSION - START_VERSION + 1))
BATCH_SIZE=$((TOTAL_VERSIONS / PARALLEL_JOBS))
if [ $BATCH_SIZE -lt 1 ]; then
    BATCH_SIZE=1
fi

echo -e "${YELLOW}Starting tests...${NC}"
echo ""

# Test in batches
current_start=$START_VERSION
batch_num=1

while [ $current_start -le $END_VERSION ]; do
    current_end=$((current_start + BATCH_SIZE - 1))
    if [ $current_end -gt $END_VERSION ]; then
        current_end=$END_VERSION
    fi
    
    test_batch $current_start $current_end $batch_num
    
    current_start=$((current_end + 1))
    batch_num=$((batch_num + 1))
done

echo ""
echo -e "${BLUE}Testing completed!${NC}"
echo ""

# Display results
if [ -s /tmp/available_versions.txt ]; then
    echo -e "${GREEN}Available versions:${NC}"
    sort -n /tmp/available_versions.txt | while read version; do
        echo -e "${GREEN}  ✅ Version ${version}${NC}"
    done
    echo ""
    
    # Show the highest version
    HIGHEST_VERSION=$(sort -n /tmp/available_versions.txt | tail -1)
    echo -e "${GREEN}Highest available version: ${HIGHEST_VERSION}${NC}"
else
    echo -e "${RED}No available versions found in range ${START_VERSION}-${END_VERSION}${NC}"
fi

# Show some failed versions for reference
if [ -s /tmp/failed_versions.txt ]; then
    echo ""
    echo -e "${YELLOW}Sample failed versions:${NC}"
    head -5 /tmp/failed_versions.txt | while read version; do
        echo -e "${RED}  ❌ Version ${version}${NC}"
    done
    if [ $(wc -l < /tmp/failed_versions.txt) -gt 5 ]; then
        echo -e "${YELLOW}  ... and $(($(wc -l < /tmp/failed_versions.txt) - 5)) more${NC}"
    fi
fi

# Cleanup
rm -f /tmp/eae_test_*.xml
rm -f /tmp/available_versions.txt
rm -f /tmp/failed_versions.txt

echo ""
echo -e "${BLUE}Test completed!${NC}"
