# ENV["REDISTOGO_URL"] ||= "redis://username:password@host:1234/"
ENV["REDISTOGO_URL"] ||= "redis://redistogo:d05ed00a33e4b8369f4670f058c50f99@drum.redistogo.com:9519"

uri = URI.parse(ENV["REDISTOGO_URL"])
Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password, :thread_safe => true)
