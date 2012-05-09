------------------------------------------------------------------------------------------------------
-- module gérant la fenêtre "Consultation du programme d'un festival"
-- Auteur :  Annie Culet 2011-2012
----------------------------------------------------------------------------------------------------
with Gtk.Widget; use Gtk.Widget;
package P_window_consultProgramme is
-- affiche la fenêtre avec les villes dont le festival est entièrement programmé,
-- initialise les variables composants et associe les procédures handler
procedure charge;
-- détruit la fenêtre et ses composants
procedure ferme_win_affProg (widget : access Gtk_Widget_Record'Class);
-- détruit la fenêtre et ses composants
procedure annule_affProg (widget : access Gtk_Widget_Record'Class);
-- lance la consultation du programme des 2 journées du festival de la ville sélectionnée
-- et affiche la liste des groupes programmés chaque jour dans l'ordre de passage
procedure affiche_prog (widget : access Gtk_Widget_Record'Class);

end P_window_consultProgramme;