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
package body P_window_bilanfestival is

	window : Gtk_Window;
	butOK  : Gtk_Button;
	treeviewVilles,treeviewGenres:Gtk_Tree_View;
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
		
		clear (modele_ville);
		
	end init_fenetre;





	procedure charge is
		XML : Glade_XML;
	begin
		
		Glade.XML.Gtk_New(XML, "src/ihm/8-faireUnBilanDesFestivals.glade");
		window := Gtk_Window(Get_Widget(XML, "windowBilanFestivals"));
		
		butOK := Gtk_button(Get_Widget(XML, "buttonOK"));
		
		
		treeviewVilles := Gtk_Tree_View(Get_Widget(XML, "treeviewville"));
		treeviewGenres := Gtk_Tree_View(Get_Widget(XML, "treeviewgenre"));

		
		Glade.XML.signal_connect(XML, "on_buttonOK_clicked", ferme'address,null_address);
		p_util_treeview.creerColonne("nomVille ", treeviewVilles, false);
		
		
	end charge;

	procedure ferme (widget : access Gtk_Widget_Record'Class) is
	begin
		destroy (window);
	end ferme ;
	
	


	
	
	
	

end P_window_bilanfestival;