# Name:    downloadRucArchive.rb
# Author:  Chris Wynnyk
# Purpose: Automated Ruby shell script for mass download of RUC data.
# Created: March 16, 2011
#
# Usage:
#    This downloads the older RUC data, up to 1 year old.  (13 km, 37 level pgrb files.)
#    
# ToDO:
#   Improve directory creation to be more robust.
#

require 'net/ftp'

# ## Create directories.
yr = '2009'
for month in 12..12
   m = sprintf('%02d',month)
   for day in 1..31
     begin
       d = sprintf('%02d',day)
       nd = '/data/ruc_wind_data/'+yr+'/ruc2a.'+yr+m+d
       Dir.mkdir(nd)
       p nd
     rescue
     next
     end
   end
end


# Download Nomads-archived RUC
# ftp://nomads.ncdc.noaa.gov/RUC/13km/201003/20100313/
#ftp = Net::FTP::new("ftp.ruby-lang.org")
ftp = Net::FTP::new("nomads.ncdc.noaa.gov")
ftp.login("ftp","a")

yr = '2009'
for month in 12..12
  m = sprintf('%02d',month)
  for day in 1..31
    d = sprintf('%02d',day)
    for hour in 0..23
      h = sprintf('%02d',hour) 
      val = (yr+m+d).to_i;
      for f in ['00'] #['00','01','03','06']
 	#f = sprintf('%02d',forecast);
	print '.'
	STDOUT.flush
	# Create file names.
	remote = '/RUC/20km/'+yr+m+'/'+yr+m+d+'/ruc2_252_'+yr+m+d+'_'+h+'00_0'+f+'.grb'
	local = '/data/ruc_wind_data/'+yr+'/ruc2a.'+yr+m+d+'/ruc2_252_'+yr+m+d+'_'+h+'00_0'+f+'.grb2'
	p "Downloading " + remote
	begin
	  ftp.getbinaryfile(remote,local)
          p 'Success: ' +remote
	rescue
          p 'Failed: ' + local
        next
        end
      end
    end
  end
end
ftp.close
