require 'tropo-provisioning'

namespace :tropo do

  desc "List all applications in your tropo account"
  task :apps => :environment do
    prov = TropoProvisioning.new(TROPO_USERNAME, TROPO_PASSWORD)
    prov.applications.each do |apps|
      puts "ID: #{apps.id}"
      puts "Name: #{apps.name}"
      puts "MessagingURL: #{apps.messagingUrl}"
      puts "VoiceURL: #{apps.voiceURL}"
      puts "Partition: #{apps.partition}"
      puts "Platform: #{apps.platform}"
    end
  end

end
