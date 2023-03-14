#!/bin/sh
set -e
export RAILS_SERVE_STATIC_FILES=true
exec puma -C config/puma.rb
