--------------------------
--auteur:Vincent
--------------------------
with Glade.XML;use Glade.XML;
with System; use System; -- module permettant l'interaction avec la boucle événementielle principale

with Gtk.Main; -- pour les boites de dialogue
with Gtkada.Dialogs;use Gtkada.Dialogs; -- module GtkAda pour le composant fenêtre et les autres
with Gtk.Window; use Gtk.Window;
with Gtk.Button; use Gtk.Button;
with Gtk.GEntry; use Gtk.GEntry;
with Gtk.Tree_View; use Gtk.Tree_View;

-- pour gérer le composant Tree_View
with Gtk.Tree_Model; use Gtk.Tree_Model; -- pour l'itérateur rang dans le modèle
with Gtk.Tree_Store; use Gtk.Tree_Store; -- le modèle associé à la vue
with Gtk.Tree_Selection; use Gtk.Tree_Selection; -- pour la sélection dans la vue
with p_util_treeview; use p_util_treeview; -- utilitaire de gestion du composant treeView
with p_esiut;use p_esiut;
with p_conversion; use p_conversion; -- utilitaire de conversion
with based108_data; use based108_data; -- types Ada
with p_application; use p_application; -- couche application
with Gtk.Toggle_Button; use Gtk.Toggle_Button;
with base_types;use base_types;
package body p_window_consultergroupepargenre is

	
	window : Gtk_Window;
	treeviewGroupe : Gtk_Tree_View;
	modele_groupe : Gtk_Tree_Store;  -- le modèle associé à la vue
	rang_groupe: Gtk_Tree_Iter := Null_Iter;  -- ligne dans le modele
	radiobuttonHard, radiobuttonFusion, radiobuttonAlternatif, radiobuttonPop, radiobuttonPunk, radiobuttonRockabilly : Gtk_Toggle_Button;
	butAnnuler, butAfficher, butRetour, butFermer:Gtk_Button;

	-- construit le modèle associé à la vue treeviewVilles avec une ville par ligne
	procedure alimente_groupe(pos : groupe_List.Cursor) is
		groupe : based108_data.tgroupe;
	begin
		groupe := groupe_List.element(pos);
		append(modele_groupe, rang_groupe, Null_Iter); -- rajoute une ligne vide
		-- et met dans la colonne 1 de cette ligne le nom de la ville
		Set (modele_groupe, rang_groupe, 0, p_conversion.to_string(groupe.nom_groupe));
		Set (modele_groupe, rang_groupe, 1, p_conversion.to_string(groupe.coord_contact));
	end alimente_groupe;

	
	-- (ré)initialise la fenêtre avec la liste des villes enregistrées ou un message
	procedure init_fenetre is
		groupe:tgroupe;
		rep : Message_Dialog_Buttons;
		groupes:based108_data.Groupe_List.vector;
		
	begin
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

		p_application.retrouver_groupes_genre(groupe.Genre,groupes);

		clear (modele_groupe);
		-- alimentation du modèle avec les noms de villes
		groupe_List.iterate(groupes ,alimente_groupe'Access);

		exception
			when exAucuneVille => rep:=message_dialog("hello");
			when exAucunGroupe => rep:=message_dialog("Il n'y a aucun groupe pour cette ville");
			affRegion1;
	end init_fenetre;

	procedure charge is
		XML : Glade_XML;
	begin
		Glade.XML.Gtk_New(XML, "src/ihm/12-ConulsterLesGroupesParGenre.glade");
		window := Gtk_Window(Get_Widget(XML,"windowConsulterGroupe"));

		treeviewGroupe := Gtk_Tree_View(Get_Widget(XML, "treeviewGroupe"));
		
		radiobuttonHard := Gtk_Toggle_Button(Get_Widget(XML, "radiobuttonHard"));
		radiobuttonFusion := Gtk_Toggle_Button(Get_Widget(XML, "radiobuttonFusion"));
		radiobuttonAlternatif := Gtk_Toggle_Button(Get_Widget(XML, "radiobuttonAlternatif"));
		radiobuttonPop := Gtk_Toggle_Button(Get_Widget(XML, "radiobuttonPop"));
		radiobuttonPunk := Gtk_Toggle_Button(Get_Widget(XML, "radiobuttonPunk"));
		radiobuttonRockabilly := Gtk_Toggle_Button(Get_Widget(XML, "radiobuttonRockabilly"));

		butAnnuler := Gtk_button(Get_Widget(XML, "buttonAnnuler"));
		butAfficher := Gtk_button(Get_Widget(XML, "buttonAfficher"));
		butRetour := Gtk_button(Get_Widget(XML, "buttonRetour"));
		butFermer := Gtk_button(Get_Widget(XML, "buttonFermer"));
		Glade.XML.signal_connect(XML,"on_buttonFermer_clicked",ferme'address,null_address );
		Glade.XML.signal_connect(XML,"on_buttonAfficher_clicked",affRegion2'address,null_address );
		Glade.XML.signal_connect(XML,"on_buttonAnnuler_clicked",ferme'address,null_address );
		Glade.XML.signal_connect(XML,"on_buttonRetour_clicked",affRegion1'address,null_address );
		
		-- creation d'une colonne dans la vue treeviewVilles
		p_util_treeview.creerColonne("Groupe ", treeviewGroupe, true);
		p_util_treeview.creerColonne("Ville ", treeviewGroupe, true);
		-- creation du modele associé à la vue treeviewVilles
		creerModele(treeviewGroupe, modele_groupe);
		

	end charge;

	procedure ferme (widget : access Gtk_Widget_Record'Class)is
	begin
		destroy (window);
	end ferme;


	
	procedure affRegion2 (widget : access Gtk_Widget_Record'Class) is
	begin
		set_sensitive(butAnnuler, false);
		set_sensitive(butFermer, true);
		set_sensitive(butRetour, true);
		set_sensitive(butAfficher, false);
		set_sensitive(treeviewGroupe, true);
		set_sensitive(radiobuttonHard, false);
		set_sensitive(radiobuttonFusion, false);
		set_sensitive(radiobuttonAlternatif, false);
		set_sensitive(radiobuttonPop, false);
		set_sensitive(radiobuttonPunk, false);
		set_sensitive(radiobuttonRockabilly, false);
		init_fenetre;
		
		
	end affRegion2;
	
	procedure affRegion1 is
	begin
		clear (modele_groupe);
		set_sensitive(butAnnuler, true);
		set_sensitive(butFermer, false);
		set_sensitive(butRetour, false);
		set_sensitive(butAfficher, true);
		set_sensitive(treeviewGroupe, false);
		set_sensitive(radiobuttonHard, true);
		set_sensitive(radiobuttonFusion, true);
		set_sensitive(radiobuttonAlternatif, true);
		set_sensitive(radiobuttonPop, true);
		set_sensitive(radiobuttonPunk, true);
		set_sensitive(radiobuttonRockabilly, true);

	end affRegion1;
end p_window_consultergroupepargenre;
