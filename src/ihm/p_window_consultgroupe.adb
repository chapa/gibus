with Glade.XML;use Glade.XML;
with System; use System; -- module permettant l'interaction avec la boucle événementielle principale
with Gtk.Main; -- pour les boites de dialogue
with Gtkada.Dialogs;use Gtkada.Dialogs; -- module GtkAda pour le composant fenêtre et les autres
with Gtk.Window; use Gtk.Window;
with Gtk.Button; use Gtk.Button;
with Gtk.Tree_View; use Gtk.Tree_View;
with Gtk.GEntry; use Gtk.GEntry;

package body P_window_consultGroupe is

	window : Gtk_Window;
	butAnnuler, butConsulter, butFermer : Gtk_Button;
	treeViewGroupes : Gtk_Tree_View;
	entryNomGroupe, entryNomContact, entryCoordsContact, entryGenreRock, entryAdresseSite, entryVille : Gtk_GEntry;

	procedure charge is
		XML : Glade_XML;
	begin
		Glade.XML.Gtk_New(XML, "src/ihm/6-consultGroupe.glade");
		window := Gtk_Window(Get_Widget(XML, "windowConsultGroupe"));

		butAnnuler := Gtk_button(Get_Widget(XML, "buttonAnnuler"));
		butConsulter := Gtk_button(Get_Widget(XML, "buttonConsulter"));
		butFermer := Gtk_button(Get_Widget(XML, "buttonFermer"));
		treeViewGroupes := Gtk_Tree_View(Get_Widget(XML, "treeViewGroupes"));
		entryNomGroupe := Gtk_GEntry(Get_Widget(XML, "entryNomGroupe"));
		entryNomContact := Gtk_GEntry(Get_Widget(XML, "entryNomContact"));
		entryCoordsContact := Gtk_GEntry(Get_Widget(XML, "entryCoordsContact"));
		entryGenreRock := Gtk_GEntry(Get_Widget(XML, "entryGenreRock"));
		entryAdresseSite := Gtk_GEntry(Get_Widget(XML, "entryAdresseSite"));
		entryVille := Gtk_GEntry(Get_Widget(XML, "entryVille"));

		Glade.XML.signal_connect(XML, "on_buttonConsulter_clicked", afficheGroupe'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonAnnuler_clicked", ferme'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonFermer_clicked", ferme'address,null_address);
	end charge;

	procedure ferme (widget : access Gtk_Widget_Record'Class) is
	begin
		destroy (window);
	end ferme ;

	procedure afficheGroupe (widget : access Gtk_Widget_Record'Class) is
	begin
		set_sensitive(butAnnuler, false);
		set_sensitive(butConsulter, false);
		set_sensitive(butFermer, true);
		set_sensitive(treeViewGroupes, false);
		set_sensitive(entryNomGroupe, true);
		set_sensitive(entryNomContact, true);
		set_sensitive(entryCoordsContact, true);
		set_sensitive(entryGenreRock, true);
		set_sensitive(entryAdresseSite, true);
		set_sensitive(entryVille, true);
	end afficheGroupe;

end P_window_consultGroupe;