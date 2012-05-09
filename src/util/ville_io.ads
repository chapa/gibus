--
-- Created by ada_generator.py on 2012-05-09 10:13:50.815782
-- 
with Based108_Data;
with db_commons;
with base_types;
with ADA.Calendar;
with Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
with Ada.Containers; use Ada.Containers;

package Ville_IO is
  
   package d renames db_commons;   
   use base_types;
   use Ada.Strings.Unbounded;
   

   --
   -- returns true if the primary key parts of Ville match the defaults in Based108_Data.Null_Ville
   --
   function Is_Null( Ville : Based108_Data.tVille ) return Boolean;
   
   --
   -- returns true if the container is empty
   --
   function Is_Empty( Ville_Liste : Based108_Data.Ville_List.Vector ) return Boolean;

   --
   -- returns number of items of the container 
   --

   function Card( Ville_Liste : Based108_Data.Ville_List.Vector ) return Count_Type;
  
   --
   -- returns the single Ville matching the primary key fields, or the Based108_Data.Null_Ville record
   -- if no such record exists
   --
   function Retrieve_By_PK( Nom_Ville : Unbounded_String ) return Based108_Data.tVille;
   
   --
   -- Retrieves a list of Based108_Data.tVille matching the criteria, or throws an exception
   --
   function Retrieve( c : d.Criteria ) return Based108_Data.Ville_List.Vector;
   
   --
   -- Retrieves a list of Based108_Data.tVille retrived by the sql string, or throws an exception
   --
   function Retrieve( sqlstr : String ) return Based108_Data.Ville_List.Vector;
   
   --
   -- Save the given record, overwriting if it exists and overwrite is true, 
   -- otherwise throws DB_Integrity_Violation exception. 
   --
   procedure Save( Ville : Based108_Data.tVille; overwrite : Boolean := True );
   
   --
   -- Delete the given record. Throws DB_Exception exception. Sets value to Based108_Data.Null_Ville
   --
   procedure Delete( Ville : in out Based108_Data.tVille );
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
   function Retrieve_Child_Festival( Ville : Based108_Data.tVille ) return Based108_Data.tFestival;

   --
   -- functions to add something to a criteria
   --
   procedure Add_Nom_Ville( c : in out d.Criteria; Nom_Ville : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Nom_Ville( c : in out d.Criteria; Nom_Ville : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Mel_Contact( c : in out d.Criteria; Mel_Contact : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Mel_Contact( c : in out d.Criteria; Mel_Contact : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   --
   -- functions to add an ordering to a criteria
   --
   procedure Add_Nom_Ville_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Mel_Contact_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
 
end Ville_IO;
