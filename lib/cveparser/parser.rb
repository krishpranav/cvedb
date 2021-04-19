PARSER_DIR = File.dirname(File.expand_path(__FILE__))

require "#{PARSER_DIR}/parser_model"
require 'rubygems'
require 'nokogiri'

# This module provides a parser for the National Vulnerability Database
# (nvd.nist.gov). The parser can handle XML files provided by the NVD in 
# Version 2.0 and stores all entries from the parsed file in objects 
# from the module 'FIDIUS::NVDParserModel'. 

module FIDIUS
  module NVDParser
  
    include NVDParserModel
    
    # Parse Version 2.0 XML-File from nvd.nist.gov.     
    def self.parse_cve_file file
      
      doc = Nokogiri::XML(File.open(file))
      doc.css("nvd").each do |nvd| 
        version = nvd.attributes['nvd_xml_version'].value
        if version != "2.0"
          puts "Your XML has the wrong version (#{version}). " + 
               "The CVE-Parser can only handle XML-Feeds in Version 2.0."
          raise 'Invalid XML Version'
        end 
      end

      start_time = Time.now
      puts "[*] Start parsing \"#{file}\""
    
      entries = []
      entry_count = 0
      doc.css('nvd > entry').each do |entry|
        entries << single_entry(entry)
        entry_count += 1
        if entry_count % 100 == 0 and entry_count > 0
          puts "Parsed #{entry_count} CVE Entries."
        end
      end
      end_time = Time.now
      puts "[*] Finished parsing, parsed #{entries.size} entries in " +
           "#{(end_time-start_time).round} seconds."
      entries
    end
    
    private  

    # Parse single NVD-Entry and store it in an NVDEntry Object
    def self.single_entry entry
      params = {}
      params[:cve] = entry.attributes['id'].value
      params[:vulnerable_configurations] = vulnerable_configurations(entry)
      params[:cvss] = cvss(entry)
      params[:vulnerable_software] = vulnerable_software(entry)
      params[:published_datetime] = child_value(entry, 'vuln|published-datetime')
      params[:last_modified_datetime] = child_value(entry, 'vuln|last-modified-datetime')
      params[:cwe] = cwe(entry)
      params[:summary] = child_value(entry, 'vuln|summary')
      params[:references] = references(entry)
        
      NVDParserModel::NVDEntry.new(params)
    end  
    
    # Return CWE number for given CVE-Entry
    def self.cwe entry
      cwe = entry.at_css('vuln|cwe')
      cwe.attributes['id'].value if cwe
    end
    
    # Returns an array of all references which belong to the given CVE-Entry 
    def self.references entry
      ref_array = []
      entry.css('vuln|references').each do |references|
        ref_params = {}
        ref_params[:source] = child_value(references, 'vuln|source')
        ref = references.at_css('vuln|reference')
        ref_params[:link] = ref.attributes['href'].value if ref
        ref_params[:name] = child_value(references, 'vuln|reference')
        ref_array << NVDParserModel::Reference.new(ref_params)
      end
      ref_array
    end
      
    # Returns an array of all vulnerable products which belong to the given CVE-Entry
    def self.vulnerable_software entry
      vuln_products = []
      entry.css('vuln|vulnerable-software-list > vuln|product').each do |product|
        vuln_products << product.children.to_s if product
      end
      vuln_products
    end
    
    # Returns the CVSS-Data from the given CVE-Entry
    def self.cvss entry
      
      metrics = entry.css('vuln|cvss > cvss|base_metrics')
      unless metrics.empty?
        cvss_params = {}
        {
          :score                  => 'score',
          :source                 => 'source',
          :access_vector          => 'access-vector',
          :authentication         => 'authentication',
          :access_complexity      => 'access-complexity',
          :confidentiality_impact => 'confidentiality-impact',
          :integrity_impact       => 'integrity-impact',
          :availability_impact    => 'availability-impact',
          :generated_on_datetime  => 'generated-on-datetime'
        
        }.each_pair do |hash_key, xml_name|
          elem = metrics.at_css("cvss|#{xml_name}")
          value = elem ? elem.children.to_s : nil
          cvss_params[hash_key] = value
        end
        NVDParserModel::Cvss_.new(cvss_params)
      end
    end
    
    # Returns an array of all vulnerable configurations which belong to the given CVE-Entry
    def self.vulnerable_configurations entry
      v_confs = []
      entry.css('vuln|vulnerable-configuration > cpe-lang|logical-test'+
                      ' > cpe-lang|fact-ref').each do |conf|
          v_confs << conf.attributes['name'].value
      end
      v_confs
    end
    
    # Helper method to retrieve the value of a child node in a XML file
    def self.child_value(node, xml)
      val = node.at_css(xml)
      val.children.to_s if val
    end
  end
end