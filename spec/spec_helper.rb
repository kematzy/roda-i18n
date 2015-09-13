# $:.unshift(File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'lib'))

if ENV['COVERAGE']
  require File.join(File.dirname(File.expand_path(__FILE__)), "roda_i18n_coverage")
  SimpleCov.roda_i18n_coverage
end

ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'roda'
require 'tilt/erubis'
require 'rack/test'
require 'r18n-core'
require 'minitest/autorun'
require 'minitest/hooks/default'
require 'kramdown'
require 'date'

require "#{File.dirname(__FILE__)}/../lib/roda/plugins/i18n"

class Minitest::HooksSpec
  include Rack::Test::Methods
  
  def rt(path,opts={})
    get path
    last_response.body
  end
  
  def app(type=nil, &block)
    case type
    when :new
      @app = _app{route(&block)}
    when :bare
      @app = _app(&block)
    when Symbol
      @app = _app do
        plugin type
        route(&block)
      end
    else
      @app ||= _app{route(&block)}
    end
  end

  def req(path='/', env={})
    if path.is_a?(Hash)
      env = path
    else
      env['PATH_INFO'] = path
    end

    env = {"REQUEST_METHOD" => "GET", "PATH_INFO" => "/", "SCRIPT_NAME" => ""}.merge(env)
    @app.call(env)
  end

  def status(path='/', env={})
    req(path, env)[0]
  end

  def header(name, path='/', env={})
    req(path, env)[1][name]
  end

  def body(path='/', env={})
    s = ''
    b = req(path, env)[2]
    b.each{|x| s << x}
    b.close if b.respond_to?(:close)
    s
  end
  
  def _app(&block)
     c = Class.new(Roda)
     c.plugin :render
     c.plugin(:not_found){raise "path #{request.path_info} not found"}
     c.use Rack::Session::Cookie, :secret=>'topsecret'
     c.class_eval do
       def erb(s, opts={})
         render(opts.merge(:inline=>s))
       end
     end
     c.class_eval(&block)
     c
  end

  # syntactic sugar
  def _body
    last_response.body
  end
  
  # syntactic sugar
  def _status
    last_response.status
  end
  
end

