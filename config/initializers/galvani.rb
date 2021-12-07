# require 'ostruct'
require 'yaml'

GalvaniConfig = YAML.load_file("#{Rails.root}/config/galvani.yaml") || {}
# GalvaniConfig = OpenStruct.new(galvani_config)