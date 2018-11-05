#!/bin/bash

for i in {0..2}
do
     ruby run.rb "${i}" &
done

wait
