with Gtk.Widget; use Gtk.Widget;

package P_window_consultGroupe is

	-- Auteur : Mickaël Bourgier
	-- Affiche la fenêtre, initialise les composants et associe les procédures handler
	procedure charge;
	
	-- Auteur : Mickaël Bourgier
	-- Ferme la fenêtre
	procedure ferme (widget : access Gtk_Widget_Record'Class);
	
	-- Auteur : Mickaël Bourgier
	-- Affiche la région 2
	procedure afficheGroupe (widget : access Gtk_Widget_Record'Class);

end P_window_consultGroupe;