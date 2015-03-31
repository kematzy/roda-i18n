require 'rubygems'
require 'rack/test'
require 'roda'
require'r18n-core'

ENV['RACK_ENV'] = 'test'

# db_name = DB.get{current_database{}}
# raise "Doesn't look like a test database (#{db_name}), not running tests" unless db_name =~ /test\z/

# require 'rspec_sequel_matchers'
# require 'rspec/collection_matchers'
require 'rspec-html-matchers'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  # config.include RspecSequel::Matchers
  config.include RSpecHtmlMatchers
  config.mock_with :rspec
  config.expect_with :rspec
  config.raise_errors_for_deprecations!
  # ... other config ...  
end

class RSpec::Core::ExampleGroup
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
    c.class_eval(&block)
    c
  end
  
  def _body; last_response.body; end
  def _status; last_response.status; end
end
