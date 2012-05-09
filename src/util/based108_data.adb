--
-- Created by ada_generator.py on 2012-05-09 10:14:48.777646
-- 

with GNAT.Calendar.Time_IO;

package body Based108_Data is

   use ada.strings.Unbounded;
   package tio renames GNAT.Calendar.Time_IO;

   function To_String( rec : tProgramme_Jour_Festival ) return String is
   begin
      return  "Programme_Jour_Festival: " &
         "Nom_Groupe_Programme = " & To_String( rec.Nom_Groupe_Programme ) &
         "Jour_Fest = " & rec.Jour_Fest'Img &
         "Passage = " & rec.Passage'Img;
   end to_String;



   function To_String( rec : tParticipant_Festival ) return String is
   begin
      return  "Participant_Festival: " &
         "Nom_Groupe_Inscrit = " & To_String( rec.Nom_Groupe_Inscrit ) &
         "Festival = " & To_String( rec.Festival ) &
         "Gagnant = " & rec.Gagnant'Img;
   end to_String;



   function To_String( rec : tGroupe ) return String is
   begin
      return  "Groupe: " &
         "Nom_Groupe = " & To_String( rec.Nom_Groupe ) &
         "Nom_Contact = " & To_String( rec.Nom_Contact ) &
         "Coord_Contact = " & To_String( rec.Coord_Contact ) &
         "Adr_Site = " & To_String( rec.Adr_Site ) &
         "Genre = " & rec.Genre'Img;
   end to_String;



   function To_String( rec : tJour_Festival ) return String is
   begin
      return  "Jour_Festival: " &
         "Id_Jour_Festival = " & rec.Id_Jour_Festival'Img &
         "Festival = " & To_String( rec.Festival ) &
         "Num_Ordre = " & rec.Num_Ordre'Img &
         "Nbre_Concert_Max = " & rec.Nbre_Concert_Max'Img &
         "Heure_Debut = " & rec.Heure_Debut'Img;
   end to_String;



   function To_String( rec : tFestival ) return String is
   begin
      return  "Festival: " &
         "Ville_Festival = " & To_String( rec.Ville_Festival ) &
         "Date = " & tio.Image( rec.Date, tio.ISO_Date ) &
         "Lieu = " & To_String( rec.Lieu ) &
         "Prix_Place = " & rec.Prix_Place'Img;
   end to_String;



   function To_String( rec : tVille ) return String is
   begin
      return  "Ville: " &
         "Nom_Ville = " & To_String( rec.Nom_Ville ) &
         "Mel_Contact = " & To_String( rec.Mel_Contact );
   end to_String;



        

end Based108_Data;
