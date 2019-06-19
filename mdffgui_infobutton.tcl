proc MDFFGUI::gui::densitymapinfo {} {

  set text1 "Contacting Surface Area \n\n"
  set font1 "title"
  set link {http://www.ks.uiuc.edu/Research/vmd/}
  set text [list [list $text1 $font1]]
  set title "Analysis with the Computational Microscope"
  return [list ${text} $link $title]
}
