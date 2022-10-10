#!/bin/bash

function apply-patches() {
  (
    local patches_path=$1
    echo "Applying patches from path: $patches_path"
    find $patches_path -type f -iname '*.patch' | sort -n | while read patch_file ; do
      echo "Applying patch: $patch_file"
      git apply $patch_file
    done
  )
}
