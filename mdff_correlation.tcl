############################################################################
#cr
#cr            (C) Copyright 1995-2009 The Board of Trustees of the
#cr                        University of Illinois
#cr                         All Rights Reserved
#cr
############################################################################

############################################################################
# RCS INFORMATION:
#
#       $RCSfile: mdff_correlation.tcl,v $
#       $Author: ltrabuco $        $Locker:  $             $State: Exp $
#       $Revision: 1.1 $       $Date: 2009/08/06 20:07:33 $
#
############################################################################


# MDFF package
# Authors: Leonardo Trabuco <ltrabuco@ks.uiuc.edu>
#          Elizabeth Villa <villa@ks.uiuc.edu>
#
# mdff ccc
#

package require volutil
package require mdff_tmp
package provide mdff_correlation 0.2

namespace eval ::MDFF::Correlation:: {
  variable defaultGridspacing 1.0
  variable defaultCCDeprecate 0
}

proc ::MDFF::Correlation::mdff_ccc_usage { } {

  variable defaultGridspacing
  variable defaultCCDeprecate
 
  puts "Usage: mdff ccc <atom selection> -i <input map> -res <map resolution in Angstroms> ?options?"
  puts "Options:"
  puts "  -spacing <grid spacing in Angstroms> (default based on res, otherwise if using -deprecate: $defaultGridspacing)"
  puts "  -threshold <x> (ignores voxels with values below x threshold. If using -deprecate, x is sigmas)"
  puts "  -allframes (average over all frames)"
  puts "  -deprecate <use the older, slower correlation algorithm> (on: 1 off: 0, default:$defaultCCDeprecate)"
  
}

proc ::MDFF::Correlation::mdff_ccc { args } {

  variable defaultGridspacing
  variable defaultCCDeprecate

  set nargs [llength [lindex $args 0]]
  if {$nargs == 0} {
    mdff_ccc_usage
    error ""
  }

  set sel [lindex $args 0]
  if { [$sel num] == 0 } {
    error "Empty atom selection."
  } 

  # should we use all frames?
  set pos [lsearch -exact $args {-allframes}]
  if { $pos != -1 } {
    set allFrames 1
    set args [lreplace $args $pos $pos]
  } else {
    set allFrames 0
  }

  foreach {name val} [lrange $args 1 end] {
    switch -- $name {
      -i { set arg(i) $val }
      -res { set arg(res) $val }
      -spacing { set arg(spacing) $val }
      -threshold { set arg(threshold) $val }
      -deprecate { set arg(deprecate) $val }
    }
  }

  if { [info exists arg(i)] } {
    set inputMap $arg(i)
  } else {
    error "Missing input map."
  }

  if { [info exists arg(res)] } {
    set res $arg(res)
  } else {
    error "Missing input map resolution."
  }

  if { [info exists arg(spacing)] } {
    set spacing $arg(spacing)
    set use_gridspacingdefault 0
  } else {
    set spacing $defaultGridspacing
    set use_gridspacingdefault 1
  }

  if { [info exists arg(threshold)] } {
    set threshold $arg(threshold)
    set use_threshold 1
  } else {
    set use_threshold 0
  }
  
  if { [info exists arg(deprecate)] } {
    set deprecate $arg(deprecate)
  } else {
    set deprecate $defaultCCDeprecate
  }

  if $deprecate {
    # Get temporary filenames
    set tmpDir [::MDFF::Tmp::tmpdir]
    set tmpDX [file join $tmpDir \
      [::MDFF::Tmp::tmpfilename -prefix mdff_corr -suffix .dx -tmpdir $tmpDir]]
    set tmpDX2 [file join $tmpDir \
      [::MDFF::Tmp::tmpfilename -prefix mdff_corr -suffix .dx -tmpdir $tmpDir]]
    set tmpLog [file join $tmpDir \
      [::MDFF::Tmp::tmpfilename -prefix mdff_corr -suffix .log -tmpdir $tmpDir]]

    # Create simulated map
    if $allFrames {
      ::MDFF::Sim::mdff_sim $sel -o $tmpDX -res $res -spacing $spacing -allframes -deprecate 1
    } else {
      ::MDFF::Sim::mdff_sim $sel -o $tmpDX -res $res -spacing $spacing -deprecate 1
    }

    if $use_threshold {
      # Set voxels above the given threshold to NAN
      ::VolUtil::volutil -threshold $threshold $tmpDX -o $tmpDX2
      # Calculate correlation
      ::VolUtil::volutil -tee $tmpLog -quiet -safe -corr $inputMap $tmpDX2
    } else {
      # Calculate correlation
      ::VolUtil::volutil -tee $tmpLog -quiet -corr $inputMap $tmpDX
    }

    file delete $tmpDX
    file delete $tmpDX2

    # parse the output to get the correlation coefficient
    set file [open $tmpLog r]
    gets $file line
    while {$line != ""} {
      if { [regexp {^Correlation coefficient = (.*)} $line fullmatch cc] } {
        break
      }
      gets $file line
    }
    close $file

    file delete $tmpLog
  } elseif $use_threshold {
    if $use_gridspacingdefault {
        set cc [voltool cc $sel -i $inputMap -res $res -thresholddensity $threshold]
      } else {
        set cc [voltool cc $sel -i $inputMap -res $res -thresholddensity $threshold -spacing $spacing]
      }
  } else {
    if $use_gridspacingdefault {
        set cc [voltool cc $sel -i $inputMap -res $res]
      } else {
        set cc [voltool cc $sel -i $inputMap -res $res -spacing $spacing]
      }
  }

  return $cc

}

