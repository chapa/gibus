--------------------------
--auteur:Vincent
--------------------------
with Gtk.Widget; use Gtk.Widget;

package p_window_consultfestival is

	-- Affiche la fenêtre, initialise les composants et associe les procédures handler
	procedure charge;
	-- Ferme la fenêtre
	procedure ferme_win_affGroupe (widget : access Gtk_Widget_Record'Class);
	-- Affiche la région 1
	procedure affRegion1(widget : access Gtk_Widget_Record'Class);
	-- Affiche la région 2
	procedure affRegion2(widget : access Gtk_Widget_Record'Class);

end p_window_consultfestival;