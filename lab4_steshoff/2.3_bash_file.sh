#!/bin/bash
cat bash.txt | grep "000000" > /tmp/zeros
cat bash.txt | grep -v "000000" > /tmp/nozeros
echo "Первые 10 строк с нулями:"
head -10 /tmp/zeros
echo "Последние 10 строк с нулями:"
tail -10 /tmp/zeros
echo "Первые 10 строк без нулей:"
head -10 /tmp/nozeros
echo "Последние 10 строк без нулей:"
tail -10 /tmp/nozeros


