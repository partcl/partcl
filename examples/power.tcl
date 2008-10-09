#!/bin/sh
# \
exec ../../../parrot ../tcl.pbc "$0" "$@"

proc power {number power} {
  set val 1
  while {$power != 0} {
    set val [expr $val * $number]
    incr power -1
  }
  return $val
}

puts "10**2 is [power 10 2]"
puts "2**10 is [power 2 10]"
