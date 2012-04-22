ENV["REDISTOGO_URL"] ||= "redis://username:password@host:1234/"

Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }

uri = URI.parse(ENV["REDISTOGO_URL"])
Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password, :thread_safe => true)
