require './server'

require 'rack/coffee'

use Rack::Coffee, {
    :root => 'public',
    :urls => ['/features']
}

run Server
