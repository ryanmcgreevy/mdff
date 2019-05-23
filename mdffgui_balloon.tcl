#text for the popup balloons when user hover overs GUI elements

proc MDFFGUI::gui::workingdir {} {
  return "Directory to where all output files will be written."
}

proc MDFFGUI::gui::currentmol {} {
  return "Already loaded molecule with a .psf and .pdb for your starting structure."
}

proc MDFFGUI::gui::currentdensitymap {} {
  return "Add density map(s) as a target for fitting."
}

proc MDFFGUI::gui::fixedpdbtext {} {
  return "atomselection text for fixing a part of your structure during fitting."
}

proc MDFFGUI::gui::fixedpdbcolumn {} {
  return "Column in output PDB file to use to mark fixed atoms."
}

proc MDFFGUI::gui::simoutputname {} {
  return "Name prefix for simulation output files."
}

proc MDFFGUI::gui::simstep {} {
  return "Step of the fitting process. Numbers after 1 will automatically proceed from where the previous simulation finished."
}

proc MDFFGUI::gui::restraints {} {
  return "Automatically generate optional simulation restraints to prevent overfitting."
}

proc MDFFGUI::gui::ssrestraints {} {
  return "Restrain dihedral angles in secondary structures of protein as well as dihedral angles and base pairs in nucleic acids."
}

proc MDFFGUI::gui::chiralityrestraints {} {
  return "Restrain chiral centers to their initial handedness."
}

proc MDFFGUI::gui::cispeptiderestraints {} {
  return "Restrain cis peptide bonds to their initial cis or trans configuration."
}

proc MDFFGUI::gui::parameters {} {
  return "Force field parameter files to use during simulation."
}

proc MDFFGUI::gui::mdfffiles {} {
  return "Input and output file information for MDFF fitting simulations."
}

proc MDFFGUI::gui::simparams {} {
  return "Parameters controlling length, environment, and other general aspects of the simulation."
}

