#!/bin/bash

git pull --rebase origin `git name-rev --name-only HEAD`
bundle exec rake assets:upload RAILS_ENV=production
git add public/assets/manifest*
git commit -m "Compressed assets to push"
git push origin `git name-rev --name-only HEAD`:production -f

