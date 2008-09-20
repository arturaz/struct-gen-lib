#!/bin/sh
for i in $@; do
    ./execute.rb $i $i.png cour.ttf 10 600 10
done
