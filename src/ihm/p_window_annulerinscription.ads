--------------------------
--auteur:Vincent
--------------------------
with Gtk.Widget; use Gtk.Widget;

package  p_window_annulerinscription is
	-- Affiche la fenêtre, initialise les composants et associe les procédures handler
	procedure charge;
	--ferme la fenêtre
	procedure ferme (widget : access Gtk_Widget_Record'Class);
	--supprime l'inscrition d'un groupe
	procedure supprimer (widget : access Gtk_Widget_Record'Class);

end p_window_annulerinscription;
