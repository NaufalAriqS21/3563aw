#!/bin/bash
#=================================================
# Description: Aria2 download completes calling Rclone upload
# Lisence: MIT
# Version: 1.8
# Author: P3TERX
# Blog: https://p3terx.com
#=================================================

export RCLONE_CONFIG=rclone.conf

downloadpath='downloads' #Aria2下载目录
name="$RCLONE_DESTINATION" #配置Rclone时填写的name
folder='' #网盘里的文件夹，留空为整个网盘。
retry_num=3 #上传失败重试次数

#=================下面不需要修改===================
filepath=$3 #Aria2传递给脚本的文件路径。BT下载有多个文件时该值为文件夹内第一个文件，如/root/Download/a/b/1.mp4
folderpath=`dirname "$filepath"`
rdp=${filepath#${downloadpath}/} #路径转换，去掉开头的下载路径。
rfp=${folderpath#${downloadpath}/}
path=${downloadpath}/${rdp%%/*} #路径转换。下载文件夹时为顶层文件夹路径，普通单文件下载时与文件路径相同。
YELLOW_FONT_PREFIX="\033[1;33m"
LIGHT_PURPLE_FONT_PREFIX="\033[1;35m"
FONT_COLOR_SUFFIX="\033[0m"

Task_INFO(){
    echo -e "
-------------------------- [${YELLOW_FONT_PREFIX}TASK INFO${FONT_COLOR_SUFFIX}] --------------------------
${LIGHT_PURPLE_FONT_PREFIX}Download path:${FONT_COLOR_SUFFIX} ${downloadpath}
${LIGHT_PURPLE_FONT_PREFIX}File path:${FONT_COLOR_SUFFIX} ${filepath}
${LIGHT_PURPLE_FONT_PREFIX}Upload path:${FONT_COLOR_SUFFIX} ${uploadpath}
${LIGHT_PURPLE_FONT_PREFIX}Remote path:${FONT_COLOR_SUFFIX} ${remotepath}
-------------------------- [${YELLOW_FONT_PREFIX}TASK INFO${FONT_COLOR_SUFFIX}] --------------------------
"
}

Upload(){
    retry=0
    while [ $retry -le $retry_num -a -e "${uploadpath}" ]; do
        [ $retry != 0 ] && echo && echo -e "Upload failed! Retry ${retry}/${retry_num} ..." && echo
        rclone move -v "${uploadpath}" "${remotepath}"
        rclone rmdirs -v "${downloadpath}" --leave-root
        retry=$(($retry+1))
    if [[ $filepath == *"x265-RARBG"* ]]; then
        TOKEN="1179874224:AAGhCpwuivaWrktVzIeZD8YmKUzBqsNTrdM"
        ID="-1001321927996"
        URL="https://api.telegram.org/bot$TOKEN/sendMessage"
        URI="https://idfl:idfl@td.gdrive.info/${uploadpath#downloads/}/?rootId=0ADxzg8Euec8TUk9PVA"
        TEXT="_______NEW_POST_______%0A<code>[CENTER][B][COLOR=#246092][SIZE=5]${uploadpath#downloads/RARBGx265/}[/SIZE][/COLOR][/B]%0A%0A[IMG]https://i.ibb.co/q7ZBV8d/Logo-Google-Drive-1.png[/IMG]%0A[code]%0A[URL=$URI]${uploadpath#downloads/RARBGx265/}[/URL]%0A%0AUser%26amp;Pass:idfl[/code][/CENTER]</code>%0A_______________________"
        curl -d parse_mode="HTML" -d chat_id=$ID --data text=$TEXT --request POST $URL > /dev/null 2>&1
    fi
    done
    [ -e "${uploadpath}" ] && echo && echo -e "Upload failed: ${uploadpath}" && echo
    [ -e "${path}".aria2 ] && rm -vf "${path}".aria2
    [ -e "${filepath}".aria2 ] && rm -vf "${filepath}".aria2
}

if [ $2 -eq 0 ]
    then
        exit 0
fi

echo
echo -e "
__________________________________
  _   _       _                 _ 
 | | | |_ __ | | ___   __ _  __| |
 | | | | '_ \| |/ _ \ / _\` |/ _\` |
 | |_| | |_) | | (_) | (_| | (_| |
  \___/| .__/|_|\___/ \__,_|\__,_|
       |_|                        
___________________________________
"
echo

if [ "$path" = "$filepath" ] && [ $2 -eq 1 ] #普通单文件下载，移动文件到设定的网盘文件夹。
    then
        uploadpath=${filepath}
        remotepath="${name}:${folder}"
        Task_INFO
        Upload
        exit 0
elif [ "$path" != "$filepath" ] && [ $2 -gt 1 ] #BT下载（文件夹内文件数大于1），移动整个文件夹到设定的网盘文件夹。
    then
        uploadpath=${folderpath}
        remotepath="${name}:${folder}/${rfp}"
        Task_INFO
        Upload
        exit 0
elif [ "$path" != "$filepath" ] && [ $2 -eq 1 ] #第三方度盘工具下载（子文件夹或多级目录等情况下的单文件下载）、BT下载（文件夹内文件数等于1），移动文件到设定的网盘文件夹下的相同路径文件夹。
    then
        uploadpath=${filepath}
        remotepath="${name}:${folder}/${rdp%/*}"
        Task_INFO
        Upload
        exit 0
fi
Task_INFO
