#!/bin/bash

# Build the project.
echo -e "\033[0;32mBuilding the website...\033[0m"
hugo --destination ../public 

# Go To Public folder
cd ../public
# Add changes to git.
git add .

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
echo -e "\033[0;32mPushing public...\033[0m"
git push origin master

# Come Back up to the Project Root
cd ../source

# commit sources and push
git add .
git commit -m "$msg"
echo -e "\033[0;32mPushing source...\033[0m"
git push origin master

echo -e "\033[0;32mDone!\033[0m"

