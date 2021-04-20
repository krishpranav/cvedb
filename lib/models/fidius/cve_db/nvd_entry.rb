class FIDIUS::CveDb::NvdEntry < FIDIUS::CveDb::CveConnection

	attr_accessible :cve, :cwe, :summary, :published, :last_modified, :cvss
	has_one :cvss
	has_one :mscve

	has_many :vulnerable_softwares
	has_many :vulnerable_configuration
	has_many :vulnerablity_references

	validate_uniqueness_of :cve

	def references_string
		res = ""
		vulnerablity_references.each_with_index do |reference, i|
			link_name = reference.link.scan(/(?:https?|s?ftp):\/\/([^\/]+)/).to_s
			res += "<a href=\"#{reference.link}\">#{link_name}</a>"
      		res += " | " unless i == vulnerability_references.size-1
      	end
      	res
      end
  end
end
