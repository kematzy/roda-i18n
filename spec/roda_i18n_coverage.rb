# frozen_string_literal: true

require 'coverage'
require 'simplecov'

def SimpleCov.roda_i18n_coverage(_opts = {})
  start do
    add_group('Missing') { |src| src.covered_percent < 100 }
    add_group('Covered') { |src| src.covered_percent == 100 }
    enable_coverage :branch
    minimum_coverage 100

    yield self if block_given?
  end
end

ENV.fetch('COVERAGE', false)
