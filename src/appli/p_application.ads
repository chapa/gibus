with based108_data;use based108_data;
with Ada.Containers.Vectors;
with ada.strings.Unbounded; use ada.strings.Unbounded;
with ada.Calendar;
with base_types;
package  p_application is

	function parseChaineNom(str : in String) return String;
	function parseChaineAp(str : in String) return String;

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

	procedure consulter_festival(nomville : in unbounded_string;fest : out tfestival;ville : out tville);

	procedure retrouver_groupes(ensG : out Groupe_List.Vector);

	procedure consulter_groupe(groupe : in out tGroupe ; nomVille : out Unbounded_String);

	procedure retrouver_ville_avec_festival(ensVF : out based108_data.ville_List.Vector);

	procedure retrouver_ville_avec_festival_non_rempli(ensVF : out based108_data.ville_List.Vector);

	procedure consulter_nbConcertsPrevus(Nom_Ville : in Unbounded_String ; nbConcertsPrevus : out integer);

	procedure retrouver_groupes_ville(nomVille : in Unbounded_String ; participants : out Participant_Festival_List.Vector ; nbGroupes : out integer);

	procedure retrouver_groupes_ville_sans_journee(nomVille : in Unbounded_String ; participants : out Participant_Festival_List.Vector ; nbGroupes : out integer);

	procedure retrouver_groupes_ville_journee(nomVille : in Unbounded_String ; participants : out Participant_Festival_List.Vector ; numJournee : in integer);

	procedure retrouver_nbgroupes_journees(nomVille : in Unbounded_String ; nbGroupesJ1, nbGroupesJ2 : out integer);

	procedure retrouver_villes_sans_programme_avec_groupes(ensVP : out based108_data.Ville_List.Vector);

	procedure retrouver_ville_sans_festival(ensVF : out based108_data.ville_List.Vector);

	procedure creer_festival (fest:in out tFestival;jourfest1,jourfest2:in out tJour_Festival);

	procedure creer_groupe(groupe : in tGroupe ; nomVille : in Unbounded_String);

	procedure consulter_journee_festival(festival : in out tFestival);

	procedure vider_journees(nomVille : in Unbounded_String);

	procedure creer_groupe_journee(nomGroupe : in String ; numJournee, numOrdre : in integer);

	procedure marque_groupe_gagne(participant : in out  tParticipant_Festival );

	procedure retrouver_villes_sans_gagnant (ensV : out ville_List.Vector) ;

	procedure retrouver_finalistes(groupes : out Groupe_List.vector ; villes : out Ville_List.vector);

	procedure modifier_groupe(groupe : in tGroupe);
	
	procedure retrouver_festivals(festivals : out Festival_List.vector);

	procedure nb_groupe_par_genre(genre:in base_types.tgenre_Enum ;nombre:out integer);

	procedure nb_groupe_par_ville(ensG: out based108_data.festival_List.Vector);

	procedure nb_groupe (nb_groupe:out integer)  ;

	procedure enregistrer_groupe_final(nomgroupe:in Unbounded_String );

	procedure retrouver_groupes_genre (genre:in base_types.tgenre_Enum;groupes :out Groupe_List.vector);
	
	ExAucuneVille, ExAucunGroupe, ExVilleExiste, ExGroupeNonTrouve, ExGroupeExiste, ExAucunFinaliste, ExAucunFestival : exception;

end p_application; 
