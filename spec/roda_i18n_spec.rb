require_relative 'spec_helper'

describe "i18n - plugin configuration - basic " do
  
  before do
    app(:bare) do
      # setting app[:root] to fixtures directory
      opts[:root] = File.expand_path('../fixtures', __FILE__)
      plugin :i18n
      route do |r| 
        r.is('default/locale')          { erb("<%= ::R18n::I18n.default %>")  } 
        r.is('i18n/available/locales')  { i18n_available_locales              }
        r.is('i18n/default/places')     { erb '<%= i18n_default_places %>'    }
        r.is('t/one')                   { erb("<%= t.one %>")                 }
      end
    end
  end
      
  it "should return the correct default locale 'en' " do
    rt('/default/locale').must_equal "en"
  end
  
  it "should return the correct path to the i18n locales directory" do
    rt('/i18n/default/places').must_equal "#{File.expand_path('../fixtures/i18n', __FILE__)}"
  end
  
  it "should return the correct translation of 't.one' from the default locale (EN)" do
    get '/t/one'
    _body.must_equal "One"
  end
  
end

describe "i18n - plugin configuration - with ':locale => :de' " do
  
  before do
    app(:bare) do
      # setting app[:root] to fixtures directory
      opts[:root] = File.expand_path('../fixtures', __FILE__)
      plugin :i18n, :locale => [:de] #, :translations => "#{File.dirname(__FILE__)}/../spec/**/i18n"
      route do |r| 
        r.is('default/locale')         { erb("<%= ::R18n::I18n.default %>") }
        r.is('i18n/available/locales') { i18n_available_locales             }
        r.is('i18n/default/places')    { erb '<%= i18n_default_places %>'   }
        r.is('t/one')                  { erb("<%= t.one %>")                }
      end
    end
  end
      
  it "should return the correct default locale 'de' " do
    rt('/default/locale').must_equal "de"
  end
  
  it "should return the correct path to the i18n locales directory" do
    rt('/i18n/default/places').must_equal "#{File.expand_path('../fixtures/i18n', __FILE__)}"
  end
  
  it "should return the correct translation of 't.one' from the default locale (DE)" do
    get '/t/one'
    _body.must_equal "Ein"
  end
  
end


describe 'i18n - Translations & Localisations' do
  
  before do
    app(:bare) do
      plugin :i18n, :locale => 'de', :translations => "#{File.dirname(__FILE__)}/../spec/**/i18n"
      route do |r| 
        r.is('l/date') { erb '<%= l Date.parse("October 5, 2011") %>' }
        r.is('l/full') { erb '<%= l Date.parse("October 5, 2011"), :full %>' }
        
        r.is('t/hello')  { erb("<%= t.hello %>") } 
        
        r.is('t/two')  { erb("<%= t.two %>") }
        
        r.is('t/only/in/english') { erb '<%= t.only.english %>' }
        
        r.is('t/do/you/speak/german')  { erb '<%= t.do.you.speak.german %>' }
        r.is('t/do/you/speak/spanish') { erb '<%= t.do.you.speak.spanish %>' }
        r.is('t/do/you/speak/swedish') { erb '<%= t.do.you.speak.swedish %>' }
        r.is('t/do/you/speak/english') { erb '<%= t.do.you.speak.english %>' }
        
        r.is('t/user/count/:num') { |num|  erb '<%= t.user.count(n) %>', :locals => { :n => num.to_i } }
        r.is('t/user/name/:name') { |name| erb '<%= t.user.name(n) %>', :locals => { :n => name } }
        
        r.is('t/as/markdown')     { erb '<%= t.as.md %>' }
        r.is('t/as/html')         { erb '<%= t.as.html %>' }
      end
    end
  end
  
  # LOCALISATION
  it "should correctly translate 'l date'" do
    rt('/l/date').must_equal '05.10.2011'
  end
  
  it "should correctly translate 'l date, :full'" do
    rt('/l/full').must_equal ' 5. Oktober 2011'
  end
  
  # TRANSLATION
  
  it "should correctly load translations from multiple source directories 't.hello'" do
    rt('/t/hello').must_equal "Hallo aus i18n/de.yml"  # loaded from the highest level
  end
  
  it "should correctly translate 't.two'" do
    rt('/t/two').must_equal 'Zwei'
  end
  
  it "should return the default EN translations of 't.only.english' " do
    rt('/t/only/in/english').must_equal "Only in English"
  end
  
  it "should correctly translate 't.user.count' " do
    rt('/t/user/count/1').must_equal "Ist 1 Benutzer"
    rt('/t/user/count/8').must_equal "Es gibt 8 Benutzer"
  end
  
  it "should correctly translate 't.user.name' " do
    rt('/t/user/name/James').must_equal "Benutzername ist James"
  end
  
  it "should return Markdown formatted translations 't.as.md'" do
    rt('/t/as/markdown').must_equal "<p>Hello <strong>Markdown</strong>!</p>\n"
  end
  
  it "should correctly translate 't.as.html' " do
    rt('/t/as/html').must_equal "<h1>Embedded HTML!</h> <p>It just works!</p>"
  end
  
  it "should return an error for a missing translation 't.do.you.speak.swedish' " do
    rt('/t/do/you/speak/swedish').must_equal "do.you.speak.<span style=\"color: red\">[swedish]</span>"
  end
  
end

describe 'i18n - #locale() - set locale based upon route prefix' do
  
  before do
    app(:bare) do
      plugin :i18n, :locale => ['en'], :translations => "#{File.dirname(__FILE__)}/../spec/**/i18n"
      route do |r| 
        r.locale do
          r.is('t/one')  { erb("<%= t.one %>") } 
          r.is('l/date') { erb '<%= l Date.parse("October 5, 2011") %>' }
        end
      end
    end
  end
  
  describe "#locale defined translations" do
    
    it "should return the correct translation of 't.one' for locale ES (Spanish)" do
      rt('/es/t/one').must_equal 'Uno'
    end
    
    it "should return the correct translation of 't.one' for locale SV-SE (Swedish)" do
      rt('/sv-se/t/one').must_equal 'Ett'
    end
    
    it "should return the correct default translation of 't.one' for missing :locales" do
      rt('/my/t/one').must_equal 'One'
    end
    
  end
  
  describe '#locale based localisations' do
    
    it "should correctly translate 'l date' for locale ES (Spanish)" do
      rt('/es/l/date').must_equal '05/10/2011'
    end
  
    it "should correctly translate 'l date' for locale DE (German)" do
      rt('/de/l/date').must_equal '05.10.2011'
    end
    
  end
  
end


describe 'i18n - #i18n_set_locale_from(:session) - obtaining locale from sessions' do
  
  before do
    app(:bare) do
      plugin :i18n, :locale => ['es'], :translations => "#{File.dirname(__FILE__)}/../spec/**/i18n"
      route do |r| 
        r.i18n_set_locale_from(:session)
        r.is('t/one')                   { erb("<%= t.one %>")                 } 
        r.is('t/only/in/english')       { erb '<%= t.only.english %>'         }
        r.is('t/do/you/speak/spanish')  { erb '<%= t.do.you.speak.spanish %>' }
        r.is('t/do/you/speak/german')   { erb '<%= t.do.you.speak.german %>'  }
      end
    end
  end
  
  [ ['sv-se', 'Ett'], ['de','Ein'], ['en', 'One'] ].each do |l|
      
    describe "with session[:locale]='#{l[0]}' " do
      
      it "should return the correct translation of 't.one' " do
        get '/t/one', {},{ 'rack.session' => { :locale => "#{l[0]}" } }
        _body.must_equal "#{l[1]}"
      end
      
    end
    
  end
  
  it "should return the correct translation from the default locale 'es' " do
    get '/t/do/you/speak/spanish', {},{ 'rack.session' => { :locale => 'sv-se'} }
    _body.must_equal '¿Hablas español?'
  end
  
  it "should return a missing translation error for non-loaded locale 'de' " do
    get '/t/do/you/speak/german', {},{ 'rack.session' => { :locale => 'sv-se'} }
    _body.must_equal 'do.you.speak.<span style="color: red">[german]</span>'
  end
  
  it "should return the correct default English translation 't.only.english' " do
    get '/t/only/in/english', {},{ 'rack.session' => { :locale => 'sv-se'} }
    _body.must_equal 'Only in English'
  end
  
end

describe 'i18n - #i18n_set_locale_from(:params) - obtaining locale from params' do
  
  before do
    app(:bare) do
      plugin :i18n, :locale => ['es'], :translations => "#{File.dirname(__FILE__)}/../spec/**/i18n"
      route do |r| 
        r.i18n_set_locale_from(:params)
        r.is('t/one')   { erb("<%= t.one %>") } 
      end
    end
  end
  
  [ ['sv-se', 'Ett'], ['de','Ein'], ['en', 'One'] ].each do |l|
      
    describe "with 'params?locale=#{l[0]}' " do
      
      it "should return the correct translation of 't.one' " do
        get '/t/one', { :locale => "#{l[0]}" }, { 'rack.session' => { } }
        _body.must_equal "#{l[1]}"
      end
      
    end
    
  end
  
end

describe "i18n - #i18n_set_locale_from(:ENV) - obtaining locale from ENV['LANG']" do
  
  before do
    app(:bare) do
      plugin :i18n, :locale => ['es'], :translations => "#{File.dirname(__FILE__)}/../spec/**/i18n"
      route do |r| 
        r.i18n_set_locale_from(:ENV)
        r.is('env')  { erb("<%= ENV['LANG'] %>") } 
        r.is('t/one')  { erb("<%= t.one %>") } 
        r.is('t/two')  { erb("<%= t.two %>") }
        r.is('t/only/in/english') { erb '<%= t.only.english %>' }
        r.is('t/do/you/speak/spanish') { erb '<%= t.do.you.speak.spanish %>' }
        r.is('t/do/you/speak/german') { erb '<%= t.do.you.speak.german %>' }
      end
    end
  end
  
  [ ['sv-se', 'Ett'], ['de','Ein'], ['en', 'One'] ].each do |l|
    
    describe "with 'ENV['LANG']=#{l[0]}' " do
      
      it "should return the correct translation of 't.one' " do
        ENV['LANG'] = "#{l[0]}"
        get '/t/one', { }, { 'rack.session' => { } }
        _body.must_equal "#{l[1]}"
      end
      
    end
  end
  
end

describe "i18n - #i18n_set_locale_from(:http) - obtaining locale from the browser aka HTTP_ACCEPT_LANGUAGE " do
  
  before do
    app(:bare) do
      plugin :i18n, :locale => ['es'], :translations => "#{File.dirname(__FILE__)}/../spec/**/i18n"
      route do |r| 
        r.i18n_set_locale_from(:http)
        r.is('t/one')                  { erb("<%= t.one %>")                 } 
        r.is('t/do/you/speak/german')  { erb '<%= t.do.you.speak.german %>'  }
        r.is('t/do/you/speak/spanish') { erb '<%= t.do.you.speak.spanish %>' }
        r.is('t/do/you/speak/swedish') { erb '<%= t.do.you.speak.swedish %>' }
        r.is('t/do/you/speak/english') { erb '<%= t.do.you.speak.english %>' }
      end
    end
  end
  
  [ 
    ['SV-SE','sv-se;q=1,es;q=0.8,en;q=0.6,de;q=0.2', 'Ett', 'spanish'], 
    ['DE','de;q=1,en-ca,en;q=0.6,en-us;q=0.5','Ein', 'english'], 
    ['EN','en-ca,en;q=0.8,en-us;q=0.6,de-de;q=0.4,de;q=0.2', 'One', 'german'] 
  ].each do |l|
    
    describe "with 'ENV['HTTP_ACCEPT_LANGUAGE'] = #{l[0]}' " do
      
      it "should return the correct translation of 't.one' from the preferred locale " do
        get '/t/one', { }, { 'rack.session' => { }, 'HTTP_ACCEPT_LANGUAGE' => "#{l[1]}" }
        _body.must_equal "#{l[2]}"
      end
      
      it "should return the correct translation from the second priority locale " do
        get "/t/do/you/speak/#{l[3]}", { }, { 'rack.session' => { }, 'HTTP_ACCEPT_LANGUAGE' => "#{l[1]}" }
        _body.wont_equal "do.you.speak.<span style=\"color: red\">[#{l[3]}]</span>"
        _body.wont_match /style="color: red"/
      end
      
    end
  end
end

describe "i18n - #i18n_set_locale_from(:invalid) - obtaining locale from invalid value (defaulting)" do
  
  before do
    app(:bare) do
      plugin :i18n, :locale => ['es'], :translations => "#{File.dirname(__FILE__)}/../spec/**/i18n"
      route do |r| 
        r.i18n_set_locale_from(:invalid_non_existant_value)
        r.is('t/one')   { erb("<%= t.one %>") } 
      end
    end
  end
      
  it "should return the correct translation of 't.one' from the default locale (ES)" do
    get '/t/one'
    _body.must_equal "Uno"
  end
  
end


describe 'i18n - #i18n_set_locale(:locale) - setting a temporary locale within a route block' do
  
  before do
    app(:bare) do
      plugin :i18n, :locale => ['es'], :translations => "#{File.dirname(__FILE__)}/../spec/**/i18n"
      route do |r| 
        r.is('t/hello')  { erb("<%= t.hello %>") } 
        
        r.i18n_set_locale('de') do
          r.is('t/hello/block')  { erb("<%= t.hello %>") }
          r.on('posts/:id') do
            r.on('comments') do
              r.is(':id')  { erb("<%= t.one %>") } 
            end
          end 
        end
        
      end
    end
  end
      
  it "should return the correct translation from the default locale 'es' " do
    get '/t/hello'
    _body.must_equal 'Hola de app/i18n/es.yml'
  end
  
  it "should return the correct translation from the temporary scope locale 'de' " do
    get '/t/hello/block'
    _body.must_equal "Hallo aus i18n/de.yml"
  end
  
  it "should return the correct translation from the temporary scope locale 'de' deeply nested routes " do
    get '/posts/10/comments/20'
    _body.must_equal "Ein"
  end
  
end


describe 'i18n - Instance & Class Methods' do
  before do
    app(:bare) do
      plugin :i18n, :locale => ['es','de','sv-se'], :translations => "#{File.dirname(__FILE__)}/../spec/**/i18n"
      plugin :json
      route do |r| 
        r.is('i18n/opts')               { self.class.i18n_opts              }
        r.is('i18n/available/locales')  { i18n_available_locales            }
        r.is('i18n/default/places')     { erb '<%= i18n_default_places %>'  }
      end
    end
  end
  
  it "#i18n_available_locales should return available locales as an array" do
    rt('/i18n/available/locales').must_equal "[[\"de\",\"Deutsch\"],[\"en\",\"English\"],[\"es\",\"Español\"],[\"sv-SE\",\"Svenska\"]]"
  end
  
  it "#i18n_default_places should return the locations load path" do
    rt('/i18n/default/places').must_match /\/\.\.\/spec\/\*\*\/i18n/ 
  end
  
  it "#i18n_opts should return an array of configuration options" do
    rt('/i18n/opts').must_match /"default_locale":"es"/ 
  end
  
end
