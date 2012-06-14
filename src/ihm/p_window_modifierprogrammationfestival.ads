with Gtk.Widget; use Gtk.Widget;

package P_Window_ModifierProgrammationFestival is

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
	-- Echange les deux groupes sélectionné dans les deux treeviews
	procedure permut(widget : access Gtk_Widget_Record'Class);
	
	-- Auteur : Mickaël Bourgier
	-- Remonte d'une place le groupe selectionné de la journée 1
	procedure upJ1(widget : access Gtk_Widget_Record'Class);
	
	-- Auteur : Mickaël Bourgier
	-- Redescend d'une place le groupe selectionné de la journée 1
	procedure downJ1(widget : access Gtk_Widget_Record'Class);
	
	-- Auteur : Mickaël Bourgier
	-- Remonte d'une place le groupe selectionné de la journée 2
	procedure upJ2(widget : access Gtk_Widget_Record'Class);
	
	-- Auteur : Mickaël Bourgier
	-- Redescend d'une place le groupe selectionné de la journée 2
	procedure downJ2(widget : access Gtk_Widget_Record'Class);
	
	-- Auteur : Mickaël Bourgier
	-- Enregistre la programmation du festival
	procedure enregistrer(widget : access Gtk_Widget_Record'Class);

end P_Window_ModifierProgrammationFestival;