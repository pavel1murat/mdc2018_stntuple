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
  puts "usage: check_dataset -d flateminux-mix -v 721_0002 [-V]"
  exit(-1)
end
#------------------------------------------------------------------------------
# specify defaults for the global variables and parse command line options
#------------------------------------------------------------------------------

opts = GetoptLong.new(
  [ "--dataset"       , "-d",     GetoptLong::REQUIRED_ARGUMENT ],
  [ "--file"          , "-f",     GetoptLong::REQUIRED_ARGUMENT ],
  [ "--nfiles"        , "-n",     GetoptLong::REQUIRED_ARGUMENT ],
  [ "--version"       , "-v",     GetoptLong::REQUIRED_ARGUMENT ],
  [ "--verbose"       , "-V",     GetoptLong::NO_ARGUMENT       ]
)
#----------------------------- defaults
$input_file = nil
$verbose    = 0
$version    = nil
$max_nfiles = -1;

opts.each do |opt, arg|
  if    (opt == "--dataset"       ) ; $dataset        = arg
  elsif (opt == "--file"          ) ; $input_file     = arg
  elsif (opt == "--nfiles"        ) ; $max_nfiles     = arg.to_i
  elsif (opt == "--version"       ) ; $version        = arg
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


#------------------------------------------------------------------------------
# to use on the nodes with dccp installed
#------------------------------------------------------------------------------
def run2(dataset,version)

  project_def_file = File.open("mdc2018_stntuple/AAA_PROJECT.txt");

  long_dsname = nil;

  project_def_file.each_line { |line|
    puts "#{line}"
    words = line.strip.split();
    if (words[0].strip == version) and (words[1].strip == dataset) then
      long_dsname = words[2]
      break;
    end
  }

  if (long_dsname == nil) then
    printf("run2: TROUBLE! dataset .#{dataset}. version .#{version}. is not defined\n");
    return
  end

  input_fn = "catalogs/MDC2018/#{long_dsname}/#{long_dsname}.files";

# puts "input_fn=#{input_fn}"
  input_file   = File.open("#{input_fn}","r");

  bnn = File.basename(input_fn.strip);
#  outf = File.open("#{bnn}."+Time.now.strftime("%Y-%d-%m-%H-%M")+".log","w");

  nfiles = 0;

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

    nfiles = nfiles+1;
    if ($max_nfiles > 0) then
      if (nfiles >= $max_nfiles) then ; break ; end
    end
  }

#  outf.close

end


# run1($input_file);

run2($dataset,$version);

exit(0)
