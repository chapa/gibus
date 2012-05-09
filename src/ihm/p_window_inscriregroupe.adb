with Glade.XML;use Glade.XML;
with System; use System; -- module permettant l'interaction avec la boucle événementielle principale
with Gtk.Main; -- pour les boites de dialogue
with Gtkada.Dialogs;use Gtkada.Dialogs; -- module GtkAda pour le composant fenêtre et les autres
with Gtk.Window; use Gtk.Window;
with Gtk.Button; use Gtk.Button;
with Gtk.GEntry; use Gtk.GEntry;
with Gtk.Tree_View; use Gtk.Tree_View;
with Gtk.Toggle_Button; use Gtk.Toggle_Button;

package body P_Window_InscrireGroupe is

	window : Gtk_Window;
	butAnnuler, butChoisir, butAnnuler2, butEnregistrer : Gtk_Button;
	entryNbConcertsPrevus, entryNbInscriptionsPossibles, entryNomGroupe, entryNomContact, entryCoordsContact, entryAdresseSite : Gtk_GEntry;
	treeViewVilles, treeViewGroupes : Gtk_Tree_View;
	radiobuttonHard, radiobuttonFusion, radiobuttonAlternatif, radiobuttonPop, radiobuttonPunk, radiobuttonRockabilly : Gtk_Toggle_Button;

	procedure charge is
		XML : Glade_XML;
	begin
		Glade.XML.Gtk_New(XML, "src/ihm/4-inscrireGroupe.glade");
		window := Gtk_Window(Get_Widget(XML, "windowInscrireGroupe"));

		butAnnuler := Gtk_button(Get_Widget(XML, "buttonAnnuler"));
		butChoisir := Gtk_button(Get_Widget(XML, "buttonChoisir"));
		butAnnuler2 := Gtk_button(Get_Widget(XML, "buttonAnnuler2"));
		butEnregistrer := Gtk_button(Get_Widget(XML, "buttonEnregistrer"));
		entryNbConcertsPrevus := Gtk_GEntry(Get_Widget(XML, "entryNbConcertsPrevus"));
		entryNbInscriptionsPossibles := Gtk_GEntry(Get_Widget(XML, "entryNbInscriptionsPossibles"));
		entryNomGroupe := Gtk_GEntry(Get_Widget(XML, "entryNomGroupe"));
		entryNomContact := Gtk_GEntry(Get_Widget(XML, "entryNomContact"));
		entryCoordsContact := Gtk_GEntry(Get_Widget(XML, "entryCoordsContact"));
		entryAdresseSite := Gtk_GEntry(Get_Widget(XML, "entryAdresseSite"));
		treeViewVilles := Gtk_Tree_View(Get_Widget(XML, "treeViewVilles"));
		treeViewGroupes := Gtk_Tree_View(Get_Widget(XML, "treeViewGroupes"));
		radiobuttonHard := Gtk_Toggle_Button(Get_Widget(XML, "radiobuttonHard"));
		radiobuttonFusion := Gtk_Toggle_Button(Get_Widget(XML, "radiobuttonFusion"));
		radiobuttonAlternatif := Gtk_Toggle_Button(Get_Widget(XML, "radiobuttonAlternatif"));
		radiobuttonPop := Gtk_Toggle_Button(Get_Widget(XML, "radiobuttonPop"));
		radiobuttonPunk := Gtk_Toggle_Button(Get_Widget(XML, "radiobuttonPunk"));
		radiobuttonRockabilly := Gtk_Toggle_Button(Get_Widget(XML, "radiobuttonRockabilly"));

		Glade.XML.signal_connect(XML, "on_buttonAnnuler_clicked", ferme'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonChoisir_clicked", affRegion2'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonAnnuler2_clicked", affRegion1'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonEnregistrer_clicked", inscrireGroupe'address,null_address);
	end charge;

	procedure ferme(widget : access Gtk_Widget_Record'Class) is
	begin
		destroy(window);
	end ferme;

	procedure affRegion1(widget : access Gtk_Widget_Record'Class) is
	begin
		set_sensitive(butAnnuler, true);
		set_sensitive(butChoisir, true);
		set_sensitive(butAnnuler2, false);
		set_sensitive(butEnregistrer, false);
		set_sensitive(entryNbConcertsPrevus, false);
		set_sensitive(entryNbInscriptionsPossibles, false);
		set_sensitive(entryNomGroupe, false);
		set_sensitive(entryNomContact, false);
		set_sensitive(entryCoordsContact, false);
		set_sensitive(entryAdresseSite, false);
		set_sensitive(treeViewVilles, true);
		set_sensitive(treeViewGroupes, false);
		set_sensitive(radiobuttonHard, false);
		set_sensitive(radiobuttonFusion, false);
		set_sensitive(radiobuttonAlternatif, false);
		set_sensitive(radiobuttonPop, false);
		set_sensitive(radiobuttonPunk, false);
		set_sensitive(radiobuttonRockabilly, false);
	end affRegion1;

	procedure affRegion2(widget : access Gtk_Widget_Record'Class) is
	begin
		set_sensitive(butAnnuler, false);
		set_sensitive(butChoisir, false);
		set_sensitive(butAnnuler2, true);
		set_sensitive(butEnregistrer, true);
		set_sensitive(entryNbConcertsPrevus, true);
		set_sensitive(entryNbInscriptionsPossibles, true);
		set_sensitive(entryNomGroupe, true);
		set_sensitive(entryNomContact, true);
		set_sensitive(entryCoordsContact, true);
		set_sensitive(entryAdresseSite, true);
		set_sensitive(treeViewVilles, false);
		set_sensitive(treeViewGroupes, true);
		set_sensitive(radiobuttonHard, true);
		set_sensitive(radiobuttonFusion, true);
		set_sensitive(radiobuttonAlternatif, true);
		set_sensitive(radiobuttonPop, true);
		set_sensitive(radiobuttonPunk, true);
		set_sensitive(radiobuttonRockabilly, true);
	end affRegion2;

	procedure inscrireGroupe(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;
	begin
		rep := Message_Dialog("Le groupe a bien été inscrit");
		destroy(window);
	end inscrireGroupe;

end P_Window_InscrireGroupe;