--------------------------
--auteur:Vincent
--------------------------
with Gtk.Widget; use Gtk.Widget;

package  p_window_consultergroupepargenre is
	-- Affiche la fenêtre, initialise les composants et associe les procédures handler
	procedure charge;
	--ferme la fenêtre
	procedure ferme (widget : access Gtk_Widget_Record'Class);
	--affiche la région 1 de la fenêtre
	procedure affRegion1;
	--affiche la région2 de la fenêtre
	procedure affRegion2(widget : access Gtk_Widget_Record'Class);
end p_window_consultergroupepargenre;
