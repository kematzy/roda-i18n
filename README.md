# Roda-i18n

Easily add Internationalisation (i18n) and localisation support for [Roda](http://roda.jeremyevans.net/) apps, based upon the [R18n](https://github.com/ai/r18n) gem.

Extensively tested and with 100% code test coverage.


## Installation

To use this gem, just do

    $ (sudo) gem install roda-i18n
    
or if you use Bundler

    gem "roda-i18n"


<br>


## Getting Started

To add internationalisation and localisation support to your app just add the following code snippet in your app.

    plugin :i18n

By default the default locale is set to <tt>'en'</tt> and the translations directory is set to the <tt>'i18n'</tt> directory in the rooot of your app, ie: '<tt>/path/2/app/i18n</tt>'.


**IMPORTANT! Make sure you create the 'i18n' folder and add an 'en.yml' file with 
at least one translation within it.**


<br>


## Configuration

### Overriding defaults during configuration

Both <tt>:locale</tt> and <tt>:translations</tt> can be configured (overridden) during plugin configuration:

    plugin :i18n, :locale => ['de'], :translations => ['absolute/path/2/i18n']


**NOTE!** 

 1. You must set <tt>opts[:root]</tt> in your app if you do not define the <tt>:translations</tt> path during plugin configuration.

 2. When overriding <tt>:translations</tt> the **any path(s) given must be absolute**.


#### Loading translations from multiple i18n directories

The <tt>:translations</tt> path supports 'wildcards', ie: <tt>path/**/i18n</tt> so you can load translations from multiple combined apps, each with their own <tt>i18n</tt> folder with translations.

**Please Note!** 

When loading translations from multiple sources and the same translation key is available in multiple files of the same locale, then **the translations in the first loaded translation file takes precedence over subsequent loaded translations**. 

* ie: translations in <tt>./i18n/en.yml</tt> takes precedence over translations in <tt>./apps/app1/i18n/en.yml</tt>


You can also set a list of preferred locales as an array ordered by priority.

    plugin :i18n, :locale => ['es','fr','en']



<br>


##  USAGE

The **i18n** plugin depends upon simple YAML based translations files:

    # app/i18n/en.yml
    
    user:
      edit: Edit user
      name: User name is %1
      count: !!pl
        1: There is 1 user
        n: There are %1 users
    

...and the **<tt>:t</tt>** instance method to output the translations:

    
    t.user.edit         #=> "Edit user"
    t.user.name('John') #=> "User name is John"
    t.user.count(5)     #=> "There are 5 users"
    
    t.does.not.exist | 'default' #=> "default"
    

...and the **<tt>:l</tt>** (lowercase L) instance method provides built-in localisations support:

    
    l Time.now           #=> "03/01/2010 18:54"
    l Time.now, :human   #=> "now"
    l Time.now, :full    #=> "3rd of January, 2010 18:54"
    


Both the <tt>:t</tt> and <tt>:l</tt> methods are available within the route and template (erb) scopes. ie:

    
    route do |r|
      r.root do
        t.welcome.message
      end
    end
    
    # app/views/layout.erb
    <snip...>
      <h1><%= t.welcome.message %></h1>
    <snip...>
    


Please visit [R18n](https://github.com/ai/r18n/tree/master/r18n-core) for more information about the R18n gem used to create the above.

<br>

## Key Methods / Functionality


<br>


### <tt>#locale(opts={},&blk)</tt> - (request method)

This request method makes it easy to handle translations based upon the **<tt>:locale</tt> prefix on a route / URL**. ie: <tt>blog.com/**de**/posts</tt>.


To enable this, just use the following code structure:

    route do |r|
      
      # all routes are prefixed with '/:locale'
      # ie: GET /de/posts  => will use DE translations    
      # ie: GET /es/posts  => will use ES translations
      
      r.locale do          # also aliased as #i18n_locale
        r.is 'posts' do 
	      t.posts.header # use translations or locales
        end
      end
      
    end
    

	

**NOTE!** Any URL / request with a non-present or not supported locale will be given the **configured default locale** or the EN (English) default locale.


<br>


### <tt>#i18n_set_locale_from(type)</tt> - (request method)

Obtains the locale from either ENV, HTTP (browser), Params or Session values.

    route do |r|
      # A): set from session[:locale] (if present)
      r.i18n_set_locale_from(:session)
      
      # B): set from URL params ie: GET /posts?locale=de
      r.i18n_set_locale_from(:params)
      
      # C): set from the browser's HTTP request locale
      r.i18n_set_locale_from(:http)
      
      # D): set from the server ENV['LANG'] variable
      r.i18n_set_locale_from(:ENV)
      
      
      r.is 'posts' do 
        t.posts.header # use translations
      end
    end


**NOTE!** defaults to the configured default locale, or English, if the given locale type is invalid.


<br>


### <tt>#i18n_set_locale(locale, &blk)</tt> - (request method)

Enables overriding the default locale and setting a temporary :locale
within a route block.
  
    route do |r|
      # configured default locale
      
	   <snip...>
	   
      r.i18n_set_locale('de') do
        # within this route block the locale is DE (German)
      end
      
      r.i18n_set_locale('es') do
        # within this route block the locale is ES (Spanish)
      end
    
    end
  



      
## InstanceMethods

### `#t`

This is the main translation output method. (See examples above)


<br>


### `#l`

Key localisation method. Handles dates etc. (See examples above)


<br>


### `#i18n_available_locales`

Returns a two-dimensional array of available locales.

    puts i18n_available_locales #=> [ ['en', 'English'], ...]



        
### `#i18n_default_places`


<br>


## Class Methods
        
### <tt>#i18n_opts</tt>

Return the i18n options for this class as a Hash.


<br>


## Ideas

A few ideas that may be outlandish, but possible?


### Ability to load translations from multiple locations via an array.

    plugin :i18n, :translations => ['app1/i18n', 'app2/i18n', 'app3/i18n']


> [Concept Reference](https://github.com/ai/r18n/tree/master/r18n-core#loaders)
>    
> You can also set several loaders to merge translations from different sources:
>    
>     R18n.default_places = [MyLoader.new, DBLoader.new, 'path/to/yaml']
>    


### Sequel DBLoader for DB based translations support

Som form of built-in support for storing / loading translations from a Sequel based DB.


<br>


----

## TODOs

* I'm sure there's something, but right now the list is empty ;-)


## Credits

* This plugin have been inspired by the `sinatra-i18n` gem available at [github/ai/r18n](http://github.com/ai/r18n) created by [Andrey Sitnik](http://github.com/ai).

* Testing code have been partly copied from [Forme](github.com/jeremyevans/forme).

* Inspiration and assistance by [Jeremy Evans](github.com/jeremyevans). Many thanks Jeremy!! 


## Licence

MIT 

Copyright: 2015 Kematzy 



