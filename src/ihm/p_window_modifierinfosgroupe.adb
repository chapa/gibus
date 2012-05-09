with Glade.XML;use Glade.XML;
with System; use System; -- module permettant l'interaction avec la boucle événementielle principale
with Gtk.Main; -- pour les boites de dialogue
with Gtkada.Dialogs;use Gtkada.Dialogs; -- module GtkAda pour le composant fenêtre et les autres
with Gtk.Window; use Gtk.Window;
with Gtk.Button; use Gtk.Button;
with Gtk.Tree_View; use Gtk.Tree_View;
with Gtk.GEntry; use Gtk.GEntry;

package body P_Window_ModifierInfosGroupe is

	window : Gtk_Window;
	butAnnuler1, butModifier, butAnnuler2, butEnregistrer : Gtk_Button;
	treeviewGroupes : Gtk_Tree_View;
	entryNomContact, entryCoordsContact, entrySiteWeb : Gtk_GEntry;

	procedure charge is
		XML : Glade_XML;
	begin
		Glade.XML.Gtk_New(XML, "src/ihm/11-modifierInfosGroupe.glade");
		window := Gtk_Window(Get_Widget(XML, "windowModifierInfosGroupe"));

		butAnnuler1 := Gtk_button(Get_Widget(XML, "buttonAnnuler1"));
		butModifier := Gtk_button(Get_Widget(XML, "buttonModifier"));
		butAnnuler2 := Gtk_button(Get_Widget(XML, "buttonAnnuler2"));
		butEnregistrer := Gtk_button(Get_Widget(XML, "buttonEnregistrer"));
		treeviewGroupes := Gtk_Tree_View(Get_Widget(XML, "treeviewGroupes"));
		entryNomContact := Gtk_GEntry(Get_Widget(XML, "entryNomContact"));
		entryCoordsContact := Gtk_GEntry(Get_Widget(XML, "entryCoordsContact"));
		entrySiteWeb := Gtk_GEntry(Get_Widget(XML, "entrySiteWeb"));

		Glade.XML.signal_connect(XML, "on_buttonAnnuler1_clicked", ferme'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonModifier_clicked", affRegion2'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonAnnuler2_clicked", affRegion1'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonEnregistrer_clicked", enregistrer'address,null_address);
	end charge;

	procedure ferme(widget : access Gtk_Widget_Record'Class) is
	begin
		destroy (window);
	end ferme;

	procedure affRegion1(widget : access Gtk_Widget_Record'Class) is
	begin
		set_sensitive(butAnnuler1, true);
		set_sensitive(butModifier, true);
		set_sensitive(butAnnuler2, false);
		set_sensitive(butEnregistrer, false);
		set_sensitive(treeviewGroupes, true);
		set_sensitive(entryNomContact, false);
		set_sensitive(entryCoordsContact, false);
		set_sensitive(entrySiteWeb, false);
	end affRegion1;

	procedure affRegion2(widget : access Gtk_Widget_Record'Class) is
	begin
		set_sensitive(butAnnuler1, false);
		set_sensitive(butModifier, false);
		set_sensitive(butAnnuler2, true);
		set_sensitive(butEnregistrer, true);
		set_sensitive(treeviewGroupes, false);
		set_sensitive(entryNomContact, true);
		set_sensitive(entryCoordsContact, true);
		set_sensitive(entrySiteWeb, true);
	end affRegion2;

	procedure enregistrer(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;
	begin
		rep := Message_Dialog("Le groupe a bien été modifié");
		destroy(window);
	end enregistrer;
	
end P_Window_ModifierInfosGroupe;