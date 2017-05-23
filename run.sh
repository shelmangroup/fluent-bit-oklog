#!/bin/sh

if [ -z "${OKLOG_DESTINATION}" ]; then
  OKLOG_DESTINATION=$1
fi

/fluent-bit/bin/fluent-bit -c /fluent-bit/etc/fluent-bit.conf | /fluent-bit/bin/oklog forward $OKLOG_DESTINATION
