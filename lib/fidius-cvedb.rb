#!/usr/bin/env ruby
require 'fidius-cvedb/version'
require 'active_record'

module FIDIUS
    module CveDb
        GEM_BASE = File.expand_path('..', __FILE__)
        RAILS_VERSION = Rails.version.to_i

        require 'fidius-cvedb/railtie' unless RAILS_VERSION < 3

        require (File.join GEM_BASE, 'models', 'fidius', 'cve_db', 'cve_connection.rb')
        Dir.glob(File.join GEM_BASE, 'models', 'fidius', 'cve_db', '*.rb') do |rb|
            require rb
        end
    end
end
