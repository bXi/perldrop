package TimeCompare;

#this is a basic plugin which waits for something to be said in a channel
# and then it does something with the input and msges it back


use strict qw(subs vars refs);    # Make sure we can't mess up
use warnings FATAL => 'all';
use POE::Component::IRC::Plugin qw( :ALL );

sub new {
    my ($package) = shift;
    return bless {}, $package;
}

sub PCI_register {
    my ( $self, $irc ) = splice @_, 0, 2;
    $irc->plugin_register( $self, 'SERVER', qw(public msg) );
    return 1;
}

sub PCI_unregister {
    return 1;
}

sub S_public {
    our ( $self, $irc ) = splice @_, 0, 2;
    our ($hostmask) = ( split /!/, ${ $_[0] } )[1];
    our ($ident) = ( split /\@/, $hostmask )[0];
    $ident =~ s/^~//;
    our ($hostname) = ( split /\@/, $hostmask )[1];
    our	($nick) = ( split /!/, ${ $_[0] } )[0];
    our ($channel) = ${ $_[1] }->[0];
    our ($msg)     = ${ $_[2] };

    our ($file_lasttime_first) = "./data/$ident\@$hostname";
    our ($file_storage_dir) = "data";
    our ($file_lasttime_seen) = "$file_lasttime_first";

our $set_newperson = "0";
our $set_greetme = "0";
our $do_print_this = "0";
our $time_sec = "0";
our $time_min = "0";
our $time_hour = "0";
our $time_monthday = "0";
our $time_month = "0";
our $time_tmpyear = "0";
our $time_weekday = "0";
our $time_yearday = "0";
our $time_year = "0";
our $time_isdst = "0";
our $timeold_sec = "0";
our $timeold_min = "0";
our $timeold_hour = "0";
our $timeold_monthday = "0";
our $timeold_month = "0";
our $timeold_tmpyear = "0";
our $timeold_weekday = "0";
our $timeold_yearday = "0";
our $timeold_year = "0";
our $timeold_isdst = "0";
our $timegone_sec = "0";
our $timegone_min = "0";
our $timegone_hour = "0";
our $timegone_month = "0";
our $timegone_year = "0";
our $timegone_yearday = "0";
our $timemiss_sec = "0";
our $timemiss_min = "0";
our $timemiss_hour = "0";
our $timemiss_yearday = "0";
our $timemiss_month = "0";
our $timemiss_year = "0";
our $time_check_leapyear = "0";
our $time_daysinyear = "0";
our @time_monthlength = qw();
our @time_daynames = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
our @time_monthnames = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
our $time_flow_temp = "0";
our $time_flow_mast = "0";


 sub get_nick_lasttime_spoke { 
   # Here we open the last seen time file.
   # The file is dumped in an array.
   # The info in the array is split up in $timeold_xxx, where xxx is hour, minute, second etc.
   # Add 1900 to the old year count to get the correct year.
   open(FILE_LASTTIME_SEEN, "$file_lasttime_seen") || die("Could not open file!");
   my @oldtime_data=<FILE_LASTTIME_SEEN>;
  
   foreach my $timeold_info (@oldtime_data) { 
    ($timeold_sec,$timeold_min,$timeold_hour,$timeold_monthday,$timeold_month,$timeold_tmpyear,$timeold_weekday,$timeold_yearday,$timeold_isdst) = split(/\:/, $timeold_info);
   $timeold_year = 1900 + $timeold_tmpyear;
  }
 }

sub get_time {
 # Get the current time, add 1900 to the year count to get the correct year.
 ($time_sec,$time_min,$time_hour,$time_monthday,$time_month,$time_tmpyear,$time_weekday,$time_yearday,$time_isdst) = localtime(time);
 $time_year = 1900 + $time_tmpyear;
 }

 sub oldtime_renew {
  # Renew the time entry in the last seen file.
  open(FILE_LASTTIME_SEEN, ">$file_lasttime_seen") || die("Could not open file!");
  get_time;
  print FILE_LASTTIME_SEEN join(' ', "$time_sec:$time_min:$time_hour:$time_monthday:$time_month:$time_tmpyear:$time_weekday:$time_yearday:$time_isdst\n"); close FILE_LASTTIME_SEEN;
  return PCI_EAT_PLUGIN;
 }

sub check_leapyear {
  if (( $time_check_leapyear % 4 == 0 ) && ( $time_check_leapyear % 100 != 0 ) or ( $time_check_leapyear % 400 == 0 )) {
   if ($do_print_this == "1") { 
       $irc->yield( privmsg => $channel => "a leap year." );
       $do_print_this = "0"; }
    $time_daysinyear = 366;
    @time_monthlength = qw(31 60 91 121 152 182 213 244 274 305 335 366);
    return PCI_EAT_PLUGIN;
   } 
  else { 
   if ($do_print_this == "1") { $irc->yield( privmsg => $channel => "not a leap year." ); $do_print_this = "0"; }
   $time_daysinyear = 365;
   @time_monthlength = qw(31 59 90 120 151 181 212 243 273 304 334 365);
   return PCI_EAT_PLUGIN;
  }
 }


sub timegone_compare_init {
 sub time_set_flow_temp_null { $time_flow_temp = "0"; }
 sub time_set_flow_temp_forw { $time_flow_temp = "1"; }
 sub time_set_flow_temp_back { $time_flow_temp = "-1"; }
 sub time_set_flow_mast_null { $time_flow_mast = "0"; }
 sub time_set_flow_mast_forw { $time_flow_mast = "1"; }
 sub time_set_flow_mast_back { $time_flow_mast = "-1"; }

$do_print_this = "0";
 sub timegone_get_months {

  
  $time_check_leapyear = $time_year;
  check_leapyear;
  
 sub calculate_months { 
   $timegone_yearday = ($timegone_yearday - $time_monthlength[$timegone_month-1]) + 1;
  }
  
 
  if (($timegone_yearday >= 0) && ($timegone_yearday <= $time_monthlength[0])) { $timegone_month = 0; }
  else { 
   if (($timegone_yearday >= $time_monthlength[0]) && ($timegone_yearday <= $time_monthlength[1])) { $timegone_month = 1; }
   elsif (($timegone_yearday >= $time_monthlength[1]) && ($timegone_yearday <= $time_monthlength[2])) { $timegone_month = 2; }
   elsif (($timegone_yearday >= $time_monthlength[2]) && ($timegone_yearday <= $time_monthlength[3])) { $timegone_month = 3; }
   elsif (($timegone_yearday >= $time_monthlength[3]) && ($timegone_yearday <= $time_monthlength[4])) { $timegone_month = 4; }
   elsif (($timegone_yearday >= $time_monthlength[4]) && ($timegone_yearday <= $time_monthlength[5])) { $timegone_month = 5; }
   elsif (($timegone_yearday >= $time_monthlength[5]) && ($timegone_yearday <= $time_monthlength[6])) { $timegone_month = 6; }
   elsif (($timegone_yearday >= $time_monthlength[6]) && ($timegone_yearday <= $time_monthlength[7])) { $timegone_month = 7; }
   elsif (($timegone_yearday >= $time_monthlength[7]) && ($timegone_yearday <= $time_monthlength[8])) { $timegone_month = 8; }
   elsif (($timegone_yearday >= $time_monthlength[8]) && ($timegone_yearday <= $time_monthlength[9])) { $timegone_month = 9; }
   elsif (($timegone_yearday >= $time_monthlength[9]) && ($timegone_yearday <= $time_monthlength[10])) { $timegone_month = 10; }
   elsif (($timegone_yearday >= $time_monthlength[10]) && ($timegone_yearday <= $time_monthlength[11])) { $timegone_month = 11; }
   calculate_months;
  }
 }


 sub timegone_compare_seconds {
  sub timegone_calc_sec_normal { $timegone_sec = $time_sec - $timeold_sec; }
  sub timegone_calc_sec_backward { $timegone_sec = $timeold_sec - $time_sec; }
  sub timegone_calc_sec_forward { $timegone_min = $timegone_min - 1; $timegone_sec = (60 - $timeold_sec) + $time_sec; }
  sub timegone_calc_sec_negative { $timegone_min = $timegone_min - 1; $timegone_sec = (60 - $time_sec) + $timeold_sec; }
   
  
  # if the min was the same
  if ($time_flow_temp == "0") {
   if ($time_sec == $timeold_sec) { timegone_calc_sec_normal; time_set_flow_temp_null; time_set_flow_mast_null; }   # check if current sec is the same as old sec
   elsif ($time_sec > $timeold_sec) { timegone_calc_sec_normal; time_set_flow_temp_forw; time_set_flow_mast_forw; } # check if current sec is bigger then old sec
   elsif ($time_sec < $timeold_sec) { timegone_calc_sec_backward; time_set_flow_temp_back; time_set_flow_mast_back; } # check if current sec is smaller then old sec
  }
 
  # if min went forward
  elsif ($time_flow_temp == "1") {
   if ($time_sec == $timeold_sec) { timegone_calc_sec_normal; time_set_flow_temp_null; time_set_flow_mast_forw; } # check if current sec is the same as old sec
   elsif ($time_sec > $timeold_sec) { timegone_calc_sec_normal; time_set_flow_temp_forw; time_set_flow_mast_forw; } # check if current sec is bigger then old sec
   elsif ($time_sec < $timeold_sec) { timegone_calc_sec_forward; time_set_flow_temp_forw; time_set_flow_mast_forw; } # check if current sec is smaller then old sec
  }
 
  # if min went backward
  elsif ($time_flow_temp == "-1") {
   if ($time_sec == $timeold_sec) { timegone_calc_sec_backward;  time_set_flow_temp_null; time_set_flow_mast_back; } # check if current sec is the same as old sec
   elsif ($time_sec > $timeold_sec) { timegone_calc_sec_negative; time_set_flow_temp_back; time_set_flow_mast_back; } # check if current sec is bigger then old sec
   elsif ($time_sec < $timeold_sec) { timegone_calc_sec_backward; time_set_flow_temp_back; time_set_flow_mast_back; } # check if current sec is smaller then old sec
  }
  timegone_get_months;
 }


 sub timegone_compare_minutes {
  sub timegone_calc_min_normal { $timegone_min = $time_min - $timeold_min; }
  sub timegone_calc_min_backward { $timegone_min = $timeold_min - $time_min; }
  sub timegone_calc_min_forward { $timegone_hour = $timegone_hour - 1; $timegone_min = (60 - $timeold_min) + $time_min; }
  sub timegone_calc_min_negative { $timegone_hour = $timegone_hour - 1; $timegone_min = (60 - $time_min) + $timeold_min; }
   
  
  # if the hour was the same
  if ($time_flow_temp == "0") {
   if ($time_min == $timeold_min) { timegone_calc_min_normal; time_set_flow_temp_null; time_set_flow_mast_null; }   # check if current min is the same as old min
   elsif ($time_min > $timeold_min) { timegone_calc_min_normal; time_set_flow_temp_forw; time_set_flow_mast_forw; } # check if current min is bigger then old min
   elsif ($time_min < $timeold_min) { timegone_calc_min_backward; time_set_flow_temp_back; time_set_flow_mast_back; } # check if current min is smaller then old min
  }
 
  # if hour went forward
  elsif ($time_flow_temp == "1") {
   if ($time_min == $timeold_min) { timegone_calc_min_normal; time_set_flow_temp_null; time_set_flow_mast_forw; } # check if current min is the same as old min
   elsif ($time_min > $timeold_min) { timegone_calc_min_normal; time_set_flow_temp_forw; time_set_flow_mast_forw; } # check if current min is bigger then old min
   elsif ($time_min < $timeold_min) { timegone_calc_min_forward; time_set_flow_temp_forw; time_set_flow_mast_forw; } # check if current min is smaller then old min
  }
#  
  # if hour went backward
  elsif ($time_flow_temp == "-1") {
   if ($time_min == $timeold_min) { timegone_calc_min_backward;  time_set_flow_temp_null; time_set_flow_mast_back; } # check if current min is the same as old min
   elsif ($time_min > $timeold_min) { timegone_calc_min_negative; time_set_flow_temp_back; time_set_flow_mast_back; } # check if current min is bigger then old min
   elsif ($time_min < $timeold_min) { timegone_calc_min_backward; time_set_flow_temp_back; time_set_flow_mast_back; } # check if current min is smaller then old min
  }
  timegone_compare_seconds;
 }


 sub timegone_compare_hours {
  sub timegone_calc_hour_normal { $timegone_hour = $time_hour - $timeold_hour; }
  sub timegone_calc_hour_backward { $timegone_hour = $timeold_hour - $time_hour; }
  sub timegone_calc_hour_forward { $timegone_yearday = $timegone_yearday - 1; $timegone_hour = $timeold_hour - $time_hour; }
  sub timegone_calc_hour_negative { $timegone_yearday = $timegone_yearday - 1; $timegone_hour = $time_hour - $timeold_hour; }
   
  
  # if the yearday was the same
  if ($time_flow_temp == "0") {
   if ($time_hour == $timeold_hour) { timegone_calc_hour_normal; time_set_flow_temp_null; time_set_flow_mast_null; }   # check if current hour is the same as old hour
   elsif ($time_hour > $timeold_hour) { timegone_calc_hour_normal; time_set_flow_temp_forw; time_set_flow_mast_forw; } # check if current hour is bigger then old hour
   elsif ($time_hour < $timeold_hour) { timegone_calc_hour_backward; time_set_flow_temp_back; time_set_flow_mast_back; } # check if current hour is smaller then old hour
  }
 
  # if yearday went forward
  elsif ($time_flow_temp == "1") {
   if ($time_hour == $timeold_hour) { timegone_calc_hour_normal; time_set_flow_temp_null; time_set_flow_mast_forw; } # check if current hour is the same as old hour
   elsif ($time_hour > $timeold_hour) { timegone_calc_hour_normal; time_set_flow_temp_forw; time_set_flow_mast_forw; } # check if current hour is bigger then old hour
   elsif ($time_hour < $timeold_hour) { timegone_calc_hour_forward; time_set_flow_temp_forw; time_set_flow_mast_forw; } # check if current hour is smaller then old hour
  }
 
  # if yearday went backward
  elsif ($time_flow_temp == "-1") {
   if ($time_hour == $timeold_hour) { timegone_calc_hour_backward;  time_set_flow_temp_null; time_set_flow_mast_back; } # check if current hour is the same as old hour
   elsif ($time_hour > $timeold_hour) { timegone_calc_hour_negative; time_set_flow_temp_back; time_set_flow_mast_back; } # check if current hour is bigger then old hour
   elsif ($time_hour < $timeold_hour) { timegone_calc_hour_backward; time_set_flow_temp_back; time_set_flow_mast_back; } # check if current hour is smaller then old hour
  }
  timegone_compare_minutes;
 }


 sub timegone_compare_yeardays {
  sub timegone_calc_yearday_normal { $timegone_yearday = $time_yearday - $timeold_yearday; }
  sub timegone_calc_yearday_backward { $timegone_yearday = $timeold_yearday - $time_yearday; }
   
 sub timegone_calc_yearday_forward { 
   $timegone_year = $timegone_year - 1;
   $time_check_leapyear = $timeold_year;
   check_leapyear;
   $timegone_yearday = ($time_daysinyear - $timeold_yearday) + $time_yearday;
  }

 sub timegone_calc_yearday_negative { 
   $timegone_year = $timegone_year - 1;
   $time_check_leapyear = $timeold_year;
   check_leapyear;
   $timegone_yearday = ($time_daysinyear - $time_yearday) + $timeold_yearday;
  }

  # if year did not change
  if ($time_flow_temp == "0") {
   if ($time_yearday == $timeold_yearday) { timegone_calc_yearday_normal; time_set_flow_temp_null; time_set_flow_mast_null; } # check if current yearday is the same as old yearday
   elsif ($time_yearday > $timeold_yearday) { timegone_calc_yearday_normal; time_set_flow_temp_forw; time_set_flow_mast_forw; } # check if current yearday is bigger then old yearday
   elsif ($time_yearday < $timeold_yearday) { timegone_calc_yearday_backward; time_set_flow_temp_back; time_set_flow_mast_back; } # check if current yearday is smaller then old yearday;
  }
  
  # if year went forward
  elsif ($time_flow_temp == "1") {
   if ($time_yearday == $timeold_yearday) { timegone_calc_yearday_normal; time_set_flow_temp_null; time_set_flow_mast_forw; } # check if current yearday is the same as old yearday
   elsif ($time_yearday > $timeold_yearday) { timegone_calc_yearday_normal; time_set_flow_temp_forw; time_set_flow_mast_forw; } # check if current yearday is bigger then old yearday
   elsif ($time_yearday < $timeold_yearday) { timegone_calc_yearday_forward; time_set_flow_temp_forw; time_set_flow_mast_forw; } # check if current yearday is smaller then old yearday;
  }
 
  # if year went backward
  elsif ($time_flow_temp == "-1") {
   if ($time_yearday == $timeold_yearday) { timegone_calc_yearday_backward; time_set_flow_temp_null; time_set_flow_mast_back; } # check if yearday is the same as ld yearday
   elsif ($time_yearday > $timeold_yearday) { timegone_calc_yearday_negative; time_set_flow_temp_back; time_set_flow_mast_back; } # check if yearday is bigger then old yearday
   elsif ($time_yearday < $timeold_yearday) { timegone_calc_yearday_backward; time_set_flow_temp_back; time_set_flow_mast_back; } # check if yearday is smaller then old yearday
  }
  timegone_compare_hours;
 }


 sub timegone_compare_years {
  sub timegone_calc_year_normal { $timegone_year = $time_year - $timeold_year; time_set_flow_temp_null; }
  sub timegone_calc_year_positive { $timegone_year = $time_year - $timeold_year; time_set_flow_temp_forw; }
  sub timegone_calc_year_negative { $timegone_year = $timeold_year - $time_year; time_set_flow_temp_back; }

  if ($time_year == $timeold_year) { timegone_calc_year_normal; time_set_flow_mast_null; } # check if current year is the same as old year
  elsif ($time_year > $timeold_year) { timegone_calc_year_positive; time_set_flow_mast_forw; } # check if current year is bigger then old year
  elsif ($time_year < $timeold_year) { timegone_calc_year_negative; time_set_flow_mast_back; } # check if current year is bigger then old year

  timegone_compare_yeardays; # Second, we compare the yeardays
 }
 
 get_nick_lasttime_spoke; # Get last seen time info and variables.
 get_time; # Get the current time.
 timegone_compare_years; # First, we compare oldyear against newyear
}

sub print_missed_me {
 
 $timemiss_year = 0;
 $timemiss_yearday = 0;
 $timemiss_hour = 1;
 $timemiss_min = 3;
 $timemiss_sec = 37;

 sub message_missedyou { 
   $irc->yield( privmsg => $channel => "Hello $nick, I missed you! You did not speak for $timegone_year years, $timegone_month months, $timegone_yearday days, $timegone_hour hours, $timegone_min minutes and $timegone_sec seconds." );
}
 sub message_buggeroff { }
 sub message_newperson { }

 if (($set_newperson == 0) && ($set_greetme == 1)) {
   if ($timemiss_year <= 0) { 
    if ($timemiss_yearday <= 0) { 
     if ($timemiss_hour <= 0) { 
      if ($timemiss_min <= 0) {
       if ($timemiss_sec <= 0) { message_buggeroff; }
       elsif ($timemiss_sec <= $timegone_sec) { message_missedyou; }
       elsif ($timemiss_sec > $timegone_sec) { }
      }
      elsif ($timemiss_min <= $timegone_min) { message_missedyou; }
      elsif ($timemiss_min > $timegone_min) { }
     }
     elsif ($timemiss_hour <= $timegone_hour) { message_missedyou; }
     elsif ($timemiss_hour > $timegone_hour) { }
    }
    elsif ($timemiss_yearday <= $timegone_yearday) { message_missedyou; }
    elsif ($timemiss_yearday > $timegone_yearday) { }
   }
   elsif (($timemiss_year <= $timegone_year)) { message_missedyou; }
   elsif ($timemiss_year > $timegone_year) { }
 $set_greetme = "0";
 } elsif (($set_newperson == 1) && ($set_greetme == 1)) { message_newperson; $set_greetme = "0"; }
}


sub meet_new_person {
 if ( -e $file_lasttime_seen ) { $set_greetme = "1"; $set_newperson = "1"; get_time;
 return PCI_EAT_PLUGIN; }
 else { $irc->yield( privmsg => $channel => "could not write to lasttime file $nick!" ); return PCI_EAT_PLUGIN; }
}

sub check_lasttime_seen_file {
 if ( -e $file_lasttime_seen ) { $set_greetme = "1"; get_time; get_nick_lasttime_spoke; timegone_compare_init;
  #
  return PCI_EAT_PLUGIN; }
 else { oldtime_renew; meet_new_person; }
}

check_lasttime_seen_file;

print_missed_me;


       if ( $msg =~ /^!adebug$/ ) {
            $irc->yield( privmsg => $channel => "timelogfile = $file_lasttime_seen, nickname = $nick, username = $ident, nickhost = $hostname" ); 
             
            $irc->yield( privmsg => $channel => "Lasttime seenyou: " );
            $irc->yield( privmsg => $channel => "$timeold_hour:$timeold_min:$timeold_sec $time_daynames[$timeold_weekday] $timeold_monthday $time_monthnames[$timeold_month] (day $timeold_yearday) $timeold_year, which was " );
            $time_check_leapyear = $timeold_year;
            $do_print_this = "1";
            check_leapyear;
  
            $irc->yield( privmsg => $channel => "Current Datetime: " );
            $irc->yield( privmsg => $channel => "$time_hour:$time_min:$time_sec $time_daynames[$time_weekday] $time_monthday $time_monthnames[$time_month] (day $time_yearday) $time_year, which is " );
            $time_check_leapyear = $time_year; 
            $do_print_this = "1"; 
            check_leapyear; 

	    $irc->yield( privmsg => $channel => "I will miss you after " );
	    $irc->yield( privmsg => $channel => "$timemiss_year years, $timemiss_month months, $timemiss_yearday days, $timemiss_hour hours, $timemiss_min minutes and $timemiss_sec seconds." );


if ($time_flow_mast == "0") { $irc->yield( privmsg => $channel => "Time did not change: " ); }
  if ($time_flow_mast == "1") { $irc->yield( privmsg => $channel => "Time went forward by " ); }
  if ($time_flow_mast == "-1") { $irc->yield( privmsg => $channel => "Time went backward by " ); }
  
   $irc->yield( privmsg => $channel => "$timegone_year years, $timegone_month months, $timegone_yearday days, $timegone_hour hours, $timegone_min minutes and $timegone_sec seconds." );
           return PCI_EAT_PLUGIN;


    }
  oldtime_renew;
 
    return PCI_EAT_NONE;
}

return 1;