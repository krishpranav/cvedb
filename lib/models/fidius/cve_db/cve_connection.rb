class FIDIUS::CveDb::CveConnection < ActiveRecord::Base
	self.abstract_class = true

	database_yml = YAML.load_file('config/database.yml')
	unless database_yml['cve_db']
		puts "WARNING: There is no \"cve_db\" entry in your database.yml, this "+
        "will likely lead to an error."
    end

    establish_connection database_yml['cve_db']
end
