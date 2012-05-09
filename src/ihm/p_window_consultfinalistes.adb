with Glade.XML;use Glade.XML;
with System; use System; -- module permettant l'interaction avec la boucle événementielle principale
with Gtk.Main; -- pour les boites de dialogue
with Gtkada.Dialogs;use Gtkada.Dialogs; -- module GtkAda pour le composant fenêtre et les autres
with Gtk.Window; use Gtk.Window;
with Gtk.Button; use Gtk.Button;

package body P_Window_ConsultFinalistes is

	window : Gtk_Window;
	butAnnuler : Gtk_Button;

	procedure charge is
		XML : Glade_XML;
	begin
		Glade.XML.Gtk_New(XML, "src/ihm/10-consultFinalistes.glade");
		window := Gtk_Window(Get_Widget(XML, "windowConsultFinalistes"));

		butAnnuler := Gtk_button(Get_Widget(XML, "buttonAnnuler"));

		Glade.XML.signal_connect(XML, "on_buttonFermer_clicked", ferme'address,null_address);
	end charge;

	procedure ferme(widget : access Gtk_Widget_Record'Class) is
	begin
		destroy (window);
	end ferme;
	
end P_Window_ConsultFinalistes;