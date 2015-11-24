require_relative '../spec_helper'


class Rodai18nTests < Minitest::Spec

  describe Roda do
  
    describe 'RodaPlugins' do
    
      describe 'RodaI18n => :i18n' do
      
        describe ':i18n opts' do
          
          describe 'default settings' do
            before do
              @a = Class.new(Roda)
              @a.opts[:root] = File.expand_path('../../../',__FILE__)
              @a.plugin(:i18n)
            end
            
            describe 'opts' do
              
              it 'should set :locale to "en"' do
                @a.i18n_opts[:locale].must_equal 'en'
              end
            
              it 'should set :default_locale to "en"' do
                @a.i18n_opts[:default_locale].must_equal 'en'
              end
            
              it 'should set :translations to be set to default path' do
                @a.i18n_opts[:translations].must_match %r{/roda-i18n/i18n$}
              end
              
            end
            
            describe '::R18n' do
              
              it 'should set ::R18n.default_places to the "i18n" folder in the root of the app' do
                ::R18n.default_places.must_equal File.join( @a.opts[:root],'i18n')
                ::R18n.default_places.must_match %r{/roda-i18n/i18n$}
              end
            
              it 'should set ::R18n.available_locales to [] (empty)' do
                ::R18n.available_locales.must_equal([]) # no locales found at ../roda-i18n/i18n
              end
              
            end
            
          end
        
          describe 'custom settings' do
            before do
              @b = Class.new(Roda)
              @b.opts[:root] = File.expand_path('../../../',__FILE__)
            end
            
            describe 'with different values for :locale & :default_locale' do
              before do
                @b.plugin(:i18n, locale: :de, default_locale: 'sv-se')
              end
              
              describe 'opts' do
                
                it 'should set :locale to :de' do
                  @b.i18n_opts[:locale].must_equal :de
                end
              
                it 'should set :default_locale to "sv-se"' do
                  @b.i18n_opts[:default_locale].must_equal 'sv-se'
                end
              
                it 'should set :translations to be set to the default path' do
                  @b.i18n_opts[:translations].must_match %r{/roda-i18n/i18n$}
                end
                
              end
              
              describe '::R18n' do
              
                it 'should set ::R18n.default_places to the "i18n" folder in the root of the app' do
                  ::R18n.default_places.must_equal File.join( @b.opts[:root],'i18n')
                  ::R18n.default_places.must_match %r{/roda-i18n/i18n$}
                end
            
                it 'should set ::R18n.available_locales to [] (empty)' do
                  ::R18n.available_locales.must_equal([]) # no locales found at ../roda-i18n/i18n
                end
              
              end
              
            end
            
            describe 'with an array passed to :locale' do
              before do
                @b.plugin(:i18n, locale: [:es, :de, 'sv-se'])
              end
              
              describe 'opts' do
                
                it 'should set :locale to [:es,:de, "sv-se"]' do
                  @b.i18n_opts[:locale].must_equal([:es,:de, 'sv-se'])
                end
              
                it 'should retain the :default_locale' do
                  @b.i18n_opts[:default_locale].must_equal 'en'
                end
              
                it 'should set :translations to the correct location' do
                  @b.i18n_opts[:translations].must_match %r{/roda-i18n/i18n}
                end
                
              end
              
              describe '::R18n' do
                
                it 'should set ::R18n.default_places to the "i18n" folder in the root of the app' do
                  ::R18n.default_places.must_equal File.join( @b.opts[:root],'i18n')
                  ::R18n.default_places.must_match %r{/roda-i18n/i18n$}
                end
            
                it 'should set ::R18n.available_locales to [] (empty)' do
                  ::R18n.available_locales.must_equal([]) # no locales found at ../roda-i18n/i18n
                end
                
              end
              
            end
            
            describe 'setting default locale' do
              
              it 'should keep default :default_locale :en when not set' do
                @d1 = Class.new(Roda)
                @d1.plugin(:i18n)
                @d1.i18n_opts[:default_locale].must_equal 'en'
              end
              
              it 'should retain the :default_locale :en when an array is passed to :locale ' do
                @d2 = Class.new(Roda)
                @d2.plugin(:i18n, locale: [:de, :es, 'sv-se'])
                @d2.i18n_opts[:default_locale].must_equal 'en'
              end

              it 'should set :default_locale value to passed config value' do
                @d3 = Class.new(Roda)
                @d3.plugin(:i18n, default_locale: 'sv-se')
                @d3.i18n_opts[:default_locale].must_equal 'sv-se'
              end
                            
              it 'should keep default :default_locale :en when set to nil' do
                @d4 = Class.new(Roda)
                @d4.plugin(:i18n, default_locale: nil)
                @d4.i18n_opts[:default_locale].must_equal 'en'
              end
              
              it 'should keep default :default_locale :en when set to " "' do
                @d5 = Class.new(Roda)
                @d5.plugin(:i18n, default_locale: ' ')
                @d5.i18n_opts[:default_locale].must_equal 'en'
              end
              
            end
            
            describe 'with :translations: passed' do
              before do
                @b.plugin(:i18n, translations: File.expand_path('../../fixtures', __FILE__))
              end
              
              describe 'opts' do
                
                it 'should set :translations to the spec/fixtures folder' do
                  @b.i18n_opts[:translations].must_match %r{/roda-i18n/spec/fixtures}
                end
                
              end
              
              describe '::R18n' do
                
                it 'should set ::R18n.default_places to the "spec/fixtures" folder' do
                  ::R18n.default_places.must_equal File.join( @b.opts[:root],'spec', 'fixtures')
                  ::R18n.default_places.must_match %r{/roda-i18n/spec/fixtures$}
                end
            
                it 'should ::R18n.available_locales include four locales [de, en, es, sv-SE]' do
                  ::R18n.available_locales.must_be_kind_of(Array)
                  ::R18n.available_locales.first.must_be_kind_of(::R18n::Locale)
                  
                  ::R18n.available_locales[0].code.must_equal 'de'
                  ::R18n.available_locales[1].code.must_equal 'en'
                  ::R18n.available_locales[2].code.must_equal 'es'
                  ::R18n.available_locales[3].code.must_equal 'sv-SE'
                end
                
              end
              
            end
            
          end #/ custom settings
          
          describe 'double loading of plugin' do
            before do
              @c = Class.new(Roda)
              @c.plugin(:i18n, locale: ['de'], default_locale: 'es')
              @d = Class.new(@c)
              @d.plugin(:i18n, default_locale: 'sv-se')
            end
            
            it 'should retain the settings from the second load' do
              @c.i18n_opts[:locale].must_equal ['de']
              @c.i18n_opts[:default_locale].must_equal 'es'
              
              @d.i18n_opts[:locale].must_equal ['de']
              @d.i18n_opts[:default_locale].must_equal 'sv-se'
              # @d.i18n_opts.must_equal 'es'
            end
            
          end # /double loading
          
        end # /opts
        
        describe 'Request Methods' do
          
          describe '#i18n_set_locale_from(:type)' do
            
            describe 'when given an invalid value' do
              
              before do
                i18n_set_locale_from_app('es', :invalid)
              end
              
              it 'should use config :locale (:es) in routes above :i18n_set_locale_from() call' do
                body('/').must_equal 'Hola de app/i18n/es.yml'
                body('/one').must_equal 'Uno'
              end
              
              it 'should use config :default_locale (:en) below :i18n_set_locale_from() call' do
                body('/locale').must_equal 'Hello from ./i18n/en.yml'
                body('/locale/one').must_equal 'One'
              end
              
            end
            
            describe 'when given an invalid value and an array of locales' do
              
              before do
                i18n_set_locale_from_app(['de'], :invalid)
              end
              
              it 'should use config :locale (:de) in routes above :i18n_set_locale_from() call' do
                body('/').must_equal 'Hallo aus i18n/de.yml'
                body('/one').must_equal 'Ein'
              end
              
              it 'should use config :default_locale (:en) below :i18n_set_locale_from() call' do
                body('/locale').must_equal 'Hello from ./i18n/en.yml'
                body('/locale/one').must_equal 'One'
              end
              
            end
            
            describe 'when given :http - locale=(de|es|sv-se)' do
              
              [
                {
                  conf:     nil,
                  one:      'One',
                  env:      nil,
                  http:     nil,
                  lng:      'english',
                  lng_res:  'Do you speak English?'
                },
                # EN -> DE
                {
                  conf:     'en',
                  one:      'One',
                  env:      'DE',
                  http:     'en;q=1,de;q=0.8,en;q=0.6,de;q=0.2',
                  lng:      'german',
                  lng_res:  'Sprechen Sie Deutsch?'
                },
                # EN -> ES
                {
                  conf:     'en',
                  one:      'One',
                  env:      'ES',
                  http:     'en;q=1,es;q=0.8,sv-se;q=0.6,de;q=0.2',
                  lng:      'spanish',
                  lng_res:  '¿Hablas español?'
                },
                # EN -> SV-SE
                {
                  conf:     'en',
                  one:      'One',
                  env:      'SV-SE',
                  http:     'en;q=1,sv-se;q=0.8,es;q=0.6,de;q=0.2',
                  lng:      'swedish',
                  lng_res:  'Pratar du svenska?'
                },
                # SV-SE -> DE
                {
                  conf:     'sv-se',
                  one:      'Ett',
                  env:      'DE',
                  http:     'sv-se;q=1,de;q=0.8,en;q=0.6,de;q=0.2',
                  lng:      'german',
                  lng_res:  'Sprechen Sie Deutsch?'
                },
                # DE -> SV-SE
                {
                  conf:     'de',
                  one:      'Ein',
                  env:      'SV-SE',
                  http:     'de;q=1,sv-se;q=0.8,en;q=0.6,de;q=0.2',
                  lng:      'swedish',
                  lng_res:  'Pratar du svenska?'
                },
                # ES -> EN
                {
                  conf:     'es',
                  one:      'Uno',
                  env:      'EN',
                  http:     'es;q=1,en_CA,en;q=0.6,en-us;q=0.5',
                  lng:      'english',
                  lng_res:  'Do you speak English?'
                },
                # ES -> SV-SE
                {
                  conf:     'es',
                  one:      'Uno',
                  env:      'SV-SE',
                  http:     'es;q=1,sv-se;q=0.6,en-us;q=0.5',
                  lng:      'swedish',
                  lng_res:  'Pratar du svenska?'
                },
                # SV-SE -> ES
                {
                  conf:     'sv-se',
                  one:      'Ett',
                  env:      'ES',
                  http:     'sv-se;q=1,es;q=0.6,en-us;q=0.5',
                  lng:      'spanish',
                  lng_res:  '¿Hablas español?'
                }
              ].each do |h|

                describe "with 'ENV['HTTP_ACCEPT_LANGUAGE'] = #{h[:env]}' " do

                  before do
                    i18n_set_locale_from_app(h[:conf], :http)
                  end

                  it "should return the correct translation from the preferred locale " do
                    get '/one', {}, set_req({}, h[:http])
                    _body.must_equal h[:one]
                  end

                  it "should return the correct translation from the second priority locale " do
                    get "/locale/#{h[:lng]}", {}, set_req({}, h[:http])
                    _body.wont_equal %Q{do.you.speak.<span style="color: red">[#{h[:lng.to_s]}]</span>}
                    _body.must_equal h[:lng_res]
                  end

                end # / ENV HTTP_ACCEPT_LANGUAGE

              end
                            
            end
                      
            describe 'when given :params - url/?locale=(de|es|sv-se)' do
              
              before do
                i18n_set_locale_from_app('de', :params)
              end
              
              it 'should use config :locale (:de) in routes above :i18n_set_locale_from() call' do
                get '/'
                _body.must_equal 'Hallo aus i18n/de.yml'
                get '/one'
                _body.must_equal 'Ein'
              end
              
              it 'should ignore passed ?locale=:es in routes above :i18n_set_locale_from() call' do
                get '/', { locale: 'es' }
                _body.must_equal 'Hallo aus i18n/de.yml'
                get '/one', { locale: 'es' }
                _body.must_equal 'Ein'
              end
              
              it 'should use passed ?locale=[:es,"sv-se"] below :i18n_set_locale_from() call' do
                get '/locale', { locale: 'es' }, set_req({}, '')
                _body.must_equal 'Hola de app/i18n/es.yml'
                get '/locale/one', { locale: 'es' }, set_req({}, '')
                _body.must_equal 'Uno'
                
                get '/locale', { locale: 'sv-se' }, set_req({}, '')
                _body.must_equal 'Hej från ./i18n/sv-se.yml'
              end
              
            end
                      
            describe 'when given :session - { locale: (de|es|sv-se) }' do
              
              before do
                i18n_set_locale_from_app('de', :session)
              end
              
              it 'should use config :locale (:de) when session {locale: nil} above method call' do
                get '/', {}, {'rack.session' => {locale: nil}}
                _body.must_equal 'Hallo aus i18n/de.yml'
                get '/one', {}, {'rack.session' => {locale: nil}}
                _body.must_equal 'Ein'
              end
              
              it 'should ignore session {locale: :es} in routes above :i18n_set_locale_from() call' do
                get '/', {}, {'rack.session' => {locale: 'es'}}
                _body.must_equal 'Hallo aus i18n/de.yml'
                get '/one', {}, {'rack.session' => {locale: 'es'}}
                _body.must_equal 'Ein'
              end
              
              it 'should use session { locale :es } in routes below :i18n_set_locale_from() call' do
                get '/locale', {}, {'rack.session' => {locale: 'es'}}
                _body.must_equal 'Hola de app/i18n/es.yml'
                get '/locale/one', {}, {'rack.session' => {locale: 'es'}}
                _body.must_equal 'Uno'
                
                get '/locale', {}, {'rack.session' => {locale: 'sv-se'}}
                _body.must_equal 'Hej från ./i18n/sv-se.yml'
              end
              
              it 'default to { :default_locale :de } when no session { locale: } is passed' do
                body('/').must_equal 'Hallo aus i18n/de.yml'
                body('/one').must_equal 'Ein'
                body('/locale').must_equal 'Hello from ./i18n/en.yml'
                body('/locale/one').must_equal 'One'
              end
              
            end
                      
            describe 'when given :ENV - obtains locale from ENV["LANG"]' do
              
              [
                { env: nil,     app: nil,         one: 'One', l_one: 'One' },
                { env: 'de',    app: ['en'],      one: 'One', l_one: 'Ein' },
                { env: 'de',    app: ['en'],      one: 'One', l_one: 'Ein' },
                { env: 'es',    app: ['en'],      one: 'One', l_one: 'Uno' },
                { env: 'sv-se', app: ['de','en'], one: 'Ein', l_one: 'Ett' }
              ].each do |h|
                
                describe "when ENV['LANG']=#{h[:env]}" do
                  
                  before do
                    ENV['LANG'] = h[:env]
                    i18n_set_locale_from_app(h[:app], :ENV)
                  end
                  
                  it "should use config locale in routes above :i18n_set_locale_from() call" do
                    get '/one'
                    _body.must_equal h[:one]
                  end
                  
                  it "should use ENV['LANG'] in routes below :i18n_set_locale_from() call" do
                    get '/locale/one'
                    _body.must_equal h[:l_one]
                  end
                  
                end
                
              end #/ each
              
            end # / :env
            
          end # /i18n_set_locale_from
          
          describe '#i18n_set_locale' do
            
            describe 'setting a temporary locale within a route block' do
              
              before do
                                 # (loc, set_loc, set_loc2)
                i18n_set_locale_app(['es'], 'de', 'sv-se')
              end

              it "should return the correct translation from the default locale 'es' " do
                body('/').must_equal 'Hola de app/i18n/es.yml'
              end

              it "should return translation from temporary scope locale 'de'" do
                body('/t/hello').must_equal "Hallo aus i18n/de.yml"
              end

              it "should return translation from temporary scope locale 'de' in nested routes " do
                body('/posts/10/comments/20').must_equal "'10' kommentare zum '20'"
                body('/posts/4/comments/16').must_equal "'4' kommentare zum '16'"
              end
              
              it "should return translation from the second temporary locale scope 'sv-se'" do
                body('/t/2/hello').must_equal 'Hej från ./i18n/sv-se.yml'
              end
              
            end
            
          end #/ #i18n_set_locale
          
          describe '#locale - alias #i18n_locale' do
            
            describe 'set locale based upon route prefix' do

              before do
                i18n_locale_app(['en'])
              end
              
              describe 'above #locale block' do
                
                it 'should return the correct translations' do
                  rt('/').must_equal 'One'
                  rt('/one').must_equal 'One'
                end
                
              end # /above
              
              describe 'within #locale block' do
                
                it 'should return the correct translation' do
                  rt('en/t').must_equal 'One'
                  rt('es/t').must_equal 'Uno'
                  rt('de/t').must_equal 'Ein'
                  rt('sv-se/t').must_equal 'Ett'
                end
                
                it 'should return the correct localisation' do
                  rt('/en/l').must_equal '05/10/2011'
                  rt('/es/l').must_equal '05/10/2011'
                  rt('/de/l').must_equal '05.10.2011'
                  rt('/sv-se/l').must_equal '2011-10-05'
                end
                
              end # /within
              
              describe 'after #locale block' do
                
                it 'should return the correct translations' do
                  rt('/two').must_equal 'Two'
                end
                
              end # /after

            end # /route prefix
            
          end # /#locale
          
        end
        
        describe 'Class Methods' do
          
          describe '#.i18n_opts' do
            
            it 'should return the opts[:i18n]' do
              i18n_app('<%= self.class.i18n_opts[:locale] %>').must_equal 'en'
              i18n_app('<%= self.class.i18n_opts[:default_locale] %>').must_equal 'en'
            end
              
          end
          
        end
        
        describe 'Instance Methods' do
          
          before do
            @t_path = "#{File.dirname(__FILE__)}/../../spec/**/i18n"
            @de_opts  = { locale: 'de',    translations: @t_path }
            @es_opts  = { locale: 'es',    translations: @t_path }
            @en_opts  = { locale: 'en',    translations: @t_path }
            @sv_opts  = { locale: 'sv-se', translations: @t_path }
          end
          
          describe 'Localisations - :l()' do
            
            describe '#:l date' do
              
              it 'should be correctly translated in all locales [en,de,es,sv-se]' do
                i18n_app('<%= l Date.parse("October 5, 2011") %>', {}, @en_opts)
                  .must_equal '05/10/2011'
                i18n_app('<%= l Date.parse("October 5, 2011") %>', {}, @de_opts)
                  .must_equal '05.10.2011'
                i18n_app('<%= l Date.parse("October 5, 2011") %>', {}, @es_opts)
                  .must_equal '05/10/2011'
                i18n_app('<%= l Date.parse("October 5, 2011") %>', {}, @sv_opts)
                  .must_equal '2011-10-05'
              end
              
            end
            
            describe '#:l date, :full' do
              
              it 'should be correctly translated in all locales [en,de,es,sv-se]' do
                i18n_app('<%= l Date.parse("October 5, 2011"), :full %>', {}, @en_opts)
                  .must_equal '5th of October, 2011'
                i18n_app('<%= l Date.parse("October 5, 2011"), :full %>', {}, @de_opts)
                  .must_equal ' 5. Oktober 2011'
                i18n_app('<%= l Date.parse("October 5, 2011"), :full %>', {}, @es_opts)
                  .must_equal '05 de Octubre de 2011'
                i18n_app('<%= l Date.parse("October 5, 2011"), :full %>', {}, @sv_opts)
                  .must_equal ' 5 oktober 2011 2011' # TODO: fix this bug in R18n
              end
              
            end
            
          end
          
          describe 'Translations - :t()' do
            
            describe 't.hello - loading translations from multiple source directories' do
              
              it 'should load translation from highest level directory for German (DE)' do
                i18n_app('<%= t.hello %>', {}, @de_opts)
                  .must_equal "Hallo aus i18n/de.yml"  # loaded from the highest level
              end
            
              it 'should load translation from app/i18n/ directories for Spanish (ES)' do
                i18n_app('<%= t.hello %>', {}, @es_opts)
                  .must_equal 'Hola de app/i18n/es.yml'  # loaded from the second level
              end
              
            end
            
            describe 't.two' do
              
              it 'should be correctly translated in all locales [en,de,es,sv-se]' do
                i18n_app('<%= t.two %>', {}, @de_opts).must_equal 'Zwei'
                i18n_app('<%= t.two %>', {}, @es_opts).must_equal 'Dos'
                i18n_app('<%= t.two %>', {}, @en_opts).must_equal 'Two'
                i18n_app('<%= t.two %>', {}, @sv_opts).must_equal 'Två'
              end
              
            end
            
            describe 't.only.english' do
              
              it 'should return the default EN translations for [de,es,sv-se] locales' do
                i18n_app('<%= t.only.english %>', {}, @de_opts).must_equal 'Only in English'
                i18n_app('<%= t.only.english %>', {}, @es_opts).must_equal 'Only in English'
                i18n_app('<%= t.only.english %>', {}, @sv_opts).must_equal 'Only in English'
              end
              
            end
            
            describe 't.user.count(n) - countable param' do
              
              it "should be correctly translated in all locales [en,de,es,sv-se] " do
                i18n_app('<%= t.user.count(1) %>', {}, @en_opts).must_equal 'There is 1 user'
                i18n_app('<%= t.user.count(8) %>', {}, @en_opts).must_equal 'There are 8 users'
                
                i18n_app('<%= t.user.count(1) %>', {}, @de_opts).must_equal 'Ist 1 Benutzer'
                i18n_app('<%= t.user.count(8) %>', {}, @de_opts).must_equal 'Es gibt 8 Benutzer'
                
                i18n_app('<%= t.user.count(1) %>', {}, @es_opts).must_equal 'Hay 1 usuario'
                i18n_app('<%= t.user.count(88) %>', {}, @es_opts).must_equal 'Hay 88 usuarios'

                i18n_app('<%= t.user.count(1) %>', {}, @sv_opts).must_equal 'Det finns en användare'
                i18n_app('<%= t.user.count(99) %>', {}, @sv_opts).must_equal 'Det finns 99 användare'
              end
              
            end
            
            describe 't.user.name(:name) - single string param' do
              
              it "should be correctly translated in all locales [en,de,es,sv-se] " do
                i18n_app('<%= t.user.name("Joe") %>',    {}, @en_opts).must_equal 'User name is Joe'
                i18n_app('<%= t.user.name("Herman") %>', {}, @de_opts).must_equal 'Benutzername ist Herman'
                i18n_app('<%= t.user.name("Pedro") %>',  {}, @es_opts).must_equal 'Nombre de usuario es Pedro'
                i18n_app('<%= t.user.name("Sven") %>',   {}, @sv_opts).must_equal 'Användarnamn är Sven'
              end
              
            end
            
            describe 't.params(:one, :two, :three) - multiple mixed params' do
              
              it "should be correctly translated in all locales [en,de] " do
                i18n_app('<%= t.params(:a, :d, :f) %>', {}, @en_opts).must_equal 'Is f between a and d?'
                i18n_app('<%= t.params(:a, :d, 10) %>', {}, @de_opts).must_equal 'Ist 10 zwischen a und d?'
              end
              
            end
            
            describe 't.as.md - Markdown formatted translations' do
              
              it 'should be correctly translated Markdown into HTML' do
                i18n_app('<%= t.as.md %>', {}, @en_opts)
                  .must_equal "<p>Hello <strong>Markdown</strong>!</p>\n"
              end
              
            end
            
            describe 't.as.html - Embedded HTML formatted translations' do
              
              it 'should be correctly translated as HTML' do
                i18n_app('<%= t.as.html %>', {}, @en_opts)
                  .must_equal "<h1>Embedded HTML!</h> <p>It just works!</p>"
              end
              
            end
            
            describe 'missing translations handling' do
              
              it "should return an error for a missing translation" do
                i18n_app('<%= t.do.you.speak.swedish %>', {}, @en_opts)
                  .must_equal "do.you.speak.<span style=\"color: red\">[swedish]</span>"
              end
              
            end
            
            describe 'default locale fallbacks' do
              
              describe 't.robots(:num)' do
                
                it 'should fallback to default locale [sv-se] if missing' do
                  i18n_app('<%= t.do.you.speak.swedish %>', {}, @de_opts.merge!(default_locale: 'sv-se'))
                    .must_equal "Pratar du svenska?"
                end
                
              end
              
            end
            
            describe 'supports multiple locales via config' do
              
              before do
                @conf = { translations: @t_path }
              end
              
              describe %Q{when locale: ['sv-se','de','es', 'en']} do
                
                before do
                  @conf.merge!(locale: ['sv-se','de','es', 'en'])
                end
                
                it 'should support translation from :locale "sv-se"' do
                  i18n_app('<%= t.do.you.speak.swedish %>', {}, @conf)
                    .must_equal 'Pratar du svenska?'
                end
                
                it 'should support translation from :locale "de"' do
                  i18n_app('<%= t.do.you.speak.german %>', {}, @conf)
                    .must_equal 'Sprechen Sie Deutsch?'
                end
                
                it 'should support translation from :locale "es"' do
                  i18n_app('<%= t.do.you.speak.spanish %>', {}, @conf)
                    .must_equal '¿Hablas español?'
                end
                
                it 'should support translation from :locale "en"' do
                  i18n_app('<%= t.do.you.speak.english %>', {}, @conf)
                    .must_equal 'Do you speak English?'
                end
                
              end
              
              describe %Q{when locale: ['sv-se','de']} do
                
                before do
                  @conf.merge!(locale: ['sv-se','de'], default_locale: 'sv-se')
                end
                
                it 'should support translation from :locale "sv-se"' do
                  i18n_app('<%= t.do.you.speak.swedish %>', {}, @conf)
                    .must_equal 'Pratar du svenska?'
                end
                
                it 'should support translation from :locale "de"' do
                  i18n_app('<%= t.do.you.speak.german %>', {}, @conf)
                    .must_equal 'Sprechen Sie Deutsch?'
                end
                
                it 'should NOT support translation from :locale "es"' do
                  i18n_app('<%= t.do.you.speak.spanish %>', {}, @conf)
                    .must_equal 'do.you.speak.<span style="color: red">[spanish]</span>'
                end
                
                it 'should still support translation from :locale "en" somehow??' do
                  i18n_app('<%= t.do.you.speak.english %>', {}, @conf)
                    .must_equal 'Do you speak English?'
                end
                
              end
              
              
            end
            
          end
          
          describe '#i18n_default_places' do
            
            it 'should set path to the "i18n" folder in the root of the app' do
              i18n_app('<%= i18n_default_places %>').must_equal File.expand_path('../../../i18n', __FILE__)
              i18n_app('<%= i18n_default_places %>').must_equal ::R18n.default_places
            end
            
          end
          
          describe '#i18n_available_locales' do
            
            it 'should return an empty array when no locales are found' do
              i18n_app('<%= i18n_available_locales %>').must_equal("[]")
            end
            
            it 'should return an array when locales are found' do
              o = i18n_app('<%= i18n_available_locales %>', {}, { translations: @t_path })
              o.must_match /\["de", "Deutsch"\]/
              o.must_match /\["en", "English"\]/
              o.must_match /\["es", "Español"\]/
              o.must_match /\["sv-SE", "Svenska"\]/
            end
            
          end
          
          describe '#i18n_opts' do
            
            before do
              @c = Class.new(Roda)
              @c.opts[:root] = File.expand_path('../spec/fixtures',__FILE__)
              @c.plugin(:i18n)
            end
            
            it 'should return a Hash of options' do
              @c.i18n_opts.must_be_kind_of(Hash)
              @c.i18n_opts.wont_be_nil
            end
            
          end
          
        end
      
      end
    
    end
  
  end
  
end