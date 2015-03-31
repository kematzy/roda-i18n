class TestApp < Roda
  opts[:root] = File.dirname(__FILE__)
  use Rack::Session::Cookie, secret: 'topsecret', key: '_session'
  plugin :render
  plugin :i18n #, :locale => 'en', :translations => "#{Dir.pwd}spec/fixtures/i18n"
  
  route do |r|
    
    r.on ':locale' do |locale|
      i18n_get_locale(locale)
      
      r.get 'test' do
        t.only.english
      end
      
      r.get 'posts/:count' do |count|
        @post = "Roda: The ruby web framework"
        @count = count.to_i
        render(:test)
      end
      
      r.get 'time' do
        l Time.new(2015,3,1)#.utc
      end
      
      r.get 'month' do
        l Time.new(2015,3,1), "%B"#.utc
      end
      
      r.get 'locale' do
        r18n.locale.title
      end
      
      r.get 'locales' do
        r18n.available_locales.map { |i| "#{i.code}: #{i.title}" }.sort.join('; ')
      end
      
      r.get 'greater' do
        t.greater
      end
      
      r.get 'html' do
        t.warning
      end
      
      r.get 'untranslated' do
        "#{t.post.no}"
      end
      
    end
    
  end
  
end
