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
require 'fileutils'
require 'pathname'

# ## Create directories.
yr = '2012'
startMonth = 10
endMonth = 10
startDay = 25
endDay = 31


# Download Nomads-archived RUC
# ftp://nomads.ncdc.noaa.gov/RUC/13km/201003/20100313/
#ftp = Net::FTP::new("ftp.ruby-lang.org")
ftp = Net::FTP::new("nomads.ncdc.noaa.gov")
ftp.login("ftp","a")

p 'Starting downloads.'
for month in startMonth..endMonth
  m = sprintf('%02d',month)
  for day in startDay..endDay
    d = sprintf('%02d',day)
    for hour in 0..23
      h = sprintf('%02d',hour) 
      val = (yr+m+d).to_i;
      for f in ['00','01','02','03','06']
 	#f = sprintf('%02d',forecast);
	print '.'
	STDOUT.flush
	# Create file names.
	remote = '/RUC/13km/'+yr+m+'/'+yr+m+d+'/rap_130_'+yr+m+d+'_'+h+'00_0'+f+'.grb2'
        localdir = '/data/ruc_wind_data/'+yr+'/'+yr+m+d
        local = localdir+'/rap_'+yr+m+d+'_'+h+'00_0'+f+'.grb2'
          
        # Download
        localdir = File.dirname(local)
        if !File.directory?(localdir)
          FileUtils.mkdir_p(localdir)
          p 'Created dir: '+localdir
        end
        if !File.exist?(local)
          p 'Downloading: '+remote
          begin
            ftp.getbinaryfile(remote,local)
            p 'Success:  '+local
          rescue
            p 'Fail: '+local
          end
          if File.exist?(local) && (!File.size?(local))
            File.delete(local)
          end
        end
      end
    end
  end
end
ftp.close
