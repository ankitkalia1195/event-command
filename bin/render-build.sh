#!/usr/bin/env sh

set -o errexit

bundle install --without development test
bin/rails assets:precompile
bin/rails assets:clean

bin/rails db:migrate
