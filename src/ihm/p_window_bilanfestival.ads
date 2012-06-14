--------------------------
--auteur:Vincent
--------------------------
with Gtk.Widget; use Gtk.Widget;
package P_window_bilanfestival is
 	-- Affiche la fenêtre, initialise les composants et associe les procédures handler
	procedure charge;
	-- Ferme la fenêtre
	procedure ferme(widget : access Gtk_Widget_Record'Class) ;

end P_window_bilanfestival;