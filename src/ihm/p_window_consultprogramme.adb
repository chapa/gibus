with Glade.XML; use Glade.XML;
with System; use System; -- module permettant l'interaction avec la boucle événementielle principale
with Gtk.Main; -- pour les boites de dialogue
with Gtkada.Dialogs; use Gtkada.Dialogs; -- module GtkAda pour le composant fenêtre et les autres
with Gtk.Window; use Gtk.Window;
with Gtk.Button; use Gtk.Button;
with Gtk.GEntry; use Gtk.GEntry;
with Gtk.Tree_View; use Gtk.Tree_View;

package body P_window_consultProgramme is

	window : Gtk_Window;
	butAnnuler, butConsulter, butFermer : Gtk_Button;
	entryLieu, entryDateJour1, entryDateJour2 : Gtk_GEntry;
	treeviewVille, treeviewGroupesJour1, treeviewGroupesJour2 : Gtk_Tree_View;

	procedure charge is
		XML : Glade_XML;
	begin
		Glade.XML.Gtk_New(XML, "src/ihm/7-consultProgramme.glade");
		window := Gtk_Window(Get_Widget(XML, "windowConsultProgramme"));

		butAnnuler := Gtk_button(Get_Widget(XML, "buttonAnnuler"));
		butConsulter := Gtk_button(Get_Widget(XML, "buttonConsulter"));
		butFermer := Gtk_button(Get_Widget(XML, "buttonFermer"));
		entryLieu := Gtk_GEntry(Get_Widget(XML, "entryLieu"));
		entryDateJour1 := Gtk_GEntry(Get_Widget(XML, "entryDateJour1"));
		entryDateJour2 := Gtk_GEntry(Get_Widget(XML, "entryDateJour2"));
		treeviewVille := Gtk_Tree_View(Get_Widget(XML, "treeviewVille"));
		treeviewGroupesJour1 := Gtk_Tree_View(Get_Widget(XML, "treeviewGroupesJour1"));
		treeviewGroupesJour2 := Gtk_Tree_View(Get_Widget(XML, "treeviewGroupesJour2"));

		Glade.XML.signal_connect(XML, "on_buttonConsulter_clicked", afficheProg'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonFermer_clicked", ferme'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonAnnuler_clicked", ferme'address,null_address);
	end charge;

	procedure ferme(widget : access Gtk_Widget_Record'Class) is
	begin
		destroy(window);
	end ferme;

	procedure afficheProg(widget : access Gtk_Widget_Record'Class) is
	begin
		set_sensitive(butAnnuler, false);
		set_sensitive(butConsulter, false);
		set_sensitive(butFermer, true);
		set_sensitive(entryLieu, true);
		set_sensitive(entryDateJour1, true);
		set_sensitive(entryDateJour2, true);
		set_sensitive(treeviewVille, false);
		set_sensitive(treeviewGroupesJour1, true);
		set_sensitive(treeviewGroupesJour2, true);
	end afficheProg;

end P_window_consultProgramme;