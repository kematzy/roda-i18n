# RubyGems Release Process

This document describes the process to release a new version of the RubyGem.

## Before a release

1. Update/Check the version number in the gemspec file.
2. Check the [CHANGELOG](CHANGELOG.md) for all contributions since the last release. 
   * Do we need to address any breaking changes?
3. Update the [README](README.md) in case of any changes.
4. Run `bundle install` one last time to update the Gemfile.lock file, in case something was off (trust me, this will one day save the day).

## Release

1. Run `bundle exec rake release` to automagically create a git tag for the version and push the `gem` to [rubygems.org](https://rubygems.org).

## After a succesful release on RubyGems

1. Update the version number in the gemspec file to the next version.
2. Update the [CHANGELOG](CHANGELOG.md) with a new `next` section.
3. Run `bundle install` to update the Gemfile.lock file.
4. Commit the changes and push to the `default branch` repository.

