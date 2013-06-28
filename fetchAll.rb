# Purpose: Fetch all the most recent data.
#
# Copyright 2013, The MITRE Corporation. All rights reserved.

require File.dirname(__FILE__) + '/prdruc'
require File.dirname(__FILE__) + '/prdgfs'

p "Starting archive service at: #{Time.now.utc().to_s}"
PrdGfs.fetchLatest()
PrdRuc.fetchLatest()
p "Completed archive service at: #{Time.now.utc().to_s}"
