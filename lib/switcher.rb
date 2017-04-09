require "switcher/version"
require 'json'
require 'etc'

module Switcher
  module_function

  $config = {
    default_config_file: "~/.config/karabiner/karabiner.json",
    service: "org.pqrs.karabiner.karabiner_console_user_server"
  }

  def config_file
    config_file = $config[:default_config_file]
    if config_file[0] == '~'
      home_dir = Etc.getpwuid.dir
      unless home_dir
        puts 'Unable to read home directory, aborting'
        exit!
      end
      config_file = home_dir + config_file[1..-1]
    end
    config_file
  end

  def json_hash
    JSON.parse(File.read(config_file))
  end

  def profiles
    profiles = Hash[json_hash['profiles'].collect { |i| [i['name'], i['selected']] }]
  end

  def save_config(profile)
    File.open(config_file, 'w') do |f|
      f.write(JSON.pretty_generate(profile))
    end
    puts "Successfully saved profile."
  end

  def switch_profile
    puts "Karabiner-Elements profiles: "
    profiles.each_with_index do |(k,v), i|
      if v
        puts "-> #{i+1}) #{k}"
      else
        puts "   #{i+1}) #{k}"
      end
    end
    begin
      answer = gets.to_i
    rescue Interrupt => e
      puts "....Program was closed."
      exit!
    end
    if answer.to_i > profiles.length || answer.to_i <= 0
      puts "Invalid profile number"
      exit!
    end
    selected_profile = profiles.keys[answer-1]

    profile_data = json_hash
    profile_data['profiles'] = json_hash['profiles'].each do |p|
      if p['name'] == selected_profile
        p['selected'] = true
      else
        p['selected'] = false
      end
    end
    save_config(profile_data)
  end
end
