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
with Ada.Calendar; use Ada.Calendar;  -- type date
with p_application; use p_application; -- couche application

with p_esiut; use p_esiut;

package body P_Window_ModifierProgrammationFestival is

	window : Gtk_Window;
	butAnnuler1, butSelectionner, butPermut, butUpJ1, butDownJ1, butUpJ2, butDownJ2, butAnnuler2, butValider : Gtk_Button;
	entryJournee1, entryJournee2 : Gtk_GEntry;
	treeviewVilles, treeviewJournee1, treeviewJournee2 : Gtk_Tree_View;
	modele_ville, modele_journee1, modele_journee2 : Gtk_Tree_Store; -- le modèle associé aux vues
	rang_ville, rang_journee1, rang_journee2 : Gtk_Tree_Iter := Null_Iter; -- lignes dans les modeles
	nbGroupesJ1, nbGroupesJ2 : integer; -- nombre de groupes dans chaque journées

	procedure alimente_ville(pos : ville_List.Cursor) is
		ville : based108_data.tVille;
	begin
		ville := ville_List.element(pos);
		append(modele_ville, rang_ville, Null_Iter);
		Set(modele_ville, rang_ville, 0, p_conversion.to_string(ville.nom_ville));
	end alimente_ville;

	procedure init_fenetre is
		ens_ville : based108_data.ville_List.Vector;
		procedure errorBoxAucuneVille is
			rep : Message_Dialog_Buttons;
		begin
			rep := Message_Dialog("Il n'y a pas de villes avec un festival entièrement programmé");
			destroy(window);
		end errorBoxAucuneVille;
	begin
		p_application.retrouver_villes_avec_programme(ens_ville);
		clear(modele_ville);
		-- alimentation du modèle avec les noms de villes
		ville_List.iterate(ens_ville ,alimente_ville'Access);
	exception
		when exAucuneVille => errorBoxAucuneVille;
	end init_fenetre;

	procedure charge is
		XML : Glade_XML;
	begin
		Glade.XML.Gtk_New(XML, "src/ihm/15-modifierProgrammationFestival.glade");
		window := Gtk_Window(Get_Widget(XML, "windowModifierProgrammationFestival"));

		butAnnuler1 := Gtk_Button(Get_Widget(XML, "buttonAnnuler1"));
		butSelectionner := Gtk_Button(Get_Widget(XML, "buttonSelectionner"));
		butPermut := Gtk_Button(Get_Widget(XML, "buttonPermut"));
		butUpJ1 := Gtk_Button(Get_Widget(XML, "buttonUpJ1"));
		butDownJ1 := Gtk_Button(Get_Widget(XML, "buttonDownJ1"));
		butUpJ2 := Gtk_Button(Get_Widget(XML, "buttonUpJ2"));
		butDownJ2 := Gtk_Button(Get_Widget(XML, "buttonDownJ2"));
		butAnnuler2 := Gtk_Button(Get_Widget(XML, "buttonAnnuler2"));
		butValider := Gtk_Button(Get_Widget(XML, "buttonValider"));
		entryJournee1 := Gtk_GEntry(Get_Widget(XML, "entryJournee1"));
		entryJournee2 := Gtk_GEntry(Get_Widget(XML, "entryJournee2"));
		treeviewVilles := Gtk_Tree_View(Get_Widget(XML, "treeviewVilles"));
		treeviewJournee1 := Gtk_Tree_View(Get_Widget(XML, "treeviewJournee1"));
		treeviewJournee2 := Gtk_Tree_View(Get_Widget(XML, "treeviewJournee2"));

		Glade.XML.signal_connect(XML, "on_buttonAnnuler1_clicked", ferme'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonSelectionner_clicked", affRegion2'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonPermut_clicked", permut'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonUpJ1_clicked", upJ1'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonDownJ1_clicked", downJ1'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonUpJ2_clicked", upJ2'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonDownJ2_clicked", downJ2'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonAnnuler2_clicked", affRegion1'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonValider_clicked", enregistrer'address,null_address);

		-- creation pour la vue treeviewVilles d'une colonne et du modele associé
		p_util_treeview.creerColonne("nomVille", treeviewVilles, false);
		creerModele(treeviewVilles, modele_ville);
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
		destroy(window);
	end ferme;

	procedure affRegion1(widget : access Gtk_Widget_Record'Class) is
	begin
		creerModele(treeviewVilles, modele_ville);
		creerModele(treeviewJournee1, modele_journee1);
		creerModele(treeviewJournee2, modele_journee2);
		clear(modele_ville);
		clear(modele_journee1);
		clear(modele_journee2);
		set_text(entryJournee1, "");
		set_text(entryJournee2, "");

		set_sensitive(butAnnuler1, true);
		set_sensitive(butSelectionner, true);
		set_sensitive(butPermut, false);
		set_sensitive(butUpJ1, false);
		set_sensitive(butDownJ1, false);
		set_sensitive(butUpJ2, false);
		set_sensitive(butDownJ2, false);
		set_sensitive(butAnnuler2, false);
		set_sensitive(butValider, false);
		set_sensitive(entryJournee1, false);
		set_sensitive(entryJournee2, false);
		set_sensitive(treeviewVilles, true);
		set_sensitive(treeviewJournee1, false);
		set_sensitive(treeviewJournee2, false);

		init_fenetre;
	end affRegion1;

	procedure alimente_groupe_j1(pos : Participant_Festival_List.Cursor) is
		groupe : tParticipant_Festival;
	begin
		groupe := Participant_Festival_List.element(pos);
		append(modele_journee1, rang_journee1, Null_Iter);
		Set(modele_journee1, rang_journee1, 0, p_conversion.to_string(groupe.Nom_Groupe_Inscrit));
	end alimente_groupe_j1;

	procedure alimente_groupe_j2(pos : Participant_Festival_List.Cursor) is
		groupe : tParticipant_Festival;
	begin
		groupe := Participant_Festival_List.element(pos);
		append(modele_journee2, rang_journee2, Null_Iter);
		Set(modele_journee2, rang_journee2, 0, p_conversion.to_string(groupe.Nom_Groupe_Inscrit));
	end alimente_groupe_j2;

	procedure affRegion2(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;
		ville : tVille;
		festival : tFestival;
		groupes, groupes_j1, groupes_j2 : Participant_Festival_List.Vector;
		nbGroupes : integer;
	begin
		Get_Selected(Get_Selection(treeviewVilles), Gtk_Tree_Model(modele_ville), rang_ville);
		if rang_ville = Null_Iter then 
			rep := Message_Dialog("Choisissez une ville");
		else
			-- récupération de la valeur de la colonne 1 dans la ligne sélectionnée
			to_ada_type((Get_String(modele_ville, rang_ville, 0)), ville.Nom_Ville);
			-- lance la prodédure de consulation des groupes en fonction du nom de la ville
			p_application.retrouver_groupes_ville_sans_journee(ville.Nom_Ville, groupes, nbGroupes);
			p_application.retrouver_groupes_ville_journee(ville.Nom_Ville, groupes_j1, 1);
			p_application.retrouver_groupes_ville_journee(ville.Nom_Ville, groupes_j2, 2);
			p_application.retrouver_nbgroupes_journees(ville.nom_ville, nbGroupesJ1, nbGroupesJ2);

			clear(modele_journee1);
			Participant_Festival_List.iterate(groupes_j1, alimente_groupe_j1'Access);
			clear(modele_journee2);
			Participant_Festival_List.iterate(groupes_j2, alimente_groupe_j2'Access);

			festival.Ville_Festival := ville.Nom_Ville;
			p_application.consulter_journee_festival(festival);
			set_text(entryJournee1, p_conversion.to_string(festival.date));
			set_text(entryJournee2, p_conversion.to_string(festival.date + 86400.0));

			set_sensitive(butAnnuler1, false);
			set_sensitive(butSelectionner, false);
			set_sensitive(butPermut, true);
			set_sensitive(butUpJ1, true);
			set_sensitive(butDownJ1, true);
			set_sensitive(butUpJ2, true);
			set_sensitive(butDownJ2, true);
			set_sensitive(butAnnuler2, true);
			set_sensitive(butValider, true);
			set_sensitive(entryJournee1, true);
			set_sensitive(entryJournee2, true);
			set_sensitive(treeviewVilles, false);
			set_sensitive(treeviewJournee1, true);
			set_sensitive(treeviewJournee2, true);
		end if;
	end affRegion2;

	procedure permut(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;
		groupeJ1, groupeJ2 : tGroupe;
	begin
		Get_Selected(Get_Selection(treeviewJournee1), Gtk_Tree_Model(modele_journee1), rang_journee1);
		if rang_journee1 = Null_Iter then
			rep := Message_Dialog("Choisissez un groupe dans la journée 1");
		else
			Get_Selected(Get_Selection(treeviewJournee2), Gtk_Tree_Model(modele_journee2), rang_journee2);
			if rang_journee2 = Null_Iter then
				rep := Message_Dialog("Choisissez un groupe dans la journée 2");
			else
				to_ada_type(Get_String(modele_journee1, rang_journee1, 0), groupeJ1.Nom_Groupe);
				to_ada_type(Get_String(modele_journee2, rang_journee2, 0), groupeJ2.Nom_Groupe);
				set(modele_journee1, rang_journee1, 0, to_string(groupeJ2.Nom_Groupe));
				set(modele_journee2, rang_journee2, 0, to_string(groupeJ1.Nom_Groupe));
			end if;
		end if;
	end permut;

	procedure upJ1(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;
		groupe1, groupe2 : tGroupe;
		i, nb : integer := 0;
	begin
		Get_Selected(Get_Selection(treeviewJournee1), Gtk_Tree_Model(modele_journee1), rang_journee1);
		if rang_journee1 = Null_Iter then
			rep := Message_Dialog("Choisissez un groupe");
		else
			to_ada_type(Get_String(modele_journee1, rang_journee1, 0), groupe2.Nom_Groupe);

			rang_journee1 := Get_Iter_First(modele_journee1);
			to_ada_type(Get_String(modele_journee1, rang_journee1, 0), groupe1.Nom_Groupe);
			while rang_journee1 /= Null_Iter and then to_string(groupe1.Nom_Groupe) /= to_string(groupe2.Nom_Groupe) loop
				nb := nb + 1;
				Next(modele_journee1, rang_journee1);
				to_ada_type(Get_String(modele_journee1, rang_journee1, 0), groupe1.Nom_Groupe);
			end loop;

			if nb-1 >= 0 then
				rang_journee1 := Get_Iter_First(modele_journee1);
				for i in 0..nb-2 loop
					Next(modele_journee1, rang_journee1);
				end loop;
				to_ada_type(Get_String(modele_journee1, rang_journee1, 0), groupe1.Nom_Groupe);
				set(modele_journee1, rang_journee1, 0, to_string(groupe2.Nom_Groupe));
				Select_iter(Get_Selection(treeviewJournee1), rang_journee1);
				Next(modele_journee1, rang_journee1);
				set(modele_journee1, rang_journee1, 0, to_string(groupe1.Nom_Groupe));
			end if;
		end if;
	end upJ1;

	procedure downJ1(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;
		groupe1, groupe2 : tGroupe;
		i, nb : integer := 0;
	begin
		Get_Selected(Get_Selection(treeviewJournee1), Gtk_Tree_Model(modele_journee1), rang_journee1);
		if rang_journee1 = Null_Iter then
			rep := Message_Dialog("Choisissez un groupe");
		else
			to_ada_type(Get_String(modele_journee1, rang_journee1, 0), groupe1.Nom_Groupe);
			Next(modele_journee1, rang_journee1);

			if rang_journee1 /= Null_Iter then
				to_ada_type(Get_String(modele_journee1, rang_journee1, 0), groupe2.Nom_Groupe);
				set(modele_journee1, rang_journee1, 0, to_string(groupe1.Nom_Groupe));
				Get_Selected(Get_Selection(treeviewJournee1), Gtk_Tree_Model(modele_journee1), rang_journee1);
				set(modele_journee1, rang_journee1, 0, to_string(groupe2.Nom_Groupe));
				Next(modele_journee1, rang_journee1);
				Select_iter(Get_Selection(treeviewJournee1), rang_journee1);
			end if;
		end if;
	end downJ1;

	procedure upJ2(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;
		groupe1, groupe2 : tGroupe;
		i, nb : integer := 0;
	begin
		Get_Selected(Get_Selection(treeviewJournee2), Gtk_Tree_Model(modele_journee2), rang_journee2);
		if rang_journee2 = Null_Iter then
			rep := Message_Dialog("Choisissez un groupe");
		else
			to_ada_type(Get_String(modele_journee2, rang_journee2, 0), groupe2.Nom_Groupe);

			rang_journee2 := Get_Iter_First(modele_journee2);
			to_ada_type(Get_String(modele_journee2, rang_journee2, 0), groupe1.Nom_Groupe);
			while rang_journee2 /= Null_Iter and then to_string(groupe1.Nom_Groupe) /= to_string(groupe2.Nom_Groupe) loop
				nb := nb + 1;
				Next(modele_journee2, rang_journee2);
				to_ada_type(Get_String(modele_journee2, rang_journee2, 0), groupe1.Nom_Groupe);
			end loop;

			if nb-1 >= 0 then
				rang_journee2 := Get_Iter_First(modele_journee2);
				for i in 0..nb-2 loop
					Next(modele_journee2, rang_journee2);
				end loop;
				to_ada_type(Get_String(modele_journee2, rang_journee2, 0), groupe1.Nom_Groupe);
				set(modele_journee2, rang_journee2, 0, to_string(groupe2.Nom_Groupe));
				Select_iter(Get_Selection(treeviewJournee2), rang_journee2);
				Next(modele_journee2, rang_journee2);
				set(modele_journee2, rang_journee2, 0, to_string(groupe1.Nom_Groupe));
			end if;
		end if;
	end upJ2;

	procedure downJ2(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;
		groupe1, groupe2 : tGroupe;
		i, nb : integer := 0;
	begin
		Get_Selected(Get_Selection(treeviewJournee2), Gtk_Tree_Model(modele_journee2), rang_journee2);
		if rang_journee2 = Null_Iter then
			rep := Message_Dialog("Choisissez un groupe");
		else
			to_ada_type(Get_String(modele_journee2, rang_journee2, 0), groupe1.Nom_Groupe);
			Next(modele_journee2, rang_journee2);

			if rang_journee2 /= Null_Iter then
				to_ada_type(Get_String(modele_journee2, rang_journee2, 0), groupe2.Nom_Groupe);
				set(modele_journee2, rang_journee2, 0, to_string(groupe1.Nom_Groupe));
				Get_Selected(Get_Selection(treeviewJournee2), Gtk_Tree_Model(modele_journee2), rang_journee2);
				set(modele_journee2, rang_journee2, 0, to_string(groupe2.Nom_Groupe));
				Next(modele_journee2, rang_journee2);
				Select_iter(Get_Selection(treeviewJournee2), rang_journee2);
			end if;
		end if;
	end downJ2;

	procedure enregistrer(widget : access Gtk_Widget_Record'Class) is
		ville : tVille;
		rep : Message_Dialog_Buttons;
		i : integer := 1;
	begin
		to_ada_type((Get_String(modele_ville, rang_ville, 0)), ville.Nom_Ville);
		p_application.vider_journees(ville.Nom_Ville);
		rang_journee1 := Get_Iter_First(modele_journee1);
		while rang_journee1 /= Null_Iter loop
			p_application.creer_groupe_journee(Get_String(modele_journee1, rang_journee1, 0), 1, i);
			Next(modele_journee1, rang_journee1);
			i := i + 1;
		end loop;
		i := 1;
		rang_journee2 := Get_Iter_First(modele_journee2);
		while rang_journee2 /= Null_Iter loop
			p_application.creer_groupe_journee(Get_String(modele_journee2, rang_journee2, 0), 2, i);
			Next(modele_journee2, rang_journee2);
			i := i + 1;
		end loop;

		rep := Message_Dialog("La programmation du festival a bien été enregistrée");
		destroy(window);
	end enregistrer;
	
end P_Window_ModifierProgrammationFestival;