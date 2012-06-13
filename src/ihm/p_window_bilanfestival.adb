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
with base_types;use base_types;



package body P_window_bilanfestival is
package p_enumGenre is new p_conversion.p_enum(tgenre_enum);

	window : Gtk_Window;
	butOK  : Gtk_Button;
	entryNbGroupe:Gtk_GEntry;
	treeviewVilles,treeviewGenres:Gtk_Tree_View;
	modele_ville,modele_groupe: Gtk_Tree_Store;
	rang_ville,rang_groupe : Gtk_Tree_Iter := Null_Iter;

	procedure alimente_ville(pos : festival_List.Cursor) is
		ville : based108_data.tfestival;
	begin
		ecrire("hello");
		ville := festival_List.element(pos);
		append(modele_ville, rang_ville, Null_Iter); -- rajoute une ligne vide
		-- et met dans la colonne 1 de cette ligne le nom de la ville
		Set (modele_ville, rang_ville, 0, p_conversion.to_string(ville.ville_festival));
		Set (modele_ville, rang_ville,1 , p_conversion.to_string(ville.prix_place));
	end alimente_ville;

	


	-- (ré)initialise la fenêtre avec la liste des villes enregistrées ou un message
	procedure init_fenetre is
		ens_fest : based108_data.festival_List.Vector;
		nb:integer;
	begin

		clear (modele_groupe);
		clear (modele_ville);
		for i in tgenre_Enum'range loop
			nb_groupe_par_genre(i,nb);
			append(modele_groupe, rang_groupe, Null_Iter);
			Set (modele_groupe, rang_groupe, 0, p_enumGenre.to_string(i));
			Set (modele_groupe, rang_groupe, 1, p_conversion.to_string(nb));
		end loop;
		nb_groupe_par_ville(ens_fest);
		festival_List.iterate(ens_fest ,alimente_ville'Access);
		nb_groupe(nb);
		set_text(entryNbGroupe, p_conversion.to_string(nb));

	end init_fenetre;





	procedure charge is
		XML : Glade_XML;
	begin
		
		Glade.XML.Gtk_New(XML, "src/ihm/8-faireUnBilanDesFestivals.glade");
		window := Gtk_Window(Get_Widget(XML, "windowBilanFestivals"));
		

		entryNbGroupe := Gtk_GEntry(Get_Widget(XML, "entryNbGroupe"));
		butOK := Gtk_button(Get_Widget(XML, "buttonOK"));
		
		
		treeviewVilles := Gtk_Tree_View(Get_Widget(XML, "treeviewville"));
		treeviewGenres := Gtk_Tree_View(Get_Widget(XML, "treeviewgenre"));

		
		Glade.XML.signal_connect(XML, "on_buttonOK_clicked", ferme'address,null_address);
		p_util_treeview.creerColonne("Genre", treeviewGenres, true);
		p_util_treeview.creerColonne("Effectif ", treeviewGenres, true);
		p_util_treeview.creerColonne("Ville", treeviewVilles, true);
		p_util_treeview.creerColonne("Effectif", treeviewVilles, true);
		creerModele(treeviewVilles, modele_ville);
		creerModele(treeviewGenres, modele_groupe);
		init_fenetre;
	end charge;

	procedure ferme (widget : access Gtk_Widget_Record'Class) is
	begin
		destroy (window);
	end ferme ;
	
	


	
	
	
	

end P_window_bilanfestival;