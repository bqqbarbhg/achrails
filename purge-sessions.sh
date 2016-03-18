#!/usr/bin/env bash

# Run this in the background to purge the sessions
# $ ./purge-sessions.sh &

# Log file
LOG=log/purge.log

# Purge sessions every hour
TIMEOUT=3600

while true
do
	echo >> $LOG
	echo Purging sessions: `date -u` >> $LOG
	bundle exec rake sessions:purge 2&>1 >> $LOG

	sleep $TIMEOUT
done

