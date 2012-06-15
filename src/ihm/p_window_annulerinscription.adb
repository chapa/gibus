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
with p_util_treeview; use p_util_treeview; -- utili
with p_conversion; use p_conversion; -- utilitaire de conversion
with based108_data; use based108_data; -- types Ada
with p_application; use p_application; -- couche application
with p_esiut; use p_esiut;
with Ada.Calendar;Use ada.Calendar;
package body p_window_annulerinscription is

	window : Gtk_Window;
	butAnnuler,butSupprimer : Gtk_Button;
	treeviewgroupe:Gtk_Tree_View;
	modele_groupe: Gtk_Tree_Store;
	rang_groupe : Gtk_Tree_Iter := Null_Iter;

	procedure alimente_groupe(pos : groupe_List.Cursor) is
		groupe : based108_data.tgroupe;
	begin
		groupe := groupe_List.element(pos);
		append(modele_groupe, rang_groupe, Null_Iter); -- rajoute une ligne vide
		-- et met dans la colonne 1 de cette ligne le nom de la ville
		Set (modele_groupe, rang_groupe, 0, p_conversion.to_string(groupe.nom_groupe));
		Set (modele_groupe, rang_groupe, 1, p_conversion.to_string(groupe.nom_contact));
	end alimente_groupe;

	


	-- (ré)initialise la fenêtre avec la liste des villes enregistrées ou un message
	procedure init_fenetre is
		ens_groupe : based108_data.groupe_List.Vector;
		rep : Message_Dialog_Buttons;
	begin
		retrouver_groupe_et_villes(ens_groupe);
		clear (modele_groupe);
		groupe_List.iterate(ens_groupe ,alimente_groupe'Access);

		exception
			when exAucunGroupe => rep:=Message_Dialog ("Aucun groupe existant");destroy(window);
			when exAucuneVille => rep:=Message_Dialog ("Aucune ville");destroy(window);
			-- rajoute une ligne vide
			-- et met dans la colonne 1 de cette ligne le message
			
			
	end init_fenetre;





	procedure charge is
		XML : Glade_XML;
	begin
		
		Glade.XML.Gtk_New(XML, "src/ihm/13-annulerInscriptionGroupe.glade");
		window := Gtk_Window(Get_Widget(XML, "window1"));

		butAnnuler := Gtk_button(Get_Widget(XML, "buttonAnnuler"));
		butSupprimer := Gtk_button(Get_Widget(XML, "buttonSupprimer"));
		
		treeviewgroupe := Gtk_Tree_View(Get_Widget(XML, "treeviewGroupe"));


		Glade.XML.signal_connect(XML, "on_buttonAnnuler_clicked", ferme'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonSupprimer_clicked", supprimer'address,null_address);

		
		p_util_treeview.creerColonne("Groupe", treeviewGroupe, true);
		p_util_treeview.creerColonne("Ville", treeviewGroupe, true);
		creerModele(treeviewGroupe, modele_groupe);
		init_fenetre;
		
	end charge;

	procedure ferme (widget : access Gtk_Widget_Record'Class) is
	begin
		destroy (window);
	end ferme ;
	
	procedure supprimer (widget : access Gtk_Widget_Record'Class)is
		groupe:tgroupe;
		rep : Message_Dialog_Buttons;
		ExManqueInfos : exception;
	begin
		Get_Selected(Get_Selection(treeviewGroupe), Gtk_Tree_Model(modele_groupe), rang_groupe);
		if rang_groupe = Null_Iter   then
			raise ExManqueInfos;
		end if;

		to_ada_type ((Get_String(modele_groupe, rang_groupe, 0)),groupe.nom_groupe) ;
		to_ada_type ((Get_String(modele_groupe, rang_groupe, 1)),groupe.nom_contact) ;
		desinscrire_groupe(groupe);
		
		rep:=Message_Dialog ("Le groupe a été désinscrit");

		destroy (window);
		exception
			
			-- cas où une donnée obligatoire est absente
			when ExManqueInfos => rep:=Message_Dialog ("Selectionner une ville");
			-- cas d'une erreur de type dans les donnéess
			when Exconversion => return;
	
	end supprimer;


	
	

end p_window_annulerinscription;