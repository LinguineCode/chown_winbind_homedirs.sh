#!/bin/bash

OWN_DOMAIN="$(wbinfo --own-domain)"

if [ "$OWN_DOMAIN" ]; then

 find "/home/$OWN_DOMAIN/" -mindepth 1 -maxdepth 1 -type d | while read directory;
 do
  USER="$(basename $directory)"
  GROUP="$(id -g $USER)"

  chown -R $USER.$GROUP "$directory"
 done

else
 echo "$0: wbinfo is not properly configured or not installed"
 exit 1

fi
