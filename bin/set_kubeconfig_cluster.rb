#!/usr/bin/env ruby

require "yaml"

new_name = ARGV[0]

data = YAML.load(STDIN.read)

data["clusters"].each { |c| c["name"] = new_name }

data["contexts"].each do |c|
  c["context"]["cluster"] = new_name
  c["context"]["user"] = new_name + "-admin"
  c["name"] = new_name + "-admin"
end

data["users"].each { |u| u["name"] = new_name + "-admin" }

data["current-context"] = new_name + "-admin"

puts data.to_yaml
