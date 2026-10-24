#!/usr/bin/env bash
# usage: fal.sh <endpoint> <json-file>  -> prints first image url
eval "$(grep -E '^export FAL_KEY=' ~/.zshrc | tail -1)"
curl -s "https://fal.run/$1" -H "Authorization: Key $FAL_KEY" -H 'Content-Type: application/json' -d @"$2" \
 | python3 -c "import json,sys;d=json.load(sys.stdin);i=d.get('images') or ([d['image']] if 'image' in d else None);print(i[0]['url'] if i else d)"
