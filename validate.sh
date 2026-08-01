#!/usr/bin/env bash
# Checks index.json the way CI does. --offline skips the url reachability pass.
set -uo pipefail
cd "$(dirname "$0")"

index="index.json"
offline=0
[[ "${1:-}" == "--offline" ]] && offline=1
fail=0

err() {
    echo "  $1"
    fail=1
}

jq empty "$index" 2>/dev/null || {
    echo "$index is not valid json"
    exit 1
}

[[ "$(jq -r .formatVersion "$index")" == "1" ]] || err "formatVersion must be 1"

count=$(jq '.widgets | length' "$index")
echo "$count widgets"

for i in $(seq 0 $((count - 1))); do
    w=$(jq -c ".widgets[$i]" "$index")
    id=$(jq -r '.id // ""' <<< "$w")
    [[ -n "$id" ]] || { err "[$i] has no id"; continue; }

    for f in name description icon author url minShellVersion; do
        [[ -n "$(jq -r ".$f // \"\"" <<< "$w")" ]] || err "$id: $f is empty"
    done
    for f in dependencies tags; do
        [[ "$(jq -r ".$f | type" <<< "$w")" == "array" ]] || err "$id: $f must be an array"
    done

    [[ "$id" =~ ^[a-zA-Z][a-zA-Z0-9]*$ ]] || err "$id: id must be a bare camelCase word"
    [[ "$(jq -r .minShellVersion <<< "$w")" =~ ^[0-9]+\.[0-9]+$ ]] || err "$id: minShellVersion must be major.minor"

    url=$(jq -r .url <<< "$w")
    [[ "$url" =~ ^https://[^[:space:]]+$ ]] || err "$id: url must be https"
    if (( ! offline )) && ! curl -sfI --max-time 10 "$url" >/dev/null; then
        err "$id: $url is unreachable"
    fi
done

dupes=$(jq -r '.widgets[].id' "$index" | sort | uniq -d)
[[ -z "$dupes" ]] || err "duplicate ids: $dupes"

sorted=$(jq -r '.widgets[].id' "$index")
[[ "$sorted" == "$(sort <<< "$sorted")" ]] || err "widgets must be sorted by id"

(( fail )) && { echo "failed"; exit 1; }
echo "ok"
