#!/usr/bin/env ruby
#------------------------------------------------------------------------------
#  split dataset file list into nfiles large chunks
#  example: 
#  --------
# split_dataset  --dsid aaaaa --nfiles 1000
#-----------------------------------------------------------------------
#------------------------------------------------------------------------------
# puts "starting---"

require 'find'
require 'fileutils'
require 'getoptlong'

# puts " emoe"
#-----------------------------------------------------------------------
def usage
  puts "usage: make_concat_requests -f format -h host -i input_dir "
  puts "                            -p name_pattern -o output_dir  "
  puts "                            -b book -d dataset -t output_tcl"
  exit(-1)
end
#------------------------------------------------------------------------------
# specify defaults for the global variables and parse command line options
#------------------------------------------------------------------------------

opts = GetoptLong.new(
  [ "--file"          , "-f",     GetoptLong::REQUIRED_ARGUMENT ],
  [ "--verbose"       , "-v",     GetoptLong::NO_ARGUMENT       ]
)
#----------------------------- defaults
$file=nil
$verbose=0

opts.each do |opt, arg|
  if    (opt == "--file"          ) ; $file     = arg
  elsif (opt == "--verbose"       ) ; $verbose  = 1
  end

  if ($verbose != 0) ; puts "Option: #{opt}, arg #{arg.inspect}" ; end
end

#------------------------------------------------------------------------------
def run(fn)

  dir = File.dirname(fn.strip).strip;
  bn  = File.basename(fn.strip).strip;

  cmd = "cd #{dir} ; cat \".(use)(4)(#{bn})\" ";

  x = `#{cmd}`.strip

#    puts "dir=#{dir} bn=#{bn} cmd=#{cmd}"
  puts x

  cmd = "cd #{dir} ; cat \".(get)(#{bn})(locality))\" ";

  x = `#{cmd}`.strip

  puts "locality: #{x}"

end


#------------------------------------------------------------------------------
def run1(fn)

  dir = File.dirname(fn.strip).strip;
  bn  = File.basename(fn.strip).strip;

  f = fn.sub("/pnfs","dcap://fndca1.fnal.gov:24125//pnfs/fnal.gov/usr");

  puts f;

  #  return;

  cmd = "dccp -P -t -1 #{f} ; rc=$? ; echo $rc";

  x = `#{cmd}`.strip

  puts x

end


run1($file);

exit(0)
