with db_commons; use db_commons;
with festival_io;
with programme_jour_festival_io;
with groupe_io;
with jour_festival_io;
with participant_festival_io;
with ville_io;
with GNU.DB.SQLCLI;
with p_esiut ; use p_esiut ;
with Ada.Exceptions ; use Ada.Exceptions ;

with ada.containers;

package body p_application is

	----
	-- AJOUTER UNE DESCRIPTION DE LA PROCÉDURE
	-- DANS QUEL CU EST-ELLE UTILISÉE ?
	----
	procedure vider_tables is
		criteria : db_commons.Criteria;
	begin
		festival_io.delete (criteria);
		programme_jour_festival_io.delete (criteria);
		participant_festival_io.delete (criteria);
		groupe_io.delete (criteria);
		jour_festival_io.delete (criteria);
		ville_io.delete (criteria);
	end vider_tables;

	----
	-- AJOUTER UNE DESCRIPTION DE LA PROCÉDURE
	-- DANS QUEL CU EST-ELLE UTILISÉE ?
	----
	procedure retrouver_villes(ensV : out ville_List.Vector ) is
		c : db_commons.Criteria;
	begin
		-- fixe l'ordre du résultat par ordre alphabétique des noms de ville
		ville_io.add_nom_ville_to_orderings (c, asc);
		ensV := ville_io.retrieve( c );
		if ville_io.is_empty(ensV) then raise ExAucuneVille ;end if;
	end retrouver_villes;

	----
	-- AJOUTER UNE DESCRIPTION DE LA PROCÉDURE
	-- DANS QUEL CU EST-ELLE UTILISÉE ?
	----
	procedure retrouver_villes_avec_programme (ensVP : out based108_data.ville_List.Vector ) is
		ensFest : festival_List.Vector;
		c : db_commons.Criteria;
		-- conserve dans ensVP les villes pour lesquelles un festival est entièrement programmé
		procedure verifie_prog (pos : festival_list.cursor) is
			c , c1, c2 ,c3 : db_commons.Criteria;
			n1, n2 : integer;
			fest : tfestival;
			ensJour : Jour_Festival_List.vector;
			j1, j2 : tjour_festival;  -- les 2 journées d'un festival
			ensProg1, ensProg2 : Programme_Jour_Festival_List.Vector;-- programme des 2 journées
			ensGroupesInscrits : participant_festival_list.vector;
			ville : tville;
		begin
			fest := festival_List.element( pos );
			-- recherche des journées du festival de la ville
			ensJour := festival_io.Retrieve_Associated_Jour_Festivals(fest);

			j1 := Jour_Festival_List.element(ensJour, Jour_Festival_List.first_index(ensJour));
			-- recherche du programme de la journée 1
			ensProg1 := jour_festival_io.Retrieve_Associated_Programme_Jour_Festivals(j1);

			j2 := Jour_Festival_List.element(ensJour, Jour_Festival_List.last_index(ensJour));
			-- recherche du programme de la journée 2
			programme_jour_festival_io.Add_Jour_Fest(c2, j2.id_jour_festival);
			ensProg2 := programme_jour_festival_io.retrieve (c2);

			-- recherche des groupes inscrits au festival de la ville
			ensGroupesInscrits := festival_io.Retrieve_Associated_Participant_Festivals(fest);

			-- n1 : nombre de groupes programmés total sur les 2 jours
			n1 := integer(programme_jour_festival_io.card (ensProg1)) + integer(programme_jour_festival_io.card(ensProg2));

			--n2 : nombre de groupes inscrits
			n2 :=  integer(participant_festival_io.card(ensGroupesInscrits));

			-- teste si le festival est entièrement programmé et ajoute la ville dans ensV
			if n1 = n2 then
				ville.nom_ville := fest.ville_festival;
				ville_list.append (ensVP, ville);
			end if;
		end verifie_prog;
	begin
		ensFest := festival_io.retrieve (c);
		festival_list.iterate (ensFest, verifie_prog'Access);
		if ville_List.is_empty(ensVP) then
			raise ExAucuneVille;
		end if;
	end retrouver_villes_avec_programme;

	----
	-- AJOUTER UNE DESCRIPTION DE LA PROCÉDURE
	-- DANS QUEL CU EST-ELLE UTILISÉE ?
	----
	procedure creer_ville (ville : tville) is
	begin
		ville_io.Save( ville, False );
	exception
		when GNU.DB.SQLCLI.INTEGRITY_VIOLATION => raise exvilleExiste;
	end creer_ville;

	----
	-- AJOUTER UNE DESCRIPTION DE LA PROCÉDURE
	-- DANS QUEL CU EST-ELLE UTILISÉE ?
	----
	procedure consultGroupe (nom : unbounded_string; groupe : out tgroupe) is
	begin
		groupe := groupe_io.retrieve_by_pk (nom);
		if groupe_io.is_null (groupe) then
			raise ExGroupeNonTrouve;
		end if;
	end consultGroupe;

	----
	-- AJOUTER UNE DESCRIPTION DE LA PROCÉDURE
	-- DANS QUEL CU EST-ELLE UTILISÉE ?
	----
	procedure consulter_programme_festival(nomville : unbounded_string ; fest : out tfestival; ensProg1, ensProg2 : out Programme_Jour_Festival_List.Vector ) is
		ensJour : Jour_Festival_List.Vector;
		j1, j2 : tjour_festival;
		c1, c2 : db_commons.criteria;
	begin
		fest := festival_io.Retrieve_by_pk(nomVille);
		-- recherche des journées du festival de la ville
		ensJour := festival_io.Retrieve_Associated_Jour_Festivals( fest);

		j1 := Jour_Festival_List.element(ensJour, Jour_Festival_List.first_index(ensJour));
		-- recherche du programme de la journée 1, les groupes étant triés par ordre de passage
		programme_jour_festival_io.Add_Jour_Fest( c1 , j1.id_jour_festival);
		programme_jour_festival_io.Add_Passage_To_Orderings (c1, asc);
		ensProg1 := programme_jour_festival_io.retrieve (c1);

		j2 := Jour_Festival_List.element(ensJour, Jour_Festival_List.last_index(ensJour));
		-- recherche du programme de la journée 2, les groupes étant triés par ordre de passage
		programme_jour_festival_io.Add_Jour_Fest( c2 , j2.id_jour_festival);
		programme_jour_festival_io.Add_Passage_To_Orderings (c2, asc);
		ensProg2 := programme_jour_festival_io.retrieve (c2);
	end consulter_programme_festival;

	----
	-- AJOUTER UNE DESCRIPTION DE LA PROCÉDURE
	-- DANS QUEL CU EST-ELLE UTILISÉE ?
	----
	procedure consulter_festival(nomville : in unbounded_string;date : out Ada.Calendar.Time;Mel_Contact,lieu : out Unbounded_String ;prix_place: out integer)is
		fest:tFestival;
		ville : tVille;

	begin
		fest :=festival_io.Retrieve_by_pk(nomVille);
		date:= fest.date;
		lieu:= fest.lieu;
		prix_place:=fest.prix_place;
		ville := ville_io.Retrieve_by_pk(nomVille);
		Mel_Contact:=ville.Mel_Contact;
	end consulter_festival;

	----
	-- Procédure qui retourne la liste des tous les groupes existants
	-- Utilisée dans le CU6 : consultGroupe
	----
	procedure retrouver_groupes(ensG : out Groupe_List.Vector) is
		c : db_commons.Criteria;
	begin
		-- fixe l'ordre du résultat par ordre alphabétique des noms de groupe
		groupe_io.add_nom_groupe_to_orderings(c, asc);
		ensG := groupe_io.retrieve(c);
		if groupe_io.is_empty(ensG) then
			raise ExAucunGroupe;
		end if;
	end retrouver_groupes;

	----
	-- Procédure qui retourne le groupe et le nom de la ville du groupe à partir du nom du groupe (groupe.Nom_Groupe)
	-- Utilisée dans le CU6 : consultGroupe
	----
	procedure consulter_groupe(groupe : in out tGroupe ; nomVille : out Unbounded_String) is
		participant : Participant_Festival_List.Vector;
		festival : Festival_List.Vector;
	begin
		groupe := groupe_io.retrieve_by_pk(groupe.Nom_Groupe);
		participant := groupe_io.Retrieve_Associated_Participant_Festivals(groupe);
		nomVille := Participant_Festival_List.element(participant, Participant_Festival_List.first_index(participant)).festival;
	end consulter_groupe;

	----
	-- procédure qui retourne les ville avec festivals
	-- Utilisée dans le CU3 (consultFestival) et CU4 (inscrireGroupe) 
	----
	procedure retrouver_ville_avec_festival(ensVF : out based108_data.ville_List.Vector) is --a faire : enlever les villes sans festivals
		c : db_commons.Criteria;
		ensVille : ville_List.Vector;
		

		procedure verifie_festival (pos : ville_list.cursor) is
			
			
			ville : tVille;
			
			
			
			
			
			
		begin
			ville := ville_List.element( pos );
			-- recherche des journées du festival de la ville
			--ens := festival_io.Retrieve_Associated_Jour_Festivals(fest);
			
			
			
			

			-- teste si le festival est entièrement programmé et ajoute la ville dans ensV
			if not festival_io.Is_Null(ville_io.Retrieve_Child_Festival(ville)) then
				--ville.nom_ville := fest.ville_festival;
				ville_list.append (ensVF, ville);
			end if;
		end verifie_festival;
	
	begin
		ville_io.add_nom_ville_to_orderings(c,asc);
		ensVille:= ville_io.retrieve(c);
		ville_list.iterate (ensVille, verifie_festival'Access);
	end retrouver_ville_avec_festival;

	----
	-- procédure qui retourne les ville sans festivals
	-- Utilisée dans le CU2 (creerFestival)
	----

	procedure retrouver_ville_sans_festival(ensVF : out based108_data.ville_List.Vector) is --a faire : enlever les villes sans festivals
		c : db_commons.Criteria;
		ensVille : ville_List.Vector;
		

		procedure verifie_festival (pos : ville_list.cursor) is
			
			ville : tVille;
			
			
		begin
			ville := ville_List.element( pos );

			-- test si le festival est entièrement programmé et ajoute la ville dans ensV
			if  festival_io.Is_Null(ville_io.Retrieve_Child_Festival(ville)) then
				--ville.nom_ville := fest.ville_festival;

				ville_list.append (ensVF, ville);
			end if;
		end verifie_festival;
	
	begin
		ville_io.add_nom_ville_to_orderings(c,asc);
		ensVille:= ville_io.retrieve(c);
		ville_list.iterate (ensVille, verifie_festival'Access);
	end retrouver_ville_sans_festival;

	----
	-- Procédure qui retourne le nombre de concerts prévus pour une ville (somme des concerts prévus pour chaque journée) à partir de son nom
	-- Utilisée dans le CU4 : inscrireGroupe
	----
	procedure consulter_nbConcertsPrevus(Nom_Ville : in Unbounded_String ; nbConcertsPrevus : out integer) is
		c : db_commons.Criteria;
		ensJour : Jour_Festival_List.Vector;
	begin
		jour_festival_io.Add_Festival(c, Nom_Ville);
		ensJour := jour_festival_io.retrieve(c);
		if not jour_festival_io.is_empty(ensJour) then
			nbConcertsPrevus := Jour_Festival_List.element(ensJour, Jour_Festival_List.first_index(ensJour)).Nbre_Concert_Max + Jour_Festival_List.element(ensJour, Jour_Festival_List.last_index(ensJour)).Nbre_Concert_Max;
		else
			nbConcertsPrevus := 0;
		end if;
	end consulter_nbConcertsPrevus;

	----
	-- Procédure qui retourne les groupes participants (participants) au festival de la ville de nom nomVille, et combien il y en a (nbGroupes)
	-- Utilisée dans le CU6 : consultGroupe
	----
	procedure retrouver_groupes_ville(nomVille : in Unbounded_String ; participants : out Participant_Festival_List.Vector ; nbGroupes : out integer) is
		festival : tFestival;
	begin
		festival := festival_io.Retrieve_by_pk(nomVille);
		participants := festival_io.Retrieve_Associated_Participant_Festivals(festival);
		nbGroupes := integer(participant_festival_io.card(participants));
	end ;
	procedure creer_festival (fest:in out tFestival;jourfest1,jourfest2:in out tJour_Festival)is
		
	begin
		
		festival_io.save(fest,False);
		jourfest1.Id_Jour_Festival:=Jour_Festival_io.Next_Free_Id_Jour_Festival;
		jourfest2.Id_Jour_Festival:=Jour_Festival_io.Next_Free_Id_Jour_Festival;
		Jour_Festival_io.save(jourfest1,False);
		Jour_Festival_io.save(jourfest2,False);
		
	end creer_festival;

end p_application;
