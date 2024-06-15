if [ -f $1/qBittorrent.conf ]; then
    echo "WebUI\\Password_PBKDF2=\"@ByteArray($2)\"" >> $1/qBittorrent.conf
fi
# else
#     mkdir -p $1
#     echo "[Preferences]" > $1/qBittorrent.conf
#     echo "WebUI\\Password_PBKDF2=\"@ByteArray($2)\"" > $1/qBittorrent.conf
