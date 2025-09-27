#!/usr/bin/env sh

set -o errexit

bundle install --without development test
bin/rails assets:precompile
bin/rails assets:clean

bin/rails db:migrate

# Setup SolidQueue tables
bin/rails runner "ActiveRecord::Schema.define(version: 1) { load Rails.root.join('db', 'queue_schema.rb') }"
