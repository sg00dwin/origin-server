mount --bind -o defaults,nosuid,noexec,nodev /tmp /tmp
mount --bind -o defaults,nosuid,noexec,nodev,remount /tmp /tmp

mount --bind -o defaults,nosuid,noexec,nodev /var/log/audit /var/log/audit
mount --bind -o defaults,nosuid,noexec,nodev,remount /var/log/audit /var/log/audit

mount --bind -o defaults,nosuid,noexec,nodev /home /home
mount --bind -o defaults,nosuid,noexec,nodev,remount /home /home

mount --bind -o defaults,nosuid,nodev /var/lib/libra/ /var/lib/libra
mount --bind -o defaults,nosuid,nodev,remount /var/lib/libra /var/lib/libra

mount --bind -o defaults,nosuid /var /var
mount --bind -o defaults,nosuid,remount /var /var

mount --bind -o defaults,nosuid,noexec,nodev /boot /boot
mount --bind -o defaults,nosuid,noexec,nodev,remount /boot /boot

mount --bind -o defaults,nosuid,noexec,nodev /tmp /var/tmp
