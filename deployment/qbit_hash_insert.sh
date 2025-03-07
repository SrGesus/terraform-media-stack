# if file exists
if [ -f /config/qBittorrent/qBittorrent.conf ]; then
    cp /config/qBittorrent/qBittorrent.conf /config/qBittorrent/qBittorrent.conf.tmp;
    grep -Fv "Password_PBKDF2" /config/qBittorrent/qBittorrent.conf.tmp > /config/qBittorrent/qBittorrent.conf;
    echo "WebUI\\Password_PBKDF2=\"@ByteArray($1)\"" >> /config/qBittorrent/qBittorrent.conf;
fi
