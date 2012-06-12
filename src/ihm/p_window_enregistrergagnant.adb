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
package body P_window_enregistrerGagnant is

	window : Gtk_Window;
	butAnnuler, butEnregistrer,butRetour,butSelectionner  : Gtk_Button;
	treeviewVilles,treeviewGroupes:Gtk_Tree_View;
	modele_ville,modele_groupe: Gtk_Tree_Store;
	rang_ville,rang_groupe : Gtk_Tree_Iter := Null_Iter;

	procedure alimente_ville(pos : ville_List.Cursor) is
		ville : based108_data.tVille; 
	begin
		ville := ville_List.element(pos);
		append(modele_ville, rang_ville, Null_Iter); -- rajoute une ligne vide
		-- et met dans la colonne 1 de cette ligne le nom de la ville
		Set (modele_ville, rang_ville, 0, p_conversion.to_string(ville.nom_ville));
	end alimente_ville;

	procedure alimente_groupe(pos : Participant_Festival_List.Cursor) is
		groupe : based108_data.tParticipant_Festival;
	begin
		groupe := Participant_Festival_List.element(pos);
		append(modele_groupe, rang_groupe, Null_Iter); -- rajoute une ligne vide
		-- et met dans la colonne 1 de cette ligne le nom de la ville
		Set (modele_groupe, rang_groupe, 0, p_conversion.to_string(groupe.Nom_Groupe_Inscrit));
	end alimente_groupe;

	
	-- (ré)initialise la fenêtre avec la liste des villes enregistrées ou un message
	procedure init_fenetre is
		ens_ville : based108_data.ville_List.Vector;
		rep : Message_Dialog_Buttons;
	begin
		retrouver_villes_sans_gagnant(ens_ville );
		clear (modele_ville);
		ville_List.iterate(ens_ville ,alimente_ville'Access);
		
	exception
		when exAucuneVille => append (modele_ville, rang_ville, Null_Iter);
		-- rajoute une ligne vide
		-- et met dans la colonne 1 de cette ligne le message
	
		rep:=Message_Dialog ("Aucune ville sans gagnant");destroy(window);
	end init_fenetre;





	procedure charge is
		XML : Glade_XML;
	begin
		
		Glade.XML.Gtk_New(XML, "src/ihm/9-EnregistrerGagnantFestival.glade");
		window := Gtk_Window(Get_Widget(XML, "WindowEnregistrerGagnantFestival"));

		butAnnuler := Gtk_button(Get_Widget(XML, "buttonAnnuler"));
		butRetour := Gtk_button(Get_Widget(XML, "buttonRetour"));
		butEnregistrer := Gtk_button(Get_Widget(XML, "buttonEnregistrer"));
		butSelectionner := Gtk_button(Get_Widget(XML, "buttonSelectionner"));

		
		treeviewVilles := Gtk_Tree_View(Get_Widget(XML, "treeviewville"));
		treeviewGroupes := Gtk_Tree_View(Get_Widget(XML, "treeviewGroupes"));

		Glade.XML.signal_connect(XML, "on_buttonAnnuler_clicked", ferme'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonRetour_clicked", affRegion1'address,null_address);

		Glade.XML.signal_connect(XML, "on_buttonSelectionner_clicked", affRegion2'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonEnregistrer_clicked", enregistrer'address,null_address);
		p_util_treeview.creerColonne("nomVille ", treeviewVilles, false);
		p_util_treeview.creerColonne("nomGroupes ", treeviewGroupes, false);


		creerModele(treeviewVilles, modele_ville);
		creerModele(treeviewGroupes, modele_groupe);
		init_fenetre;
		
	end charge;

	procedure ferme (widget : access Gtk_Widget_Record'Class) is
	begin
		destroy (window);
	end ferme ;
	
	procedure enregistrer (widget : access Gtk_Widget_Record'Class)is
		fest:tFestival;
		participants:tParticipant_Festival;
		jourfest1,jourfest2:tJour_Festival;
		rep : Message_Dialog_Buttons;
		ExManqueInfos : exception;
	begin
		ecrire("h1");
		Get_Selected(Get_Selection(treeviewGroupes), Gtk_Tree_Model(modele_groupe), rang_groupe);
		ecrire("h2");
		Get_Selected(Get_Selection(treeviewVilles), Gtk_Tree_Model(modele_ville), rang_ville);
		ecrire("h3");
		if rang_ville = Null_Iter or rang_groupe = Null_Iter   then
			raise ExManqueInfos;
		end if;
		ecrire("h4");
		to_ada_type ((Get_String(modele_groupe, rang_groupe, 0)),participants.Nom_Groupe_Inscrit) ;
		ecrire("h5");
		to_ada_type ((Get_String(modele_ville, rang_ville, 0)),participants.Festival);
		ecrire("h6");
		
		
		inscrire_groupe(participants);
		rep:=Message_Dialog ("Le gagnant est enregistré");

		destroy (window);
		exception
			-- cas d'une ville déjà enregistrée
			when ExvilleExiste => rep:=Message_Dialog ("La ville était déjà enregistrée !");
				init_fenetre;
			-- cas où une donnée obligatoire est absente
			when ExManqueInfos => rep:=Message_Dialog ("Selectionner un groupe");
			-- cas d'une erreur de type dans les donnéess
			when Exconversion => return;
	
	end enregistrer;


	
	procedure affRegion1 is
	rep: Message_Dialog_Buttons;
	begin
		set_sensitive(butAnnuler, true);
		set_sensitive(butSelectionner, true);
		set_sensitive(butRetour, false);
		set_sensitive(butEnregistrer, false);

		

		set_sensitive(treeviewVilles, true);
		set_sensitive(treeviewGroupes, false);
		

	end affRegion1;
	
	procedure affRegion2(widget : access Gtk_Widget_Record'Class)is
		
		fest:tFestival;
		rep: Message_Dialog_Buttons;
		ExManqueInfos :exception;
		participants:Participant_Festival_List.Vector;
		nbGroupes:integer;
		
	begin
		Get_Selected(Get_Selection(treeviewVilles), Gtk_Tree_Model(modele_ville), rang_ville);
		if rang_ville = Null_Iter then
			raise ExManqueInfos;
		end if;
		to_ada_type ((Get_String(modele_ville, rang_ville, 0)),fest.Ville_Festival);
		retrouver_groupes_ville(fest.Ville_Festival , participants , nbGroupes);
		clear (modele_groupe);
		Participant_Festival_List.iterate(participants ,alimente_groupe'Access);



		set_sensitive(butAnnuler, false);
		set_sensitive(butSelectionner, false);
		set_sensitive(butRetour, true);
		set_sensitive(butEnregistrer, true);

		

		set_sensitive(treeviewVilles, false);
		set_sensitive(treeviewGroupes, true);
		exception
		when ExManqueInfos => rep:=Message_Dialog ("Selectionner une ville");
		when ExAucunGroupe => rep:=Message_Dialog ("Aucun groupe");affRegion1;
	end affRegion2;
	

end P_window_enregistrerGagnant;