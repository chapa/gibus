with Glade.XML;use Glade.XML;
with System; use System; -- module permettant l'interaction avec la boucle événementielle principale
with Gtk.Main; -- pour les boites de dialogue
with Gtkada.Dialogs;use Gtkada.Dialogs; -- module GtkAda pour le composant fenêtre et les autres
with Gtk.Window; use Gtk.Window;
with Gtk.Button; use Gtk.Button;
with Gtk.GEntry; use Gtk.GEntry;
with Gtk.Tree_View; use Gtk.Tree_View;
with Gtk.Toggle_Button; use Gtk.Toggle_Button;

-- pour gérer le composant Tree_View
with Gtk.Tree_Model; use Gtk.Tree_Model; -- pour l'itérateur rang dans le modèle
with Gtk.Tree_Store; use Gtk.Tree_Store; -- le modèle associé à la vue
with Gtk.Tree_Selection; use Gtk.Tree_Selection; -- pour la sélection dans la vue
with p_util_treeview; use p_util_treeview; -- utilitaire de gestion du composant treeView

with p_conversion; use p_conversion; --utilitaire de conversion
with based108_data; use based108_data; -- types Ada
with base_types; use base_types; -- types énumérés
with Ada.Calendar;use Ada.Calendar; -- type date
with p_application; use p_application; -- couche application

package body P_Window_InscrireGroupe is

	window : Gtk_Window;
	butAnnuler, butChoisir, butAnnuler2, butFermer, butEnregistrer : Gtk_Button;
	entryNbConcertsPrevus, entryNbInscriptionsPossibles, entryNomGroupe, entryNomContact, entryCoordsContact, entryAdresseSite : Gtk_GEntry;
	treeViewVilles, treeViewGroupes : Gtk_Tree_View;
	radiobuttonHard, radiobuttonFusion, radiobuttonAlternatif, radiobuttonPop, radiobuttonPunk, radiobuttonRockabilly : Gtk_Toggle_Button;
	modele_ville, modele_groupe : Gtk_Tree_Store; -- le modèle associé aux vues
	rang_ville, rang_groupe : Gtk_Tree_Iter := Null_Iter; -- lignes dans les modeles

	-- construit le modèle associé à la vue treeViewVilles avec une ville par ligne
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
			rep := Message_Dialog("Il n'y a pas de villes enregistrées avec un festival");
			destroy(window);
		end errorBoxAucuneVille;
	begin
		p_application.retrouver_ville_avec_festival(ens_ville);
		clear(modele_ville);
		-- alimentation du modèle avec les noms de villes
		ville_List.iterate(ens_ville ,alimente_ville'Access);
	exception
		when exAucuneVille => errorBoxAucuneVille;
	end init_fenetre;

	procedure charge is
		XML : Glade_XML;
	begin
		Glade.XML.Gtk_New(XML, "src/ihm/4-inscrireGroupe.glade");
		window := Gtk_Window(Get_Widget(XML, "windowInscrireGroupe"));

		butAnnuler := Gtk_button(Get_Widget(XML, "buttonAnnuler"));
		butChoisir := Gtk_button(Get_Widget(XML, "buttonChoisir"));
		butAnnuler2 := Gtk_button(Get_Widget(XML, "buttonAnnuler2"));
		butFermer := Gtk_button(Get_Widget(XML, "buttonFermer"));
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
		Glade.XML.signal_connect(XML, "on_buttonFermer_clicked", ferme'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonEnregistrer_clicked", inscrireGroupe'address,null_address);

		-- creation pour la vue treeViewVilles d'une colonne et du modele associé
		p_util_treeview.creerColonne("nomVille", treeViewVilles, false);
		creerModele(treeViewVilles, modele_ville);
		-- creation pour la vue treeViewGroupes d'une colonne et du modele associé
		p_util_treeview.creerColonne("nomGroupe", treeViewGroupes, false);
		creerModele(treeViewGroupes, modele_groupe);

		init_fenetre;
	end charge;

	procedure ferme(widget : access Gtk_Widget_Record'Class) is
	begin
		destroy(window);
	end ferme;

	procedure affRegion1(widget : access Gtk_Widget_Record'Class) is
	begin
		set_text(entryNbConcertsPrevus, "");
		set_text(entryNbInscriptionsPossibles, "");
		set_text(entryNomGroupe, "");
		set_text(entryNomContact, "");
		set_text(entryCoordsContact, "");
		set_text(entryAdresseSite, "");
		clear(modele_groupe);

		set_sensitive(butAnnuler, true);
		set_sensitive(butChoisir, true);
		set_sensitive(butAnnuler2, false);
		set_sensitive(butFermer, false);
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

	procedure alimente_groupe(pos : Participant_Festival_List.Cursor) is
		groupe : tParticipant_Festival;
	begin
		groupe := Participant_Festival_List.element(pos);
		append(modele_groupe, rang_groupe, Null_Iter);
		Set(modele_groupe, rang_groupe, 0, p_conversion.to_string(groupe.Nom_Groupe_Inscrit));
	end alimente_groupe;

	procedure affRegion2(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;
		ville : tVille;
		nbConcertsPrevus, nbGroupes : integer;
		groupes : Participant_Festival_List.Vector;
	begin
		-- récupération du modèle et de la ligne sélectionnée
		Get_Selected(Get_Selection(treeViewVilles), Gtk_Tree_Model(modele_ville), rang_ville);
		if rang_ville = Null_Iter then 
			rep := Message_Dialog("Choisissez une ville");
		else
			-- récupération de la valeur de la colonne 1 dans la ligne sélectionnée
			to_ada_type(Get_String(modele_ville, rang_ville, 0), ville.Nom_Ville);
			-- lance la prodédure de consulation du nombre de concerts prévus en fonction du nom de la ville
			p_application.consulter_nbConcertsPrevus(ville.Nom_Ville, nbConcertsPrevus);
			-- lance la prodédure de consulation des groupes en fonction du nom de la ville
			p_application.retrouver_groupes_ville(ville.Nom_Ville, groupes, nbGroupes);

			if nbConcertsPrevus - nbGroupes <= 0 then
				rep := Message_Dialog("Tous les groupes ont étés enregistrés, il n'y a plus de place pour le festival de cette ville");
				affRegion1(widget);
				return;
			end if;

			set_text(entryNbConcertsPrevus, p_conversion.to_string(nbConcertsPrevus));
			set_text(entryNbInscriptionsPossibles, p_conversion.to_string(nbConcertsPrevus-nbGroupes));
			set_text(entryNbConcertsPrevus, p_conversion.to_string(nbConcertsPrevus));
			set_text(entryNomGroupe, "");
			set_text(entryNomContact, "");
			set_text(entryCoordsContact, "");
			set_text(entryAdresseSite, "");
			set_active(radiobuttonHard, true);
			clear(modele_groupe);
			-- alimentation du modèle avec les noms des groupes
			Participant_Festival_List.iterate(groupes, alimente_groupe'Access);

			set_sensitive(butAnnuler, false);
			set_sensitive(butChoisir, false);
			set_sensitive(butAnnuler2, true);
			set_sensitive(butFermer, true);
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
		end if;
	exception
		when ExAucunGroupe => rep := Message_Dialog("Il n'y a pas de groupes encore inscrits");
	end affRegion2;

	procedure inscrireGroupe(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;
		groupe : tGroupe;
		ville : tVille;
		procedure errorBoxGroupeExiste is
			rep : Message_Dialog_Buttons;
		begin
			rep := Message_Dialog("Ce groupe existe déjà");
		end errorBoxGroupeExiste;
	begin
		p_conversion.to_ada_type(Get_String(modele_ville, rang_ville, 0), ville.nom_ville);
		p_conversion.to_ada_type(get_text(entryNomGroupe), groupe.Nom_Groupe);
		p_conversion.to_ada_type(get_text(entryNomContact), groupe.Nom_Contact);
		p_conversion.to_ada_type(get_text(entryCoordsContact), groupe.Coord_Contact);
		p_conversion.to_ada_type(get_text(entryAdresseSite), groupe.Adr_Site);
		if get_active(radiobuttonHard) then
			groupe.Genre := hard;
		elsif get_active(radiobuttonFusion) then
			groupe.Genre := fusion;
		elsif get_active(radiobuttonAlternatif) then
			groupe.Genre := alternatif;
		elsif get_active(radiobuttonPop) then
			groupe.Genre := pop;
		elsif get_active(radiobuttonPunk) then
			groupe.Genre := punk;
		elsif get_active(radiobuttonRockabilly) then
			groupe.Genre := rockabilly;
		end if;

		p_application.creer_groupe(groupe, ville.nom_ville);
		rep := Message_Dialog("Le groupe a bien été inscrit");
		affRegion2(widget);
	exception
		when ExGroupeExiste => errorBoxGroupeExiste;
	end inscrireGroupe;

end P_Window_InscrireGroupe;