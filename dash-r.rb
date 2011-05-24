#!/usr/bin/env ruby

# -r -- git revisions numbers at last!
# Copyright 2011  James M. Jensen II <badocelot@badocelot.com>
# License: GNU General Public License, Version 2 or later

def parse_revision rev
	if rev == "0"
		0
	elsif rev.to_i != 0 and rev !~ /[\._]/ then
		rev.to_i
	else
		rev
	end
end

if __FILE__ == $0
	if (ARGV.length == 0) then
		# print the log, w/ rev #'s
		log = `git log`
		# Escape existing %'s
		log.gsub!('%','%%')
		# Replace the "commit <hash>" lines with something more useful...
		log.gsub!(/^(commit) ([0-9a-fA-F]+)$/,
		          "\\1 %d  id: \\2")
		
		# print the whole mess, putting version numbers in there
		# TODO find a better way of getting the commits count
		num_revs = `git log --pretty=format:'' | wc -l`.to_i + 1
		puts log % num_revs.times.map.reverse
	else
		# get the checksums
		revs = `git log --pretty=format:'%H'`.split("\n").reverse
		revno = ARGV.shift

		# check for ranges
		if revno =~ /[^\.](\.{2,3})[^\.]/ then
			dots = $1
			first, last = revno.split(dots).map {|rev| parse_revision rev}
			puts ((first.is_a? Fixnum) ? revs[first] : first) + dots \
			     + ((last) ? ((last.is_a? Fixnum) ? revs[last] : last) : "")
		else
			# but if there's only one...
			revno = parse_revision revno
			if revno.is_a? Fixnum then
				puts revs[revno]
			else
				puts revno
			end
		end
	end
end
