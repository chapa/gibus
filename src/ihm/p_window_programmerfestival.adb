with Glade.XML;use Glade.XML;
with System; use System; -- module permettant l'interaction avec la boucle événementielle principale
with Gtk.Main; -- pour les boites de dialogue
with Gtkada.Dialogs;use Gtkada.Dialogs; -- module GtkAda pour le composant fenêtre et les autres
with Gtk.Window; use Gtk.Window;
with Gtk.Button; use Gtk.Button;
with Gtk.GEntry; use Gtk.GEntry;
with Gtk.Arrow; use Gtk.Arrow;
with Gtk.Tree_View; use Gtk.Tree_View;

package body P_Window_ProgrammerFestival is

	window : Gtk_Window;
	butAnnuler1, butValider1, butAnnuler2, butValider2 : Gtk_Button;
	entryJournee1, entryJournee2 : Gtk_GEntry;
	arrowJournee1Down, arrowJournee1Up, arrowJournee2Down, arrowJournee2Up : Gtk_Arrow;
	treeviewVilles, treeviewListeGroupes, treeviewJournee1, treeviewJournee2 : Gtk_Tree_View;

	procedure charge is
		XML : Glade_XML;
	begin
		Glade.XML.Gtk_New(XML, "src/ihm/5-programmerFestival.glade");
		window := Gtk_Window(Get_Widget(XML, "windowProgrammerFestival"));

		butAnnuler1 := Gtk_button(Get_Widget(XML, "buttonAnnuler1"));
		butValider1 := Gtk_button(Get_Widget(XML, "buttonValider1"));
		butAnnuler2 := Gtk_button(Get_Widget(XML, "buttonAnnuler2"));
		butValider2 := Gtk_button(Get_Widget(XML, "buttonValider2"));
		entryJournee1 := Gtk_GEntry(Get_Widget(XML, "entryJournee1"));
		entryJournee2 := Gtk_GEntry(Get_Widget(XML, "entryJournee2"));
		arrowJournee1Down := Gtk_Arrow(Get_Widget(XML, "arrowJournee1Down"));
		arrowJournee1Up := Gtk_Arrow(Get_Widget(XML, "arrowJournee1Up"));
		arrowJournee2Down := Gtk_Arrow(Get_Widget(XML, "arrowJournee2Down"));
		arrowJournee2Up := Gtk_Arrow(Get_Widget(XML, "arrowJournee2Up"));
		treeviewVilles := Gtk_Tree_View(Get_Widget(XML, "treeviewVilles"));
		treeviewListeGroupes := Gtk_Tree_View(Get_Widget(XML, "treeviewListeGroupes"));
		treeviewJournee1 := Gtk_Tree_View(Get_Widget(XML, "treeviewJournee1"));
		treeviewJournee2 := Gtk_Tree_View(Get_Widget(XML, "treeviewJournee2"));

		Glade.XML.signal_connect(XML, "on_buttonAnnuler1_clicked", ferme'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonValider1_clicked", affRegion2'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonAnnuler2_clicked", affRegion1'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonValider2_clicked", enregistrerFestival'address,null_address);
	end charge;

	procedure ferme(widget : access Gtk_Widget_Record'Class) is
	begin
		destroy (window);
	end ferme;

	procedure affRegion1(widget : access Gtk_Widget_Record'Class) is
	begin
		set_sensitive(butAnnuler1, true);
		set_sensitive(butValider1, true);
		set_sensitive(butAnnuler2, false);
		set_sensitive(butValider2, false);
		set_sensitive(entryJournee1, false);
		set_sensitive(entryJournee2, false);
		set_sensitive(arrowJournee1Down, false);
		set_sensitive(arrowJournee1Up, false);
		set_sensitive(arrowJournee2Down, false);
		set_sensitive(arrowJournee2Up, false);
		set_sensitive(treeviewVilles, true);
		set_sensitive(treeviewListeGroupes, false);
		set_sensitive(treeviewJournee1, false);
		set_sensitive(treeviewJournee2, false);
	end affRegion1;

	procedure affRegion2(widget : access Gtk_Widget_Record'Class) is
	begin
		set_sensitive(butAnnuler1, false);
		set_sensitive(butValider1, false);
		set_sensitive(butAnnuler2, true);
		set_sensitive(butValider2, true);
		set_sensitive(entryJournee1, true);
		set_sensitive(entryJournee2, true);
		set_sensitive(arrowJournee1Down, true);
		set_sensitive(arrowJournee1Up, true);
		set_sensitive(arrowJournee2Down, true);
		set_sensitive(arrowJournee2Up, true);
		set_sensitive(treeviewVilles, false);
		set_sensitive(treeviewListeGroupes, true);
		set_sensitive(treeviewJournee1, true);
		set_sensitive(treeviewJournee2, true);
	end affRegion2;

	procedure enregistrerFestival(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;
	begin
		rep := Message_Dialog("Le festival a bien été enregistré");
		destroy(window);
	end enregistrerFestival;

end P_Window_ProgrammerFestival;