require 'open-uri'
require 'nokogiri'

# This module provides a parser for the mapping between CVE-Number
# and Microsoft Security Bulletin Number. It also stores the 
# relationships in the database, so you need the models to store 
# them.

module FIDIUS
  module MSParser
  
    BASE_URL = "http://cve.mitre.org/data/refs/refmap/source-MS.html"
    
    # Calls 'parse' and stores the mapping in the database
    def self.parse_ms_cve
      entries = parse
      counter = 0
      entries.each_pair do |ms,cves|
        cves.each do |cve|       
          existing_cve = NvdEntry.find_by_cve(cve.strip)
          if existing_cve
            Mscve.find_or_create_by_nvd_entry_id_and_name(existing_cve.id, ms)
            puts "Found: #{existing_cve.cve}."
            counter += 1
          end
        end
      end  
      puts "Added #{counter} items to database."
    end

    # Print all MS-Notation numbers mapped to CVE-Entries 
    def self.print_map
      entries = parse    
      entries.each_pair do |ms,cves|
        puts "#{ms}"
        cves.each {|cve| puts "----#{cve}"}
      end
    end 

    private
    
    # Parses the page given by BASE_URL and returns
    # all entries 
    def self.parse
      doc = Nokogiri::HTML(open(BASE_URL))
      entries = Hash.new("")
      current_ms_entry = ""
      doc.css('table[border="2"] > tr').each do |entry|
        entry.css("td").each do |td|
          if td.content =~ /CVE-\d{4}-\d{4}/
            entries[current_ms_entry] = td.content.split("\n")
          else
            current_ms_entry = td.content.split(":").last
            entries[current_ms_entry]
          end
        end
      end
      puts "Parsed #{entries.size} entries."
      entries
    end
  end
end