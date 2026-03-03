#!/bin/bash

git fetch origin
git remote add origin-remote https://github.com/ratata1590hcm/beacon.git || true
git remote set-url origin-remote https://github.com/ratata1590hcm/beacon.git
git tag -f build origin/main
git push --delete origin-remote build
git push -f origin-remote build