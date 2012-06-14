with p_esiut; use p_esiut;
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

with p_esiut; use p_esiut;

package body P_Window_ProgrammerFestival is

	window : Gtk_Window;
	butAnnuler1, butValider1, butDownJ1, butUpJ1, butDownJ2, butUpJ2, butAnnuler2, butValider2 : Gtk_Button;
	entryJournee1, entryJournee2 : Gtk_GEntry;
	treeviewVilles, treeviewListeGroupes, treeviewJournee1, treeviewJournee2 : Gtk_Tree_View;
	modele_ville, modele_liste_groupe, modele_journee1, modele_journee2 : Gtk_Tree_Store; -- le modèle associé aux vues
	rang_ville, rang_liste_groupe, rang_journee1, rang_journee2 : Gtk_Tree_Iter := Null_Iter; -- lignes dans les modeles
	nbGroupesJ1, nbGroupesJ2 : integer; -- nombre de groupes dans chaque journées

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
		butDownJ1 := Gtk_Button(Get_Widget(XML, "buttonDownJ1"));
		butUpJ1 := Gtk_Button(Get_Widget(XML, "buttonUpJ1"));
		butDownJ2 := Gtk_Button(Get_Widget(XML, "buttonDownJ2"));
		butUpJ2 := Gtk_Button(Get_Widget(XML, "buttonUpJ2"));
		treeviewVilles := Gtk_Tree_View(Get_Widget(XML, "treeviewVilles"));
		treeviewListeGroupes := Gtk_Tree_View(Get_Widget(XML, "treeviewListeGroupes"));
		treeviewJournee1 := Gtk_Tree_View(Get_Widget(XML, "treeviewJournee1"));
		treeviewJournee2 := Gtk_Tree_View(Get_Widget(XML, "treeviewJournee2"));

		Glade.XML.signal_connect(XML, "on_buttonAnnuler1_clicked", ferme'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonValider1_clicked", affRegion2'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonDownJ1_clicked", ajouterGroupeJ1'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonUpJ1_clicked", retirerGroupeJ1'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonDownJ2_clicked", ajouterGroupeJ2'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonUpJ2_clicked", retirerGroupeJ2'address,null_address);
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
		clear(modele_liste_groupe);
		clear(modele_journee1);
		clear(modele_journee2);
		set_text(entryJournee1, "");
		set_text(entryJournee2, "");
		set_sensitive(butAnnuler1, true);
		set_sensitive(butValider1, true);
		set_sensitive(butAnnuler2, false);
		set_sensitive(butValider2, false);
		set_sensitive(entryJournee1, false);
		set_sensitive(entryJournee2, false);
		set_sensitive(butDownJ1, false);
		set_sensitive(butUpJ1, false);
		set_sensitive(butDownJ2, false);
		set_sensitive(butUpJ2, false);
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
		groupes, groupes_j1, groupes_j2 : Participant_Festival_List.Vector;
		nbGroupes : integer;
		festival : tFestival;
	begin
		-- récupération du modèle et de la ligne sélectionnée
		Get_Selected(Get_Selection(treeViewVilles), Gtk_Tree_Model(modele_ville), rang_ville);
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

			clear(modele_liste_groupe);
			Participant_Festival_List.iterate(groupes, alimente_groupe'Access);
			clear(modele_journee1);
			Participant_Festival_List.iterate(groupes_j1, alimente_groupe_j1'Access);
			clear(modele_journee2);
			Participant_Festival_List.iterate(groupes_j2, alimente_groupe_j2'Access);

			festival.Ville_Festival := ville.Nom_Ville;
			p_application.consulter_journee_festival(festival);
			set_text(entryJournee1, p_conversion.to_string(festival.date));
			set_text(entryJournee2, p_conversion.to_string(festival.date + 86400.0));

			set_sensitive(butAnnuler1, false);
			set_sensitive(butValider1, false);
			set_sensitive(butAnnuler2, true);
			set_sensitive(butValider2, true);
			set_sensitive(entryJournee1, true);
			set_sensitive(entryJournee2, true);
			set_sensitive(butDownJ1, true);
			set_sensitive(butUpJ1, true);
			set_sensitive(butDownJ2, true);
			set_sensitive(butUpJ2, true);
			set_sensitive(treeviewVilles, false);
			set_sensitive(treeviewListeGroupes, true);
			set_sensitive(treeviewJournee1, true);
			set_sensitive(treeviewJournee2, true);
		end if;
	end affRegion2;

	procedure ajouterGroupeJ1(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;
		groupe : tGroupe;
		nb : integer := 0;
	begin
		rang_journee1 := Get_Iter_First(modele_journee1);
		while rang_journee1 /= Null_Iter loop
			nb := nb + 1;
			Next(modele_journee1, rang_journee1);
		end loop;
		Get_Selected(Get_Selection(treeviewListeGroupes), Gtk_Tree_Model(modele_liste_groupe), rang_liste_groupe);
		if rang_liste_groupe = Null_Iter then 
			rep := Message_Dialog("Choisissez un groupe");
		elsif nb >= nbGroupesJ1 then
			rep := Message_Dialog("Cette journée est pleine");
		else
			to_ada_type((Get_String(modele_liste_groupe, rang_liste_groupe, 0)), groupe.Nom_Groupe);
			append(modele_journee1, rang_journee1, Null_Iter);
			Set(modele_journee1, rang_journee1, 0, p_conversion.to_string(groupe.Nom_Groupe));
			remove(modele_liste_groupe, rang_liste_groupe);
		end if;
	end ajouterGroupeJ1;

	procedure retirerGroupeJ1(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;
		groupe : tGroupe;
	begin
		Get_Selected(Get_Selection(treeviewJournee1), Gtk_Tree_Model(modele_journee1), rang_journee1);
		if rang_journee1 = Null_Iter then 
			rep := Message_Dialog("Choisissez un groupe");
		else
			to_ada_type((Get_String(modele_journee1, rang_journee1, 0)), groupe.Nom_Groupe);
			append(modele_liste_groupe, rang_liste_groupe, Null_Iter);
			Set(modele_liste_groupe, rang_liste_groupe, 0, p_conversion.to_string(groupe.Nom_Groupe));
			remove(modele_journee1, rang_journee1);
		end if;
	end retirerGroupeJ1;

	procedure ajouterGroupeJ2(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;
		groupe : tGroupe;
		nb : integer := 0;
	begin
		rang_journee2 := Get_Iter_First(modele_journee2);
		while rang_journee2 /= Null_Iter loop
			nb := nb + 1;
			Next(modele_journee2, rang_journee2);
		end loop;
		Get_Selected(Get_Selection(treeviewListeGroupes), Gtk_Tree_Model(modele_liste_groupe), rang_liste_groupe);
		if rang_liste_groupe = Null_Iter then 
			rep := Message_Dialog("Choisissez un groupe");
		elsif nb >= nbGroupesJ2 then
			rep := Message_Dialog("Cette journée est pleine");
		else
			to_ada_type((Get_String(modele_liste_groupe, rang_liste_groupe, 0)), groupe.Nom_Groupe);
			append(modele_journee2, rang_journee2, Null_Iter);
			Set(modele_journee2, rang_journee2, 0, p_conversion.to_string(groupe.Nom_Groupe));
			remove(modele_liste_groupe, rang_liste_groupe);
		end if;
	end ajouterGroupeJ2;

	procedure retirerGroupeJ2(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;
		groupe : tGroupe;
	begin
		Get_Selected(Get_Selection(treeviewJournee2), Gtk_Tree_Model(modele_journee2), rang_journee2);
		if rang_journee2 = Null_Iter then 
			rep := Message_Dialog("Choisissez un groupe");
		else
			to_ada_type((Get_String(modele_journee2, rang_journee2, 0)), groupe.Nom_Groupe);
			append(modele_liste_groupe, rang_liste_groupe, Null_Iter);
			Set(modele_liste_groupe, rang_liste_groupe, 0, p_conversion.to_string(groupe.Nom_Groupe));
			remove(modele_journee2, rang_journee2);
		end if;
	end retirerGroupeJ2;

	procedure enregistrerFestival(widget : access Gtk_Widget_Record'Class) is
		ville : tVille;
		groupe : tGroupe;
		rep : Message_Dialog_Buttons;
		i : integer := 1;
	begin
		to_ada_type((Get_String(modele_ville, rang_ville, 0)), ville.Nom_Ville);
		p_application.vider_journees(ville.Nom_Ville);
		rang_journee1 := Get_Iter_First(modele_journee1);
		while rang_journee1 /= Null_Iter loop
			to_ada_type(Get_String(modele_journee1, rang_journee1, 0), groupe.Nom_Groupe);
			p_application.creer_groupe_journee(ville.Nom_Ville, groupe.Nom_Groupe, 1, i);
			Next(modele_journee1, rang_journee1);
			i := i + 1;
		end loop;
		i := 1;
		rang_journee2 := Get_Iter_First(modele_journee2);
		while rang_journee2 /= Null_Iter loop
			to_ada_type(Get_String(modele_journee2, rang_journee2, 0), groupe.Nom_Groupe);
			p_application.creer_groupe_journee(ville.Nom_Ville, groupe.Nom_Groupe, 2, i);
			Next(modele_journee2, rang_journee2);
			i := i + 1;
		end loop;

		rep := Message_Dialog("La programmation du festival a bien été enregistrée");
		destroy(window);
	end enregistrerFestival;

end P_Window_ProgrammerFestival;