require_relative 'spec_helper'
# loading app here to set load paths to fixtures
require_relative 'fixtures/app'

describe TestApp do
  include Rack::Test::Methods
  
  def app
    TestApp
  end
  
  context 'Defaults' do
    
    context 'configurations' do
      
      context '.i18n_opts' do
        
        it ":locale should be 'en'" do
          expect(app.i18n_opts).to include(:locale)
          expect(app.i18n_opts[:locale]).to eq('en')
        end
        
        it ":translations should be '../spec/fixtures/i18n'" do
          expect(app.i18n_opts).to include(:translations)
          expect(app.i18n_opts[:translations]).to eq("#{Dir.pwd}/spec/fixtures/i18n")
        end
        
      end
      
    end
      
    context 'translations' do
      
      it 'should work correctly in routes' do
        { 'en' => "Only in English", 
          'de' => 'Nein, nicht auf Englisch', 
          'sv-se' => 'Nej, inte på engelska'
        }.each do |k,v|
          get "/#{k}/test"
          expect(_status).to eq(200)
          expect(_body).to eq(v)
        end
      end
      
      it 'should work correctly in rendered views' do
        get '/en/posts/0'
        expect(_status).to eq(200)
        expect(_body).to have_tag('h1',:text => "Blog post: 'Roda: The ruby web framework'")
        expect(_body).to have_tag('p', :text => "no comments for 'Roda: The ruby web framework'")
        
        get '/de/posts/1'
        expect(_status).to eq(200)
        expect(_body).to have_tag('p', :text => "einen kommentar 'Roda: The ruby web framework'")
        
        get '/sv-se/posts/99'
        expect(_status).to eq(200)
        expect(_body).to have_tag('p', :text => "99 kommentarer för 'Roda: The ruby web framework'")
      end
      
    end
    
    context 'InstanceMethods' do
      
      context '.r18n' do
      
        it "'r18n.locale.title' should return the correct locale" do
          { 'en' => "English", 'de' => 'Deutsch', 'sv-se' => 'Svenska'}.each do |k,v|
            get "/#{k}/locale"
            expect(_status).to eq(200)
            expect(_body).to eq(v)
          end
        end
      
        it 'should return all available locales' do
          get '/en/locales'
          expect(_status).to eq(200)
          expect(_body).to eq("de: Deutsch; en: English; sv-SE: Svenska")
        end
      
      end
    
      context '.l ' do
        
        it 'should format date & time correctly' do
          { 'en' => "01/03/2015 00:00", 'de'=>'01.03.2015 00:00', 'sv-se'=>'2015-03-01 00:00'}.each do |k,v|
            get "/#{k}/time"
            expect(_status).to eq(200)
            expect(_body).to eq(v)
          end
        end
        
        it 'should format month names correctly' do
          { 'en' => 'March', 'de'=>'März', 'sv-se'=>'mars'}.each do |k,v|
            get "/#{k}/month"
            expect(_status).to eq(200)
            expect(_body).to eq(v)
          end
        end
        
      end
    
      context '.t' do
      
        it 'should handle HTML formatted translations' do
          get '/en/html'
          expect(_status).to eq(200)
          expect(_body).to eq("<b>It works!</b>")
        end
        
        it 'should handle missing translations' do
          get '/en/untranslated'
          expect(_status).to eq(200)
          expect(_body).to eq('post.<span style="color: red">[no]</span>')
        end
      
      end
      
    end
    
  end
  
end

describe 'CustomApp' do
  include Rack::Test::Methods
  
  context 'Custom configuration' do
    before do
      app(:bare) do
        opts[:root] = File.expand_path('../fixtures', __FILE__)
        # plugin :error_handler
        plugin :i18n, :locale => 'es', :translations => "#{Dir.pwd}/spec/fixtures/app/i18n"
        
        route do |r|
          r.get 'do-you-speak-english' do
            t.do.you.speak.english
          end
          r.get 'hello' do
            t.hello
          end
        end
      end
      
    end
    
    context 'configurations' do
      
      context '.i18n_opts' do
        
        it ":locale should be 'es'" do
          expect(app.i18n_opts).to include(:locale)
          expect(app.i18n_opts[:locale]).to eq('es')
        end
        
        it ":translations should be '../spec/fixtures/app/i18n'" do
          expect(app.i18n_opts).to include(:translations)
          expect(app.i18n_opts[:translations]).to eq("#{Dir.pwd}/spec/fixtures/app/i18n")
        end
        
      end
      
    end
    
    context 'translations' do
      
      it "should return the Spanish translation" do
        get '/do-you-speak-english'
        expect(_status).to eq(200)
        expect(_body).to eq("Habla usted Inglés?")
      end
      
      it "should return the default (English) translation when no Spanish translation" do
        get '/hello'
        expect(_status).to eq(200)
        expect(_body).to eq("Hello from app/i18n/en.yml")
      end
    end
  end
end

describe 'CustomLocaleApp' do
  include Rack::Test::Methods
  
  context 'Custom configuration' do
    before do
      app(:bare) do
        # opts[:root] = File.expand_path('../fixtures', __FILE__)
        plugin :i18n, :locale => 'de', :translations => "#{Dir.pwd}/spec/fixtures/app/i18n"
        
        route do |r|
          
          r.get 'hello' do
            t.hello
          end
          
          r.get 'do-you-speak-english' do
            t.do.you.speak.english
          end
          
          r.on 'es' do
            
            i18n_get_locale('es')
            
            r.get 'hello' do
              # "Does not work??"
              # R18n.change('es').
              # t.do.you.speak.english #
              t.hello
            end
            
            r.get 'do-you-speak-english' do
              # "asjfldaljlj"
              t.do.you.speak.english
            end
            
          end #/es
          
          r.get 'after-es-route' do
            t.do.you.speak.english
          end
          
        end
      end
      
    end
    
    context 'configurations' do
      
      context '.i18n_opts' do
        
        it ":locale should be 'de'" do
          expect(app.i18n_opts).to include(:locale)
          expect(app.i18n_opts[:locale]).to eq('de')
        end
        
        it ":translations should be '../spec/fixtures/app/i18n'" do
          expect(app.i18n_opts).to include(:translations)
          expect(app.i18n_opts[:translations]).to eq("#{Dir.pwd}/spec/fixtures/app/i18n")
        end
        
      end
      
    end
    
    context 'translations' do
      
      context "when :locale => 'de'" do
        
        it "should return the correct file" do
          get '/hello'
          expect(_status).to eq(200)
          expect(_body).to eq("Hallo aus app/i18n/de.yml")
        end
        
        it "should return the German translation" do
          get '/do-you-speak-english'
          expect(_status).to eq(200)
          expect(_body).to eq("Kannst du Englisch?")
        end
        
      end
      
      context 'when overriding within routes' do
        
        it "should return the Spanish translation" do
          get '/es/do-you-speak-english'
          expect(_status).to eq(200)
          expect(_body).to eq("Habla usted Inglés?")
        end
        
        it "BUG: should return the default (German) translation when no Spanish translation" do
          get '/es/hello'
          expect(_status).to eq(200)
          expect(_body).not_to eq("Hallo aus app/i18n/de.yml")
        end
        
        it "TMP FIX: should return the default (EN) translation when no Spanish translation" do
          get '/es/hello'
          expect(_status).to eq(200)
          expect(_body).to eq("Hello from app/i18n/en.yml")
        end
        
        it "should reset back to configured :locale " do
          get '/after-es-route'
          expect(_status).to eq(200)
          expect(_body).to eq("Kannst du Englisch?")
        end
        
      end
      
    end
  end
end


describe 'CustomArrayApp' do
  include Rack::Test::Methods
  
  before do
    app(:bare) do
      # setting opts[:root] to overcome path issues in this test
      opts[:root] = File.expand_path('../fixtures', __FILE__)
      use Rack::Session::Cookie, secret: 'topsecret', key: '_custom_array_session'
      plugin :i18n, :locale => ['sv-se','en','de'],
         :translations => "#{Dir.pwd}/spec/fixtures/i18n"
      
      route do |r|
        r.get 'test' do
          t.only.english
        end
        r.on ':locale' do |locale|
          i18n_get_locale(locale)
          r.get 'test' do
            t.only.english
          end
        end
        
        r.get 'r18n' do
          r18n.only.english
        end
      end
    end
  end
  
  context 'Configurations' do
    
    it "should set the priority :locale to :sv-se" do
      expect(app.i18n_opts[:locale][0]).to eq('sv-se')
    end
    
    it ":locale should be an array" do
      expect(app.i18n_opts[:locale]).to be_instance_of(Array)
      ['sv-se','de','en'].each { |l| expect(app.i18n_opts[:locale]).to include(l) }
    end
    
    it "should set the :translations to the default i18n directory" do
      expect(app.i18n_opts[:translations]).to include("#{Dir.pwd}/spec/fixtures/i18n")
    end
    
  end
  
  context 'Translations' do
    
    context 'without locale' do
      
      it "should return 'sv-se' translation" do
        get '/test'
        expect(_status).to eq(200)
        expect(_body).to eq("Nej, inte på engelska")
      end
    end
    
    
    context 'loaded with locale' do
      it 'should return the correct translation' do
        {
          'en' => 'Only in English',
          'de' => 'Nein, nicht auf Englisch',
          # TODO: should respect the default locale for missing translations
          # 'fr' => 'Nein, nicht auf Englisch',
          'sv-se' => 'Nej, inte på engelska',
        }.each do |k,v|
          get "/#{k}/test"
          expect(_status).to eq(200)
          expect(_body).to eq(v)
        end
      end
    end
    
  end

end