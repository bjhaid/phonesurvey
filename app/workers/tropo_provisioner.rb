require "tropo-provisioning"

class TropoProvisioner
  @queue = :tropo_provisioner

  @tropo_username = TROPO_CONFIG['username']
  @tropo_password = TROPO_CONFIG['password']
  @tropo_app_id = TROPO_CONFIG['app_id']

  def self.perform(product_id)
    product = Product.find(product_id)

    prov = TropoProvisioning.new(@tropo_username, @tropo_password)

    prefix = '1805'

    response = prov.create_address(@tropo_app_id, :type => 'number', :prefix => prefix)

    product.update_attribute(:tropo_number, response['address'])
  end
end
