# Name:    downloadRucArchive.rb
# Author:  Chris Wynnyk
# Purpose: Automated Ruby shell script for mass download of GFS data.
# Created: March 16, 2011
#
# Usage:
#    This downloads the NOMADS archive of GFS data.

require 'net/ftp'

yr = '2012'
sMonth = 8
eMonth = 8
sDay = 1
eDay = 6

ftp = Net::FTP::new("ftp.ruby-lang.org")
ftp = Net::FTP::new("nomads.ncdc.noaa.gov")
ftp.login("ftp","a")

for month in sMonth..eMonth
  m = sprintf('%02d',month)
  for day in sDay..eDay
    d = sprintf('%02d',day)

    # Create the local directory.
    nd = '/data/gfs/'+yr+'/'+yr+m+d
    begin
      Dir.mkdir(nd)
      p 'Created local dir: '+nd
    rescue
      p 'Local dir exists: '+nd
    end

    for h in ['00','06','12','18']
      val = (yr+m+d).to_i;
      for f in ['00','03','06']
        print '.'
        STDOUT.flush

        # Create file names.
        remote = '/GFS/Grid4/'+yr+m+'/'+yr+m+d+'/gfs_4_'+yr+m+d+'_'+h+'00_0'+f+'.grb2'
        local = '/data/gfs/'+yr+'/'+yr+m+d+'/gfs_'+yr+m+d+'_'+h+'00_0'+f+'.grb2'
        begin
          ftp.getbinaryfile(remote,local)
          p 'Success: '+remote
        rescue
          p 'Fail: '+remote
          `#{'rm '+local}`
        next
        end
      end
    end
  end
end
ftp.close

