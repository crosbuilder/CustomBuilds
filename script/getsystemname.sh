#!/bin/bash
IFS=":" m=(`dmidecode | grep -n3 'System Information' | grep 'Manufacturer'`)
IFS=":" n=(`dmidecode | grep -n3 'System Information' | grep 'Product Name'`)
echo ${m}
echo ${n}
echo ${m[1]}
echo ${n[1]}
