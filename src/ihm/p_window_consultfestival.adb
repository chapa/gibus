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

with p_conversion; use p_conversion; -- utilitaire de conversion
with based108_data; use based108_data; -- types Ada
with p_application; use p_application; -- couche application
package body p_window_consultfestival is
	modele_ville : Gtk_Tree_Store;
	window : Gtk_Window;
	butAnnuler, butConsulter, butFermer : Gtk_Button;
	entryLieu,entryDate,entryPrixPlace,entryMail : Gtk_GEntry;
	treeviewVilles:Gtk_Tree_View;
	rang_ville : Gtk_Tree_Iter := Null_Iter;


	procedure alimente_ville(pos : ville_List.Cursor) is
		ville : based108_data.tVille;
	begin
		ville := ville_List.element(pos);
		append(modele_ville, rang_ville, Null_Iter); -- rajoute une ligne vide
		-- et met dans la colonne 1 de cette ligne le nom de la ville
		Set (modele_ville, rang_ville, 0, p_conversion.to_string(ville.nom_ville));
	end alimente_ville;



	procedure init is
		ens_ville :based108_data.ville_List.Vector;
	begin
		retrouver_ville_avec_festival(ens_ville );
		clear (modele_ville);
		ville_List.iterate(ens_ville ,alimente_ville'Access);
		exception
			when exAucuneVille => append (modele_ville, rang_ville, Null_Iter);
			-- rajoute une ligne vide
			-- et met dans la colonne 1 de cette ligne le message
			Set (modele_ville, rang_ville, 0, "aucune ville enregistrée");
	end init;

	procedure charge is
		XML : Glade_XML;
	begin
		Glade.XML.Gtk_New(XML, "src/ihm/3-consultFestival.glade");
		window := Gtk_Window(Get_Widget(XML, "windowConsultFestival"));

		butAnnuler := Gtk_button(Get_Widget(XML, "buttonAnnuler"));
		butConsulter := Gtk_button(Get_Widget(XML, "buttonConsulter"));
		butFermer := Gtk_button(Get_Widget(XML, "buttonFermer"));

		entryLieu := Gtk_GEntry(Get_Widget(XML, "entryLieu"));
		entryDate := Gtk_GEntry(Get_Widget(XML, "entryDate"));
		entryPrixPlace := Gtk_GEntry(Get_Widget(XML, "entryPrixPlace"));
		entryMail := Gtk_GEntry(Get_Widget(XML, "entryMail"));

		
		treeviewVilles := Gtk_Tree_View(Get_Widget(XML, "treeviewVilles"));

		Glade.XML.signal_connect(XML, "on_buttonConsulter_clicked", affRegion2'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonAnnuler_clicked", ferme_win_affGroupe'address,null_address);
		Glade.XML.signal_connect(XML, "on_buttonFermer_clicked", ferme_win_affGroupe'address,null_address);
		p_util_treeview.creerColonne("nomVille ", treeviewVilles, false);
		creerModele(treeviewVilles, modele_ville);
		init;
	end charge;

	procedure ferme_win_affGroupe (widget : access Gtk_Widget_Record'Class) is
	begin
		destroy (window);
	end ferme_win_affGroupe ;

	procedure affRegion2 (widget : access Gtk_Widget_Record'Class) is
		ensVP :based108_data.ville_List.Vector;
	begin
		retrouver_ville_avec_festival(ensVP );
		set_sensitive(butAnnuler, false);
		set_sensitive(butConsulter, false);
		set_sensitive(butFermer, true);

		set_sensitive(entryLieu, true);
		set_sensitive(entryDate, true);
		set_sensitive(entryPrixPlace, true);

		set_sensitive(entryMail, true);
		

		set_sensitive(treeviewVilles, false);
	end affRegion2;

	procedure affRegion1(widget : access Gtk_Widget_Record'Class) is
	begin
		set_sensitive(butAnnuler, true);
		set_sensitive(butConsulter, true);
		set_sensitive(butFermer, false);

		set_sensitive(entryLieu, false);
		set_sensitive(entryDate, false);
		set_sensitive(entryPrixPlace, false);

		set_sensitive(entryMail, false);
		

		set_sensitive(treeviewVilles, true);

	end affRegion1;
	
end p_window_consultfestival;