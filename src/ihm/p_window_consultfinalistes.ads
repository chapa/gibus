with Gtk.Widget; use Gtk.Widget;

package P_Window_ConsultFinalistes is

	-- Auteur : Mickaël Bourgier
	-- Affiche la fenêtre, initialise les composants et associe les procédures handler
	procedure charge;

	-- Auteur : Mickaël Bourgier
	-- Ferme la fenêtre
	procedure ferme(widget : access Gtk_Widget_Record'Class);

end P_Window_ConsultFinalistes;