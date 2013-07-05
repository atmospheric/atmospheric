# Name:    rucBackfill.rb
# Author:  Chris Wynnyk
# Created: July 6th, 2012
# Purpose: This downloads RUC data from NOMADS HTTP archive.

yr = '2012'
sMonth = 10
eMonth = 10
sDay = 25
eDay = 31

for month in sMonth..eMonth
  m = sprintf('%02d',month)
  for day in sDay..eDay
    d = sprintf('%02d',day)

    # Create the local directory.
    nd = '/data/ruc_wind_data/'+yr+'/'+yr+m+d
    begin
      Dir.mkdir(nd)
      p 'Created local dir: '+nd
    rescue
      p 'Local dir exists: '+nd
    end

    for hour in 0..23
      h = sprintf('%02d',hour)
      val = (yr+m+d).to_i;
      for f in ['00']
        print '.'
        STDOUT.flush

        # Create file names.
        server = 'nomads.ncdc.noaa.gov/data/rucanl/'
        remote = server + yr+m+'/'+yr+m+d+'/'+'ruc2anl_130_'+yr+m+d+'_'+h+'00_0'+f+'.grb2'
        local = '/data/ruc_wind_data/'+yr+'/'+yr+m+d+'/ruc2_130_'+yr+m+d+'_'+h+'00_0'+f+'.grb2'
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

