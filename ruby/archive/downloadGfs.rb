# Name:    downloadGfs.rb
# Author:  Chris Wynnyk
# Purpose: Automated Ruby shell script for download of GFS.
# Created: August 6, 2012

require 'net/ftp'

def downloadDayOfGfs(ftp,time)
  yr = sprintf('%04d',time.year)
  m = sprintf('%02d',time.month)
  d = sprintf('%02d',time.day)
 
   # Create the local directory.
  localdir = '/data/gfs/'+yr+'/'+yr+m+d
  if !File.directory?(localdir)
    Dir.mkdir(localdir)
  end

  for h in ['00','06','12','18']
    val = (yr+m+d).to_i;
    for f in ['00','03','06']
      print '.'
      STDOUT.flush

       # Download the file.
#      remote = '/GFS/Grid4/'+yr+m+'/'+yr+m+d+'/gfs_4_'+yr+m+d+'_'+h+'00_0'+f+'.grb2'
      remote = '/pub/data/nccf/com/gfs/prod/gfs.'+yr+m+d+h+'/gfs.t'+h+'z.pgrb2f'+f
      local = '/data/gfs/'+yr+'/'+yr+m+d+'/gfs_'+yr+m+d+'_'+h+'00_0'+f+'.grb2'
      if !File.exist?(local)
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

p 'Starting download.'
ftp = Net::FTP::new("ftpprd.ncep.noaa.gov")
ftp.login("ftp","a")
time = Time.now.localtime
downloadDayOfGfs(ftp,time)
downloadDayOfGfs(ftp, time - (24*60*60) )
ftp.close
p 'Complete.'

