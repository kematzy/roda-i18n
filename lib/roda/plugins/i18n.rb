require 'r18n-core'

class Roda
  module RodaPlugins
    # The i18n plugin allows you to easily add internationalisation (i18n) and
    # localisation support to your Roda app, by adding the following:
    # 
    #    plugin :i18n
    # 
    # By default the default locale is set to <tt>'en'</tt> and the translations directory 
    # is set to <tt>'i18n'</tt> in the rooot of your app.
    # 
    # Both <tt>:locale</tt> and <tt>:translations</tt> can be overridden during configuration:
    #    
    #    plugin :i18n, :locale => ['de'], :translations => ['absolute/path/2/i18n']
    # 
    # Please note! 
    #  1) You must set <tt>opts[:root]</tt> in your app if you don't define the <tt>:translations</tt> path.
    #  
    # 2) When overriding <tt>:translations</tt> the path given must be absolute.
    # 
    # The path supports 'wildcards', ie: path/**/i18n so you can load translations from multiple
    # combined apps each with their own <tt>i18n</tt> folder with translations.
    # 
    # Note! when loading translations from multiple sources and the same translation key is used 
    # in both files, the first loaded file takes precedence, ie: <tt>./i18n/en.yml</tt> takes precedence over
    # <tt>./apps/app1/i18n/en.yml</tt>
    # 
    # == USAGE
    # 
    # The i18n plugin depends upon simple YAML based translations files:
    # 
    #     # app/i18n/en.yml
    #     
    #     user:
    #       edit: Edit user
    #       name: User name is %1
    #       count: !!pl
    #         1: There is 1 user
    #         n: There are %1 users
    #     
    # 
    # and the <tt>:t</tt> instance method to output the translations:
    # 
    #     
    #     t.user.edit         #=> "Edit user"
    #     t.user.name('John') #=> "User name is John"
    #     t.user.count(5)     #=> "There are 5 users"
    #     
    #     t.does.not.exist | 'default' #=> "default"
    #     
    #  
    # the <tt>:l</tt> instance method provides built-in localisations support:
    # 
    #      l Time.now           #=> "03/01/2010 18:54"
    #      l Time.now, :human   #=> "now"
    #      l Time.now, :full    #=> "3rd of January, 2010 18:54"
    #   
    # Both the <tt>:t</tt> and <tt>:l</tt> methods are available in the route and template (erb) scopes. ie:
    # 
    #     route do |r|
    #       r.root do
    #         t.welcome.message
    #       end
    #     end
    #     
    #     # app/views/layout.erb
    #     <snip...>
    #       <h1><%= t.welcome.message %></h1>
    #     <snip...>
    #     
    # 
    # 
    # Visit [R18n](https://github.com/ai/r18n/tree/master/r18n-core) for more information.
    # 
    # 
    # The i18n plugin also makes it easy to handle locales:
    # 
    # 
    # === <tt>:locale</tt> RequestMethod
    # 
    # This request method makes it to handle translations based upon the :locale prefix on a URL,
    #  ie: <tt>blog.com/de/posts</tt>, just use the following code:
    # 
    #     route do |r|
    #       
    #       r.locale do
    #         r.is 'posts' do 
    #           t.posts.header
    #         end
    #       end
    #       
    #     end
    # 
    # 
    # === <tt>:i18n_set_locale_from</tt> RequestMethod
    # 
    # Obtains the locale from either ENV, HTTP (browser), Params or Session
    # values
    # 
    # 
    # Naturally we can allow browsers to override the default locale within routes, like this:
    # 
    #     route do |r|
    #       i18n_set_locale_from(:http)  #=> set to the browser's default locale (en-US)
    #       r.get '' do
    #         t.hello  #=> 'Howdy, I speak American English'
    #       end
    #     end
    # 
    # The def
    # 
    # 
    #     route do |r|
    #       i18n_set_locale('de')
    #       r.get 'in-german' do
    #         t.hello  #=> 'Guten tag, ich spreche deutsch'
    #       end
    #     end
    # 
    # 
    # 
    # 
    module RodaI18n
      
      def self.load_dependencies(app, opts={})
        # app.plugin :render
        # app.plugin :environments
      end
      
      def self.configure(app, opts={})
        opts = app.opts[:i18n][:orig_opts].merge(opts) if app.opts[:i18n]
        app.opts[:i18n] = opts.dup
        app.opts[:i18n][:orig_opts] = opts
        opts = app.opts[:i18n]
        
        ::R18n.default_places = opts[:translations] || File.expand_path('i18n', app.opts[:root])
        
        opts[:default_locale] = opts[:locale].is_a?(Array) ? opts[:locale].first : opts[:locale] || 'en'
        ::R18n::I18n.default = opts[:default_locale]
        
        ::R18n.clear_cache! if ENV['RACK_ENV'] != 'production'
        i18n   = R18n::I18n.new(opts[:locale], ::R18n.default_places,
                                  off_filters: :untranslated,
                                  on_filters:  :untranslated_html)
        ::R18n.set(i18n)
      end
      
      
      module RequestMethods
        
        # Obtains the locale from either ENV, HTTP (browser), Params or Session
        # values.
        # 
        #   route do |r|
        #     # A): set from URL params ie: GET /posts?locale=de
        #     r.i18n_set_locale_from(:params)
        #     
        #     # B): set from session[:locale] (if present)
        #     r.i18n_set_locale_from(:session)
        #     
        #     # C): set from the browser's HTTP request locale
        #     r.i18n_set_locale_from(:http)
        #     
        #     # D): set from the server ENV['LANG'] variable
        #     r.i18n_set_locale_from(:ENV)
        #     
        #     
        #     r.is 'posts' do 
        #       t.posts.header # use translations
        #     end
        #   end
        # 
        def i18n_set_locale_from(type)
          case type.to_sym
          when :http
            _locale = ::R18n::I18n.parse_http(scope.request.env['HTTP_ACCEPT_LANGUAGE'])
          when :session
            _locale = session[:locale] if session[:locale]
          when :params
            _locale = scope.request.params['locale'] if scope.request.params['locale']
          when :ENV
            _locale = ENV['LANG'].split('.').first if ENV['LANG']
          else
            _locale = nil
          end
          # sanity check: set to default locale if not set above
          _locale = ::R18n::I18n.default.to_s if _locale.nil?
          
          _i18n = ::R18n::I18n.new(_locale, ::R18n.default_places,
                                    off_filters: :untranslated, 
                                    on_filters: :untranslated_html)
          ::R18n.set(_i18n)
        end
        
        # Enables setting temporary :locale.
        # 
        #   route do |r|
        #     
        #     r.i18n_set_locale('de') do
        #       # within this block the locale is DE (German)
        #     end
        #     
        #     r.i18n_set_locale('es') do
        #       # within this block the locale is ES (Spanish)
        #     end
        #     
        #   end
        # 
        def i18n_set_locale(locale, &blk)
          locale = ::R18n::I18n.default.to_s if locale.nil?
          
          _i18n = ::R18n::I18n.new(locale, ::R18n.default_places,
                                    off_filters: :untranslated, 
                                    on_filters: :untranslated_html)
          ::R18n.set(_i18n)
          yield
        end
        
        # Sets the locale based upon <tt>:locale</tt> prefixed routes
        #  
        #   route do |r|
        #     r.locale do
        #       # all routes are prefixed with '/:locale'
        #       # ie: GET /de/posts  => will use DE translations
        #       # ie: GET /es/posts  => will use ES translations
        #       r.is 'posts' do 
        #         t.posts.header # use translations or locales
        #       end
        #     end
        #   end
        #
        def locale(opts={}, &blk)
          on(':locale', opts) do |l|
            _locale = l || self.class.opts[:locale]
            session[:locale] = _locale unless session[:locale]
            ::R18n.set(_locale)
            yield
          end
        end
        alias_method :i18n_locale, :locale
      
      
      end #/module RequestMethods
      
      module ClassMethods
        
        # Return the i18n options for this class.
        def i18n_opts
          opts[:i18n]
        end
        
      end #/module ClassMethods
      
      module InstanceMethods
        include ::R18n::Helpers
        
        def i18n_available_locales
          @available_locales = []
          ::R18n.available_locales.each do |l|
            @available_locales << [l.code, l.title]
          end
          @available_locales
        end
        
        def i18n_default_places
          ::R18n.default_places
        end
        
      end
      
    end #/module RodaI18n
    
    register_plugin(:i18n, RodaI18n)
  end #/module RodaPlugins
end #/class Roda