#!/usr/bin/env ruby
# This ruby example requires the ruby odbc library which can be found
# at http://www.ch-werner.de/rubyodbc/  Unfortunately, this isn't available
# as a gem as of yet.

$VERBOSE = 1

require 'odbc'
require 'optparse'

DRIVER = 'ezRETS ODBC Driver'
drv = ODBC::Driver.new
drv.name = DRIVER
drv.attrs["DRIVER"] = DRIVER
drv.attrs["LoginUrl"] = "http://demo.crt.realtors.org:6103/rets/login"
drv.attrs["UID"] = "Joe"
drv.attrs["PWD"] = "Schmoe"
drv.attrs["StandardNames"] = "false"
if PLATFORM =~ /darwin/
  # iodbc actually takes the path to the driver, not the name as
  # registered in odbcinst.ini.  Right now, of our platforms, OS X
  # is the only one that uses iODBC by default.
  drv.attrs["DRIVER"] = '/Library/ODBC/ezRETS/ezrets.dylib'
else
  drv.attrs["DRIVER"] = DRIVER
end

LookupColStruct = Struct.new(:column, :lookup)

def getLookupsForTable(dbc, table)
  returns = Array.new
  lookupColTable = 'lookupcolumns:' + table.split(':', 2)[1]
  dbc.run("select * from #{lookupColTable}") do |stmt|
    # pull it out of table and stick in some objects to return
    stmt.each { |row| returns << LookupColStruct.new(row[0], row[1]) }
  end
  return returns
end

usage = OptionParser.new do |opts|
  opts.banner = "Usage: MetadataBrowse.rb [options]"
  opts.on('-b', '--bulk_metadata', 'Grab the metadata all at once') do |a|
    drv.attrs["UseBulkMetadata"] = "true"
  end
  opts.on('-dARG', '--debug_log ARG', 'Debug log to given file') do |a|
    drv.attrs["DebugLogFile"] = a
  end
  opts.on('-HARG', '--http_log ARG', 'HTTP log to given file') do |a|
    drv.attrs["HttpLogFile"] = a
  end
  opts.on('-lARG', '--loginUrl ARG', 'Login URL') do |a|
    drv.attrs["LoginUrl"] = a
  end
  opts.on('-pARG', '--password ARG') { |a| drv.attrs["PWD"] = a }
  opts.on('-rARG', '--rets_version ARG') { |a| drv.attrs["RetsVersion"] = a }
  opts.on('-s', '--standard_names', 'Use standard names') do
    drv.attrs["StandardNames"] = "true"
  end
  opts.on('-i', '--ignore_metadata', 'Ignore the metadata type') do
    drv.attrs["IgnoreMetadataType"] = "true"
  end
  opts.on('-uARG', '--user ARG') { |a| drv.attrs["UID"] = a }
  opts.on('-UARG', '--user_agent ARG') { |a| drv.attrs["UserAgent"] = a }
  opts.on('-vARG', '--version ARG') { |a| drv.attrs["RetsVersion"] = a }
  opts.on('-h', '--help', 'Show this message') { puts opts ; exit }
  opts.parse!(ARGV)
end

if drv.attrs.has_key?('DebugLogFile')
  drv.attrs['UseDebugLogging'] = "true"
end

if drv.attrs.has_key?('HttpLogFile')
  drv.attrs['UseHttpLogging'] = "true"
end


dbc = ODBC::Database.new
dbc.drvconnect(drv)

tables = Array.new

dbc.tables do |stmt|
  stmt.each_hash do |row|
    tables << row["TABLE_NAME"]
  end
end

tables.each do |table|
  puts table
  lookupCols = getLookupsForTable(dbc, table)
  dbc.columns(table) do |stmt|
    stmt.each_hash do |row|
      printf("    %-25s  %-25s\n", row["COLUMN_NAME"], row["TYPE_NAME"])
    end
  end
end

dbc.disconnect
