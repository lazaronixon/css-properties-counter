require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "css_parser", "~> 1.6"
end

require "css_parser"

def group_and_count_css_properties(css_file)
  css_data = File.read(css_file)

  parser = CssParser::Parser.new
  parser.add_block!(css_data)

  properties  = Hash.new(0)

  total_count = 0

  parser.each_rule_set do |rule_set|
    rule_set.each_declaration do |property, _value, _important|
      next if property.start_with?("-")
      next if property.start_with?(":")

      # Group similar properties
      grouped_property = group_similar_properties(property)
      properties[grouped_property] += 1
      total_count += 1
    end
  end

  ranked_properties = properties.sort_by { |_property, count| -count }.each_with_index.map do |(property, count), index|
    utilization = properties.values[0..index].sum.to_f / total_count * 100
    [index + 1, property, count, utilization.round(2)]
  end

  ranked_properties
end

def group_similar_properties(property)
  similar_groups = {
    'margin-left' => 'margin',
    'margin-right' => 'margin',
    'margin-top' => 'margin',
    'margin-bottom' => 'margin',
    #######################################
    'padding-left' => 'padding',
    'padding-right' => 'padding',
    'padding-top' => 'padding',
    'padding-bottom' => 'padding',
    #######################################
    'border-left' => 'border',
    'border-right' => 'border',
    'border-top' => 'border',
    'border-bottom' => 'border',
    #######################################
    'border-width' => 'border',
    'border-color' => 'border',
    'border-style' => 'border',
    #######################################
    'top' => 'top/left/right/bottom',
    'left' => 'top/left/right/bottom',
    'right' => 'top/left/right/bottom',
    'bottom' => 'top/left/right/bottom',
    #######################################
    'width' => 'width/height',
    'height' => 'width/height',
    #######################################
    'background-color' => 'background',
  }

  similar_groups[property] || property
end

# Usage example
css_file_path = 'hey.css'
file_name = File.basename(css_file_path)
property_rankings = group_and_count_css_properties(css_file_path)

# Generate Markdown table
table = "# CSS property utilization for #{file_name}\n\n"
table << "| Rank | Property | Count | % |\n"
table << "| ---- | -------- | ----- | - |\n"

property_rankings.each do |rank, property, count, utilization|
  table << "| #{rank} | #{property} | #{count} | #{utilization} |\n"
end

puts table
