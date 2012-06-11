with Glade.XML;use Glade.XML;
with System; use System;
with Gtk.Main; -- module permettant l'interaction avec la boucle événementielle principale
with Gtkada.Dialogs;use Gtkada.Dialogs; -- pour les boites de dialogue
-- module GtkAda pour le composant fenêtre et les autres
with Gtk.Window; use Gtk.Window;
with Gtk.Button; use Gtk.Button;
with Gtk.Tree_View; use Gtk.Tree_View;
with Gtk.GEntry; use Gtk.GEntry;
with Gtk.Toggle_Button; use Gtk.Toggle_Button;

-- pour gérer le composant Tree_View
with Gtk.Tree_Model; use Gtk.Tree_Model; -- pour l'itérateur rang dans le modèle
with Gtk.Tree_Store; use Gtk.Tree_Store; -- le modèle associé à la vue
with Gtk.Tree_Selection; use Gtk.Tree_Selection; -- pour la sélection dans la vue
with p_util_treeview; use p_util_treeview; -- utilitaire de gestion du composant treeView

with p_conversion; use p_conversion; --utilitaire de conversion
with based108_data; use based108_data; -- types Ada
with base_types; use base_types; -- types énumérés
with p_application; use p_application; -- couche application

package body P_Window_ModifierInfosGroupe is

	window : Gtk_Window;
	butAnnuler1, butModifier, butAnnuler2, butEnregistrer : Gtk_Button;
	treeviewGroupes : Gtk_Tree_View;
	entryNomGroupe, entryNomContact, entryCoordsContact, entrySiteWeb : Gtk_GEntry;
	radiobuttonHard, radiobuttonFusion, radiobuttonAlternatif, radiobuttonPop, radiobuttonPunk, radiobuttonRockabilly : Gtk_Toggle_Button;
	modele_groupe : Gtk_Tree_Store; -- le modèle associé aux vues
	rang_groupe : Gtk_Tree_Iter := Null_Iter; -- lignes dans les modeles

	-- construit le modèle associé à la vue treeviewGroupes avec un groupe par ligne
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
		Glade.XML.Gtk_New(XML, "src/ihm/11-modifierInfosGroupe.glade");
		window := Gtk_Window(Get_Widget(XML, "windowModifierInfosGroupe"));

		butAnnuler1 := Gtk_button(Get_Widget(XML, "buttonAnnuler1"));
		butModifier := Gtk_button(Get_Widget(XML, "buttonModifier"));
		butAnnuler2 := Gtk_button(Get_Widget(XML, "buttonAnnuler2"));
		butEnregistrer := Gtk_button(Get_Widget(XML, "buttonEnregistrer"));
		treeviewGroupes := Gtk_Tree_View(Get_Widget(XML, "treeviewGroupes"));
		entryNomGroupe := Gtk_GEntry(Get_Widget(XML, "entryNomGroupe"));
		entryNomContact := Gtk_GEntry(Get_Widget(XML, "entryNomContact"));
		entryCoordsContact := Gtk_GEntry(Get_Widget(XML, "entryCoordsContact"));
		entrySiteWeb := Gtk_GEntry(Get_Widget(XML, "entrySiteWeb"));radiobuttonHard := Gtk_Toggle_Button(Get_Widget(XML, "radiobuttonHard"));
		radiobuttonFusion := Gtk_Toggle_Button(Get_Widget(XML, "radiobuttonFusion"));
		radiobuttonAlternatif := Gtk_Toggle_Button(Get_Widget(XML, "radiobuttonAlternatif"));
		radiobuttonPop := Gtk_Toggle_Button(Get_Widget(XML, "radiobuttonPop"));
		radiobuttonPunk := Gtk_Toggle_Button(Get_Widget(XML, "radiobuttonPunk"));
		radiobuttonRockabilly := Gtk_Toggle_Button(Get_Widget(XML, "radiobuttonRockabilly"));

		Glade.XML.signal_connect(XML, "on_buttonAnnuler1_clicked", ferme'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonModifier_clicked", affRegion2'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonAnnuler2_clicked", affRegion1'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonEnregistrer_clicked", enregistrer'address,null_address);

		-- creation pour la vue treeviewGroupes d'une colonne et du modele associé
		p_util_treeview.creerColonne("nomVille ", treeviewGroupes, false);
		creerModele(treeviewGroupes, modele_groupe);

		init_fenetre;
	end charge;

	procedure ferme(widget : access Gtk_Widget_Record'Class) is
	begin
		destroy (window);
	end ferme;

	procedure affRegion1(widget : access Gtk_Widget_Record'Class) is
	begin
		set_text(entryNomGroupe, "");
		set_text(entryNomContact, "");
		set_text(entryCoordsContact, "");
		set_text(entrySiteWeb, "");
		set_active(radiobuttonHard, true);

		set_sensitive(butAnnuler1, true);
		set_sensitive(butModifier, true);
		set_sensitive(butAnnuler2, false);
		set_sensitive(butEnregistrer, false);
		set_sensitive(treeviewGroupes, true);
		set_sensitive(entryNomGroupe, false);
		set_sensitive(entryNomContact, false);
		set_sensitive(entryCoordsContact, false);
		set_sensitive(entrySiteWeb, false);
		set_sensitive(radiobuttonHard, false);
		set_sensitive(radiobuttonFusion, false);
		set_sensitive(radiobuttonAlternatif, false);
		set_sensitive(radiobuttonPop, false);
		set_sensitive(radiobuttonPunk, false);
		set_sensitive(radiobuttonRockabilly, false);
	end affRegion1;

	procedure affRegion2(widget : access Gtk_Widget_Record'Class) is
		groupe : tGroupe;
		rep : Message_Dialog_Buttons;
	begin
		-- récupération du modèle et de la ligne sélectionnée
		Get_Selected(Get_Selection(treeviewGroupes), Gtk_Tree_Model(modele_groupe), rang_groupe);
		--vérification qu'une ligne est sélectionnée
		if rang_groupe = Null_Iter then 
			rep := Message_Dialog("Choisissez un groupe");
		else --récupération de la valeur de la colonne 1 dans la ligne sélectionnée
			to_ada_type((Get_String(modele_groupe, rang_groupe, 0)), groupe.Nom_Groupe);
			-- lance la prodédure de consulation du festival et des groupes programmés
			p_application.consultGroupe(groupe.Nom_Groupe, groupe);

			set_text(entryNomGroupe, p_conversion.to_string(groupe.Nom_Groupe));
			set_text(entryNomContact, p_conversion.to_string(groupe.Nom_Contact));
			set_text(entryCoordsContact, p_conversion.to_string(groupe.Coord_Contact));
			set_text(entrySiteWeb, p_conversion.to_string(groupe.Adr_Site));
			if groupe.Genre = hard then
				set_active(radiobuttonHard, true);
			elsif groupe.Genre = fusion then
				set_active(radiobuttonFusion, true);
			elsif groupe.Genre = alternatif then
				set_active(radiobuttonAlternatif, true);
			elsif groupe.Genre = pop then
				set_active(radiobuttonPop, true);
			elsif groupe.Genre = punk then
				set_active(radiobuttonPunk, true);
			elsif groupe.Genre = rockabilly then
				set_active(radiobuttonRockabilly, true);
			end if;

			set_sensitive(butAnnuler1, false);
			set_sensitive(butModifier, false);
			set_sensitive(butAnnuler2, true);
			set_sensitive(butEnregistrer, true);
			set_sensitive(treeviewGroupes, false);
			set_sensitive(entryNomGroupe, true);
			set_sensitive(entryNomContact, true);
			set_sensitive(entryCoordsContact, true);
			set_sensitive(entrySiteWeb, true);
			set_sensitive(radiobuttonHard, true);
			set_sensitive(radiobuttonFusion, true);
			set_sensitive(radiobuttonAlternatif, true);
			set_sensitive(radiobuttonPop, true);
			set_sensitive(radiobuttonPunk, true);
			set_sensitive(radiobuttonRockabilly, true);
		end if;
	end affRegion2;

	procedure enregistrer(widget : access Gtk_Widget_Record'Class) is
		rep : Message_Dialog_Buttons;
		groupe : tGroupe;
	begin
		to_ada_type((Get_String(modele_groupe, rang_groupe, 0)), groupe.Nom_Groupe);
		p_conversion.to_ada_type(get_text(entryNomContact), groupe.Nom_Contact);
		p_conversion.to_ada_type(get_text(entryCoordsContact), groupe.Coord_Contact);
		p_conversion.to_ada_type(get_text(entrySiteWeb), groupe.Adr_Site);
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

		p_application.modifier_groupe(groupe);
		rep := Message_Dialog("Les modifications du groupe ont bien été enregistrées");
		destroy(window);
	end enregistrer;
	
end P_Window_ModifierInfosGroupe;