# Name:    Gfs.rb
# Author:  Chris Wynnyk
# Purpose: Download GFS data.
# Created: August 29th, 2012
require 'net/ftp'
require 'fileutils'
require 'pathname'

module Noaa
  class Gfs
    # Gfs.download Downloads a time range from the NOAA server.
    #
    def self.download(sTime,eTime,outlook=0,interval=21600)
      ftp = Net::FTP::new('ftpprd.ncep.noaa.gov')
      ftp.login('ftp','cwynnyk@mitre.org')
      hour = sTime
      while hour <= eTime
        downloadSingleFile(hour,ftp,outlook)
        hour += interval
      end
      ftp.close();
    end

    def self.latest()
      p 'GFS: Defaulting to downloading previous 24 hours'
      sixHours = 60*60*6
      oneDay = 60*60*24
      eTime = Time.at((Time.now.utc.to_f / sixHours).floor * sixHours)
      sTime = eTime - oneDay
      for outlook in [0,3,6]
        download(sTime,eTime,outlook)
      end
    end

    private

    def self.downloadSingleFile(time,ftp,outlook)
      # Files available every six hours.
      sixHours = 60*60*6;
      time = Time.at( (time.to_f / sixHours).round * sixHours)
     
      # Naming
      yr = sprintf('%04d',time.utc.year)
      m = sprintf('%02d',time.utc.month)
      d = sprintf('%02d',time.utc.day)
      h = sprintf('%02d',time.utc.hour)
      f = sprintf('%02d',outlook)
      local = '/data/gfs/'+yr+'/'+yr+m+d+'/gfs_'+yr+m+d+'_'+h+'00_0'+f+'.grb2'
      remote = '/pub/data/nccf/com/gfs/prod/gfs.'+yr+m+d+h+'/gfs.t'+h+'z.pgrb2f'+f
    
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
