# require 'ostruct'
require 'yaml'

OctaviaConfig = YAML.load_file("#{Rails.root}/config/support/octavia.yaml") || {}