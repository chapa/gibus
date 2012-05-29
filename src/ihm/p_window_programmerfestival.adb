with Glade.XML;use Glade.XML;
with System; use System; -- module permettant l'interaction avec la boucle événementielle principale
with Gtk.Main; -- pour les boites de dialogue
with Gtkada.Dialogs;use Gtkada.Dialogs; -- module GtkAda pour le composant fenêtre et les autres
with Gtk.Window; use Gtk.Window;
with Gtk.Button; use Gtk.Button;
with Gtk.GEntry; use Gtk.GEntry;
with Gtk.Arrow; use Gtk.Arrow;
with Gtk.Tree_View; use Gtk.Tree_View;

-- pour gérer le composant Tree_View
with Gtk.Tree_Model; use Gtk.Tree_Model;-- pour l'itérateur rang dans le modèle
with Gtk.Tree_Store; use Gtk.Tree_Store;-- le modèle associé à la vue
with Gtk.Tree_Selection; use Gtk.Tree_Selection;  -- pour la sélection dans la vue
with p_util_treeview; use p_util_treeview;  -- utilitaire de gestion du composant treeView

with p_conversion; use p_conversion; --utilitaire de conversion
with based108_data; use based108_data;  -- types Ada
with base_types; use base_types;  -- types énumérés
with Ada.Calendar;use Ada.Calendar;  -- type date
with p_application; use p_application;  -- couche application

package body P_Window_ProgrammerFestival is

	window : Gtk_Window;
	butAnnuler1, butValider1, butAnnuler2, butValider2 : Gtk_Button;
	entryJournee1, entryJournee2 : Gtk_GEntry;
	arrowJournee1Down, arrowJournee1Up, arrowJournee2Down, arrowJournee2Up : Gtk_Arrow;
	treeviewVilles, treeviewListeGroupes, treeviewJournee1, treeviewJournee2 : Gtk_Tree_View;
	modele_ville, modele_liste_groupe, modele_journee1, modele_journee2 : Gtk_Tree_Store; -- le modèle associé aux vues
	rang_ville, rang_liste_groupe, rang_journee1, rang_journee2 : Gtk_Tree_Iter := Null_Iter; -- lignes dans les modeles

	-- construit le modèle associé à la vue treeviewVilles avec une ville par ligne
	procedure alimente_ville(pos : ville_List.Cursor) is
		ville : based108_data.tVille;
	begin
		ville := ville_List.element(pos);
		append(modele_ville, rang_ville, Null_Iter); -- rajoute une ligne vide
		-- et met dans la colonne 1 de cette ligne le nom de la ville
		Set(modele_ville, rang_ville, 0, p_conversion.to_string(ville.nom_ville));
	end alimente_ville;

	-- (ré)initialise la fenêtre avec la liste des villes dont le festival est programmé ou un message
	procedure init_fenetre is
		ens_ville : based108_data.ville_List.Vector;
		procedure errorBoxAucuneVille is
			rep : Message_Dialog_Buttons;
		begin
			rep := Message_Dialog("Il n'y a pas de villes enregistrées sans festival programmé et avec des groupes");
			destroy(window);
		end errorBoxAucuneVille;
	begin
		p_application.retrouver_villes_sans_programme_avec_groupes(ens_ville);
		clear(modele_ville);
		-- alimentation du modèle avec les noms de villes
		ville_List.iterate(ens_ville ,alimente_ville'Access);
	exception
		when exAucuneVille => errorBoxAucuneVille;
	end init_fenetre;

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

		-- creation pour la vue treeviewVilles d'une colonne et du modele associé
		p_util_treeview.creerColonne("nomVille", treeviewVilles, false);
		creerModele(treeviewVilles, modele_ville);
		-- creation pour la vue treeviewListeGroupes d'une colonne et du modele associé
		p_util_treeview.creerColonne("nomGroupe", treeviewListeGroupes, false);
		creerModele(treeviewListeGroupes, modele_liste_groupe);
		-- creation pour la vue treeviewJournee1 d'une colonne et du modele associé
		p_util_treeview.creerColonne("nomGroupe", treeviewJournee1, false);
		creerModele(treeviewJournee1, modele_journee1);
		-- creation pour la vue treeviewJournee2 d'une colonne et du modele associé
		p_util_treeview.creerColonne("nomGroupe", treeviewJournee2, false);
		creerModele(treeviewJournee2, modele_journee2);

		init_fenetre;

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

	procedure alimente_groupe(pos : Participant_Festival_List.Cursor) is
		groupe : tParticipant_Festival;
	begin
		groupe := Participant_Festival_List.element(pos);
		append(modele_liste_groupe, rang_liste_groupe, Null_Iter);
		Set(modele_liste_groupe, rang_liste_groupe, 0, p_conversion.to_string(groupe.Nom_Groupe_Inscrit));
	end alimente_groupe;

	procedure affRegion2(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;
		ville : tVille;
		groupes : Participant_Festival_List.Vector;
		nbGroupes : integer;
		procedure errorBoxAucunGroupe is
			rep : Message_Dialog_Buttons;
		begin
			rep := Message_Dialog("Il n'y a pas de groupes encore inscrits pour ce festival (normalement impossible)");
		end errorBoxAucunGroupe;
	begin
		-- récupération du modèle et de la ligne sélectionnée
		Get_Selected(Get_Selection(treeViewVilles), Gtk_Tree_Model(modele_ville), rang_ville);
		if rang_ville = Null_Iter then 
			rep := Message_Dialog("Choisissez une ville");
		else
			-- récupération de la valeur de la colonne 1 dans la ligne sélectionnée
			to_ada_type((Get_String(modele_ville, rang_ville, 0)), ville.Nom_Ville);
			-- lance la prodédure de consulation des groupes en fonction du nom de la ville
			p_application.retrouver_groupes_ville(ville.Nom_Ville, groupes, nbGroupes);
			if nbGroupes = 0 then
				errorBoxAucunGroupe;
			end if;

			clear(modele_liste_groupe);
			-- alimentation du modèle avec les noms des groupes
			Participant_Festival_List.iterate(groupes, alimente_groupe'Access);

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
		end if;
	end affRegion2;

	procedure enregistrerFestival(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;
	begin
		rep := Message_Dialog("Le festival a bien été enregistré");
		destroy(window);
	end enregistrerFestival;

end P_Window_ProgrammerFestival;