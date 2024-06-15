# if file exists
if [ -f $1/qBittorrent.conf ]; then
    cp $1/qBittorrent.conf $1/qBittorrent.conf.tmp
    grep -Fv "Password_PBKDF2" $1/qBittorrent.conf.tmp > $1/qBittorrent.conf
fi
