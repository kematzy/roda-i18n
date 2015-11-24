require 'r18n-core'

# 
class Roda
  
  # 
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
    #  1) You must set +opts[:root]+ in your app if you don't define the +:translations+ path.
    #  
    # 2) When overriding <tt>:translations</tt> the path given <b>must be absolute</b>.
    # 
    # The path supports 'wildcards', ie: path/**/i18n so you can load translations from multiple
    # combined apps each with their own <tt>i18n</tt> folder with translations.
    # 
    # Note! when loading translations from multiple sources and the same translation key is used 
    # in both files, the first loaded file takes precedence, ie: <tt>./i18n/en.yml</tt> takes 
    # precedence over <tt>./apps/app1/i18n/en.yml</tt>
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
    # Both the +:t+ and +:l+ methods are available in the route and template (erb) scopes. ie:
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
    #       r.locale do    # or r.i18n_locale
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
    # Obtains the locale from either ENV, HTTP (browser), Params or Session values
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
      
      # default options
      OPTS = {
        # set the default locale
        locale:           'en',
        # set the default fallback locale
        default_locale:   'en',
        # set the default translations.
        translations:     nil
      }.freeze
      
            
      def self.configure(app, opts = OPTS)
        if app.opts[:i18n]
          opts = app.opts[:i18n][:orig_opts].merge(opts)
        else
          opts = OPTS.merge(opts)
        end
        
        app.opts[:i18n]             = opts.dup
        app.opts[:i18n][:orig_opts] = opts
        opts = app.opts[:i18n]
        
        # set the translations path to defaults if nil
        opts[:translations] = File.expand_path('i18n', app.opts[:root]) if opts[:translations].nil?
        ::R18n.default_places = opts[:translations]
        
        # default_locale is either 'en' or the set value, so reset :default_locale if 
        # it is somehow nil or an empty string ' '
        if opts[:default_locale].nil? || opts[:default_locale] =~ /^\s*$/
          opts[:default_locale] = 'en'
        end
        ::R18n::I18n.default = opts[:default_locale]
        
        ::R18n.clear_cache! if ENV['RACK_ENV'] != 'production'
        i18n   = R18n::I18n.new(
          opts[:locale], 
          ::R18n.default_places,
          off_filters:  :untranslated,
          on_filters:   :untranslated_html
        )
        ::R18n.set(i18n)
      end
      
      # methods used within Roda's route block
      # 
      module RequestMethods
        
        # Obtains the locale from either ENV, HTTP (browser), Params or Session
        # values.
        # 
        #   route do |r|
        #     # A): set from URL params ie: GET /posts?locale=de
        #     r.i18n_set_locale_from(:params)
        # 
        #       /url?locale=de
        #       <%= t.one %>    #=> Ein
        #       /url?locale=es
        #       <%= t.one %>    #=> Uno
        #     
        #     # B): set from session[:locale] (if present)
        #     r.i18n_set_locale_from(:session)
        # 
        #       session[:locale] = 'de'
        #       <%= t.one %>    #=> Ein
        #       session[:locale] = 'es'
        #       <%= t.one %>    #=> Uno
        #     
        #     # C): set from the browser's HTTP request locale
        #     r.i18n_set_locale_from(:http)
        # 
        #       HTTP_ACCEPT_LANGUAGE = 'sv-se;q=1,es;q=0.8,en;q=0.6'
        #       <%= t.one %>    #=> Ett
        #     
        #     # D): set from the server ENV['LANG'] variable
        #     r.i18n_set_locale_from(:ENV)
        #     
        #       ENV['LANG'] = 'en_US.UTF8'
        #         <%= t.one %>    #=> One
        #       ENV['LANG'] = 'es'
        #         <%= t.one %>    #=> Uno
        #     
        #     r.is 'posts' do 
        #       t.posts.header # use translations
        #     end
        #   end
        # 
        def i18n_set_locale_from(type)
          case type.to_sym
          when :http
            loc = ::R18n::I18n.parse_http(scope.request.env['HTTP_ACCEPT_LANGUAGE'])
          when :session
            loc = session[:locale] if session[:locale]
          when :params
            loc = scope.request.params['locale'] if scope.request.params['locale']
          when :ENV
            # ENV['LANG']="en_US.UTF-8"
            loc = ENV['LANG'].split('.').first if ENV['LANG']
          else
            loc = nil
          end
          # sanity check: set to default locale if not set above
          loc = ::R18n::I18n.default.to_s if loc.nil?
          
          i18n = ::R18n::I18n.new(
            loc, 
            ::R18n.default_places,
            off_filters:  :untranslated, 
            on_filters:   :untranslated_html 
          )
          ::R18n.set(i18n)
        end
        
        # Enables setting temporary :locale blocks within the routing block.
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
          
          i18n = ::R18n::I18n.new(
            locale, 
            ::R18n.default_places, 
            off_filters:  :untranslated, 
            on_filters:   :untranslated_html
          )
          ::R18n.set(i18n)
          yield if block_given?
          # return # NB!! needed to enable routes below to work
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
        def locale(opts = {}, &blk)
          on(':locale', opts) do |l|
            loc = l || self.class.opts[:locale]
            session[:locale] = loc unless session[:locale]
            ::R18n.set(loc)
            yield if block_given?
            return # NB!! needed to enable routes below to work
          end
        end
        alias_method :i18n_locale, :locale
      
      end # /module RequestMethods
      
      
      module ClassMethods
        
        # Return the i18n options for this plugin.
        def i18n_opts
          opts[:i18n]
        end
        
      end # /module ClassMethods
      
      
      # defines method available within the views / routing block
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
      
    end # /module RodaI18n
    
    register_plugin(:i18n, RodaI18n)
  end # /module RodaPlugins
end # /class Roda
