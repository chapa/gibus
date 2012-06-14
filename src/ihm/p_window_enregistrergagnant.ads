--------------------------
--auteur:Vincent
--------------------------
with Gtk.Widget; use Gtk.Widget;
package P_window_enregistrerGagnant is
 	-- Affiche la fenêtre, initialise les composants et associe les procédures handler
	procedure charge;
	-- Ferme la fenêtre
	procedure ferme(widget : access Gtk_Widget_Record'Class) ;
	--affiche la région 1 de la fenêtre
	procedure affRegion1;
	--affiche la région2 de la fenêtre
	procedure affRegion2(widget : access Gtk_Widget_Record'Class);
	--enregistre le gagnant
	procedure enregistrer (widget : access Gtk_Widget_Record'Class);


end P_window_enregistrerGagnant;