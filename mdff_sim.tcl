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
#       $RCSfile: mdff_sim.tcl,v $
#       $Author: ltrabuco $        $Locker:  $             $State: Exp $
#       $Revision: 1.1 $       $Date: 2009/08/06 20:07:34 $
#
############################################################################


# MDFF package
# Authors: Leonardo Trabuco <ltrabuco@ks.uiuc.edu>
#          Elizabeth Villa <villa@ks.uiuc.edu>
#
# mdff sim -- creates a simulated map from an atomic structure
#

package require volutil
package require mdff_tmp
package provide mdff_sim 0.2

namespace eval ::MDFF::Sim:: {

  variable defaultGridspacing 1.0
  variable defaultTargetResolution 10.0
  variable defaultCCDeprecate 0
}

proc ::MDFF::Sim::mdff_sim_usage { } {

  variable defaultTargetResolution
  variable defaultGridspacing
  variable defaultCCDeprecate 

  puts "Usage: mdff sim <atomselection> -o <output map> ?options?"
  puts "Options:"
  puts "  -res <target resolution in Angstroms> (default: $defaultTargetResolution)"
  puts "  -spacing <grid spacing in Angstroms> (default based on res, otherwise if using -deprecate: $defaultGridspacing)"
  puts "  -allframes (average over all frames)"
  puts "  -deprecate <use the older, slower correlation algorithm> (on: 1 off: 0, default:$defaultCCDeprecate)"

}

proc ::MDFF::Sim::mdff_sim { args } {

  variable defaultGridspacing
  variable defaultTargetResolution
  variable defaultCCDeprecate

  set nargs [llength $args]
  if {$nargs == 0} {
    mdff_sim_usage
    error ""
  }

  set sel [lindex $args 0]
  if { [$sel num] == 0 } {
    error "mdff_sim: empty atomselection."
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
      -o     { set arg(o)     $val }
      -res   { set arg(res)   $val }
      -spacing { set arg(spacing) $val }
      -deprecate { set arg(deprecate) $val }
    }
  }

  if { [info exists arg(spacing)] } {
    set gridspacing $arg(spacing)
    set use_gridspacingdefault 0
  } else {
    set gridspacing $defaultGridspacing
    set use_gridspacingdefault 1
  }

  if { [info exists arg(res)] } {
    set targetResolution $arg(res)
  } else {
    set targetResolution $defaultTargetResolution
  }
  
  if { [info exists arg(deprecate)] } {
    set deprecate $arg(deprecate)
  } else {
    set deprecate $defaultCCDeprecate
  }

  if { [info exists arg(o)] } {
    set dxout $arg(o)
  } else {
    error "Missing output dx map."
  }

  if $deprecate {
    # Interpolate atomic numbers onto a map
    set weight [::MDFF::Tmp::getAtomicNumber $sel]

    # Get temporary filename
    set tmpDir [::MDFF::Tmp::tmpdir]
    set tmpDX [file join $tmpDir \
      [::MDFF::Tmp::tmpfilename -prefix mdff_sim -suffix .dx -tmpdir $tmpDir]]

    if $allFrames {
      volmap interp $sel -res $gridspacing -weight $weight -o $tmpDX -allframes
    } else {
      volmap interp $sel -res $gridspacing -weight $weight -o $tmpDX
    }

    # Low pass filter to the target resolution 
    # volutil pre-divides sigma by sqrt(3), so we don't have to do it here
    set sigma [expr {0.5 * $targetResolution}]
    ::VolUtil::volutil -o $dxout -pad -smooth $sigma $tmpDX

    file delete $tmpDX
  } elseif $use_gridspacingdefault {
    voltool sim $sel -res $targetResolution -o $dxout 
  } else {
    voltool sim $sel -res $targetResolution -spacing $gridspacing -o $dxout 
  }
  return

}


