# Name:    downloadRucArchive.rb
# Author:  Chris Wynnyk
# Created: July 5th, 2012
# Purpose: This downloads GFS data from NOMADS HTTP archive.

yr = '2010'
sMonth = 1
eMonth = 7
sDay = 1
eDay = 31

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
        server = 'nomads.ncdc.noaa.gov/data/gfsanl/'
        remote = server + yr+m+'/'+yr+m+d+'/'+'gfsanl_4_'+yr+m+d+'_'+h+'00_0'+f+'.grb2'
        local = '/data/gfs/'+yr+'/'+yr+m+d+'/gfs_4_'+yr+m+d+'_'+h+'00_0'+f+'.grb2'
        begin
          cmd = 'wget '+remote+' -O '+local
	 `#{cmd}`
          p 'Success: '+remote
        rescue
          p 'Failed:  '+remote
        next
        end
      end
    end
  end
end

