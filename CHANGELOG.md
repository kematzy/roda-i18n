# CHANGELOG


## 0.4.0 (2018-05-08)

* Merge pull request #4 from adam12/yield-matched-locale - Yield matched locale to block

  > Yield the matched locale to the block, similar to a normal Roda route.

* Merge pull request #5 from adam12/no-session-setting - Don't set session (BREAKING CHANGE)

  I think setting the session should be done by the user inside the yielded block, using the value yielded from the match in #4, if they want that value to be set in the first place.

  ```ruby
  r.locale do |locale|
    session[:locale] ||= locale
  end
  ```

  If we assume that a session exists, this plugin can't be used where there is no session - ie. a Roda app that performs mailing only.

  ```ruby
  class Mailer < Roda
    plugin :mailer
    plugin :i18n

    route do |r|
      r.locale do  
        r.mail "/some-path" {}
      end
    end
  end

  Mailer.sendmail("/en/some-path")  # FAILS! No Rack::Session available
  ```

  This is likely a breaking change for anybody relying on this functionality.

* Merge pull request #6 from adam12/fix-nil - Cast potentially matched locale to string

  > Without this cast, a `root` block below the `locale` block will never be reached due to an exception of calling `downcase` on `nil`.

  > I didn't add a new spec as moving the `r.root` call to the bottom of the block was enough to trigger the failure.

* Merge pull request #7 from zaidan/update/roda-3 - Making routes behind #locale block work

  * Fix deprecated use of placeholders in string matchers
  * Fix missing dependency on `r18n-core` < `2.2.0`
  * Fix spec failures caused by unexpected order of `available_locales`
  * Update dependency `roda` to `3.7`
  * Update development dependency `rack-test` to `1.0`
  * Update dependency `r18n-core` to `3.0.x`
  * Update development dependency `rake` to `12.3`
  * Remove noop check for exception


## 0.3.0 (2016-08-11)

* Merged PR #3 by @jonduarte - Making routes behind #locale block work

* Added Travis CI support (all builds passing)

* Change r18n-core gem to version 2.1.4

* Add alias for rake test


## 0.2.0 (2015-11-24)

* Mainly internal build and setup improvements


## 0.1.0 (2015-09-13)

* Initial public release
  
  * Big Thank You to @jeremyevans for his assistance in creating this initial version.
  
