#!/bin/bash

if [[ -n $RCLONE_CONFIG_BASE64 && -n $RCLONE_DESTINATION ]]; then
	echo "Rclone config detected"
	echo "[DRIVE]" > rclone.conf
	echo "$(echo $RCLONE_CONFIG_BASE64|base64 -d)" >> rclone.conf
	echo "on-download-stop=./delete.sh" >> aria2c.conf
	echo "on-download-complete=./on-complete.sh" >> aria2c.conf
	chmod +x delete.sh
	chmod +x on-complete.sh
fi

echo "rpc-secret=$ARIA2C_SECRET" >> aria2c.conf
aria2c --conf-path=aria2c.conf&
yarn start
