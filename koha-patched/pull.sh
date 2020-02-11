#!/bin/bash -e
echo "KOHA_RELEASE: ${KOHA_RELEASE}"

if [ -z "$KOHA_RELEASE" ]; then
	echo "Need KOHA_RELEASE"
	exit 1
fi
https://github.com/cmosh/Koha/releases/tag/v${KOHA_RELEASE}.tar.gz
mkdir -p /koha && cd /koha
RES=`curl -sSLk -Iso /dev/null -w "%{http_code}" https://github.com/${KOHA_FORK}/Koha/archive/v${KOHA_RELEASE}.tar.gz`
if [ $RES -eq 200 ]; then
  curl -sSk -o koha.tar.gz https://github.com/${KOHA_FORK}/Koha/archive/v${KOHA_RELEASE}.tar.gz
else
  echo "Failed getting tagged release ... giving up!"
  exit 1
fi

tar -C /koha --strip-components=1 -xzf koha.tar.gz
rm -rf koha.tar.gz
