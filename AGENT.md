# Flipper Ruby Gem Development Guide

## Commands
- **Run all tests**: `bundle exec rake` (runs RSpec, Minitest, and Rails tests)
- **Run RSpec tests**: `bundle exec rake spec` or `bundle exec rspec`
- **Run single RSpec test**: `bundle exec rspec spec/path/to/file_spec.rb`
- **Run Minitest tests**: `bundle exec rake test`
- **Run single Minitest**: `bundle exec ruby -Ilib:test test/path/to/file_test.rb`
- **Run Rails tests**: `bundle exec rake test_rails`
- **Build gem**: `bundle exec rake build`
- **Install dependencies**: `bundle install`

## Code Style
- Use 2-space indentation, snake_case for methods/variables, PascalCase for classes/modules
- Require statements at top of file, grouped by standard library, gems, then local files
- Use double quotes for strings, symbol notation `:symbol` vs `'symbol'`
- Method visibility: public methods first, then private/protected at bottom with keywords
- Error handling: prefer explicit rescue blocks, raise specific exception classes
- Comments: use `# Public:` and `# Private:` for method documentation
- Module structure: extend self for module methods, use proper namespacing under Flipper::
- Test style: RSpec with `describe`/`it`, Minitest with class inheritance and `def test_*` methods
- Use `double()` for mocks in RSpec, `prepend` for shared test modules in Minitest
