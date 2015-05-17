#!/bin/bash

# get current registration

clientId=`grep GOOGLE_DEFAULT_CLIENT_ID /etc/chrome_dev.conf | cut -d "=" -f 2`
clientSecret=`grep GOOGLE_DEFAULT_CLIENT_SECRET /etc/chrome_dev.conf | cut -d "=" -f 2`
apiKey=`grep GOOGLE_API_KEY /etc/chrome_dev.conf | cut -d "=" -f 2`

if [ -n "${apiKey}" ]; then
  status="N"
  echo API Key has been already registered.
  echo
  echo "CLIENT_ID:    ${clientId}"
  echo "CLIENT_SECRET:${clientSecret}"
  echo "API_KEY:      ${apiKey}"
  echo
  read -p "Do you want to change API Key?(y/N)" status
  if [ ! "y" = ${status} ]; then
    exit
  fi
fi

status="N"
while [ ! "y" = ${status} ] 
do
  read -p "Input CLIENT ID:" clientId
  read -p "Input CLIENT SECRET:" clientSecret
  read -p "Input API KEY:" apiKey
  echo 
  echo "CLIENT ID is     " ${clientId}
  echo "CLIENT SECRET is " ${clientSecret}
  echo "API KEY is       " ${apiKey}
  echo
  read -p "Is this correct?(y/N)" status
done

mount -o remount,rw /
if [ 0 -ne $? ]; then
  echo remount root partition failed . Abort.
  exit
fi 
sed -e '/^GOOGLE_DEFAULT_CLIENT_ID/d' -i /etc/chrome_dev.conf
sed -e '/^GOOGLE_DEFAULT_CLIENT_SECRET/d' -i /etc/chrome_dev.conf
sed -e '/^GOOGLE_API_KEY/d' -i /etc/chrome_dev.conf

echo GOOGLE_DEFAULT_CLIENT_ID=${clientId} >> /etc/chrome_dev.conf
echo GOOGLE_DEFAULT_CLIENT_SECRET=${clientSecret} >> /etc/chrome_dev.conf
echo GOOGLE_API_KEY=${apiKey} >> /etc/chrome_dev.conf

echo 
echo API Key registered.
echo Please restart your machine.
