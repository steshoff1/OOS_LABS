#!/bin/bash
find ~ -name "*.txt"
cat `find ~ -name "*.txt"` | wc -c
cat `find ~ -name "*.txt"` | wc -l
