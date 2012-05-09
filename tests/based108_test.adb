--
-- Created by ada_generator.py on 2012-05-09 10:13:51.469855
-- 


with Ada.Calendar;
with Ada.Containers.Vectors;
with Ada.Exceptions;
with Ada.Strings.Unbounded; 

with AUnit.Assertions; 
with AUnit.Test_Cases.Registration; 
with AUnit.Test_Results ; use AUnit.Test_Results ; 
   
with logger;
with base_types;
with environment;
with db_commons.odbc;
with db_commons;
with Based108_Data;

with Ville_IO;
with Festival_IO;
with Jour_Festival_IO;
with Groupe_IO;
with Participant_Festival_IO;
with Programme_Jour_Festival_IO;

package body Based108_Test is

   RECORDS_TO_ADD     : constant integer := 100;
   RECORDS_TO_DELETE  : constant integer := 50;
   RECORDS_TO_ALTER   : constant integer := 50;
   
   package d renames db_commons;
   
   use base_types;
   use ada.strings.Unbounded;
   use Based108_Data;
   
   use AUnit.Test_Cases;
   use AUnit.Assertions;
   use AUnit.Test_Cases.Registration;
   
   use Ada.Strings.Unbounded;
   use Ada.Exceptions;
   use Ada.Calendar;
   
   
--
-- test creating and deleting records  
--
--
   procedure Ville_Create_Test(  T : in out AUnit.Test_Cases.Test_Case'Class ) is
      --
      -- local print iteration routine
      --
      procedure Print( pos : Ville_List.Cursor ) is 
      Ville_Test_Item : Based108_Data.tVille;
      begin
         Ville_Test_Item := Ville_List.element( pos );
         Logger.info( To_String( Ville_Test_Item ));
      end print;

   
      Ville_Test_Item : Based108_Data.tVille;
      Ville_test_list : Based108_Data.Ville_List.Vector;
      criteria  : d.Criteria;
      startTime : Time;
      endTime   : Time;
      elapsed   : Duration;
   begin
      startTime := Clock;
      Logger.info( "Starting test Ville_Create_Test" );
      
      Logger.info( "Clearing out the table" );
      Ville_io.Delete( criteria );
      
      Logger.info( "Ville_Create_Test: create tests" );
      for i in 1 .. RECORDS_TO_ADD loop
         Ville_Test_Item.Nom_Ville := To_Unbounded_String( "k_" & i'img );
         Ville_Test_Item.Mel_Contact := To_Unbounded_String("dat forMel_Contact");
         Ville_io.Save( Ville_Test_Item, False );         
      end loop;
      
      Ville_test_list := Ville_Io.Retrieve( criteria );
      
      Logger.info( "Ville_Create_Test: alter tests" );
      for i in 1 .. RECORDS_TO_ALTER loop
         Ville_Test_Item := Ville_List.element( Ville_test_list, i );
         Ville_Test_Item.Mel_Contact := To_Unbounded_String("Altered::dat forMel_Contact");
         Ville_io.Save( Ville_Test_Item );         
      end loop;
      
      Logger.info( "Ville_Create_Test: delete tests" );
      for i in RECORDS_TO_DELETE .. RECORDS_TO_ADD loop
         Ville_Test_Item := Ville_List.element( Ville_test_list, i );
         Ville_io.Delete( Ville_Test_Item );         
      end loop;
      
      Logger.info( "Ville_Create_Test: retrieve all records" );
      Ville_List.iterate( Ville_test_list, print'Access );
      endTime := Clock;
      elapsed := endTime - startTime;
      Logger.info( "Ending test Ville_Create_Test. Time taken = " & elapsed'Img );

   exception 
      when Error : others =>
         Logger.error( "Ville_Create_Test execute query failed with message " & Exception_Information(Error) );
         assert( False,  
            "Ville_Create_Test : exception thrown " & Exception_Information(Error) );
   end Ville_Create_Test;

   
--
-- test creating and deleting records  
--
--
   procedure Festival_Create_Test(  T : in out AUnit.Test_Cases.Test_Case'Class ) is
      --
      -- local print iteration routine
      --
      procedure Print( pos : Festival_List.Cursor ) is 
      Festival_Test_Item : Based108_Data.tFestival;
      begin
         Festival_Test_Item := Festival_List.element( pos );
         Logger.info( To_String( Festival_Test_Item ));
      end print;

   
      Festival_Test_Item : Based108_Data.tFestival;
      Festival_test_list : Based108_Data.Festival_List.Vector;
      criteria  : d.Criteria;
      startTime : Time;
      endTime   : Time;
      elapsed   : Duration;
   begin
      startTime := Clock;
      Logger.info( "Starting test Festival_Create_Test" );
      
      Logger.info( "Clearing out the table" );
      Festival_io.Delete( criteria );
      
      Logger.info( "Festival_Create_Test: create tests" );
      for i in 1 .. RECORDS_TO_ADD loop
         Festival_Test_Item.Ville_Festival := To_Unbounded_String( "k_" & i'img );
         Festival_Test_Item.Date := Ada.Calendar.Clock;
         Festival_Test_Item.Lieu := To_Unbounded_String("dat forLieu");
         -- missingFestival_Test_Item declaration ;
         Festival_io.Save( Festival_Test_Item, False );         
      end loop;
      
      Festival_test_list := Festival_Io.Retrieve( criteria );
      
      Logger.info( "Festival_Create_Test: alter tests" );
      for i in 1 .. RECORDS_TO_ALTER loop
         Festival_Test_Item := Festival_List.element( Festival_test_list, i );
         Festival_Test_Item.Lieu := To_Unbounded_String("Altered::dat forLieu");
         Festival_io.Save( Festival_Test_Item );         
      end loop;
      
      Logger.info( "Festival_Create_Test: delete tests" );
      for i in RECORDS_TO_DELETE .. RECORDS_TO_ADD loop
         Festival_Test_Item := Festival_List.element( Festival_test_list, i );
         Festival_io.Delete( Festival_Test_Item );         
      end loop;
      
      Logger.info( "Festival_Create_Test: retrieve all records" );
      Festival_List.iterate( Festival_test_list, print'Access );
      endTime := Clock;
      elapsed := endTime - startTime;
      Logger.info( "Ending test Festival_Create_Test. Time taken = " & elapsed'Img );

   exception 
      when Error : others =>
         Logger.error( "Festival_Create_Test execute query failed with message " & Exception_Information(Error) );
         assert( False,  
            "Festival_Create_Test : exception thrown " & Exception_Information(Error) );
   end Festival_Create_Test;

   
--
-- test creating and deleting records  
--
--
   procedure Jour_Festival_Create_Test(  T : in out AUnit.Test_Cases.Test_Case'Class ) is
      --
      -- local print iteration routine
      --
      procedure Print( pos : Jour_Festival_List.Cursor ) is 
      Jour_Festival_Test_Item : Based108_Data.tJour_Festival;
      begin
         Jour_Festival_Test_Item := Jour_Festival_List.element( pos );
         Logger.info( To_String( Jour_Festival_Test_Item ));
      end print;

   
      Jour_Festival_Test_Item : Based108_Data.tJour_Festival;
      Jour_Festival_test_list : Based108_Data.Jour_Festival_List.Vector;
      criteria  : d.Criteria;
      startTime : Time;
      endTime   : Time;
      elapsed   : Duration;
   begin
      startTime := Clock;
      Logger.info( "Starting test Jour_Festival_Create_Test" );
      
      Logger.info( "Clearing out the table" );
      Jour_Festival_io.Delete( criteria );
      
      Logger.info( "Jour_Festival_Create_Test: create tests" );
      for i in 1 .. RECORDS_TO_ADD loop
         Jour_Festival_Test_Item.Id_Jour_Festival := Jour_Festival_io.Next_Free_Id_Jour_Festival;
         Jour_Festival_Test_Item.Festival := To_Unbounded_String("dat forFestival");
         -- missingJour_Festival_Test_Item declaration ;
         -- missingJour_Festival_Test_Item declaration ;
         -- missingJour_Festival_Test_Item declaration ;
         Jour_Festival_io.Save( Jour_Festival_Test_Item, False );         
      end loop;
      
      Jour_Festival_test_list := Jour_Festival_Io.Retrieve( criteria );
      
      Logger.info( "Jour_Festival_Create_Test: alter tests" );
      for i in 1 .. RECORDS_TO_ALTER loop
         Jour_Festival_Test_Item := Jour_Festival_List.element( Jour_Festival_test_list, i );
         Jour_Festival_Test_Item.Festival := To_Unbounded_String("Altered::dat forFestival");
         Jour_Festival_io.Save( Jour_Festival_Test_Item );         
      end loop;
      
      Logger.info( "Jour_Festival_Create_Test: delete tests" );
      for i in RECORDS_TO_DELETE .. RECORDS_TO_ADD loop
         Jour_Festival_Test_Item := Jour_Festival_List.element( Jour_Festival_test_list, i );
         Jour_Festival_io.Delete( Jour_Festival_Test_Item );         
      end loop;
      
      Logger.info( "Jour_Festival_Create_Test: retrieve all records" );
      Jour_Festival_List.iterate( Jour_Festival_test_list, print'Access );
      endTime := Clock;
      elapsed := endTime - startTime;
      Logger.info( "Ending test Jour_Festival_Create_Test. Time taken = " & elapsed'Img );

   exception 
      when Error : others =>
         Logger.error( "Jour_Festival_Create_Test execute query failed with message " & Exception_Information(Error) );
         assert( False,  
            "Jour_Festival_Create_Test : exception thrown " & Exception_Information(Error) );
   end Jour_Festival_Create_Test;

   
--
-- test creating and deleting records  
--
--
   procedure Groupe_Create_Test(  T : in out AUnit.Test_Cases.Test_Case'Class ) is
      --
      -- local print iteration routine
      --
      procedure Print( pos : Groupe_List.Cursor ) is 
      Groupe_Test_Item : Based108_Data.tGroupe;
      begin
         Groupe_Test_Item := Groupe_List.element( pos );
         Logger.info( To_String( Groupe_Test_Item ));
      end print;

   
      Groupe_Test_Item : Based108_Data.tGroupe;
      Groupe_test_list : Based108_Data.Groupe_List.Vector;
      criteria  : d.Criteria;
      startTime : Time;
      endTime   : Time;
      elapsed   : Duration;
   begin
      startTime := Clock;
      Logger.info( "Starting test Groupe_Create_Test" );
      
      Logger.info( "Clearing out the table" );
      Groupe_io.Delete( criteria );
      
      Logger.info( "Groupe_Create_Test: create tests" );
      for i in 1 .. RECORDS_TO_ADD loop
         Groupe_Test_Item.Nom_Groupe := To_Unbounded_String( "k_" & i'img );
         Groupe_Test_Item.Nom_Contact := To_Unbounded_String("dat forNom_Contact");
         Groupe_Test_Item.Coord_Contact := To_Unbounded_String("dat forCoord_Contact");
         Groupe_Test_Item.Adr_Site := To_Unbounded_String("dat forAdr_Site");
         -- missingGroupe_Test_Item declaration ;
         Groupe_io.Save( Groupe_Test_Item, False );         
      end loop;
      
      Groupe_test_list := Groupe_Io.Retrieve( criteria );
      
      Logger.info( "Groupe_Create_Test: alter tests" );
      for i in 1 .. RECORDS_TO_ALTER loop
         Groupe_Test_Item := Groupe_List.element( Groupe_test_list, i );
         Groupe_Test_Item.Nom_Contact := To_Unbounded_String("Altered::dat forNom_Contact");
         Groupe_Test_Item.Coord_Contact := To_Unbounded_String("Altered::dat forCoord_Contact");
         Groupe_Test_Item.Adr_Site := To_Unbounded_String("Altered::dat forAdr_Site");
         Groupe_io.Save( Groupe_Test_Item );         
      end loop;
      
      Logger.info( "Groupe_Create_Test: delete tests" );
      for i in RECORDS_TO_DELETE .. RECORDS_TO_ADD loop
         Groupe_Test_Item := Groupe_List.element( Groupe_test_list, i );
         Groupe_io.Delete( Groupe_Test_Item );         
      end loop;
      
      Logger.info( "Groupe_Create_Test: retrieve all records" );
      Groupe_List.iterate( Groupe_test_list, print'Access );
      endTime := Clock;
      elapsed := endTime - startTime;
      Logger.info( "Ending test Groupe_Create_Test. Time taken = " & elapsed'Img );

   exception 
      when Error : others =>
         Logger.error( "Groupe_Create_Test execute query failed with message " & Exception_Information(Error) );
         assert( False,  
            "Groupe_Create_Test : exception thrown " & Exception_Information(Error) );
   end Groupe_Create_Test;

   
--
-- test creating and deleting records  
--
--
   procedure Participant_Festival_Create_Test(  T : in out AUnit.Test_Cases.Test_Case'Class ) is
      --
      -- local print iteration routine
      --
      procedure Print( pos : Participant_Festival_List.Cursor ) is 
      Participant_Festival_Test_Item : Based108_Data.tParticipant_Festival;
      begin
         Participant_Festival_Test_Item := Participant_Festival_List.element( pos );
         Logger.info( To_String( Participant_Festival_Test_Item ));
      end print;

   
      Participant_Festival_Test_Item : Based108_Data.tParticipant_Festival;
      Participant_Festival_test_list : Based108_Data.Participant_Festival_List.Vector;
      criteria  : d.Criteria;
      startTime : Time;
      endTime   : Time;
      elapsed   : Duration;
   begin
      startTime := Clock;
      Logger.info( "Starting test Participant_Festival_Create_Test" );
      
      Logger.info( "Clearing out the table" );
      Participant_Festival_io.Delete( criteria );
      
      Logger.info( "Participant_Festival_Create_Test: create tests" );
      for i in 1 .. RECORDS_TO_ADD loop
         Participant_Festival_Test_Item.Nom_Groupe_Inscrit := To_Unbounded_String( "k_" & i'img );
         Participant_Festival_Test_Item.Festival := To_Unbounded_String( "k_" & i'img );
         -- missingParticipant_Festival_Test_Item declaration ;
         Participant_Festival_io.Save( Participant_Festival_Test_Item, False );         
      end loop;
      
      Participant_Festival_test_list := Participant_Festival_Io.Retrieve( criteria );
      
      Logger.info( "Participant_Festival_Create_Test: alter tests" );
      for i in 1 .. RECORDS_TO_ALTER loop
         Participant_Festival_Test_Item := Participant_Festival_List.element( Participant_Festival_test_list, i );
         Participant_Festival_io.Save( Participant_Festival_Test_Item );         
      end loop;
      
      Logger.info( "Participant_Festival_Create_Test: delete tests" );
      for i in RECORDS_TO_DELETE .. RECORDS_TO_ADD loop
         Participant_Festival_Test_Item := Participant_Festival_List.element( Participant_Festival_test_list, i );
         Participant_Festival_io.Delete( Participant_Festival_Test_Item );         
      end loop;
      
      Logger.info( "Participant_Festival_Create_Test: retrieve all records" );
      Participant_Festival_List.iterate( Participant_Festival_test_list, print'Access );
      endTime := Clock;
      elapsed := endTime - startTime;
      Logger.info( "Ending test Participant_Festival_Create_Test. Time taken = " & elapsed'Img );

   exception 
      when Error : others =>
         Logger.error( "Participant_Festival_Create_Test execute query failed with message " & Exception_Information(Error) );
         assert( False,  
            "Participant_Festival_Create_Test : exception thrown " & Exception_Information(Error) );
   end Participant_Festival_Create_Test;

   
--
-- test creating and deleting records  
--
--
   procedure Programme_Jour_Festival_Create_Test(  T : in out AUnit.Test_Cases.Test_Case'Class ) is
      --
      -- local print iteration routine
      --
      procedure Print( pos : Programme_Jour_Festival_List.Cursor ) is 
      Programme_Jour_Festival_Test_Item : Based108_Data.tProgramme_Jour_Festival;
      begin
         Programme_Jour_Festival_Test_Item := Programme_Jour_Festival_List.element( pos );
         Logger.info( To_String( Programme_Jour_Festival_Test_Item ));
      end print;

   
      Programme_Jour_Festival_Test_Item : Based108_Data.tProgramme_Jour_Festival;
      Programme_Jour_Festival_test_list : Based108_Data.Programme_Jour_Festival_List.Vector;
      criteria  : d.Criteria;
      startTime : Time;
      endTime   : Time;
      elapsed   : Duration;
   begin
      startTime := Clock;
      Logger.info( "Starting test Programme_Jour_Festival_Create_Test" );
      
      Logger.info( "Clearing out the table" );
      Programme_Jour_Festival_io.Delete( criteria );
      
      Logger.info( "Programme_Jour_Festival_Create_Test: create tests" );
      for i in 1 .. RECORDS_TO_ADD loop
         Programme_Jour_Festival_Test_Item.Nom_Groupe_Programme := To_Unbounded_String( "k_" & i'img );
         Programme_Jour_Festival_Test_Item.Jour_Fest := Programme_Jour_Festival_io.Next_Free_Jour_Fest;
         -- missingProgramme_Jour_Festival_Test_Item declaration ;
         Programme_Jour_Festival_io.Save( Programme_Jour_Festival_Test_Item, False );         
      end loop;
      
      Programme_Jour_Festival_test_list := Programme_Jour_Festival_Io.Retrieve( criteria );
      
      Logger.info( "Programme_Jour_Festival_Create_Test: alter tests" );
      for i in 1 .. RECORDS_TO_ALTER loop
         Programme_Jour_Festival_Test_Item := Programme_Jour_Festival_List.element( Programme_Jour_Festival_test_list, i );
         Programme_Jour_Festival_io.Save( Programme_Jour_Festival_Test_Item );         
      end loop;
      
      Logger.info( "Programme_Jour_Festival_Create_Test: delete tests" );
      for i in RECORDS_TO_DELETE .. RECORDS_TO_ADD loop
         Programme_Jour_Festival_Test_Item := Programme_Jour_Festival_List.element( Programme_Jour_Festival_test_list, i );
         Programme_Jour_Festival_io.Delete( Programme_Jour_Festival_Test_Item );         
      end loop;
      
      Logger.info( "Programme_Jour_Festival_Create_Test: retrieve all records" );
      Programme_Jour_Festival_List.iterate( Programme_Jour_Festival_test_list, print'Access );
      endTime := Clock;
      elapsed := endTime - startTime;
      Logger.info( "Ending test Programme_Jour_Festival_Create_Test. Time taken = " & elapsed'Img );

   exception 
      when Error : others =>
         Logger.error( "Programme_Jour_Festival_Create_Test execute query failed with message " & Exception_Information(Error) );
         assert( False,  
            "Programme_Jour_Festival_Create_Test : exception thrown " & Exception_Information(Error) );
   end Programme_Jour_Festival_Create_Test;

   
   
   
   
   
   
   
   procedure Register_Tests (T : in out Test_Case) is
   begin
      --
      -- Tests of record creation/deletion
      --
      Register_Routine (T, Ville_Create_Test'Access, "Test of Creation and deletion of Ville" );
      Register_Routine (T, Festival_Create_Test'Access, "Test of Creation and deletion of Festival" );
      Register_Routine (T, Jour_Festival_Create_Test'Access, "Test of Creation and deletion of Jour_Festival" );
      Register_Routine (T, Groupe_Create_Test'Access, "Test of Creation and deletion of Groupe" );
      Register_Routine (T, Participant_Festival_Create_Test'Access, "Test of Creation and deletion of Participant_Festival" );
      Register_Routine (T, Programme_Jour_Festival_Create_Test'Access, "Test of Creation and deletion of Programme_Jour_Festival" );
      --
      -- Tests of foreign key relationships
      --
      --  not implemented yet Register_Routine (T, Ville_Child_Retrieve_Test'Access, "Test of Finding Children of Ville" );
      --  not implemented yet Register_Routine (T, Festival_Child_Retrieve_Test'Access, "Test of Finding Children of Festival" );
      --  not implemented yet Register_Routine (T, Jour_Festival_Child_Retrieve_Test'Access, "Test of Finding Children of Jour_Festival" );
      --  not implemented yet Register_Routine (T, Groupe_Child_Retrieve_Test'Access, "Test of Finding Children of Groupe" );
   end Register_Tests;
   
   --  Register routines to be run
   
   
   function Name ( t : Test_Case ) return String_Access is
   begin
          return new String'( "Based108_Test Test Suite" );
   end Name;

   
   --  Preparation performed before each routine:
   procedure Set_Up( t : in out Test_Case ) is
   begin
      Logger.set_Log_Level( Logger.debug_level );
   end Set_Up;
   
   --  Preparation performed before each routine:
   procedure Shut_Down( t : in out Test_Case ) is
   begin
      Null;
   end Shut_Down;

end Based108_Test;
