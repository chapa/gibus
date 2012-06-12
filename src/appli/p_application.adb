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
with p_conversion; use p_conversion; -- utilitaire de conversion

with ada.containers;

package body p_application is

	function parseVille(str : in String) return String is
		newStr : string(str'range);
		function min(c : in Character) return Character is
		begin
			if c in 'A'..'Z' then
				return character'val(character'pos(c) + 32);
			else
				return c;
			end if;
		end min;
		function maj(c : in Character) return Character is
		begin
			if c in 'a'..'z' then
				return character'val(character'pos(c) - 32);
			else
				return c;
			end if;
		end maj;
	begin
		for i in str'range loop
			if str(i) = ' ' then
				newStr(i) := '-';
			else
				newStr(i) := min(str(i));
			end if;
		end loop;
		newStr(str'first) := maj(str(str'first));
		return newStr;
	end parseVille;

	----
	-- AJOUTER UNE DESCRIPTION DE LA PROCÉDURE
	-- DANS QUEL CU EST-ELLE UTILISÉE ?
	----
	procedure vider_tables is
		criteria : db_commons.Criteria;
		ville:tVille;
	begin
		festival_io.delete (criteria);
		programme_jour_festival_io.delete (criteria);
		participant_festival_io.delete (criteria);
		groupe_io.delete (criteria);
		jour_festival_io.delete (criteria);
		ville_io.delete (criteria);
		p_conversion.to_ada_type("Paris-gibus",ville.nom_ville);
		p_conversion.to_ada_type("final@Paris-gibus",ville.Mel_Contact);
		creer_ville (ville );
	end vider_tables;

	----
	-- AJOUTER UNE DESCRIPTION DE LA PROCÉDURE
	-- DANS QUEL CU EST-ELLE UTILISÉE ?
	----
	procedure retrouver_villes(ensV : out Ville_List.Vector ) is
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
	procedure retrouver_villes_avec_programme (ensVP : out based108_data.Ville_List.Vector ) is
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
			ensGroupesInscrits : Participant_Festival_List.vector;
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
			if n1 = n2 AND n2 > 0 then
				ville.nom_ville := fest.ville_festival;
				Ville_List.append (ensVP, ville);
			end if;
		end verifie_prog;
	begin
		ensFest := festival_io.retrieve (c);
		festival_list.iterate (ensFest, verifie_prog'Access);
		if Ville_List.is_empty(ensVP) then
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
	-- Procédure qui retourne les information d'un festival
	--Utilise dans le CU3 consulter un festival
	----
	procedure consulter_festival(nomville : in unbounded_string;fest : out tfestival;ville : out tville)is
		
		

	begin
		fest :=festival_io.Retrieve_by_pk(nomVille);
		
		ville := ville_io.Retrieve_by_pk(nomVille);
		
		
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
	-- Utilisée dans le CU3 (consultFestival)
	----
	procedure retrouver_ville_avec_festival(ensVF : out based108_data.ville_List.Vector) is
		c : db_commons.Criteria;
		ensVille : ville_List.Vector;
		procedure verifie_festival (pos : ville_list.cursor) is
			ville : tVille;
		begin
			ville := ville_List.element( pos );
			if not festival_io.Is_Null(festival_io.retrieve_by_pk(ville.nom_ville)) then
				ville_list.append (ensVF, ville);
			end if;
		end verifie_festival;
	begin
		ville_io.add_nom_ville_to_orderings(c,asc);
		ensVille:= ville_io.retrieve(c);
		
		ville_list.iterate (ensVille, verifie_festival'Access);
		if ville_io.is_empty(ensVF) then
			raise ExAucuneVille;
		end if;
	end retrouver_ville_avec_festival;

	----
	-- procédure qui retourne les ville avec festivals
	-- Utilisée dans le CU4 (inscrireGroupe) 
	----
	procedure retrouver_ville_avec_festival_non_rempli(ensVF : out based108_data.ville_List.Vector) is
		c : db_commons.Criteria;
		ensVille : ville_List.Vector;
		nbGroupes, nbConcertsPrevus : integer;
		procedure verifie_festival (pos : ville_list.cursor) is
			ville : tVille;
		begin
			ville := ville_List.element( pos );
			nbGroupes := integer(participant_festival_io.card(festival_io.Retrieve_Associated_Participant_Festivals(festival_io.Retrieve_by_pk(ville.nom_ville))));
			consulter_nbConcertsPrevus(ville.nom_ville, nbConcertsPrevus);
			if not festival_io.Is_Null(festival_io.retrieve_by_pk(ville.nom_ville)) AND nbConcertsPrevus - nbGroupes > 0 then
				ville_list.append (ensVF, ville);
			end if;
		end verifie_festival;
	begin
		ville_io.add_nom_ville_to_orderings(c,asc);
		ensVille:= ville_io.retrieve(c);
		
		ville_list.iterate (ensVille, verifie_festival'Access);
		if ville_io.is_empty(ensVF) then
			raise ExAucuneVille;
		end if;
	end retrouver_ville_avec_festival_non_rempli;

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
			ecrire( p_conversion.to_string(ville.nom_ville));
			-- test si le festival est entièrement programmé et ajoute la ville dans ensV

			if  festival_io.Is_Null(festival_io.retrieve_by_pk(ville.nom_ville)) then
				--ville.nom_ville := fest.ville_festival;
				ville_list.append (ensVF, ville);

			end if;
		end verifie_festival;
	
	begin
		ville_io.add_nom_ville_to_orderings(c,asc);
		ensVille:= ville_io.retrieve(c);
		
		ville_list.iterate (ensVille, verifie_festival'Access);
		if ville_io.is_empty(ensVF) then
			raise ExAucuneVille;
		end if;
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
	end;

	----
	-- Procédure qui retourne les groupes participants (participants) au festival de la ville de nom nomVille mais qui ne sont pas inscrits dans une journée
	-- Utilisée dans le CU5 : programmerFestival
	----
	procedure retrouver_groupes_ville_sans_journee(nomVille : in Unbounded_String ; participants : out Participant_Festival_List.Vector ; nbGroupes : out integer) is
		festival : tFestival;
		ensParticipants : Participant_Festival_List.vector;
		procedure verifie_participant(pos : Participant_Festival_List.cursor) is
			participant : tParticipant_Festival;
			c : db_commons.Criteria;
		begin
			participant := Participant_Festival_List.element(pos);
			programme_jour_festival_io.Add_Nom_Groupe_Programme(c, participant.Nom_Groupe_Inscrit);
			if programme_jour_festival_io.is_empty(programme_jour_festival_io.retrieve(c)) then
				Participant_Festival_List.append(participants, participant);
			end if;
		end verifie_participant;
	begin
		festival := festival_io.Retrieve_by_pk(nomVille);
		ensParticipants := festival_io.Retrieve_Associated_Participant_Festivals(festival);
		Participant_Festival_List.iterate(ensParticipants, verifie_participant'Access);
		nbGroupes := integer(participant_festival_io.card(participants));
	end retrouver_groupes_ville_sans_journee;

	procedure retrouver_groupes_ville_journee(nomVille : in Unbounded_String ; participants : out Participant_Festival_List.Vector ; numJournee : in integer) is
		ensJour : Jour_Festival_List.Vector;
		idJour : integer;
		c, c2 : db_commons.Criteria;
		ensProgJourFest : Programme_Jour_Festival_List.Vector;
		procedure verifie_participant(pos : Programme_Jour_Festival_List.cursor) is
			participant : tParticipant_Festival;
		begin
			participant := participant_festival_io.Retrieve_by_pk(Programme_Jour_Festival_List.element(pos).Nom_Groupe_Programme, nomVille);
			Participant_Festival_List.append(participants, participant);
		end verifie_participant;
	begin
		jour_festival_io.Add_Festival(c, nomVille);
		jour_festival_io.Add_Num_Ordre(c, numJournee);
		ensJour := jour_festival_io.retrieve(c);
		idJour := Jour_Festival_List.element(ensJour, Jour_Festival_List.first_index(ensJour)).Id_Jour_Festival;
		programme_jour_festival_io.Add_Jour_Fest(c2, idJour);
		ensProgJourFest := programme_jour_festival_io.retrieve(c2);
		Programme_Jour_Festival_List.iterate(ensProgJourFest, verifie_participant'Access);
	end retrouver_groupes_ville_journee;

	procedure retrouver_nbgroupes_journees(nomVille : in Unbounded_String ; nbGroupesJ1, nbGroupesJ2 : out integer) is
		c : db_commons.Criteria;
		ensJour : Jour_Festival_List.Vector;
	begin
		jour_festival_io.Add_Festival(c, nomVille);
		ensJour := jour_festival_io.retrieve(c);
		if not jour_festival_io.is_empty(ensJour) then
			nbGroupesJ1 := Jour_Festival_List.element(ensJour, Jour_Festival_List.first_index(ensJour)).Nbre_Concert_Max;
			nbGroupesJ2 := Jour_Festival_List.element(ensJour, Jour_Festival_List.last_index(ensJour)).Nbre_Concert_Max;
		else
			nbGroupesJ1 := 0;
			nbGroupesJ2 := 0;
		end if;
	end retrouver_nbgroupes_journees;

	procedure creer_festival (fest:in out tFestival;jourfest1,jourfest2:in out tJour_Festival)is
		
	begin
		
		festival_io.save(fest,False);
		jourfest1.Id_Jour_Festival:=Jour_Festival_io.Next_Free_Id_Jour_Festival;
		Jour_Festival_io.save(jourfest1,False);
		jourfest2.Id_Jour_Festival:=Jour_Festival_io.Next_Free_Id_Jour_Festival;
		
		Jour_Festival_io.save(jourfest2,False);
		
	end creer_festival;

	----
	-- Procédure qui retourne les villes sans programme (mais avec festival)
	-- Utilisée dans le CU5 : programmerFestival
	----
	procedure retrouver_villes_sans_programme_avec_groupes(ensVP : out based108_data.Ville_List.Vector) is
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
			ensGroupesInscrits : Participant_Festival_List.vector;
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

			-- teste si le festival n'est pas entièrement programmé et ajoute la ville dans ensV (s'il y a des groupes)
			if n1 < n2 and (n2-n1) > 0 then
				ville.nom_ville := fest.ville_festival;
				Ville_List.append (ensVP, ville);
			end if;
		end verifie_prog;
	begin
		ensFest := festival_io.retrieve (c);
		festival_list.iterate (ensFest, verifie_prog'Access);
		if Ville_List.is_empty(ensVP) then
			raise ExAucuneVille;
		end if;
	end retrouver_villes_sans_programme_avec_groupes;

	procedure creer_groupe(groupe : in tGroupe ; nomVille : in Unbounded_String) is
		participants : tParticipant_Festival;
	begin
		participants := (groupe.Nom_Groupe, nomVille, false);
		groupe_io.save(groupe, false);
		participant_festival_io.save(participants, false);
	exception
		when GNU.DB.SQLCLI.INTEGRITY_VIOLATION => raise ExGroupeExiste;
	end creer_groupe;

	procedure consulter_journee_festival(festival : in out tFestival) is
	begin
		festival := festival_io.retrieve_by_pk(festival.Ville_Festival);
	end consulter_journee_festival;

	procedure vider_journees(nomVille : in Unbounded_String) is
		jours_festival : Jour_Festival_List.Vector;
		c, c2 : db_commons.Criteria;
	begin
		jour_festival_io.Add_Festival(c, nomVille);
		jours_festival := jour_festival_io.retrieve(c);
		programme_jour_festival_io.Add_Jour_Fest(c2, Jour_Festival_List.element(jours_festival, Jour_Festival_List.first_index(jours_festival)).Id_Jour_Festival);
		programme_jour_festival_io.Add_Jour_Fest(c2, Jour_Festival_List.element(jours_festival, Jour_Festival_List.last_index(jours_festival)).Id_Jour_Festival, db_commons.eq, db_commons.join_or);
		programme_jour_festival_io.delete(c2);
	end vider_journees;

	procedure creer_groupe_journee(nomGroupe : in String ; numJournee, numOrdre : in integer) is
		prog : tProgramme_Jour_Festival;
		nomG : Unbounded_String;
		jours_festival : Jour_Festival_List.Vector;
		groupe : tGroupe;
		participant : Participant_Festival_List.Vector;
		c : db_commons.Criteria;
		nomVille : unbounded_string;
	begin
		p_conversion.to_ada_type(nomGroupe, nomG);
		groupe := groupe_io.retrieve_by_pk(nomG);
		participant := groupe_io.Retrieve_Associated_Participant_Festivals(groupe);
		nomVille := Participant_Festival_List.element(participant, Participant_Festival_List.first_index(participant)).festival;

		jour_festival_io.Add_Festival(c, nomVille);
		jour_festival_io.Add_Num_Ordre(c, numJournee);
		jours_festival := jour_festival_io.retrieve(c);

		p_conversion.to_ada_type(nomGroupe, nomG);
		prog := (nomG, Jour_Festival_List.element(jours_festival, Jour_Festival_List.first_index(jours_festival)).Id_Jour_Festival, numOrdre);
		programme_jour_festival_io.save(prog, false);
	end creer_groupe_journee;
	procedure inscrire_groupe(participant : in out tParticipant_Festival )is
	begin
		participant.gagnant:=true;
		participant_festival_io.save(participant,true);
	end inscrire_groupe;


	procedure retrouver_villes_sans_gagnant (ensV : out based108_data.Ville_List.Vector) is
		c : db_commons.Criteria;
		ensVP :  based108_data.Ville_List.Vector;
		procedure verifie_gagne(pos : ville_List.cursor) is
			ville : tville;
			c : db_commons.Criteria;
		begin
			ville := ville_List.element(pos);
			participant_festival_io.Add_Gagnant(c,true);
			participant_festival_io.Add_Festival(c,ville.nom_ville);
			
			ecrire("t0");
			if participant_festival_io.is_empty(participant_festival_io.Retrieve(c)) then
				
				Ville_List.append (ensV, ville);
				ecrire("t2");
			end if;
		end verifie_gagne;
	
	begin
		

		ville_io.add_nom_ville_to_orderings (c, asc);
		ensVp := ville_io.retrieve( c );
		ville_List.iterate(ensVp,verifie_gagne'Access);
		

		if ville_io.is_empty(ensV) then raise ExAucuneVille ;end if;
	end retrouver_villes_sans_gagnant;

	procedure retrouver_finalistes(groupes : out Groupe_List.vector ; villes : out Ville_List.vector) is
		ens_participant : Participant_Festival_List.Vector;
		c : db_commons.Criteria;
		procedure remplir_groupe(pos : Participant_Festival_List.cursor) is
			participant : tParticipant_Festival;
		begin
			participant := Participant_Festival_List.element(pos);
			Groupe_List.append(groupes, groupe_io.Retrieve_by_pk(participant.Nom_Groupe_Inscrit));
			Ville_List.append(villes, ville_io.Retrieve_by_pk(participant.festival));
		end remplir_groupe;
	begin
		participant_festival_io.Add_Gagnant(c, true);
		ens_participant := participant_festival_io.retrieve(c);

		if Participant_Festival_List.is_empty(ens_participant) then
			raise ExAucunFinaliste;
		end if;

		Participant_Festival_List.iterate(ens_participant, remplir_groupe'Access);
	end retrouver_finalistes;

	procedure modifier_groupe(groupe : in tGroupe) is
	begin
		groupe_io.save(groupe, true);
	end modifier_groupe;

	procedure retrouver_festivals(festivals : out Festival_List.vector) is
		c : db_commons.Criteria;
	begin
		festival_io.Add_Date_To_Orderings(c, asc);
		festivals := festival_io.retrieve(c);
		if festival_io.is_empty(festivals) then
			raise ExAucunFestival;
		end if;
	end retrouver_festivals;

end p_application;
