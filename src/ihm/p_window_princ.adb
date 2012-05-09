with Glade.XML;use Glade.XML; -- module permettant de créer dynamiquement les composants à partir de la description XML de l'interface
with System; use System; -- module permettant l'interaction avec la boucle événementielle principale
with Gtk.Main; -- module GtkAda pour le composant fenêtre
with Gtk.Window; use Gtk.Window; -- pour les boites de dialogue
with Gtkada.Dialogs; use Gtkada.Dialogs;

with p_window_enregVilles; -- (1)
with p_window_creerFestival; -- (2)
with p_window_consultFestival; -- (3)
with p_window_inscrireGroupe; -- (4)
with p_window_programmerFestival; -- (5)
with p_window_consultGroupe; -- (6)
with p_window_consultProgramme; -- (7)
with p_window_consultFinalistes; -- (10)
with p_window_modifierInfosGroupe;
with p_application;
package body p_window_princ is

	window_princ : Gtk_Window; -- variable désignant la fenêtre

	procedure charge is
		XML : Glade_XML; -- variable référençant l'interface (la fenêtre et tous ses composants)
	begin
		-- chargement de l'interface à partir du fichier XML
		Glade.XML.Gtk_New(XML, "src/ihm/fenprinc.glade", "windowPrinc");

		-- chargement du composant fenêtre de l'interface
		window_princ := Gtk_Window(Get_Widget(XML, "windowPrinc"));

		-- connection des différents signaux de l'interface en associant les procédures handler correspondantes
		Glade.XML.signal_connect(XML, "on_windowPrinc_delete_event", quitter'address,null_address);
		Glade.XML.signal_connect(XML, "on_menuitem_init_activate", viderTables'address,null_address);
		Glade.XML.signal_connect(XML, "on_menuitem_quitter_activate", quitter'address,null_address);

		Glade.XML.signal_connect(XML, "on_menuitem_enregVille_activate", affiche_win_enregVilles'address,null_address);
		Glade.XML.signal_connect(XML, "on_menuitem_creerFestival_activate", affiche_win_creerFestival'address,null_address);
		Glade.XML.signal_connect(XML, "on_menuitem_programmerFestival_activate", affiche_win_programmerFestival'address,null_address);
		Glade.XML.signal_connect(XML, "on_menuitem_consultFestival_activate", affiche_win_consultFestival'address,null_address);
		Glade.XML.signal_connect(XML, "on_menuitem_consultProgramme_activate", affiche_win_consultProgramme'address,null_address);
		Glade.XML.signal_connect(XML, "on_menuitem_consultFinalistes_activate", affiche_win_consultFinalistes'address,null_address);

		Glade.XML.signal_connect(XML, "on_menuitem_inscrireGroupe_activate", affiche_win_inscrireGroupe'address,null_address);
		Glade.XML.signal_connect(XML, "on_menuitem_modifierInfosGroupe_activate", affiche_win_modifierInfosGroupe'address,null_address);
		Glade.XML.signal_connect(XML, "on_menuitem_consultGroupe_activate", affiche_win_consultGroupe'address,null_address);
	end charge;

	procedure quitter(widget : access Gtk_Widget_Record'Class) is
		-- quitte l'application
	begin
		Gtk.Main.main_quit;
	end quitter;

	procedure viderTables(widget : access Gtk_Widget_Record'Class) is
		-- détruit le contenu de toutes les tables
		rep : Message_Dialog_Buttons;
	begin
		rep := Message_Dialog("Une base existe. Voulez-vous vraiment la détruire ?",confirmation, button_ok or button_no);
		if rep = button_ok then
			p_application.vider_tables ;
			rep := Message_Dialog("Le contenu de la base est détruit");
		else
			rep:=Message_Dialog ("La base est conservée.");
		end if;
		
	end viderTables;

	procedure affiche_win_enregVilles(widget : access Gtk_Widget_Record'Class) is
		-- affiche la fenêtre pour enregistrer les villes organisatrices
	begin
		p_window_enregVilles.charge;
	end affiche_win_enregVilles;

	procedure affiche_win_creerFestival(widget : access Gtk_Widget_Record'Class) is
		-- affiche la fenêtre pour créer un festival
	begin
		p_window_creerFestival.charge;
	end affiche_win_creerFestival;

	procedure affiche_win_consultFestival(widget : access Gtk_Widget_Record'Class) is
		-- affiche la fenêtre pour créer un festival
	begin
		p_window_consultFestival.charge;
	end affiche_win_consultFestival;

	procedure affiche_win_inscrireGroupe(widget : access Gtk_Widget_Record'Class) is
		-- affiche la fenêtre pour créer un festival
	begin
		p_window_inscrireGroupe.charge;
	end affiche_win_inscrireGroupe;

	procedure affiche_win_programmerFestival(widget : access Gtk_Widget_Record'Class) is
		-- affiche la fenêtre pour programmer un festival
	begin
		p_window_programmerFestival.charge;
	end affiche_win_programmerFestival;

	procedure affiche_win_consultGroupe(widget : access Gtk_Widget_Record'Class) is
		-- affiche la fenêtre pour consulter un groupe d'un festival
	begin
		p_window_consultGroupe.charge;
	end affiche_win_consultGroupe;

	procedure affiche_win_consultProgramme(widget : access Gtk_Widget_Record'Class) is
		-- affiche la fenêtre pour consulter un programme d'un festival
	begin
		p_window_consultProgramme.charge;
	end affiche_win_consultProgramme;

	procedure affiche_win_consultFinalistes(widget : access Gtk_Widget_Record'Class) is
		-- affiche la fenêtre pour consulter les finalistes
	begin
		p_window_consultFinalistes.charge;
	end affiche_win_consultFinalistes;

	procedure affiche_win_modifierInfosGroupe(widget : access Gtk_Widget_Record'Class) is
		-- affiche la fenêtre pour consulter les finalistes
	begin
		p_window_modifierInfosGroupe.charge;
	end affiche_win_modifierInfosGroupe;

end p_window_princ;