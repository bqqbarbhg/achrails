#
# https://vagrantup.com
#

VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'ubuntu/trusty32'
  config.vm.network 'private_network', ip: '10.11.12.13'

  config.vm.provision 'shell', path: './provisioning/provisioning.sh',
                               privileged: false,
                               env: { "LAYERS_API_URI" => ENV["LAYERS_API_URI"],
                                      "ACHRAILS_OIDC_CLIENT_SECRET" => ENV["ACHRAILS_OIDC_CLIENT_SECRET"],
                                      "ACHRAILS_OIDC_CLIENT_ID" => ENV["ACHRAILS_OIDC_CLIENT_ID"] }
end
