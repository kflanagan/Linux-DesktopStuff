#!/bin/bash
# Change the host name in a text file from upper to lower case

file=/code/bashclass/bar

host=`hostname -s`
echo "host name is "$host

lowerhost=`echo "$host" | sed -e 's/\(.*\)/\L\1/'`

echo "The host in lower case is" $lowerhost
echo $file
sed -i "s/$host/$lowerhost/g" /code/bashclass/bar
cat bar