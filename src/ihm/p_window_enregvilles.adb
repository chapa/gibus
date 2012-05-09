

with Glade.XML;use Glade.XML;
with System; use System;
-- module permettant l'interaction avec la boucle événementielle principale
with Gtk.Main;
-- pour les boites de dialogue
with Gtkada.Dialogs;use Gtkada.Dialogs;
-- module GtkAda pour le composant fenêtre et les autres
with Gtk.Window; use Gtk.Window;
with Gtk.GEntry; use Gtk.GEntry;
with Gtk.Tree_View; use Gtk.Tree_View;
with Gtk.Button; use Gtk.Button;

package body P_window_enregVilles is

	window : Gtk_Window;
	butAnnuler, butConsulter : Gtk_Button;
	treeviewVilles :Gtk_Tree_View;
	entryNomVille,entryMelOrga:Gtk_GEntry;
	procedure charge is
		XML : Glade_XML;
	begin

		Glade.XML.Gtk_New(XML, "src/ihm/1-enregVilles.glade");
	  	window := Gtk_Window(Get_Widget(XML,"windowEnregVilles"));

	  	butAnnuler := Gtk_button(Get_Widget(XML, "buttonFermer"));
		butConsulter := Gtk_button(Get_Widget(XML, "buttonEnregistrer"));
		treeviewVilles := Gtk_Tree_View(Get_Widget(XML, "treeviewVille"));
		entryNomVille := Gtk_GEntry(Get_Widget(XML, "entryNomVille"));
		entryMelOrga := Gtk_GEntry(Get_Widget(XML, "entryMelOrga"));

	  	Glade.XML.signal_connect(XML,"on_buttonFermer_clicked",ferme'address,null_address );
		Glade.XML.signal_connect(XML,"on_buttonEnregistrer_clicked",enregVille'address,null_address );
	end charge;

	procedure ferme (widget : access Gtk_Widget_Record'Class)is
	begin
	  	destroy (window);
	end ferme;


	procedure enregVille(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;

	begin
		rep:=Message_Dialog ("La ville est enregistrée");
		
	end enregVille;

end P_window_enregVilles ;