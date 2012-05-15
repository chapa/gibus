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
with Gtk.Tree_Model; use Gtk.Tree_Model;-- pour l'itérateur rang dans le modèle
with Gtk.Tree_Store; use Gtk.Tree_Store;-- le modèle associé à la vue
with Gtk.Tree_Selection; use Gtk.Tree_Selection;  -- pour la sélection dans la vue
with p_util_treeview; use p_util_treeview;  -- utilitaire de gestion du composant treeView

with p_conversion; use p_conversion; --utilitaire de conversion
with based108_data; use based108_data;  -- types Ada
with base_types; use base_types;  -- types énumérés
with Ada.Calendar;use Ada.Calendar;  -- type date
with p_application; use p_application;  -- couche application

package body P_Window_InscrireGroupe is

	window : Gtk_Window;
	butAnnuler, butChoisir, butAnnuler2, butEnregistrer : Gtk_Button;
	entryNbConcertsPrevus, entryNbInscriptionsPossibles, entryNomGroupe, entryNomContact, entryCoordsContact, entryAdresseSite : Gtk_GEntry;
	treeViewVilles, treeViewGroupes : Gtk_Tree_View;
	radiobuttonHard, radiobuttonFusion, radiobuttonAlternatif, radiobuttonPop, radiobuttonPunk, radiobuttonRockabilly : Gtk_Toggle_Button;
	modele_ville : Gtk_Tree_Store; -- le modèle associé aux vues
	rang_ville : Gtk_Tree_Iter := Null_Iter; -- lignes dans les modeles

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
			rep := Message_Dialog("Il n'y a pas de villes enregistrées");
			destroy(window);
		end errorBoxAucuneVille;
	begin
		p_application.retrouver_villes(ens_ville);
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
		Glade.XML.signal_connect(XML, "on_buttonEnregistrer_clicked", inscrireGroupe'address,null_address);

		-- creation pour la vue treeViewVilles d'une colonne et du modele associé
		p_util_treeview.creerColonne("nomVille", treeViewVilles, false);
		creerModele(treeViewVilles, modele_ville);

		init_fenetre;
	end charge;

	procedure ferme(widget : access Gtk_Widget_Record'Class) is
	begin
		destroy(window);
	end ferme;

	procedure affRegion1(widget : access Gtk_Widget_Record'Class) is
	begin
		set_sensitive(butAnnuler, true);
		set_sensitive(butChoisir, true);
		set_sensitive(butAnnuler2, false);
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

	procedure affRegion2(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;
	begin
		-- récupération du modèle et de la ligne sélectionnée
		Get_Selected(Get_Selection(treeViewVilles), Gtk_Tree_Model(modele_ville), rang_ville);
		if rang_ville = Null_Iter then 
			rep := Message_Dialog("Choisissez une ville");
		else --récupération de la valeur de la colonne 1 dans la ligne sélectionnée
			set_sensitive(butAnnuler, false);
			set_sensitive(butChoisir, false);
			set_sensitive(butAnnuler2, true);
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
	end affRegion2;

	procedure inscrireGroupe(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;
	begin
		rep := Message_Dialog("Le groupe a bien été inscrit");
		destroy(window);
	end inscrireGroupe;

end P_Window_InscrireGroupe;