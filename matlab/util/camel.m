function out = camel(str)
%CAMEL Converts a string to camelCase using regular expressions.
%
%INPUTS:
%  str - String or cell array of strings.
%
%OUTPUTS:
%  out - CamelCased version of input.
%
%SYNTAX:
%  out = camel(str)

% Copyright 2013, The MITRE Corporation.  All rights reserved.
%==========================================================================
str = regexprep(str,'[A-Z]{2,}','${[upper($0(1)), lower($0(2:end))]}');
str = regexprep(str,'^[A-Z]+','${lower($0)}');
str = regexprep(str,'_.','${upper($0(2))}');
out = regexprep(str,'-.','${upper($0(2))}');
