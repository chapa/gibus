with Glade.XML;use Glade.XML;
with System; use System; -- module permettant l'interaction avec la boucle événementielle principale
with Gtk.Main; -- pour les boites de dialogue
with Gtkada.Dialogs;use Gtkada.Dialogs; -- module GtkAda pour le composant fenêtre et les autres
with Gtk.Window; use Gtk.Window;
with Gtk.Button; use Gtk.Button;
with Gtk.GEntry; use Gtk.GEntry;
with Gtk.Tree_View; use Gtk.Tree_View;

package body P_window_creerfestival is

	window : Gtk_Window;
	butAnnuler1,butAnnuler2, butEnregistrer1,butEnregistrer2  : Gtk_Button;
	entryLieu,entryDate,entryPrixPlace,entryJournee1,entryJournee2,entryNbGroupe1,entryNbGroupe2,entryHeureDeb1,entryHeureDeb2 : Gtk_GEntry;
	treeviewVilles:Gtk_Tree_View;
	procedure charge is
		XML : Glade_XML;
	begin
		
		Glade.XML.Gtk_New(XML, "src/ihm/2-creerFestival.glade");
		window := Gtk_Window(Get_Widget(XML, "windowCreerFestival"));

		butAnnuler1 := Gtk_button(Get_Widget(XML, "buttonAnnuler1"));
		butAnnuler2 := Gtk_button(Get_Widget(XML, "buttonAnnuler2"));
		butEnregistrer1 := Gtk_button(Get_Widget(XML, "buttonEnregistrer1"));
		butEnregistrer2 := Gtk_button(Get_Widget(XML, "buttonEnregistrer2"));

		entryLieu := Gtk_GEntry(Get_Widget(XML, "entryLieu"));
		entryDate := Gtk_GEntry(Get_Widget(XML, "entryDate"));
		entryPrixPlace := Gtk_GEntry(Get_Widget(XML, "entryPrixPlace"));

		entryJournee1 := Gtk_GEntry(Get_Widget(XML, "entryJournee1"));
		entryJournee2 := Gtk_GEntry(Get_Widget(XML, "entryJournee2"));
		entryNbGroupe1 := Gtk_GEntry(Get_Widget(XML, "entryNbGroupe1"));

		entryNbGroupe2 := Gtk_GEntry(Get_Widget(XML, "entryNbGroupe2"));
		entryHeureDeb1 := Gtk_GEntry(Get_Widget(XML, "entryHeureDeb1"));
		entryHeureDeb2 := Gtk_GEntry(Get_Widget(XML, "entryHeureDeb2"));
		treeviewVilles := Gtk_Tree_View(Get_Widget(XML, "treeviewVilles"));


		Glade.XML.signal_connect(XML, "on_buttonAnnuler1_clicked", ferme'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonAnnuler2_clicked", affRegion1'address,null_address);

		Glade.XML.signal_connect(XML, "on_buttonEnregistrer1_clicked", affRegion2'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonEnregistrer2_clicked", enregistrer'address,null_address);
		
	end charge;

	procedure ferme (widget : access Gtk_Widget_Record'Class) is
	begin
		destroy (window);
	end ferme ;
	
	procedure enregistrer (widget : access Gtk_Widget_Record'Class)is
	
		rep : Message_Dialog_Buttons;
	begin
		rep:=Message_Dialog ("Le festival est enregistrée");
		destroy (window);
	end enregistrer;


	
	procedure affRegion1(widget : access Gtk_Widget_Record'Class)is
	begin
		set_sensitive(butAnnuler1, true);
		set_sensitive(butEnregistrer1, true);
		set_sensitive(butAnnuler2, false);
		set_sensitive(butEnregistrer2, false);

		set_sensitive(entryLieu, true);
		set_sensitive(entryDate, true);
		set_sensitive(entryPrixPlace, true);

		set_sensitive(entryJournee1, false);
		set_sensitive(entryJournee2, false);
		set_sensitive(entryNbGroupe1, false);

		set_sensitive(entryNbGroupe2, false);
		set_sensitive(entryHeureDeb1, false);
		set_sensitive(entryHeureDeb2, false);

		set_sensitive(treeviewVilles, true);


	end affRegion1;
	procedure affRegion2(widget : access Gtk_Widget_Record'Class)is
	begin
	 
	
		set_sensitive(butAnnuler1, false);
		set_sensitive(butEnregistrer1, false);
		set_sensitive(butAnnuler2, true);
		set_sensitive(butEnregistrer2, true);

		set_sensitive(entryLieu, false);
		set_sensitive(entryDate, false);
		set_sensitive(entryPrixPlace, false);

		set_sensitive(entryJournee1, true);
		set_sensitive(entryJournee2, true);
		set_sensitive(entryNbGroupe1, true);

		set_sensitive(entryNbGroupe2, true);
		set_sensitive(entryHeureDeb1, true);
		set_sensitive(entryHeureDeb2, true);

		set_sensitive(treeviewVilles, false);


	end affRegion2;
	

end P_window_creerfestival;