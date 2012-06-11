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

package body P_Window_ConsultFinalistes is

	-- instanciation du module p_enum pour les genres de musique
	package p_enumGenre is new p_conversion.p_enum(tgenre_enum);

	window : Gtk_Window;
	butAnnuler : Gtk_Button;
	modele_groupe : Gtk_Tree_Store;
	treeviewGroupesFinalistes : Gtk_Tree_View;
	rang_groupe : Gtk_Tree_Iter := Null_Iter;

	procedure init_fenetre is
		ens_finalistes : groupe_list.Vector;
		ens_villes : ville_List.Vector;
		rep : Message_Dialog_Buttons;
		procedure alimente_groupes(pos : groupe_list.cursor) is
			groupe : tGroupe;
		begin
			groupe := groupe_list.element(pos);
			append(modele_groupe, rang_groupe, Null_Iter);
			Set(modele_groupe, rang_groupe, 0, p_conversion.to_string(groupe.nom_groupe));
			Set(modele_groupe, rang_groupe, 2, p_enumGenre.to_string(groupe.genre));
		end alimente_groupes;
		procedure alimente_villes(pos : ville_List.cursor) is
			ville : tVille;
		begin
			ville := ville_List.element(pos);
			Set(modele_groupe, rang_groupe, 1, p_conversion.to_string(ville.nom_ville));
			Next(modele_groupe, rang_groupe);
		end alimente_villes;
	begin
		p_application.retrouver_finalistes(ens_finalistes, ens_villes);

		clear(modele_groupe);
		groupe_list.iterate(ens_finalistes, alimente_groupes'Access);
		rang_groupe := Get_Iter_First(modele_groupe);
		ville_List.iterate(ens_villes, alimente_villes'Access);
		
		exception
			when ExAucunFinaliste => 
				rep := Message_Dialog("Il n'y a encore aucun finaliste");
				destroy(window);
	end init_fenetre;

	procedure charge is
		XML : Glade_XML;
	begin
		Glade.XML.Gtk_New(XML, "src/ihm/10-consultFinalistes.glade");
		window := Gtk_Window(Get_Widget(XML, "windowConsultFinalistes"));

		butAnnuler := Gtk_button(Get_Widget(XML, "buttonAnnuler"));
		treeviewGroupesFinalistes := Gtk_Tree_View(Get_Widget(XML, "treeviewGroupesFinalistes"));

		Glade.XML.signal_connect(XML, "on_buttonFermer_clicked", ferme'address,null_address);

		-- creation pour la vue treeviewGroupesFinalistes des colonne et du modele associé
		p_util_treeview.creerColonne("nomGroupe ", treeviewGroupesFinalistes, false);
		p_util_treeview.creerColonne("nomVille ", treeviewGroupesFinalistes, false);
		p_util_treeview.creerColonne("genre ", treeviewGroupesFinalistes, false);
		creerModele(treeviewGroupesFinalistes, modele_groupe);

		init_fenetre;
	end charge;

	procedure ferme(widget : access Gtk_Widget_Record'Class) is
	begin
		destroy (window);
	end ferme;
	
end P_Window_ConsultFinalistes;