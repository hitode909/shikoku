#!/usr/bin/env python
import sys
import tokenize
import token
import json

generator =  tokenize.generate_tokens(sys.stdin.readline)

result = []

for token_class, token_value, _, _, _ in generator:
    result.append([token.tok_name[token_class], token_value])

print json.dumps(result)

# 標準入力読み込み，[ [token_class, token_value] ] をJSONで標準出力
