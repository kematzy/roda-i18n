# Roda-i18n

Internationalisation (i18n) and localisation support for [Roda](http://roda.jeremyevans.net/) apps.

Much of this plugin have been inspired (extracted) from the `sinatra-i18n` gem available at [github/ai/r18n](http://github.com/ai/r18n) created by [Andrey Sitnik](http://github.com/ai).


## Installation

To use this gem, just do

    $ (sudo) gem install roda-i18n
    
or if you use Bundler

    gem "roda-i18n"


## Getting Started

To add internationalisation and localisation support to your app just add the following 
code snippet in your app.

    plugin :i18n

This by default sets the locale to `'en'` and the translations directory to `'i18n'` in 
the root of your app, ie: '/path/2/app/i18n'.

**NOTE! Make sure you create the 'i18n' folder and add the 'en.yml' file with at least one
translation within it.**


### Usage - Overriding the defaults

However, both `:locale` and `:translations` can be overridden during configuration:
   
     plugin :i18n, :locale => 'de', :translations => 'path/2/i18n'


You can also set a list of preferred locales as an array ordered by priority.

     plugin :i18n, :locale => ['en','es','fr']


### Usage - Browser setting locale

Naturally we can allow browsers to override the default locale within routes, like this:
  
    class MyApp < Roda
      plugin :i18n, :locale => 'de'
      
      route do |r|
        
        i18n_set_locale   #=> set to the browser's default locale (en-US)
        
        r.get '' do
          t.hello  #=> 'Howdy, I speak American English'
        end
        
      end
      
    end

### Usage - Temporary locale override

You can also override locales within routes, like this:
    
    class MyApp < Roda
      plugin :i18n, :locale => 'de'
      
      route do |r|
        r.on 'es' do
          i18n_set_locale('es')   #=> set to Spanish
          r.get '' do
            t.hello  #=> 'Hola, hablo español'
          end
        end
      end
      
    end
  
  
Find more information about the [R18n](https://github.com/ai/r18n/tree/master/r18n-core) 
gem that's used to create the above.



## Ideas

A list of ideas that may be possible or even outlandish.


* Ability to load translations from multiple locations via an array.

      plugin :i18n, :translations => ['app1/i18n', 'app2/i18n', 'app3/i18n']
   
   Reference: [https://github.com/ai/r18n/tree/master/r18n-core#loaders]
   
   You can also set several loaders to merge translations from different sources:
   
       R18n.default_places = [MyLoader.new, DBLoader.new, 'path/to/yaml']
   



## TODOs

* clean-up the code a bit





## Licence

MIT 

Copyright: 2015 Kematzy 

