# EAE Version Tester

This script systematically tests EAE (EasyAudioEncoder) versions to find available versions beyond the known 2001.

## Files

-   `test_eae_versions.sh` - Full-featured parallel tester with detailed output
-   `test_eae_simple.sh` - Simple version for quick testing

## Usage

### Full Version (Recommended)

```bash
# Make executable
chmod +x test_eae_versions.sh

# Test versions 2001-3000 with 10 parallel jobs
./test_eae_versions.sh 2001 3000 10

# Test versions 2001-5000 with 20 parallel jobs
./test_eae_versions.sh 2001 5000 20

# Test versions 3000-4000 with 5 parallel jobs
./test_eae_versions.sh 3000 4000 5
```

### Simple Version

```bash
# Make executable
chmod +x test_eae_simple.sh

# Test versions 2001-2100
./test_eae_simple.sh 2001 2100

# Test versions 3000-3100
./test_eae_simple.sh 3000 3100
```

## Parameters

### Full Version

1. **Start version** (default: 2001)
2. **End version** (default: 3000)
3. **Parallel jobs** (default: 10)

### Simple Version

1. **Start version** (default: 2001)
2. **End version** (default: 2100)

## Features

-   **Parallel testing** - Tests multiple versions simultaneously
-   **Color-coded output** - Green for available, red for not found
-   **Progress tracking** - Shows which batch is being tested
-   **Result summary** - Lists all available versions found
-   **Automatic cleanup** - Removes temporary files

## Expected Output

```
EAE Version Tester
=================
Testing versions: 2001 to 3000
Parallel jobs: 10
Architecture: linux-x86_64-standard
Plex version: 1.42.2.10156

Testing batch 1: versions 2001-2010
✅ Version 2001: AVAILABLE
❌ Version 2002: HTTP 404
❌ Version 2003: HTTP 404
...

Available versions:
  ✅ Version 2001
  ✅ Version 2000
  ✅ Version 1995

Highest available version: 2001
```

## Notes

-   The script uses the latest Plex Media Server version (1.42.2.10156)
-   Tests are done in parallel to speed up the process
-   Each test makes a single HTTP request to the Plex API
-   Results are saved temporarily and cleaned up automatically

## Troubleshooting

If you get permission errors:

```bash
chmod +x test_eae_versions.sh
chmod +x test_eae_simple.sh
```

If curl is not found:

```bash
sudo apt-get install curl  # Ubuntu/Debian
```

## Running on Ubuntu

1. Copy the scripts to your Ubuntu box
2. Make them executable: `chmod +x *.sh`
3. Run: `./test_eae_versions.sh 2001 5000 20`

The script will systematically test versions and report any that are available.
