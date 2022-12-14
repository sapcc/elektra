# require 'ostruct'
require "yaml"

GalvaniConfig =
  YAML.load_file("#{Rails.root}/config/support/galvani.yaml") || {}
# GalvaniConfig = OpenStruct.new(galvani_config)
