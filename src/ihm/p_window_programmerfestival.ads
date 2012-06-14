with Gtk.Widget; use Gtk.Widget;

package P_Window_ProgrammerFestival is

	-- Auteur : Mickaël Bourgier
	-- Affiche la fenêtre, initialise les composants et associe les procédures handler
	procedure charge;

	-- Auteur : Mickaël Bourgier
	-- Ferme la fenêtre
	procedure ferme(widget : access Gtk_Widget_Record'Class);

	-- Auteur : Mickaël Bourgier
	-- Affiche la région 1 de la fenêtre
	procedure affRegion1(widget : access Gtk_Widget_Record'Class);

	-- Auteur : Mickaël Bourgier
	-- Affiche la région 2 de la fenêtre
	procedure affRegion2(widget : access Gtk_Widget_Record'Class);

	-- Auteur : Mickaël Bourgier
	-- Ajoute le groupe dans la treeview de la journée 1
	procedure ajouterGroupeJ1(widget : access Gtk_Widget_Record'Class);

	-- Auteur : Mickaël Bourgier
	-- Retire le groupe dans la treeview de la journée 1
	procedure retirerGroupeJ1(widget : access Gtk_Widget_Record'Class);

	-- Auteur : Mickaël Bourgier
	-- Ajoute le groupe dans la treeview de la journée 2
	procedure ajouterGroupeJ2(widget : access Gtk_Widget_Record'Class);

	-- Auteur : Mickaël Bourgier
	-- Retire le groupe dans la treeview de la journée 2
	procedure retirerGroupeJ2(widget : access Gtk_Widget_Record'Class);

	-- Auteur : Mickaël Bourgier
	-- Enregistre la programmation du festival
	procedure enregistrerFestival(widget : access Gtk_Widget_Record'Class);

end P_Window_ProgrammerFestival;