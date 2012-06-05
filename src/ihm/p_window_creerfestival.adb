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
package body P_window_creerfestival is

	window : Gtk_Window;
	butAnnuler1,butAnnuler2, butEnregistrer1,butEnregistrer2  : Gtk_Button;
	entryLieu,entryDate,entryPrixPlace,entryJournee1,entryJournee2,entryNbGroupe1,entryNbGroupe2,entryHeureDeb1,entryHeureDeb2 : Gtk_GEntry;
	treeviewVilles:Gtk_Tree_View;
	modele_ville: Gtk_Tree_Store;
	rang_ville : Gtk_Tree_Iter := Null_Iter;

	procedure alimente_ville(pos : ville_List.Cursor) is
		ville : based108_data.tVille;
	begin
		ville := ville_List.element(pos);
		append(modele_ville, rang_ville, Null_Iter); -- rajoute une ligne vide
		-- et met dans la colonne 1 de cette ligne le nom de la ville
		Set (modele_ville, rang_ville, 0, p_conversion.to_string(ville.nom_ville));
	end alimente_ville;

	


	-- (ré)initialise la fenêtre avec la liste des villes enregistrées ou un message
	procedure init_fenetre is
		ens_ville : based108_data.ville_List.Vector;
		rep : Message_Dialog_Buttons;
	begin
		p_application.retrouver_ville_sans_festival(ens_ville);
		clear (modele_ville);
		--delete_text(entryNomVille); delete_text(entryMelOrga);
		-- alimentation du modèle avec les noms de villes
		ville_List.iterate(ens_ville ,alimente_ville'Access);

		exception
			when exAucuneVille => append (modele_ville, rang_ville, Null_Iter);
			-- rajoute une ligne vide
			-- et met dans la colonne 1 de cette ligne le message
			
			rep:=Message_Dialog ("aucune ville enregistrée");destroy(window);
	end init_fenetre;





	procedure charge is
		XML : Glade_XML;
	begin
		
		Glade.XML.Gtk_New(XML, "src/ihm/2-creerFestival.glade");
		window := Gtk_Window(Get_Widget(XML, "windowCreerFestival"));

		butAnnuler1 := Gtk_button(Get_Widget(XML, "buttonAnnuler1"));
		butAnnuler2 := Gtk_button(Get_Widget(XML, "buttonAnnuler2"));
		butEnregistrer1 := Gtk_button(Get_Widget(XML, "buttonEnregistrer1"));
		butEnregistrer2 := Gtk_button(Get_Widget(XML, "buttonEnregistrer2"));

		entryLieu := Gtk_GEntry(Get_Widget(XML, "entryLieu"));
		entryDate := Gtk_GEntry(Get_Widget(XML, "entryDate"));
		entryPrixPlace := Gtk_GEntry(Get_Widget(XML, "entryPrixPlace"));

		entryJournee1 := Gtk_GEntry(Get_Widget(XML, "entryJournee1"));
		entryJournee2 := Gtk_GEntry(Get_Widget(XML, "entryJournee2"));
		entryNbGroupe1 := Gtk_GEntry(Get_Widget(XML, "entryNbGroupe1"));

		entryNbGroupe2 := Gtk_GEntry(Get_Widget(XML, "entryNbGroupe2"));
		entryHeureDeb1 := Gtk_GEntry(Get_Widget(XML, "entryHeureDeb1"));
		entryHeureDeb2 := Gtk_GEntry(Get_Widget(XML, "entryHeureDeb2"));
		treeviewVilles := Gtk_Tree_View(Get_Widget(XML, "treeviewVilles"));


		Glade.XML.signal_connect(XML, "on_buttonAnnuler1_clicked", ferme'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonAnnuler2_clicked", affRegion1'address,null_address);

		Glade.XML.signal_connect(XML, "on_buttonEnregistrer1_clicked", affRegion2'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonEnregistrer2_clicked", enregistrer'address,null_address);
		p_util_treeview.creerColonne("nomVille ", treeviewVilles, false);
		creerModele(treeviewVilles, modele_ville);
		init_fenetre;
		
	end charge;

	procedure ferme (widget : access Gtk_Widget_Record'Class) is
	begin
		destroy (window);
	end ferme ;
	
	procedure enregistrer (widget : access Gtk_Widget_Record'Class)is
		fest:tFestival;
		jourfest1,jourfest2:tJour_Festival;
		rep : Message_Dialog_Buttons;
		ExManqueInfos : exception;
	begin
		Get_Selected(Get_Selection(treeviewVilles), Gtk_Tree_Model(modele_ville), rang_ville);
		if rang_ville = Null_Iter   oR empty(get_text(entryLieu)) OR empty(get_text(entryDate)) OR empty(get_text(entryPrixPlace)) OR empty(get_text(entryNbGroupe1))OR empty(get_text(entryNbGroupe2))OR empty(get_text(entryHeureDeb1))OR empty(get_text(entryHeureDeb2)) then
			raise ExManqueInfos;
		end if;
		to_ada_type ((Get_String(modele_ville, rang_ville, 0)),fest.Ville_Festival) ;

		p_conversion.to_ada_type(get_text(entryLieu), fest.Lieu );
		p_conversion.to_ada_type(get_text(entryDate), fest.Date);
		p_conversion.to_ada_type(get_text(entryPrixPlace), fest.prix_place );
		p_conversion.to_ada_type(get_text(entryNbGroupe1), jourfest1.Nbre_Concert_Max);
		p_conversion.to_ada_type(get_text(entryNbGroupe2), jourfest2.Nbre_Concert_Max );
		p_conversion.to_ada_type(get_text(entryHeureDeb1), jourfest1.Heure_Debut);
		p_conversion.to_ada_type(get_text(entryHeureDeb2), jourfest2.Heure_Debut );
		jourfest1.Num_Ordre:=1;
		jourfest2.Num_Ordre:=2;
		jourfest1.Festival:=fest.Ville_Festival;
		jourfest2.Festival:=fest.Ville_Festival;
		
		creer_festival(fest,jourfest1,jourfest2);
		rep:=Message_Dialog ("Le festival est enregistrée");

		destroy (window);
		exception
			-- cas d'une ville déjà enregistrée
			when ExvilleExiste => rep:=Message_Dialog ("La ville était déjà enregistrée !");
				init_fenetre;
			-- cas où une donnée obligatoire est absente
			when ExManqueInfos => rep:=Message_Dialog ("Informations manquantes");
			-- cas d'une erreur de type dans les donnéess
			when Exconversion => return;
	
	end enregistrer;


	
	procedure affRegion1(widget : access Gtk_Widget_Record'Class)is
	ExManqueInfos :exception;
	rep: Message_Dialog_Buttons;
	begin
		set_sensitive(butAnnuler1, true);
		set_sensitive(butEnregistrer1, true);
		set_sensitive(butAnnuler2, false);
		set_sensitive(butEnregistrer2, false);

		set_sensitive(entryLieu, true);
		set_sensitive(entryDate, true);
		set_sensitive(entryPrixPlace, true);

		set_sensitive(entryJournee1, false);
		set_sensitive(entryJournee2, false);
		set_sensitive(entryNbGroupe1, false);

		set_sensitive(entryNbGroupe2, false);
		set_sensitive(entryHeureDeb1, false);
		set_sensitive(entryHeureDeb2, false);

		set_sensitive(treeviewVilles, true);
		exception
		when ExManqueInfos => rep:=Message_Dialog ("Informations manquantes");

	end affRegion1;
	procedure affRegion2(widget : access Gtk_Widget_Record'Class)is
		fest:tFestival;
		rep: Message_Dialog_Buttons;
		ExManqueInfos :exception;
		
	begin
		Get_Selected(Get_Selection(treeviewVilles), Gtk_Tree_Model(modele_ville), rang_ville);
		if rang_ville = Null_Iter   OR empty(get_text(entryLieu)) OR empty(get_text(entryDate)) OR empty(get_text(entryPrixPlace)) then
			raise ExManqueInfos;
			
		end if;
		
		
	 	p_conversion.to_ada_type(get_text(entryDate), fest.Date );
	 	
		set_text(entryJournee1,p_conversion.to_string(fest.Date));
		set_text(entryJournee2,p_conversion.to_string(fest.Date + 86400.0));
		
		
		set_sensitive(butAnnuler1, false);
		set_sensitive(butEnregistrer1, false);
		set_sensitive(butAnnuler2, true);
		set_sensitive(butEnregistrer2, true);

		set_sensitive(entryLieu, false);
		set_sensitive(entryDate, false);
		set_sensitive(entryPrixPlace, false);

		set_sensitive(entryJournee1, true);
		set_sensitive(entryJournee2, true);
		set_sensitive(entryNbGroupe1, true);

		set_sensitive(entryNbGroupe2, true);
		set_sensitive(entryHeureDeb1, true);
		set_sensitive(entryHeureDeb2, true);

		set_sensitive(treeviewVilles, false);
		exception
		-- cas d'une erreur de type dans les donnéess
			when ExManqueInfos => rep:=Message_Dialog ("Informations manquantes");
			when Exconversion => return;
	

	end affRegion2;
	

end P_window_creerfestival;