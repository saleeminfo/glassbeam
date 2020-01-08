#!/bin/bash

ifconfig | grep Bcast | egrep -o 'addr:([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}' | egrep -o '[[:digit:]].*'
