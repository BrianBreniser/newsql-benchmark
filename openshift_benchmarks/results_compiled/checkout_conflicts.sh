#!/bin/bash
cat $1 | rg -i "minutes|conflict|running test" | rg -A6 -i "_r_" | rg -A6 -i "running test"
echo ""
echo "=================="
echo ""
cat $1 | rg -i "minutes|conflict|running test" | rg -A6 -i "_u_" | rg -A6 -i "running test"
echo ""
echo "=================="
echo ""
cat $1 | rg -i "minutes|conflict|running test" | rg -A6 -i "_w_" | rg -A6 -i "running test"
echo ""
echo "=================="
echo ""
cat $1 | rg -i "minutes|conflict|running test" | rg -A6 -i "rmu" | rg -A6 -i "running test"
echo ""
echo "=================="
echo ""
