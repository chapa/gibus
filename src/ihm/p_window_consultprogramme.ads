with Gtk.Widget; use Gtk.Widget;

package P_window_consultProgramme is

	-- Auteur : Mickaël Bourgier
	-- Affiche la fenêtre, initialise les composants et associe les procédures handler
	procedure charge;
	
	-- Auteur : Mickaël Bourgier
	-- Ferme la fenêtre
	procedure ferme (widget : access Gtk_Widget_Record'Class);
	
	-- Auteur : Mickaël Bourgier
	-- Affiche la région 1
	procedure annule_affProg (widget : access Gtk_Widget_Record'Class);
	
	-- Auteur : Mickaël Bourgier
	-- Affiche la région 2
	procedure affiche_prog (widget : access Gtk_Widget_Record'Class);

end P_window_consultProgramme;