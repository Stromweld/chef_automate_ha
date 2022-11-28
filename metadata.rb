name 'automate_ha'
maintainer 'Corey Hemminger'
maintainer_email 'hemminger@hotmail.com'
license 'Apache-2.0'
description 'Installs/Configures automate_ha'
version '0.1.0'
chef_version '>= 16.0'

issues_url 'https://github.com/Stromweld/automate_ha/issues'
source_url 'https://github.com/Stromweld/automate_ha'

%w(alma amazon centos redhat rocky ubuntu).each do |os|
  supports os
end

depends 'line'
depends 'ssh_authorized_keys'
