with Glade.XML;use Glade.XML;
with System; use System;
with Gtk.Main; -- module permettant l'interaction avec la boucle événementielle principale
with Gtkada.Dialogs;use Gtkada.Dialogs; -- pour les boites de dialogue
-- module GtkAda pour le composant fenêtre et les autres
with Gtk.Window; use Gtk.Window;
with Gtk.Button; use Gtk.Button;
with Gtk.Tree_View; use Gtk.Tree_View;
with Gtk.GEntry; use Gtk.GEntry;

-- pour gérer le composant Tree_View
with Gtk.Tree_Model; use Gtk.Tree_Model; -- pour l'itérateur rang dans le modèle
with Gtk.Tree_Store; use Gtk.Tree_Store; -- le modèle associé à la vue
with Gtk.Tree_Selection; use Gtk.Tree_Selection; -- pour la sélection dans la vue
with p_util_treeview; use p_util_treeview; -- utilitaire de gestion du composant treeView

with p_conversion; use p_conversion; --utilitaire de conversion
with based108_data; use based108_data; -- types Ada
with base_types; use base_types; -- types énumérés
with p_application; use p_application; -- couche application

package body P_window_consultGroupe is

	-- instanciation du module p_enum pour les genres de musique
	package p_enumGenre is new p_conversion.p_enum(tgenre_enum);

	window : Gtk_Window;
	butAnnuler, butConsulter, butFermer : Gtk_Button;
	treeViewGroupes : Gtk_Tree_View;
	entryNomGroupe, entryNomContact, entryCoordsContact, entryGenreRock, entryAdresseSite, entryVille : Gtk_GEntry;
	modele_groupe : Gtk_Tree_Store; -- le modèle associé aux vues
	rang_groupe : Gtk_Tree_Iter := Null_Iter; -- lignes dans les modeles

	-- construit le modèle associé à la vue treeViewGroupes avec un groupe par ligne
	procedure alimente_groupe(pos : Groupe_List.Cursor) is
		groupe : based108_data.tGroupe;
	begin
		groupe := Groupe_List.element(pos);
		append(modele_groupe, rang_groupe, Null_Iter); -- rajoute une ligne vide
		-- et met dans la colonne 1 de cette ligne le nom de la groupe
		Set(modele_groupe, rang_groupe, 0, p_conversion.to_string(groupe.Nom_Groupe));
	end alimente_groupe;

	-- (ré)initialise la fenêtre avec la liste des villes dont le festival est programmé ou un message
	procedure init_fenetre is
		ens_groupe : based108_data.Groupe_List.Vector;
		procedure errorBoxAucunGroupe is
			rep : Message_Dialog_Buttons;
		begin
			rep := Message_Dialog("Il n'y a pas de groupe inscrits");
			destroy(window);
		end errorBoxAucunGroupe;
	begin
	    p_application.retrouver_groupes(ens_groupe);
		-- alimentation du modèle avec les noms de villes
		Groupe_List.iterate(ens_groupe, alimente_groupe'Access);
	exception
		when exAucunGroupe => errorBoxAucunGroupe;
	end init_fenetre;

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

		-- creation pour la vue treeViewGroupes d'une colonne et du modele associé
		p_util_treeview.creerColonne("nomVille ", treeViewGroupes, false);
		creerModele(treeViewGroupes, modele_groupe);

		init_fenetre;
	end charge;

	procedure ferme (widget : access Gtk_Widget_Record'Class) is
	begin
		destroy (window);
	end ferme ;

	procedure afficheGroupe (widget : access Gtk_Widget_Record'Class) is
		groupe : tGroupe;
		ville : tVille;
		rep : Message_Dialog_Buttons;
	begin
		-- récupération du modèle et de la ligne sélectionnée
		Get_Selected(Get_Selection(treeViewGroupes), Gtk_Tree_Model(modele_groupe), rang_groupe);
		--vérification qu'une ligne est sélectionnée
		if rang_groupe = Null_Iter then 
			rep := Message_Dialog("Choisissez un groupe");
		else --récupération de la valeur de la colonne 1 dans la ligne sélectionnée
			to_ada_type((Get_String(modele_groupe, rang_groupe, 0)), groupe.Nom_Groupe) ;
			-- lance la prodédure de consulation du festival et des groupes programmés
			p_application.consulter_groupe(groupe, ville.Nom_Ville);
			set_text(entryNomGroupe, p_conversion.to_string(groupe.Nom_Groupe));
			set_text(entryNomContact, p_conversion.to_string(groupe.Nom_Contact));
			set_text(entryCoordsContact, p_conversion.to_string(groupe.Coord_Contact));
			set_text(entryGenreRock, p_enumGenre.to_string(groupe.Genre));
			set_text(entryAdresseSite, p_conversion.to_string(groupe.Adr_Site));
			set_text(entryVille, p_conversion.to_string(ville.Nom_Ville));

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
		end if;
	end afficheGroupe;

end P_window_consultGroupe;