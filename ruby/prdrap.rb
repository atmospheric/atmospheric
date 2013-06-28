# Name:    prdrap.rb
# Purpose: Downloads Rapid Refresh files from NOAA Production ftp.
#
# Copyright 2013, The MITRE Corporation.  All rights reserved.

require 'net/ftp'
require 'fileutils'
require 'pathname'

module PrdRap
  @root = "/data/ruc_wind_data"
  @outlooks = [0,1,2,3,6]
  @ftpId = "yourname@yourOrg.com"
  @lateralGrid = "130"
  @verticalGrid = "bgrb"
  
  # Downloads all Rapid Refresh from the last 24 hours.
  def self.fetchLatest()
    oneDay = 60*60*24
    eTime = Time.now.utc;
    sTime = eTime - oneDay
    for outlook in @outlooks
      fetchRange(sTime,eTime,outlook)
    end
  end
  
  # Downloads Rapid Refresh from the NOAA production FTP server.
  def self.fetchRange(sTime,eTime,outlook=0,interval=3600)
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
    yr = sprintf('%04d',time.utc.year)
    m = sprintf('%02d',time.utc.month)
    d = sprintf('%02d',time.utc.day)
    h = sprintf('%02d',time.utc.hour)
    f = sprintf('%02d',outlook)
    local=@root+"/#{yr}/#{yr+m+d}/rap_#{yr+m+d}_#{h}00_0#{f}.grb2"
    remote="/pub/data/nccf/com/rap/prod/rap." + \
      "#{yr+m+d}/rap.t#{h}z.awp"+@lateralGrid+@verticalGrid+"f#{f}.grib2"
 
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
