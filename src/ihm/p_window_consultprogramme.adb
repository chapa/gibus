with Glade.XML;use Glade.XML;
with System; use System;
-- module permettant l'interaction avec la boucle événementielle principale
with Gtk.Main;
-- pour les boites de dialogue
with Gtkada.Dialogs;use Gtkada.Dialogs;
-- modules GtkAda pour les composant graphiques
with Gtk.Window; use Gtk.Window;
with Gtk.Button; use Gtk.Button;
with Gtk.Gentry; use Gtk.Gentry;
with Gtk.label; use Gtk.label;
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

package body P_window_consultProg is

-- instanciation du module p_enum pour les genres de musique
package p_enumGenre is new p_conversion.p_enum (tgenre_enum);

window : Gtk_Window;
tree_ville, tree_groupes_J1, tree_groupes_J2 : Gtk_tree_view;
entJ1 , entJ2 , entLieu: Gtk_entry;
butAnnuler, butFermer , butConsulter: Gtk_Button;
modele_ville, modele_J1, modele_J2  : Gtk_Tree_Store;  -- le modèle associé aux vues
rang_ville, rang_J1, rang_J2  : Gtk_Tree_Iter := Null_Iter;  -- lignes dans les modeles

-- construit le modèle associé à la vue tree_ville avec une ville par ligne
procedure alimente_ville( pos : ville_List.Cursor ) is
ville : gibus_Data.tVille;
begin
	ville := ville_List.element( pos );
	append (modele_ville, rang_ville, Null_Iter); -- rajoute une ligne vide
	-- et met dans la colonne 1 de cette ligne le nom de la ville
	Set (modele_ville, rang_ville, 0, p_conversion.to_string(ville.nom_ville));
end alimente_ville;

-- (ré)initialise la fenêtre avec la liste des villes dont le festival est programmé ou un message
procedure init_fenetre is
	ens_ville : gibus_Data.ville_List.Vector;
begin
    p_application.retrouver_villes_avec_programme (ens_ville ) ;
	-- alimentation du modèle avec les noms de villes
	ville_List.iterate( ens_ville , alimente_ville'Access );
exception
when exAucuneVille => append (modele_ville, rang_ville, Null_Iter);
	-- rajoute une ligne vide
	-- et met dans la colonne 1 de cette ligne le message
	Set (modele_ville, rang_ville, 0, "aucune ville n'a de festival entièrement programmé");
	set_sensitive (butConsulter, false);
end init_fenetre;

procedure charge is
XML : Glade_XML;
begin
	Glade.XML.Gtk_New(XML, "src/ihm/consultProgramme.glade");

	window := Gtk_Window(Get_Widget(XML,"windowConsultprog"));
	tree_ville :=Gtk_tree_view(Get_Widget(XML,"treeviewVille"));
	entLieu := Gtk_entry(Get_Widget(XML,"entryLieu"));
	entJ1 :=Gtk_entry(Get_Widget(XML,"entryDateJour1"));
	tree_groupes_J1 :=Gtk_tree_view(Get_Widget(XML,"treeviewGroupesJour1"));
	entJ2 := Gtk_entry(Get_Widget(XML,"entryDateJour2"));
	tree_groupes_J2 :=Gtk_tree_view(Get_Widget(XML,"treeviewGroupesJour2"));
	butAnnuler := Gtk_button(Get_Widget(XML,"buttonAnnuler"));
	butFermer := Gtk_button(Get_Widget(XML,"buttonFermer"));
	butConsulter :=Gtk_button(Get_Widget(XML,"buttonConsulter")); 

	
	Glade.XML.signal_connect(XML,"on_buttonConsulter_clicked",affiche_prog'address,null_address );
	
	Glade.XML.signal_connect(XML,"on_buttonFermer_clicked",ferme_win_affProg'address,null_address );
	Glade.XML.signal_connect(XML,"on_buttonAnnuler_clicked",annule_affProg'address,null_address );

    -- creation pour la vue tree_ville d'une colonne et du modele associé
	p_util_treeview.creerColonne ("nomVille ", tree_ville, false);
	creerModele ( tree_ville , modele_ville);

	-- creation pour la vue tree_groupes_J1 de 2 colonnes et du modele associé
	p_util_treeview.creerColonne ("groupesJ1 ", tree_groupes_J1, false);
	p_util_treeview.creerColonne ("groupesJ1 ", tree_groupes_J1, false);
	creerModele ( tree_groupes_J1 , modele_J1);

	-- creation pour la vue tree_groupes_J2 de 2 colonnes et du modele associé
	p_util_treeview.creerColonne ("groupesJ2 ", tree_groupes_J2, false);
	p_util_treeview.creerColonne ("groupesJ2 ", tree_groupes_J2, false);
	creerModele ( tree_groupes_J2 , modele_J2);

    init_fenetre;

end charge;

procedure ferme_win_affProg (widget : access Gtk_Widget_Record'Class)is
begin
	destroy (window);
end ferme_win_affProg ;

procedure annule_affProg (widget : access Gtk_Widget_Record'Class)is
begin
	destroy (window);
end annule_affProg ;

-- construit le modèle associé à la vue tree_groupes_J1 avec un nom de groupe et son genre par ligne
procedure alimente_groupeJ1( pos :Programme_Jour_Festival_List.Cursor ) is
	prog : gibus_Data.tProgramme_Jour_Festival;
	groupe : tgroupe;
begin
	prog := Programme_Jour_Festival_List.element( pos );
	append (modele_J1, rang_J1, Null_Iter); -- rajoute une ligne vide
	-- et met dans la colonne 1 de cette ligne le nom de la ville
	Set (modele_J1, rang_J1, 0, p_conversion.to_string(prog.nom_groupe_programme));
	-- consulte le groupe pour avoir son genre
	p_application.consultGroupe (prog.nom_groupe_programme, groupe);
	--  met dans la colonne 2 de cette ligne le genre du groupe
	Set (modele_J1, rang_J1, 1, p_enumGenre.to_string(groupe.genre));
end alimente_groupeJ1;







-- construit le modèle associé à la vue tree_groupes_J2 avec un nom de groupe et son genre par ligne
procedure alimente_groupeJ2( pos : Programme_Jour_Festival_List.Cursor ) is
	prog : gibus_Data.tProgramme_Jour_Festival;
	groupe : tgroupe;
begin
	prog := Programme_Jour_Festival_List.element( pos );
	append (modele_J2, rang_J2, Null_Iter); -- rajoute une ligne vide
	-- et met dans la colonne 1 de cette ligne le nom de la ville
	Set (modele_J2, rang_J2, 0, p_conversion.to_string(prog.nom_groupe_programme));
	p_application.consultGroupe (prog.nom_groupe_programme, groupe);
	 --  met dans la colonne 2 de cette ligne le genre du groupe
	Set (modele_J2, rang_J2, 1, p_enumGenre.to_string(groupe.genre));
end alimente_groupeJ2;










-- affiche la liste des groupes des 2 journées du festival dans leur ordre de passage
procedure afficher_groupes (ensPr1, ensPr2 :Programme_Jour_Festival_List.vector)is
begin
-- alimentation des 2 modèles avec les noms et genres des groupes
	Programme_Jour_Festival_List.iterate( ensPr1 , alimente_groupeJ1'Access );
	Programme_Jour_Festival_List.iterate( ensPr2 , alimente_groupeJ2'Access );
end afficher_groupes;





procedure affiche_prog (widget : access Gtk_Widget_Record'Class)is
	ville : tville; -- la ville sélectionnée
	fest : tfestival; -- le festival de la ville
	ensProg1, ensProg2 : Programme_Jour_Festival_List.Vector; -- les programmes de chaque journée
	rep : Message_Dialog_Buttons;
begin
	-- récupération du modèle et de la ligne sélectionnée
	Get_Selected(Get_Selection(tree_ville), Gtk_Tree_Model(modele_ville), rang_ville);
	--vérification qu'une ligne est sélectionnée
	if rang_ville = Null_Iter then 
		rep:=Message_Dialog ("Choisissez la ville");
		--récupération de la valeur de la colonne 1 dans la ligne sélectionnée
	else
		to_ada_type ((Get_String(modele_ville, rang_ville, 0)),ville.nom_Ville) ;
		-- lance la prodédure de consulation du festival et des groupes programmés
		p_application.consulter_programme_festival (ville.nom_Ville,fest,ensProg1,ensProg2);
		set_text(entLieu,p_conversion.to_string(fest.lieu));
		set_text(entJ1,p_conversion.to_string(fest.date));
		set_text(entJ2,p_conversion.to_string(fest.date + 86400.0));
		-- affiche dans les tree_view des 2 journées la liste des groupes dans leur ordre de passage
		afficher_groupes(ensProg1, ensProg2);
		-- change l'état de la fenêtre
		set_sensitive(butFermer, true);
		set_sensitive(butAnnuler, false);
		set_sensitive(butConsulter,false);
	end if;
end affiche_prog;

end P_window_consultProg;