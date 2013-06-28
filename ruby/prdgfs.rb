# Name:    prdgfs.rb
# Purpose: Downloads Global Forecast System files from NOAA Production ftp.
#
# Copyright 2013, The MITRE Corporation.  All rights reserved.

require 'net/ftp'
require 'fileutils'
require 'pathname'

module PrdGfs
  @root = "/data/gfs"
  @outlooks = [0,3,6]
  @ftpId = "yourname@yourorg.com"
  
    # Downloads all Rapid Refresh from the last 24 hours.
  def self.fetchLatest()
    oneDay = 60*60*24
    eTime = Time.now.utc;
    sTime = eTime - oneDay
    for outlook in @outlooks
      fetchRange(sTime,eTime,outlook)
    end
  end
  
  # Downloads GFS from the NOAA production FTP server.
  def self.fetchRange(sTime,eTime,outlook=0,interval=21600)
    ftp = Net::FTP::new('ftpprd.ncep.noaa.gov')
    ftp.login('ftp',@ftpId)
    hour = sTime
    while hour <= eTime
      fetch(hour,ftp,outlook)
      hour += interval
    end
    ftp.close();
  end

  def self.fetch(time,ftp,outlook)
    # Files available every six hours.
    sixHours = 60*60*6;
    time = Time.at( (time.to_f / sixHours).round * sixHours)
   
    # Naming
    yr = sprintf('%04d',time.utc.year)
    m = sprintf('%02d',time.utc.month)
    d = sprintf('%02d',time.utc.day)
    h = sprintf('%02d',time.utc.hour)
    f = sprintf('%02d',outlook)
    local = @root+'/'+yr+'/'+yr+m+d+'/gfs_'+yr+m+d+'_'+h+'00_0'+f+'.grb2'
    remote = '/pub/data/nccf/com/gfs/prod/gfs.'+yr+m+d+h+'/gfs.t'+h+'z.pgrb2f'+f
   
    # Create the destination (and folder hierarchy) if it doesn't exist.
    localdir = File.dirname(local)
    if !File.directory?(localdir)
      FileUtils.mkdir_p(localdir)
      p 'Created dir: '+localdir
    end
    
    # Download if we don't have the local file already.
    if !File.exist?(local)
      p 'Downloading: '+remote
      begin
        ftp.getbinaryfile(remote,local)
        p 'Success: '+local
      rescue
        p 'Fail: '+local
      end
      
      # If FTP fails, it creates an empty file- so we delete it.
      if File.exist?(local) && (!File.size?(local))
        File.delete(local)
      end
    end
  end

end
