#!/bin/bash

for user in "$@" ; do
  echo "$user"
  echo "export HISTTIMEFORMAT='%d/%m/%y %T '" >> /home/$user/.bashrc

done
