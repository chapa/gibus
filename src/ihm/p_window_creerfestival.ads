--------------------------
--auteur:Vincent
--------------------------
with Gtk.Widget; use Gtk.Widget;

package P_window_creerfestival is
	--charge les composant de la fenêtre
	procedure charge;
	--ferme la fenêtre
	procedure ferme (widget : access Gtk_Widget_Record'Class);
	--enregistre le festival avec ces journées
	procedure enregistrer (widget : access Gtk_Widget_Record'Class);
	--affiche la region 1 de la fenêtre
	procedure affRegion1(widget : access Gtk_Widget_Record'Class);
	--affiche la région 2 de la fenêtre
	procedure affRegion2(widget : access Gtk_Widget_Record'Class);
end P_window_creerfestival;