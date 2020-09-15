#!/bin/bash

if [[ -n $RCLONE_CONFIG_BASE64 && -n $RCLONE_DESTINATION ]]; then
	echo "Rclone config detected"
	echo "$(echo $RCLONE_CONFIG_BASE64|base64 -d)" > rclone.conf
	echo "on-download-stop=./delete.sh" >> aria2c.conf
	echo "on-download-complete=./on-complete.sh" >> aria2c.conf
	chmod +x delete.sh
	chmod +x on-complete.sh
fi

echo "rpc-secret=$ARIA2C_SECRET" >> aria2c.conf

#Peer Agent
echo "peer-id-prefix=-qB4250-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!~*()._-' | fold -w 12 | head -n 1)" >> aria2c.conf
echo "peer-agent=qBittorrent/4.2.5" >> aria2c.conf

# Tracker
tracker_list=`curl -Ns https://gdridfl.com/trackers.php | awk '$1' | tr '\n' ',' | cat`
echo "bt-tracker=$tracker_list" >> aria2c.conf

aria2c --conf-path=aria2c.conf&

yarn start
