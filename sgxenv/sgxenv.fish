#!/usr/bin/env fish

if test (count $argv) -eq 0
    set SGX_SDK_DIR /opt/intel/sgxsdk
else
    set SGX_SDK_DIR $argv[1]
end

set OUTPUT_FILE "$SGX_SDK_DIR/environment.fish"

if not test -d "$SGX_SDK_DIR"
    echo "Error: Directory '$SGX_SDK_DIR' not found." >&2
    exit 1
end

echo $OUTPUT_FILE

set SCRIPT_CONTENT "
set -gx SGX_SDK '$SGX_SDK_DIR'
set -gx PATH \$PATH \$SGX_SDK/bin \$SGX_SDK/bin/x64
set -gx PKG_CONFIG_PATH \$PKG_CONFIG_PATH \$SGX_SDK/pkgconfig
if not set -q LD_LIBRARY_PATH
     set -gx LD_LIBRARY_PATH \$SGX_SDK/sdk_libs
else
     set -gx LD_LIBRARY_PATH \$LD_LIBRARY_PATH \$SGX_SDK/sdk_libs
end
"

echo $SCRIPT_CONTENT > $OUTPUT_FILE
