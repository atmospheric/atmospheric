# The program creates a local cache of the RUC wind files.
#
# @author Chris Wynnyk
# @example
#   For automated downloading of RUC data:
#     ssh into the comp64 cluster
#     crontab -e to open up the vi editor
#     'escape-i' to set insert mode
#     Add the following line for hourly updating:
#
#        * 0 * * * ruby /home/cwynnyk/downloadRuc.rb
#
#     Escape- wq <enter key>  to save and close
#
# @todo
#    Change over to using FileUtil class once comp64 is updated to 1.92

# Copyright 2011, The MITRE Corporation.  All rights reserved.
#==========================================================================
 
require 'net/ftp'
#require 'FileUtils'

# Downloads an entire day's worth of RUC from the NOAA.gov website.
# Saves data directly to samba share drive.
#
# @param [Number] Time
def downloadDayOfRuc(time)
yr = sprintf('%04d',time.year)
m = sprintf('%02d',time.month)
d = sprintf('%02d',time.day)

remotedir = '/pub/data/nccf/com/rap/prod/rap.'+yr+m+d+'/'
localdir = '/data/ruc_wind_data/'+yr+'/'+yr+m+d+'/'

# Create local storage directory.
#if !Dir.exist?(localdir)
if !File.directory?(localdir)
  #FileUtils.mkdir_p(localdir)
  Dir.mkdir(localdir)
end

# Login to NOAA
ftp=Net::FTP::new('ftpprd.ncep.noaa.gov')
ftp.login('ftp','a');

# Start download.
for grid in ['130bgrb']
  for hour in 0..23
    hr = sprintf('%02d',hour);
    for outlook in ['00','01','02','03','06']
      filename='rap.t'+hr+'z.awp'+grid+'f'+outlook+'.grib2'
      localfile = localdir+'rap_'+yr+m+d+'_'+hr+'00_0'+outlook+'.grb2'
      begin     
         if !File.exist?(localfile)
           p 'Attempting Download '+filename
           ftp.getbinaryfile(remotedir+filename,localfile)
           p 'Download complete: '+filename
         end
      rescue
        if File.exist?(localfile)
          p 'File unavailable: ' + filename
          `rm #{localfile}`
        end
        next
      end
    end
  end
end

ftp.close
end


###############################################################################
## Main function
time = Time.now.localtime
downloadDayOfRuc(time)  # Grab today's data.
downloadDayOfRuc(time -(24*60*60) )  # Grab yesterday's data.

p 'Downloading complete.'

