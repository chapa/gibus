--
-- Created by ada_generator.py on 2012-05-09 10:14:48.764793
-- 
with Ada.Containers.Vectors;
--
-- FIXME: may not be needed
--
with Ada.Calendar;

with base_types; use base_types;

with Ada.Strings.Unbounded;

package Based108_Data is

   use Ada.Strings.Unbounded;

      --
      -- record modelling programme_jour_festival : L'ordre de passage des groupes sur un jour de festival
      --
      type tProgramme_Jour_Festival is record
         Nom_Groupe_Programme : Unbounded_String := MISSING_W_KEY;
         Jour_Fest : integer := MISSING_I_KEY;
         Passage : integer := 0;
      end record;
      --
      -- container for programme_jour_festival : L'ordre de passage des groupes sur un jour de festival
      --
      package Programme_Jour_Festival_List is new Ada.Containers.Vectors
         (Element_Type => tProgramme_Jour_Festival,
         Index_Type => Positive );
      --
      -- default value for programme_jour_festival : L'ordre de passage des groupes sur un jour de festival
      --
      Null_Programme_Jour_Festival : constant tProgramme_Jour_Festival := (
         Nom_Groupe_Programme => MISSING_W_KEY,
         Jour_Fest => MISSING_I_KEY,
         Passage => 0
      );
      --
      -- simple print routine for programme_jour_festival : L'ordre de passage des groupes sur un jour de festival
      --
      function To_String( rec : tProgramme_Jour_Festival ) return String;

      --
      -- record modelling participant_festival : Les groupes inscrits a  un festival
      --
      type tParticipant_Festival is record
         Nom_Groupe_Inscrit : Unbounded_String := MISSING_W_KEY;
         Festival : Unbounded_String := MISSING_W_KEY;
         Gagnant : boolean := false;
      end record;
      --
      -- container for participant_festival : Les groupes inscrits a  un festival
      --
      package Participant_Festival_List is new Ada.Containers.Vectors
         (Element_Type => tParticipant_Festival,
         Index_Type => Positive );
      --
      -- default value for participant_festival : Les groupes inscrits a  un festival
      --
      Null_Participant_Festival : constant tParticipant_Festival := (
         Nom_Groupe_Inscrit => MISSING_W_KEY,
         Festival => MISSING_W_KEY,
         Gagnant => false
      );
      --
      -- simple print routine for participant_festival : Les groupes inscrits a  un festival
      --
      function To_String( rec : tParticipant_Festival ) return String;

      --
      -- record modelling groupe : Les groupes
      --
      type tGroupe is record
         Nom_Groupe : Unbounded_String := MISSING_W_KEY;
         Nom_Contact : Unbounded_String := Ada.Strings.Unbounded.Null_Unbounded_String;
         Coord_Contact : Unbounded_String := Ada.Strings.Unbounded.Null_Unbounded_String;
         Adr_Site : Unbounded_String := Ada.Strings.Unbounded.Null_Unbounded_String;
         Genre : tgenre_Enum := hard;
         Participant_Festivals : Participant_Festival_List.Vector;
         Programme_Jour_Festivals : Programme_Jour_Festival_List.Vector;
      end record;
      --
      -- container for groupe : Les groupes
      --
      package Groupe_List is new Ada.Containers.Vectors
         (Element_Type => tGroupe,
         Index_Type => Positive );
      --
      -- default value for groupe : Les groupes
      --
      Null_Groupe : constant tGroupe := (
         Nom_Groupe => MISSING_W_KEY,
         Nom_Contact => Ada.Strings.Unbounded.Null_Unbounded_String,
         Coord_Contact => Ada.Strings.Unbounded.Null_Unbounded_String,
         Adr_Site => Ada.Strings.Unbounded.Null_Unbounded_String,
         Genre => hard,
         Participant_Festivals => Participant_Festival_List.Empty_Vector,
         Programme_Jour_Festivals => Programme_Jour_Festival_List.Empty_Vector
      );
      --
      -- simple print routine for groupe : Les groupes
      --
      function To_String( rec : tGroupe ) return String;

      --
      -- record modelling jour_festival : Les journees des festivals
      --
      type tJour_Festival is record
         Id_Jour_Festival : integer := MISSING_I_KEY;
         Festival : Unbounded_String := Ada.Strings.Unbounded.Null_Unbounded_String;
         Num_Ordre : integer := 0;
         Nbre_Concert_Max : integer := 0;
         Heure_Debut : integer := 0;
         Programme_Jour_Festivals : Programme_Jour_Festival_List.Vector;
      end record;
      --
      -- container for jour_festival : Les journees des festivals
      --
      package Jour_Festival_List is new Ada.Containers.Vectors
         (Element_Type => tJour_Festival,
         Index_Type => Positive );
      --
      -- default value for jour_festival : Les journees des festivals
      --
      Null_Jour_Festival : constant tJour_Festival := (
         Id_Jour_Festival => MISSING_I_KEY,
         Festival => Ada.Strings.Unbounded.Null_Unbounded_String,
         Num_Ordre => 0,
         Nbre_Concert_Max => 0,
         Heure_Debut => 0,
         Programme_Jour_Festivals => Programme_Jour_Festival_List.Empty_Vector
      );
      --
      -- simple print routine for jour_festival : Les journees des festivals
      --
      function To_String( rec : tJour_Festival ) return String;

      --
      -- record modelling festival : Les festivals
      --
      type tFestival is record
         Ville_Festival : Unbounded_String := MISSING_W_KEY;
         Date : Ada.Calendar.Time := FIRST_DATE;
         Lieu : Unbounded_String := Ada.Strings.Unbounded.Null_Unbounded_String;
         Prix_Place : integer := 0;
         Jour_Festivals : Jour_Festival_List.Vector;
         Participant_Festivals : Participant_Festival_List.Vector;
      end record;
      --
      -- container for festival : Les festivals
      --
      package Festival_List is new Ada.Containers.Vectors
         (Element_Type => tFestival,
         Index_Type => Positive );
      --
      -- default value for festival : Les festivals
      --
      Null_Festival : constant tFestival := (
         Ville_Festival => MISSING_W_KEY,
         Date => FIRST_DATE,
         Lieu => Ada.Strings.Unbounded.Null_Unbounded_String,
         Prix_Place => 0,
         Jour_Festivals => Jour_Festival_List.Empty_Vector,
         Participant_Festivals => Participant_Festival_List.Empty_Vector
      );
      --
      -- simple print routine for festival : Les festivals
      --
      function To_String( rec : tFestival ) return String;

      --
      -- record modelling ville : Les villes
      --
      type tVille is record
         Nom_Ville : Unbounded_String := MISSING_W_KEY;
         Mel_Contact : Unbounded_String := Ada.Strings.Unbounded.Null_Unbounded_String;
         Festival_Child :tFestival := Null_Festival;
      end record;
      --
      -- container for ville : Les villes
      --
      package Ville_List is new Ada.Containers.Vectors
         (Element_Type => tVille,
         Index_Type => Positive );
      --
      -- default value for ville : Les villes
      --
      Null_Ville : constant tVille := (
         Nom_Ville => MISSING_W_KEY,
         Mel_Contact => Ada.Strings.Unbounded.Null_Unbounded_String,
         Festival_Child => Null_Festival
      );
      --
      -- simple print routine for ville : Les villes
      --
      function To_String( rec : tVille ) return String;

        

end Based108_Data;
