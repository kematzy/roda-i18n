ENV['RACK_ENV'] = 'test'
if ENV['COVERAGE']
  require File.join(File.dirname(File.expand_path(__FILE__)), "roda_i18n_coverage")
  SimpleCov.roda_i18n_coverage
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rubygems'
require 'roda/i18n'
require 'tilt/erubis'
require 'rack/test'
require 'r18n-core'
require 'minitest/autorun'
require 'minitest/assert_errors'
require 'minitest/hooks/default'
require 'minitest/rg'
require 'kramdown'
require 'date'


class Minitest::Spec
  include Rack::Test::Methods
  
  def rt(path,opts = {})
    get path
    last_response.body
  end
  
  def app(type = nil, &block)
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

  def req(path = '/', env = {})
    if path.is_a?(Hash)
      env = path
    else
      env['PATH_INFO'] = path
    end

    env = {"REQUEST_METHOD" => "GET", "PATH_INFO" => "/", "SCRIPT_NAME" => ""}.merge(env)
    @app.call(env)
  end

  def status(path = '/', env = {})
    req(path, env)[0]
  end

  def header(name, path = '/', env = {})
    req(path, env)[1][name]
  end

  def body(path = '/', env = {})
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
  
  
  # Custom specs app
  def i18n_app(view, opts = {}, configs = {})
    app(:bare) do
      plugin(:i18n, configs)
      route do |r|
        r.root do
          view(inline: view, layout: {inline: '<%= yield %>'}.merge(opts))
        end
      end
    end
    body('/')
  end
  
  # Custom specs app for :i18n_set_locale_from()
  def i18n_set_locale_from_app(loc, type)
    confs = { locale: loc, translations: File.expand_path('../fixtures/**/i18n', __FILE__) }
    app(:bare) do
      plugin :i18n, confs
      route do |r|
        r.root { erb('<%= t.hello %>') }
        r.is('env')  { erb("<%= env.inspect %>") }
        r.is('one') { erb('<%= t.one %>') }
        r.i18n_set_locale_from(type)
        r.get('locale') { erb('<%= t.hello %>') }
        r.get('locale/one') { erb('<%= t.one %>') }
        r.get('locale', :lang) do |lng|
          @lng = lng
          # erb(%Q{<%= @lng %>})
          erb(%Q{<%= t.do.you.speak[:#{@lng}] %>}, {locals: { lng: @lng.to_sym }})
        end
      end
    end
  end
  
  # shortcut for setting config opts
  def set_req(session = {}, http_accept = '')
    { 'rack.session' => session, 'HTTP_ACCEPT_LANGUAGE' => http_accept }
  end
  
  # Custom specs app for :i18n_set_locale()
  def i18n_set_locale_app(loc, set_loc, set_loc2)
    confs = { locale: loc, translations: File.expand_path('../fixtures/**/i18n', __FILE__) }
    app(:bare) do
      plugin :i18n, confs
      route do |r|
        r.root { erb('<%= t.hello %>') }
        r.i18n_set_locale( set_loc ) do
          r.is('t/hello')  { erb("<%= t.hello %>") }
          r.on('posts', :id) do |id|
            @id = id.to_i
            r.on('comments') do
              r.is(:id) do |cid|
                @cid = cid.to_i
                erb('<%= t.post.comments(@id, @cid) %>')
              end
            end
          end
        end
        # second block
        r.i18n_set_locale( set_loc2 ) do
          r.is('t/2/hello')  { erb("<%= t.hello %>") }
        end
      end
    end
  end
  
  # Custom specs app for r.i18n_locale()
  def i18n_locale_app(loc)
    confs = { locale: loc, translations: File.expand_path('../fixtures/**/i18n', __FILE__) }
    app(:bare) do
      plugin :i18n, confs
      route do |r|
        r.root      { erb('<%= t.one %>') }
        r.is('one') { erb('<%= t.one %>') }
        r.locale do
          r.is('t') { erb('<%= t.one %>') }
          r.is('l') { erb '<%= l Date.parse("October 5, 2011") %>' }
        end
        # routes behind the block does not work
        r.get('two')   { erb('<%= t.two %>') }
      end
    end
  end
  
end

