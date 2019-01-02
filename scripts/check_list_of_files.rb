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
$input_file=nil
$verbose=0

opts.each do |opt, arg|
  if    (opt == "--file"          ) ; $input_file     = arg
  elsif (opt == "--verbose"       ) ; $verbose        = 1
  end

  if ($verbose != 0) ; puts "Option: #{opt}, arg #{arg.inspect}" ; end
end

#------------------------------------------------------------------------------
def run(input_fn)

# puts "input_fn=#{input_fn}"
  input_file   = File.open("#{input_fn}","r");

  bnn = File.basename(input_fn.strip);
  outf = File.open("#{bnn}."+Time.now.strftime("%Y-%d-%m-%H-%M")+".log","w");

  input_file.each_line { |fn|
    next if (fn[0] == '#') ;
    dir = File.dirname(fn.strip).strip;
    bn  = File.basename(fn.strip).strip;

    cmd = "cd #{dir} ; cat \".(get)(#{bn})(locality))\" ";

    x = `#{cmd}`.strip

#    puts "dir=#{dir} bn=#{bn} cmd=#{cmd}"
    outf.puts "fn=#{fn.strip} locality=#{x}"
#    puts x
  }

  outf.close

end


#------------------------------------------------------------------------------
# to use on the nodes with dccp installed
#------------------------------------------------------------------------------
def run1(input_fn)

# puts "input_fn=#{input_fn}"
  input_file   = File.open("#{input_fn}","r");

  bnn = File.basename(input_fn.strip);
#  outf = File.open("#{bnn}."+Time.now.strftime("%Y-%d-%m-%H-%M")+".log","w");

  input_file.each_line { |fn|
    next if (fn[0] == '#') ;
    dir = File.dirname(fn.strip).strip;
    bn  = File.basename(fn.strip).strip;

    f = fn.strip.sub("/pnfs","dcap://fndca1.fnal.gov:24125//pnfs/fnal.gov/usr");

    cmd = "dccp -P -t -1 #{f} 2>/dev/null; rc=$? ; echo $rc";
    x = `#{cmd}`.strip

    #    outf.puts "filename=#{f.strip} locality=#{x}"
    if ( x == "0") then puts "filename=#{f.strip} locality=#{x}"
    else                puts "filename=#{f.strip} locality=#{x} ******************* NEED TO STAGE"
    end
  }

#  outf.close

end


run1($input_file);

exit(0)
