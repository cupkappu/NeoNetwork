#!/usr/bin/env bash
set -e

IPTOOL="$PWD/Misc/C/ip"

if [ ! -x "$IPTOOL" ]; then
	echo "You need to build Misc/C/ip first"
	exit 1
fi

print_record()
{
	printf "%s\tIN\tPTR\t%s\n" "$1" "$2"
}

sed -i '/AUTOGENERATED/,$d' dns/db.10.127
echo '; AUTOGENERATED' >> dns/db.10.127

(
cd route
for i in *; do
	source "$i"
	if [ "$TYPE" = "TUN30" ]; then
		upstream_ip=$("$IPTOOL" "$i" 1)
		downstream_ip=$("$IPTOOL" "$i" 2)

		print_record "$upstream_ip" "$DOWNSTREAM.$UPSTREAM.tun30.neo."
		print_record "$downstream_ip" "$UPSTREAM.$DOWNSTREAM.tun30.neo."
	fi
done
) | sort -n >> dns/db.10.127
