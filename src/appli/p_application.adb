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

	function parseChaineNom(str : in String) return String is
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
			elsif str(i) = ''' then
				newStr(i) := '_';
			else
				newStr(i) := min(str(i));
			end if;
		end loop;
		newStr(str'first) := maj(str(str'first));
		return newStr;
	end parseChaineNom;

	function parseChaineAp(str : in String) return String is
		newStr : string(str'range);
	begin
		for i in str'range loop
			if str(i) = ''' then
				newStr(i) := '_';
			else
				newStr(i) := str(i);
			end if;
		end loop;
		return newStr;
	end parseChaineAp;

	----
	-- AJOUTER UNE DESCRIPTION DE LA PROCÉDURE
	-- DANS QUEL CU EST-ELLE UTILISÉE ?
	----
	procedure vider_tables is
		criteria : db_commons.Criteria;
		ville:tVille;
		fest:tFestival;
		journ1,journ2:tJour_Festival;
	begin
		festival_io.delete (criteria);
		programme_jour_festival_io.delete (criteria);
		participant_festival_io.delete (criteria);
		groupe_io.delete (criteria);
		jour_festival_io.delete (criteria);
		ville_io.delete (criteria);
		p_conversion.to_ada_type("Paris_gibus",ville.nom_ville);
		p_conversion.to_ada_type("final@Paris_gibus",ville.Mel_Contact);
		p_conversion.to_ada_type("Paris_gibus",fest.ville_festival);
		p_conversion.to_ada_type("19/02/2012",fest.date);
		p_conversion.to_ada_type("Place de la Concorde",fest.lieu);
		fest.prix_place:=50;
		creer_ville(ville);
		p_conversion.to_ada_type("Paris_gibus",journ1.festival);
		p_conversion.to_ada_type("Paris_gibus",journ2.festival);
		journ1.num_ordre:=1;
		journ2.num_ordre:=2;
		creer_festival(fest,journ1,journ2);

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
			n1, n2, n3 : integer;
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

			-- n1 : nombre de groupes prévus sur les 2 jours
			consulter_nbConcertsPrevus(fest.Ville_Festival, n1);

			--n2 : nombre de groupes inscrits
			n2 :=  integer(participant_festival_io.card(ensGroupesInscrits));

			-- n3 : nombre de groupes programmés total sur les 2 jours
			n3 := integer(programme_jour_festival_io.card (ensProg1)) + integer(programme_jour_festival_io.card(ensProg2));

			-- teste si le festival est entièrement programmé et ajoute la ville dans ensV
			if n1 = n2 AND n2 > 0 AND n1 = n3 then
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
			if not festival_io.Is_Null(festival_io.retrieve_by_pk(ville.nom_ville)) AND nbConcertsPrevus - nbGroupes > 0 and p_conversion.to_string(ville.nom_ville)/="Paris_gibus" then
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
			ecrire_ligne( p_conversion.to_string(ville.nom_ville));
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
	-- Utilisée dans le CU5 : programmerFestival; CU9 EnregistrerGagnantFestival
	----
	procedure retrouver_groupes_ville_sans_journee(nomVille : in Unbounded_String ; participants : out Participant_Festival_List.Vector ; nbGroupes : out integer) is
		festival : tFestival;
		ensParticipants : Participant_Festival_List.vector;
		procedure verifie_participant(pos : Participant_Festival_List.cursor) is
			participant : tParticipant_Festival;
			c, c2 : db_commons.Criteria;
			journees : jour_festival_list.vector;
			idJournee1, idJournee2 : integer;
		begin
			participant := Participant_Festival_List.element(pos);
			jour_festival_io.Add_Festival(c2, participant.festival);
			journees := Jour_Festival_io.retrieve(c2);
			idJournee1 := jour_festival_list.element(journees, jour_festival_list.first_index(journees)).Id_Jour_Festival;
			idJournee2 := jour_festival_list.element(journees, jour_festival_list.last_index(journees)).Id_Jour_Festival;
			programme_jour_festival_io.Add_Nom_Groupe_Programme(c, participant.Nom_Groupe_Inscrit);
			programme_jour_festival_io.Add_Jour_Fest(c, idJournee1);
			programme_jour_festival_io.Add_Nom_Groupe_Programme(c, participant.Nom_Groupe_Inscrit, db_commons.eq, db_commons.join_or);
			programme_jour_festival_io.Add_Jour_Fest(c, idJournee2);
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
	----
	--Procédure qui retourne les groupes qui passe dans un festival a une certaine journée
	--utilise dans CU5:progrmmaer festival;CU9 :enregistrer_gagnant;CU15: modifier_programmation_festival
	----
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
	----
	--procedure qui retrouve le nombre de groupe pour chacune des journées
	----

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
	----
	--procedure qui crée un festival avec ces journées
	---- 
	procedure creer_festival (fest:in out tFestival;jourfest1,jourfest2:in out tJour_Festival)is
		
	begin
		
		festival_io.save(fest,False);
		jourfest1.Id_Jour_Festival:=Jour_Festival_io.Next_Free_Id_Jour_Festival;
		Jour_Festival_io.save(jourfest1,False);
		jourfest2.Id_Jour_Festival:=Jour_Festival_io.Next_Free_Id_Jour_Festival;
		
		Jour_Festival_io.save(jourfest2,False);
		if p_conversion.to_string(fest.ville_festival)/="Paris_gibus" then
			ajouter_Paris_gibus_nbgroupe;
		end if;
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
			n1, n2, n3 : integer;
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

			-- n1 : nombre de groupes prévus sur les 2 jours
			consulter_nbConcertsPrevus(fest.Ville_Festival, n1);

			--n2 : nombre de groupes inscrits
			n2 :=  integer(participant_festival_io.card(ensGroupesInscrits));

			-- n3 : nombre de groupes programmés total sur les 2 jours
			n3 := integer(programme_jour_festival_io.card (ensProg1)) + integer(programme_jour_festival_io.card(ensProg2));

			-- teste si le festival n'est pas entièrement programmé et ajoute la ville dans ensV (s'il y a des groupes)
			if n2 > 0 AND n1 >= n2 AND n1 /= n3 then
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
	----
	--procedure qui crée un groupe et qui l'associe au festival d'une ville
	----
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
	----
	--vide les journées d'une ville
	----
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
	----
	--crée une ascocie un groupe a une journe d'un festival
	----
	procedure creer_groupe_journee(nomVille, nomGroupe : in Unbounded_String ; numJournee, numOrdre : in integer) is
		prog : tProgramme_Jour_Festival;
		jours_festival : Jour_Festival_List.Vector;
		c : db_commons.Criteria;
	begin
		jour_festival_io.Add_Festival(c, nomVille);
		jour_festival_io.Add_Num_Ordre(c, numJournee);
		jours_festival := jour_festival_io.retrieve(c);

		prog := (nomGroupe, Jour_Festival_List.element(jours_festival, Jour_Festival_List.first_index(jours_festival)).Id_Jour_Festival, numOrdre);
		programme_jour_festival_io.save(prog, false);
	end creer_groupe_journee;
	----
	--marque le groupe comme le gagnant d'un festival
	----
	procedure marque_groupe_gagne(participant : in out tParticipant_Festival )is
	begin
		participant.gagnant:=true;
		participant_festival_io.save(participant,true);
	end marque_groupe_gagne;
	----
	--retrouve les villes ou il n'y a pas de gagnant pour festival ascocier
	---- 
	procedure retrouver_villes_sans_gagnant (ensV : out based108_data.Ville_List.Vector) is
		c : db_commons.Criteria;
		ensVP :  based108_data.Ville_List.Vector;
		procedure verifie_gagne(pos : ville_List.cursor) is
			ville : tville;
			c1 : db_commons.Criteria;
		begin
			ville := ville_List.element(pos);
			participant_festival_io.Add_Gagnant(c1,true);
			participant_festival_io.Add_Festival(c1,ville.nom_ville);
			if participant_festival_io.is_empty(participant_festival_io.Retrieve(c1)) then
				Ville_List.append (ensV, ville);
			end if;
		end verifie_gagne;
	
	begin
		
		retrouver_villes_avec_programme(ensVP);
		ville_List.iterate(ensVp,verifie_gagne'Access);
		
		if ville_io.is_empty(ensV) then raise ExAucuneVille ;end if;
	end retrouver_villes_sans_gagnant;
	----
	--retouve les finaliste(participant au festival Paris_gibus)
	----
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
	----
	--retrouve tous les festivals
	----
	procedure retrouver_festivals(festivals : out Festival_List.vector) is
		c : db_commons.Criteria;
	begin
		festival_io.Add_Date_To_Orderings(c, asc);
		festivals := festival_io.retrieve(c);
		if festival_io.is_empty(festivals) then
			raise ExAucunFestival;
		end if;
	end retrouver_festivals;
	----
	--retourne le nombre de groupe par genre
	----
	procedure nb_groupe_par_genre(genre:in base_types.tgenre_Enum ;nombre:out integer) is
		c:db_commons.criteria;
	begin
		
		
		groupe_io.Add_Genre(c,genre);
		nombre:=integer(groupe_io.card(groupe_io.Retrieve(c)));
	end nb_groupe_par_genre;
	procedure nb_groupe (nb_groupe:out integer)  is
		c:db_commons.Criteria;
	begin
		nb_groupe:=integer(groupe_io.card(groupe_io.retrieve(c)));
		
	
	end nb_groupe ;
	----
	--retourne les villes avec pour chaque ville le nombre de groupes corespondant
	----
	procedure nb_groupe_par_ville(ensG: out based108_data.festival_List.Vector) is
		c:db_commons.criteria;
		ensVP:based108_data.Ville_List.Vector;

		procedure remplir_festival(pos : ville_List.cursor) is
			ville : tville;
			c : db_commons.Criteria;
			fest:tfestival;
		begin
			ville := ville_List.element(pos);
			participant_festival_io.Add_Festival(c,ville.nom_ville);
			fest.ville_festival:=ville.nom_ville;
			fest.prix_place	:=integer(participant_festival_io.card(participant_festival_io.retrieve(c)));
			festival_List.append (ensG, fest);
			
		end remplir_festival;


	begin
		
		
		ville_io.add_nom_ville_to_orderings (c, asc);
		
		ensVp := ville_io.retrieve( c );
		ville_List.iterate(ensvp, remplir_festival'Access);
		if festival_io.is_empty(ensG) then
			raise ExAucuneVille;
		end if;
	end nb_groupe_par_ville;
	----
	--enregistre un groupe au festival Paris_gibus et augmente le nombre de concert prévus dans l'une des deux journée
	----
	procedure ajouter_Paris_gibus_nbgroupe is
		j1,j2:tjour_festival;
		ensJ:Based108_Data.Jour_Festival_List.Vector;
		fest:tFestival;
		modifier:boolean:=false;
		nb_journe: integer:=0;
		procedure compte_groupe(pos : jour_festival_list.cursor) is
			journe:tjour_festival;
		begin
			journe :=  jour_festival_List.element(pos);
			nb_journe:=nb_journe+journe.nbre_concert_max;
		end compte_groupe;
		procedure ajoute_un(pos : jour_festival_list.cursor) is
			journe:tjour_festival;
		begin
			journe :=  jour_festival_List.element(pos);
			
			if not modifier then
				modifier:=true;
				journe.nbre_concert_max:=(nb_journe+2)/2;
				j1:=journe;
			else
				modifier:=false;
				journe.nbre_concert_max:=(nb_journe+1)/2;
				j2:=journe;
			end if;

		end ajoute_un;
	begin
		to_ada_type("Paris_gibus",fest.ville_festival);
		ensJ:=festival_io.Retrieve_Associated_Jour_Festivals(fest);
		jour_festival_list.iterate (ensJ, compte_groupe'Access);
		jour_festival_list.iterate (ensJ, ajoute_un'Access);
		jour_festival_io.save(j1,true);
		jour_festival_io.save(j2,true);
	end ajouter_Paris_gibus_nbgroupe;

	procedure enregistrer_groupe_final(nomgroupe:in Unbounded_String )is 
		part:tParticipant_Festival;
		
		
	begin
		part.nom_groupe_inscrit:=nomGroupe;
		to_ada_type("Paris_gibus",part.festival);
		participant_festival_io.save(part,false);
		
	end enregistrer_groupe_final;
	----
	--retrouve les groupes pour un genre donné
	----
	procedure retrouver_groupes_genre (genre:in base_types.tgenre_Enum;groupes :out Groupe_List.vector) is
		c:db_commons.criteria;
		ensG:Based108_Data.groupe_List.Vector;
		procedure ajouter_ville(pos :groupe_list.cursor) is
			groupe:tgroupe;
			c:db_commons.criteria;
			part:tParticipant_Festival;
			enspart:Participant_Festival_List.vector;
		begin

			groupe :=  groupe_List.element(pos);
			participant_festival_io.Add_Festival(c,"Paris_gibus",db_commons.ne);
			participant_festival_io.Add_Nom_Groupe_Inscrit(c,groupe.nom_groupe);
			enspart:=participant_festival_io.Retrieve(c);
			part:=Participant_Festival_List.element(enspart, Participant_Festival_List.first_index(enspart));
			if not participant_festival_io.is_empty(enspart) then
				groupe.coord_contact:=part.festival;
				groupe_List.append (groupes, groupe);
			end if;
		end ajouter_ville;
	begin
		groupe_io.add_genre(c,genre);
		ensG:=groupe_io.Retrieve(c);
		groupe_List.iterate(ensG, ajouter_ville'Access);
		if groupe_list.is_empty(ensG) then
			raise ExAucunGroupe;
		end if;
	end retrouver_groupes_genre;
	----
	--retrouve le groupe et la ville associer si le groupe est programmé a Paris_gibus alors ville = Paris_gibus
	----

	procedure retrouver_groupe_et_villes(groupes :out Groupe_List.vector)is
		ensG:groupe_List.vector;
		c:db_commons.criteria;
		ensv:ville_List.vector;

		procedure trouver_groupe(pos :ville_list.cursor) is	
			participant:tParticipant_Festival;
			ville:tville;
			ensP:Participant_Festival_List.Vector;
			nbGroupes:integer;
			procedure ajouter_groupe (pos1 :Participant_Festival_List.cursor)is
				part:tParticipant_Festival;
				groupe:tGroupe;
			begin
				part:=Participant_Festival_List.element(pos1);
				groupe.nom_contact:=part.festival;
				groupe.nom_groupe:=part.nom_groupe_inscrit;
				groupe_list.append(groupes,groupe);
			end ajouter_groupe ;
		begin
			ville:=ville_list.element(pos);
			retrouver_groupes_ville(Ville.nom_ville,ensP,nbGroupes);
			Participant_Festival_List.iterate(ensP,ajouter_groupe'access);
		end trouver_groupe;
	begin
		retrouver_villes_sans_gagnant(ensV);
		
		ville_list.iterate(ensV,trouver_groupe'Access);
		if groupe_io.is_empty(groupes) then
			raise ExAucunGroupe;
		end if;
	end retrouver_groupe_et_villes;
	
	----
	--desinscrit un groupe d'un festival:
		--si le festival= Paris_gibus alors il le désinscrit
		--si le festival n'est pas paris gibus alors il supprime aussi le groupe
	----
	procedure desinscrire_groupe(groupe:in out tgroupe)is
		c,c2:db_commons.criteria;
		prog:tprogramme_jour_festival;
		part:tParticipant_Festival;
		ensP:Programme_Jour_Festival_List.vector;
		procedure retrouverBonProgramme (pos :Programme_Jour_Festival_List.cursor)is--retrouve le bon programme parmis deux possible (si final) et decrement le nombre max de groupe pour la journe
			prog1:tProgramme_Jour_Festival;
			c1:db_commons.criteria;
			jfest,jfest1:tJour_Festival;

		begin
			prog1:=Programme_Jour_Festival_List.element(pos);
			jfest:=jour_festival_io.retrieve_by_pk(prog1.jour_fest);
			
			if jfest.festival=groupe.nom_contact then
				if p_conversion.to_string(jfest.festival)="Paris_gibus" then
					jfest.nbre_concert_max:=jfest.nbre_concert_max-1;									
					jour_festival_io.save(jfest,true);
				end if;
				prog:=prog1;
			end if;
		end retrouverBonProgramme;
		procedure decrementerJourFest (pos :Programme_Jour_Festival_List.cursor) is--decrement les ordre de passage pour les groupe passant apres le groupe supprimé
			prog1:tProgramme_Jour_Festival;
		begin
			prog1:=Programme_Jour_Festival_List.element(pos);
			prog1.passage:=prog1.passage-1;
			programme_jour_festival_io.save(prog1,true);
		
		end decrementerJourFest ;
	begin
		participant_festival_io.Add_Nom_Groupe_Inscrit(c,groupe.nom_groupe);--suppression de participant_festival
		participant_festival_io.Add_Festival(c,groupe.nom_contact);
		participant_festival_io.delete(c);

		ensP:=groupe_io.Retrieve_Associated_Programme_Jour_Festivals(groupe);
		Programme_Jour_Festival_List.iterate(ensP,retrouverBonProgramme'access);
		programme_jour_festival_io.Add_Jour_Fest(c2,prog.jour_fest);
		programme_jour_festival_io.Add_Passage(c2,prog.passage,db_commons.gt);
		ensP:=programme_jour_festival_io.retrieve(c2);
		Programme_Jour_Festival_List.iterate(ensP,decrementerJourFest'access);
		programme_jour_festival_io.delete(prog);
		if p_conversion.to_string(groupe.nom_contact)/="Paris_gibus" then
			groupe_io.delete(groupe);
		end if;

	end desinscrire_groupe;

end p_application;
