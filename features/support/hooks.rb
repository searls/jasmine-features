require 'childprocess'

Before do
  @process = ChildProcess.build "bundle exec shotgun -p 9394"
  @process.environment['RACK_ENV'] = "test"
  @process.start
  sleep 3
end

After do
  @process.stop
  @process.poll_for_exit(5)
end