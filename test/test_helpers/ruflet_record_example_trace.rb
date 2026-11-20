# Runs the RufletRecord page's examples and records what each statement
# returns, so ruflet_record_docs_test can compare two ruflet_record versions.
#
#   ruby -rbundler/setup -I <ruflet_record lib> ruflet_record_example_trace.rb BLOCKS_JSON OUT_JSON
#
# BLOCKS_JSON is an array of Ruby sources. Each block is split into its
# top-level statements, which run in order in one shared binding. OUT_JSON gets
# one array per block with a summary of each statement's value: records as
# their class and attributes, relations as their records, plain data as
# itself and anything else as "object". A time within a day of now (a
# timestamp) is "Time"; any other time is its UTC value.
#
# The examples query tables that are often empty at that point, so a relation
# a statement returns is loaded again after the last block, against the rows
# the examples left. Those results are appended to the block's array.
require "json"
require "prism"
require "ruflet_record"

def summarize(value, depth = 0)
  return "..." if depth > 6

  case value
  when nil, true, false, Integer, Float, String then value
  when Symbol then ":#{value}"
  when Time then (value - Time.now).abs < 86_400 ? "Time" : value.getutc.strftime("%Y-%m-%d %H:%M:%S UTC")
  when RufletRecord::Relation
    begin
      [ "relation", value.to_a.map { |record| summarize(record, depth + 1) } ]
    rescue StandardError => e
      [ "relation", "raises #{e.class}" ]
    end
  when RufletRecord::Base
    [ value.class.name, value.attributes.to_h { |name, held| [ name.to_s, summarize(held, depth + 1) ] } ]
  when Array then value.map { |item| summarize(item, depth + 1) }
  when Hash then value.to_h { |key, held| [ key.to_s, summarize(held, depth + 1) ] }
  else "object"
  end
end

blocks = JSON.parse(File.read(ARGV.fetch(0)))
context = binding
eval("start_time = Time.now.utc - 3600; end_time = Time.now.utc + 3600", context)
relations = []

results = blocks.each_with_index.map do |code, index|
  parsed = Prism.parse(code)
  raise "block #{index + 1} does not parse: #{parsed.errors.map(&:message).join(', ')}" unless parsed.errors.empty?

  parsed.value.statements.body.map do |statement|
    value = eval(statement.slice, context, "block#{index + 1}.rb", statement.location.start_line)
    relations << [ index, value ] if value.is_a?(RufletRecord::Relation)
    summarize(value)
  end
end

relations.each do |index, relation|
  results[index] << [ "again", summarize(relation.reload) ]
rescue StandardError => e
  results[index] << [ "again", "raises #{e.class}" ]
end

File.write(ARGV.fetch(1), JSON.generate(results))
