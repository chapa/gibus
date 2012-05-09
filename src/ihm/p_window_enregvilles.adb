with Glade.XML;use Glade.XML;
with System; use System;
-- module permettant l'interaction avec la boucle événementielle principale
with Gtk.Main;
-- pour les boites de dialogue
with Gtkada.Dialogs;use Gtkada.Dialogs;
-- module GtkAda pour le composant fenêtre et les autres
with Gtk.Window; use Gtk.Window;
with Gtk.GEntry; use Gtk.GEntry;
with Gtk.Tree_View; use Gtk.Tree_View;
with Gtk.Button; use Gtk.Button;
-- pour gérer le composant Tree_View
with Gtk.Tree_Model; use Gtk.Tree_Model; -- pour l'itérateur rang dans le modèle
with Gtk.Tree_Store; use Gtk.Tree_Store; -- le modèle associé à la vue
with Gtk.Tree_Selection; use Gtk.Tree_Selection; -- pour la sélection dans la vue
with p_util_treeview; use p_util_treeview; -- utilitaire de gestion du composant treeView

with p_conversion; use p_conversion; -- utilitaire de conversion
with based108_data; use based108_data; -- types Ada
with p_application; use p_application; -- couche application

package body P_window_enregVilles is

	window : Gtk_Window;
	treeviewVilles : Gtk_Tree_View;
	entryNomVille, entryMelOrga : Gtk_GEntry;
	modele_ville : Gtk_Tree_Store;  -- le modèle associé à la vue
	rang_ville : Gtk_Tree_Iter := Null_Iter;  -- ligne dans le modele

	-- construit le modèle associé à la vue treeviewVilles avec une ville par ligne
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
	begin
		p_application.retrouver_villes(ens_ville);
		clear (modele_ville);
		delete_text(entryNomVille); delete_text(entryMelOrga);delete_text(entmel2);
		-- alimentation du modèle avec les noms de villes
		ville_List.iterate(ens_ville ,alimente_ville'Access);

		exception
			when exAucuneVille => append (modele_ville, rang_ville, Null_Iter);
			-- rajoute une ligne vide
			-- et met dans la colonne 1 de cette ligne le message
			Set (modele_ville, rang_ville, 0, "aucune ville enregistrée");
	end init_fenetre;

	procedure charge is
		XML : Glade_XML;
	begin

		Glade.XML.Gtk_New(XML, "src/ihm/1-enregVilles.glade");
		window := Gtk_Window(Get_Widget(XML,"windowEnregVilles"));

		treeviewVilles := Gtk_Tree_View(Get_Widget(XML, "treeviewVille"));
		entryNomVille := Gtk_GEntry(Get_Widget(XML, "entryNomVille"));
		entryMelOrga := Gtk_GEntry(Get_Widget(XML, "entryMelOrga"));

		Glade.XML.signal_connect(XML,"on_buttonFermer_clicked",ferme'address,null_address );
		Glade.XML.signal_connect(XML,"on_buttonEnregistrer_clicked",enregVille'address,null_address );

		-- creation d'une colonne dans la vue treeviewVilles
		p_util_treeview.creerColonne("nomVille ", treeviewVilles, false);
		-- creation du modele associé à la vue treeviewVilles
		creerModele(treeviewVilles, modele_ville);
		init_fenetre;

	end charge;

	procedure ferme (widget : access Gtk_Widget_Record'Class)is
	begin
		destroy (window);
	end ferme;


	procedure enregVille(widget : access Gtk_Widget_Record'Class) is
		ville : tville;
		ExManqueInfos : exception;
		rep : Message_Dialog_Buttons;
	begin
		-- vérification des la présence des infos obligatoires
		if empty(get_text(entryNomVille)) OR empty(get_text(entryMelOrga)) then
			raise ExManqueInfos;
		end if;
		-- affectation de la variable ville
		p_conversion.to_ada_type(get_text(entryNomVille), ville.nom_ville );
		p_conversion.to_ada_type(get_text(entryMelOrga), ville.mel_contact);
		-- lance la prodédure d'enregistrement de la ville dans la base
		p_application.creer_ville(ville);
		rep:=Message_Dialog ("La ville est enregistrée");
		init_fenetre;

		exception
			-- cas d'une ville déjà enregistrée
			when ExvilleExiste => rep:=Message_Dialog ("La ville était déjà enregistrée !");
				init_fenetre;
			-- cas où une donnée obligatoire est absente
			when ExManqueInfos => rep:=Message_Dialog ("les nom et mel d'organisateur sont obligatoires");
			-- cas d'une erreur de type dans les données
			when Exconversion => return;
	end enregVille;

end P_window_enregVilles ;