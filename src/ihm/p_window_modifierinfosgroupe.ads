with Gtk.Widget; use Gtk.Widget;

package P_Window_ModifierInfosGroupe is

	-- Auteur : Mickaël Bourgier
	-- Affiche la fenêtre, initialise les composants et associe les procédures handler
	procedure charge;

	-- Auteur : Mickaël Bourgier
	-- Ferme la fenêtre
	procedure ferme(widget : access Gtk_Widget_Record'Class);

	-- Auteur : Mickaël Bourgier
	-- Affiche la région 1
	procedure affRegion1(widget : access Gtk_Widget_Record'Class);

	-- Auteur : Mickaël Bourgier
	-- Affiche la région 2
	procedure affRegion2(widget : access Gtk_Widget_Record'Class);

	-- Auteur : Mickaël Bourgier
	-- Enregistre le groupe
	procedure enregistrer(widget : access Gtk_Widget_Record'Class);

end P_Window_ModifierInfosGroupe;