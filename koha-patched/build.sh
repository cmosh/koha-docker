#!/bin/bash
set -e

################
# BUILD KOHA DEBIAN PACKAGES
# NB! PBUILDER MUST BE RUN WITH --privileged mode
################
# ENV KOHA_RELEASE
# ENV KOHABUGS
# ENV DEBEMAIL     digitalutvikling@gmail.com
# ENV DEBFULLNAME  Oslo Public Library
# ENV TEST_QA      0
# VOLUME ["/debian", "/patches"]
# WORKDIR /koha
################

cleanup() {
    rv=$?
    echo "$MSG"
    if [ -n $RETVAL ];
    then
      exit $RETVAL
    else
      exit $rv
    fi
}
trap "cleanup" INT TERM EXIT

echo "Configuring bugzilla..." && \
  git config --global bz.default-tracker bugs.koha-community.org && \
  git config --global bz.default-product Koha && \
  git config --global bz-tracker.bugs.koha-community.org.path /bugzilla3 && \
  git config --global bz-tracker.bugs.koha-community.org.bz-user $BUGZ_USER && \
  git config --global bz-tracker.bugs.koha-community.org.bz-password $BUGZ_PASS && \
  git config --global bz-tracker.bugs.koha-community.org.https true && \
  git config --global core.whitespace trailing-space,space-before-tab && \
  git config --global apply.whitespace fix

echo "KOHA_RELEASE: $KOHA_RELEASE"
echo "GITREF: $GITREF"

############
# CHANGELOG AND BUILD DEPS
############

if [ -z "$SKIP_BUILD" ]; then
  mk-build-deps -t "apt-get -y --no-install-recommends --fix-missing" -i "debian/control"

  dch --force-distribution -D "buster" \
      --newversion "${KOHA_RELEASE}" \
      "Patched version of koha ${KOHA_RELEASE}"
  dch --release "Patched version of koha ${KOHA_RELEASE}"

  # Build
  cd /koha && \
      dpkg-buildpackage -d -b -us -uc

  cp *.deb ../*.deb ../*.changes /debian
fi
