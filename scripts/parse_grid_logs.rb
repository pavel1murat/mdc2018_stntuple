#!/usr/bin/env ruby
#------------------------------------------------------------------------------
#  example: 
#  --------
# parse_grid_logs  --dsid aaaaa
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
  [ "--dsid"          , "-d",     GetoptLong::REQUIRED_ARGUMENT ],
  [ "--verbose"       , "-v",     GetoptLong::NO_ARGUMENT       ]
)
#----------------------------- defaults
$dsid    = nil
$verbose = 0

opts.each do |opt, arg|
  if    (opt == "--dsid"          ) ; $dsid     = arg
  elsif (opt == "--verbose"       ) ; $verbose  = 1
  end

  if ($verbose != 0) ; puts "Option: #{opt}, arg #{arg.inspect}" ; end
end

#------------------------------------------------------------------------------
def run(dsid)

# puts "input_fn=#{input_fn}"
  dir = "/mu2e/data/users/"+ENV["USER"]+"/datasets/"+dsid;

  printf ("t_stagein  tot_cpu  tot_wall  tfull t_istn  t_kffpar  t_kffdar\n");
  for fn in Dir.glob("#{dir}/log/*.log") do
    # puts "-----------------"+fn

    f = File.open(fn);

    start_time    = nil;
    wall_time     = nil;
    cpu_time      = nil;
    stage_in_time = nil;
    full_evt_time = nil;
    kffpar_time   = nil;
    kffdar_time   = nil;
    init_stn_time = nil;

    f.each_line { |line|
      if (line.index("Starting on host ")) then
        # puts line
        words = line.strip.split(" ");
        start_time = words[19]+" "+words[20]+" "+words[21]+" "+words[22]+" "+words[23];
      elsif line.index("# Total stage-in time:") then
        words         = line.strip.split(" ");
        stage_in_time = words[10].to_i;
      elsif line.index("TimeReport CPU =") then
        words         = line.strip.split(" ");
        cpu_time  = words[3].to_f;
        wall_time = words[6].to_f;
      elsif line.index("Full event  ") then
        full_evt_time = line.strip.split(" ")[3].to_f;
      elsif line.index("p2:InitStntuple:InitStntuple") then
        init_stn_time = line.strip.split(" ")[2].to_f;
      elsif line.index("p2:KFFDeMHPar:KalFinalFit") then
        kffpar_time = line.strip.split(" ")[2].to_f;
      elsif line.index("p2:KFFDeMHDar:KalFinalFit") then
        kffdar_time = line.strip.split(" ")[2].to_f;
      end
    } 

#    puts stage_in_time, cpu_time, wall_time, full_evt_time, kffpar_time, kffdar_time, init_stn_time;

    printf(" %6i %8.0f %8.0f %8.4f %8.4f %8.4f %8.4f\n",
           stage_in_time, cpu_time, wall_time, full_evt_time, kffpar_time, kffdar_time, init_stn_time);

    f.close
  end

#  input_file   = File.open("#{input_fn}","r");
#
#  bnn = File.basename(input_fn.strip);
#  outf = File.open("#{bnn}."+Time.now.strftime("%Y-%d-%m-%H-%M")+".log","w");
#
#  input_file.each_line { |fn|
#    next if (fn[0] == '#') ;
#    dir = File.dirname(fn.strip).strip;
#    bn  = File.basename(fn.strip).strip;
#
#    cmd = "cd #{dir} ; cat \".(get)(#{bn})(locality))\" ";
#
#    x = `#{cmd}`.strip
#
##    puts "dir=#{dir} bn=#{bn} cmd=#{cmd}"
#    outf.puts "fn=#{fn.strip} locality=#{x}"
##    puts x
#  }
#
#  outf.close
#
end


run($dsid);

exit(0)
