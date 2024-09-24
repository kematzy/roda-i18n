# RubyGems Release Process

1. Update/Check the version number in the gemspec file.
2. Check the [CHANGELOG](CHANGELOG.md) for all contributions since the last release.
3. Update the [README](README.md) in case of any changes.
4. Run `bundle install` to update the Gemfile.lock file.
5. Run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).