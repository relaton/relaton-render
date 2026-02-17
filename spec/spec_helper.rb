require "simplecov"
SimpleCov.start
require "bundler/setup"
require "relaton-render"
require "rspec/matchers"
require "equivalent-xml"
require "canon"

Canon::Config.instance.tap do |cfg|
  # Configure Canon to use spec-friendly match profiles
  cfg.xml.match.profile = :spec_friendly
  cfg.html.match.profile = :spec_friendly

  # Configure Canon to show all diffs (including inactive diffs)
  cfg.html.diff.show_diffs = :all
  cfg.xml.diff.show_diffs = :all

  # Enable verbose diff output for debugging
  cfg.html.diff.verbose_diff = true
  cfg.xml.diff.verbose_diff = true
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def metadata(hash)
  hash.sort.to_h.delete_if do |_k, v|
    v.nil? || (v.respond_to?(:empty?) && v.empty?)
  end
end

# Custom matcher to pretty-print hash diffs for better readability
RSpec::Matchers.define :match_hash_pp do |expected|
  match do |actual|
    expected == actual
  end
  
  failure_message do |actual|
    expected_pp = PP.pp(expected, +"", 120).chomp
    actual_pp = PP.pp(actual, +"", 120).chomp
    
    # Generate line-by-line diff
    require 'diff/lcs'
    expected_lines = expected_pp.split("\n")
    actual_lines = actual_pp.split("\n")
    
    diffs = Diff::LCS.sdiff(expected_lines, actual_lines)
    
    # Show diff with 3 lines of context around each change
    context_lines = 3
    diff_output = []
    diffs.each_with_index do |change, i|
      if change.action != '='
        # Include context before
        start_ctx = [i - context_lines, 0].max
        (start_ctx...i).each do |j|
          diff_output << "  #{expected_lines[j]}" if diffs[j].action == '='
        end
        
        # Include the change
        case change.action
        when '-'
          diff_output << "- #{change.old_element}"
        when '+'
          diff_output << "+ #{change.new_element}"
        when '!'
          diff_output << "- #{change.old_element}"
          diff_output << "+ #{change.new_element}"
        end
        
        # Include context after
        end_ctx = [i + context_lines, diffs.length - 1].min
        ((i + 1)..end_ctx).each do |j|
          diff_output << "  #{expected_lines[j]}" if diffs[j].action == '='
        end
        diff_output << "  ..." if i + context_lines < diffs.length - 1
      end
    end
    diff_output = diff_output.uniq.join("\n")
    
    # Return formatted output without triggering RSpec's default diff
    result = +"\n\nExpected:\n#{expected_pp}\n\nGot:\n#{actual_pp}\n\nDiff (lines that differ):\n#{diff_output}\n\n"
    # Disable RSpec's automatic diffing by not defining diffable
    result
  end
end
