#!/usr/bin/env bash

# Small, easy calculator: adds two numbers (int or float).

is_num() { [[ $1 =~ ^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$ ]]; }

if [ "$#" -eq 2 ]; then
	a=$1; b=$2
elif [ "$#" -eq 0 ]; then
	echo "hello, let's add two numbers"
	read -r -p "enter the number you need: " a
	read -r -p "enter another number: " b
else
	echo "Usage: $0 [NUM1 NUM2]" >&2
	exit 2
fi

if ! is_num "$a" || ! is_num "$b"; then
	echo "Please enter valid numbers (e.g. 1, 3.5, 1e3)." >&2
	exit 3
fi

# use awk so floats work
sum=$(awk -v x="$a" -v y="$b" 'BEGIN{print x+y}')
echo "Result: $sum"

