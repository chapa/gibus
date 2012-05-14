with based108_data;use based108_data;
with Ada.Containers.Vectors;
with ada.strings.Unbounded; use ada.strings.Unbounded;
with ada.Calendar;
package  p_application is

	-- vidage des données de la base
	procedure vider_tables ;

	-- enregistre une ville.  
	-- lève l'exception ExVilleExiste si elle était déjà présente dans la base
	procedure creer_ville (ville : tville);

	-- renvoie toutes les villes enregistrées.
	-- lève l'exception ExAucuneVille si le résultat est vide
	procedure retrouver_villes (ensV : out ville_List.Vector) ;

	-- renvoie toutes les villes dont le festival est entièrement programmé.
	-- lève l'exception ExAucuneVille si le résultat est vide
	procedure retrouver_villes_avec_programme (ensVP : out ville_List.Vector );

	-- consulte un groupe à partir de son nom.
	-- lève l'exception ExGroupeNonTrouve si le groupe ayant ce nom n'est pas présent
	procedure consultGroupe (nom : unbounded_string; groupe : out tgroupe);

	-- renvoie les programmes des 2 journées du festival de la ville de nom donné
	-- la ville nomVille a un festival programmé
	procedure consulter_programme_festival(nomville :  unbounded_string ; fest : out tfestival; ensProg1, ensProg2 : out Programme_Jour_Festival_List.Vector );

	procedure consulter_festival(nomville : unbounded_string;date : out Ada.Calendar.Time;Mel_Contact,lieu : out Unbounded_String ;prix_place: out integer);

	procedure retrouver_groupes(ensG : out Groupe_List.Vector);

	procedure consulter_groupe(groupe : in out tGroupe ; nomVille : out Unbounded_String);

	ExAucuneVille, ExAucunGroupe, ExVilleExiste, ExGroupeNonTrouve : exception;

end p_application; 
