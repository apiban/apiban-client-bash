#! /bin/bash
# * Copyright (c) 2020 @qwell
# * 
# * Permission is hereby granted, free of charge, to any person obtaining a copy
# * of this software and associated documentation files (the "Software"), to deal
# * in the Software without restriction, including without limitation the rights
# * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# * copies of the Software, and to permit persons to whom the Software is
# * furnished to do so, subject to the following conditions:
# * 
# * The above copyright notice and this permission notice shall be included in all
# * copies or substantial portions of the Software.
# * 
# * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# * SOFTWARE.

NOW=$(date +"%Y-%m-%d %H:%M:%S")

# APIKEY and last known ID are stored in config file
CONFIG=apibanconfig.sys

# Output to a LOD
LOG=apiban-client.log

if [ ! -e "${CONFIG}" ] ; then
    # cant find config file
    echo "does $CONFIG exist?"
    echo "unable to locate config file $CONFIG"
    exit 0
fi

# APIKEY and last known ID are stored in apibanconfig.sys
source $CONFIG

# Exit if no APIKEY
if [ -v "$APIKEY" ] ; then
    echo "$NOW - Cannot determine APIKEY. Exiting." >> $LOG
    exit 0
fi

# If no LKID, make it 100
if [ -v "$LKID" ] ; then
    LKID="100"
fi

# check if chain APIBAN exists
CURRIPS=$(iptables -S APIBAN | awk '$1 !="-P"' | awk '{print $4}' | awk '{gsub("/32", "");print}')
if [ -z "$CURRIPS" ] ; then
    echo "$NOW - Making target chain, resetting LKID." >> $LOG
    LKID=100
    iptables -N APIBAN
    iptables -I INPUT -j APIBAN
    iptables -I FORWARD -j APIBAN
fi

BANLIST=$(curl -s https://apiban.org/api/$APIKEY/banned/$LKID)
IPADDRESS=$(echo $BANLIST | jq -r ".ipaddress? | .[]")
CURRID=$(echo $BANLIST | jq -r ".ID?")

# No new bans
if [ "$CURRID" = "none" ] ; then
    echo "$NOW - No new bans since $LKID. Exiting." >> $LOG
    exit 0
fi

# If CURRID is not numeric, exit.
re='^[0-9]+$'
if ! [[ $CURRID =~ $re ]] ; then
    echo "$NOW - Unexpected response from API ERR1 $CURRID. Exiting." >> $LOG
    exit 1
fi

# update LKID
sed -i "s/^\(LKID=\).*$/\1${CURRID}/" $CONFIG

# parse through IPs
IPADDRESSARR=(${IPADDRESS//$'\"'/})
for i in "${IPADDRESSARR[@]}"
do
  NOW=$(date +"%Y-%m-%d %H:%M:%S")
  if [[ $CURRIPS =~ "$i" ]]; then
    echo "$NOW - $i already in APIBAN chain. Bad LKID?" >> $LOG
  else
    iptables -I APIBAN -s $i -j DROP
    echo "$NOW - Adding $i to iptables" >> $LOG
  fi
done

echo "$NOW - All done. Exiting." >> $LOG
