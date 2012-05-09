--
-- Created by ada_generator.py on 2012-05-09 10:14:49.199465
-- 
with Based108_Data;
with db_commons;
with base_types;
with ADA.Calendar;
with Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
with Ada.Containers; use Ada.Containers;

package Participant_Festival_IO is
  
   package d renames db_commons;   
   use base_types;
   use Ada.Strings.Unbounded;
   

   --
   -- returns true if the primary key parts of Participant_Festival match the defaults in Based108_Data.Null_Participant_Festival
   --
   function Is_Null( Participant_Festival : Based108_Data.tParticipant_Festival ) return Boolean;
   
   --
   -- returns true if the container is empty
   --
   function Is_Empty( Participant_Festival_Liste : Based108_Data.Participant_Festival_List.Vector ) return Boolean;

   --
   -- returns number of items of the container 
   --

   function Card( Participant_Festival_Liste : Based108_Data.Participant_Festival_List.Vector ) return Count_Type;
  
   --
   -- returns the single Participant_Festival matching the primary key fields, or the Based108_Data.Null_Participant_Festival record
   -- if no such record exists
   --
   function Retrieve_By_PK( Nom_Groupe_Inscrit : Unbounded_String; Festival : Unbounded_String ) return Based108_Data.tParticipant_Festival;
   
   --
   -- Retrieves a list of Based108_Data.tParticipant_Festival matching the criteria, or throws an exception
   --
   function Retrieve( c : d.Criteria ) return Based108_Data.Participant_Festival_List.Vector;
   
   --
   -- Retrieves a list of Based108_Data.tParticipant_Festival retrived by the sql string, or throws an exception
   --
   function Retrieve( sqlstr : String ) return Based108_Data.Participant_Festival_List.Vector;
   
   --
   -- Save the given record, overwriting if it exists and overwrite is true, 
   -- otherwise throws DB_Integrity_Violation exception. 
   --
   procedure Save( Participant_Festival : Based108_Data.tParticipant_Festival; overwrite : Boolean := True );
   
   --
   -- Delete the given record. Throws DB_Exception exception. Sets value to Based108_Data.Null_Participant_Festival
   --
   procedure Delete( Participant_Festival : in out Based108_Data.tParticipant_Festival );
   --
   -- delete the records indentified by the criteria
   --
   procedure Delete( c : d.Criteria );
   --
   -- delete all the records identified by the where SQL clause 
   --
   procedure Delete( where_Clause : String );
   --
   -- functions to retrieve records from tables with foreign keys
   -- referencing the table modelled by this package
   --

   --
   -- functions to add something to a criteria
   --
   procedure Add_Nom_Groupe_Inscrit( c : in out d.Criteria; Nom_Groupe_Inscrit : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Nom_Groupe_Inscrit( c : in out d.Criteria; Nom_Groupe_Inscrit : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Festival( c : in out d.Criteria; Festival : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Festival( c : in out d.Criteria; Festival : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Gagnant( c : in out d.Criteria; Gagnant : boolean; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   --
   -- functions to add an ordering to a criteria
   --
   procedure Add_Nom_Groupe_Inscrit_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Festival_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Gagnant_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
 
end Participant_Festival_IO;
