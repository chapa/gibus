with Glade.XML;use Glade.XML;
with System; use System; -- module permettant l'interaction avec la boucle événementielle principale
with Gtk.Main; -- pour les boites de dialogue
with Gtkada.Dialogs;use Gtkada.Dialogs; -- module GtkAda pour le composant fenêtre et les autres
with Gtk.Window; use Gtk.Window;
with Gtk.Button; use Gtk.Button;
with Gtk.Tree_View; use Gtk.Tree_View;

-- pour gérer le composant Tree_View
with Gtk.Tree_Model; use Gtk.Tree_Model; -- pour l'itérateur rang dans le modèle
with Gtk.Tree_Store; use Gtk.Tree_Store; -- le modèle associé à la vue
with Gtk.Tree_Selection; use Gtk.Tree_Selection; -- pour la sélection dans la vue
with p_util_treeview; use p_util_treeview; -- utilitaire de gestion du composant treeView

with p_conversion; use p_conversion; -- utilitaire de conversion
with based108_data; use based108_data; -- types Ada
with base_types; use base_types; -- types énumérés
with p_application; use p_application; -- couche application

package body P_Window_ConsultFestivals is

	window : Gtk_Window;
	butFermer : Gtk_Button;
	modele_festival : Gtk_Tree_Store;
	treeviewFestivals : Gtk_Tree_View;
	rang_festival : Gtk_Tree_Iter := Null_Iter;

	procedure init_fenetre is
		ens_festival : festival_list.vector;
		rep : Message_Dialog_Buttons;
		procedure alimente_festivals(pos : festival_list.cursor) is
			festival : tFestival;
		begin
			festival := festival_list.element(pos);
			append(modele_festival, rang_festival, Null_Iter);
			Set(modele_festival, rang_festival, 0, p_conversion.to_string(festival.date));
			Set(modele_festival, rang_festival, 1, p_conversion.to_string(festival.ville_festival));
		end alimente_festivals;
	begin
		p_application.retrouver_festivals(ens_festival);

		clear(modele_festival);
		festival_list.iterate(ens_festival, alimente_festivals'Access);
		
		exception
			when ExAucunFestival => 
				rep := Message_Dialog("Il n'y a aucun festival enregistré");
				destroy(window);
	end init_fenetre;

	procedure charge is
		XML : Glade_XML;
	begin
		Glade.XML.Gtk_New(XML, "src/ihm/14-consultFestivals.glade");
		window := Gtk_Window(Get_Widget(XML, "windowConsultFestivals"));

		butFermer := Gtk_button(Get_Widget(XML, "buttonFermer"));
		treeviewFestivals := Gtk_Tree_View(Get_Widget(XML, "treeviewFestivals"));

		Glade.XML.signal_connect(XML, "on_buttonFermer_clicked", ferme'address,null_address);

		-- creation pour la vue treeviewFestivals des colonne et du modele associé
		p_util_treeview.creerColonne("dateFestival ", treeviewFestivals, false);
		p_util_treeview.creerColonne("nomVille ", treeviewFestivals, false);
		creerModele(treeviewFestivals, modele_festival);

		init_fenetre;
	end charge;

	procedure ferme(widget : access Gtk_Widget_Record'Class) is
	begin
		destroy (window);
	end ferme;
	
end P_Window_ConsultFestivals;