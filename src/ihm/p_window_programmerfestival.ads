with Gtk.Widget; use Gtk.Widget;

package P_Window_ProgrammerFestival is

	procedure charge;
	procedure ferme(widget : access Gtk_Widget_Record'Class);
	procedure affRegion1(widget : access Gtk_Widget_Record'Class);
	procedure affRegion2(widget : access Gtk_Widget_Record'Class);
	procedure enregistrerFestival(widget : access Gtk_Widget_Record'Class);

end P_Window_ProgrammerFestival;