#!/bin/bash

find ~ -type f -name "*.txt" > /tmp/some.txt
cat /tmp/some.txt | xargs du -bc 2>/dev/null | tail -1 | cut -f1
cat /tmp/some.txt | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}'
rm /tmp/some.txt
