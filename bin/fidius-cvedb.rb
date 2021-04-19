#!/usr/bin/env ruby
require 'optparse'
require 'fidius-cvedb/version'
require 'fileutils'

GEM_BASE = File.expand_path('../../lib', __FILE__)

options = {}

optparse = OptionParser.new do|opts|
  
  opts.banner = "Usage: fidius-cvedb-runner [options]"
  
  opts.on_tail("-f", "--fidius", "Initialize CVE-DB for Usage in FIDIUS C&C-Server") do
    if rails_root?
      rake_tasks
    end
    exit
  end
  
  opts.on_tail("-s", "--standalone", "Initialize CVE-DB standalone version") do
    if rails_root?
      rake_tasks
    end
    exit
  end
  
  opts.on_tail("-h", "--help", "Show this message") do
    puts "GEM_BASE=#{GEM_BASE}"
    puts opts
    exit
  end

  opts.on_tail("-v", "--version", "Show version") do
    puts "FIDIUS CVE-DB, Version #{FIDIUS::Cvedb::VERSION}"
    exit
  end
end

def rake_tasks
  if rails_3?
    puts "It seems like you are using Rails 3. Rake tasks are included via "+
         "Railties and don't need to be symlinked."
  else
    symlink_rake_tasks
  end
end

def symlink_rake_tasks
  Dir.glob(File.join GEM_BASE, 'tasks', '*.rake') do |rake|
    dest = File.join 'lib', 'tasks', File.basename(rake)
    begin
      FileUtils.ln_s(rake, dest)
    rescue Errno::EEXIST
      puts "#{dest} already exists, do you want to override it? (y/n)"
      if override_it?
        FileUtils.rm(dest)
        FileUtils.ln_s(rake, dest)
        puts "Answer was 'yes', overriding the file."
      else
        puts "Answer was 'no', skipping this file."
      end
    end
  end
end

def override_it?
  while answer = gets
    case answer
    when "y\n"
      return true
    when "n\n"
      return false
    else
      puts "I don't know what you mean, enter 'y' for yes or 'n' for no."
    end
  end
end

def rails_root?
    (File.exists?('config/environment.rb') && File.exists?('app/models'))
end

def rails_3?
    File.exists? 'Gemfile'
end

optparse.parse!