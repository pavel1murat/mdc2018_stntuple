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

  printf ("#    jobid     node_name            cpu_id     bogomips    dsid   tstage  totcpu  totwall    tfull    tistn  tkffpar  tkffdar\n");
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

    job_id        = nil;
    vendor_id     = nil;
    bogomips      = nil;
    node_name     = nil;

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
      elsif (line.index("poms_data") == 0) then
#------------------------------------------------------------------------------
# grid job information
# ["campaign_id:", "task_definition_id:", "task_id:", "job_id:", "batch_id:15514434.0@jobsub02.fnal.gov", \
#  "host_site:", "bogomips:4599.37", "node_name:murat-15514434-0-fnpc7008.fnal.gov", "vendor_id:AuthenticAMD"]
#------------------------------------------------------------------------------
        ww = line.split('=')[1].gsub('"','').gsub('{','').gsub('}','').split(',');
        for w in ww do
          w1 = w.split(':');
          if    (w1[0] == "batch_id" ) then job_id    = w1[1].split('.')[0];
          elsif (w1[0] == "bogomips" ) then bogomips  = w1[1];
          elsif (w1[0] == "node_name") then node_name = w1[1].split('-')[3];
          elsif (w1[0] == "vendor_id") then vendor_id = w1[1].strip;
          end
        end
      end
    }

#    puts stage_in_time, cpu_time, wall_time, full_evt_time, kffpar_time, kffdar_time, init_stn_time;

    printf(" %11s %-19s %-12s %8s %9s %6i %8.0f %8.0f %8.4f %8.4f %8.4f %8.4f\n",
           job_id, node_name, vendor_id, bogomips, dsid,
           stage_in_time, cpu_time, wall_time, full_evt_time, init_stn_time, kffpar_time, kffdar_time );

    f.close
  end
end


run($dsid);

exit(0)
