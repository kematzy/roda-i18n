require 'r18n-core'

class Roda
  module RodaPlugins
    # The i18n plugin allows you to easily add internationlisation and
    # localisation support to your app.
    # 
    # By default the locale is set to `'en'` and the translations directory 
    # is set to `'i18n'` in the rooot of your app.
    # 
    # Both `:locale` and `:translations` can be overridden during configuration:
    #    
    #    plugin :i18n, :locale => 'de', :translations => 'path/2/i18n'
    #    
    # Naturally we can allow browsers to override the default locale within routes, like this:
    #   
    #     route do |r|
    #       i18n_set_locale #=> set to the browser's default locale (en-US)
    #       r.get '' do
    #         t.hello  #=> 'Howdy, I speak American English'
    #       end
    #       
    #       i18n_set_locale('de')
    #       r.get 'in-german' do
    #         t.hello  #=> 'Guten tag, ich spreche deutsch'
    #       end
    #       
    #     end
    #   
    # 
    # More information about [R18n](https://github.com/ai/r18n/tree/master/r18n-core)
    # 
    # 
    module RodaI18n
      OPTS={}.freeze
      
      def self.load_dependencies(app, opts=OPTS)
        # app.plugin :render
        app.plugin :environments
      end
      
      def self.configure(app, opts=OPTS)
        # app.opts[:root] = Dir.pwd unless app.opts[:root]
        
        if app.opts[:i18n]
          opts = app.opts[:i18n][:orig_opts].merge(opts)
        end
        app.opts[:i18n] = opts.dup
        app.opts[:i18n][:orig_opts] = opts
        
        opts = app.opts[:i18n]
        
        # set default locale
        opts[:locale] = 'en' unless opts[:locale]
        ::R18n::I18n.default = opts[:locale][0]
        
        # set default translations
        if opts[:translations]
          _dt = opts[:translations]
        else
          _dt = app.opts[:root] ? File.join( app.opts[:root],'i18n') : "#{Dir.pwd}/i18n"
        end
        ::R18n.default_places { _dt }
        opts[:translations] = ::R18n.default_places
        
        opts.freeze
        
        # set within the current thread
        ::R18n.thread_set do
          ::R18n.clear_cache! if app.development?
          # ::R18n.set(opts[:locale], opts[:translations])
          ::R18n::I18n.new(opts[:locale], opts[:translations],
             :off_filters => :untranslated, :on_filters => :untranslated_html)
        end
        
      end
      
      # module RequestMethods
      #
      #   # TODO: interesting idea, but not sure how to do it
      #   #
      #   # Concept:
      #   #
      #   #   route do |r|
      #   #     r.i18n_locale do
      #   #       # all routes are prefixed with '/:locale'
      #   #     end
      #   #   end
      #   #
      #   def i18n_locale(&blck)
      #     on ':locale' do |locale|
      #       @_locale = locale || "en"
      #       params[:locale] = locale
      #       
      #       super(&blck)
      #     end
      #     
      #   end
      #
      # end #/module RequestMethods
      
      module ClassMethods
        
        # Return the i18n options for this class.
        def i18n_opts
          opts[:i18n]
        end
        
      end #/module ClassMethods
      
      module InstanceMethods
        include ::R18n::Helpers
        
        # get browser locale and respect that
        def i18n_get_locale(locale=nil)
          ::R18n.thread_set do
            locales = ::R18n::I18n.parse_http(request.env['HTTP_ACCEPT_LANGUAGE'])
            if locale.nil?
              if request.params[:locale]
                locales.insert(0, request.params[:locale])
              elsif request.session[:locale]
                locales.insert(0, request.session[:locale])
              end
            else
              locales.insert(0, locale)
            end
            ::R18n::I18n.new(locales, ::R18n.default_places,
               :off_filters => :untranslated, :on_filters => :untranslated_html)
               
          end#/thread_set
        end
        
        def i18n_available_locales
          ::R18n.available_locales
        end
        
        def i18n_default_places
          ::R18n.default_places
        end
        
      end
      
    end #/module RodaI18n
    
    register_plugin(:i18n, RodaI18n)
  end #/module RodaPlugins
end #/class Roda