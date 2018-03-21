#!/bin/bash

msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
# commit sources and push
git add .
git commit -m "$msg"
echo -e "\033[0;32mPushing source...\033[0m"
git push origin master

echo -e "\033[0;32mDone!\033[0m"
