--
-- Created by ada_generator.py on 2012-05-09 10:13:51.084351
-- 
with Based108_Data;
with db_commons;
with base_types;
with ADA.Calendar;
with Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
with Ada.Containers; use Ada.Containers;

package Groupe_IO is
  
   package d renames db_commons;   
   use base_types;
   use Ada.Strings.Unbounded;
   

   --
   -- returns true if the primary key parts of Groupe match the defaults in Based108_Data.Null_Groupe
   --
   function Is_Null( Groupe : Based108_Data.tGroupe ) return Boolean;
   
   --
   -- returns true if the container is empty
   --
   function Is_Empty( Groupe_Liste : Based108_Data.Groupe_List.Vector ) return Boolean;

   --
   -- returns number of items of the container 
   --

   function Card( Groupe_Liste : Based108_Data.Groupe_List.Vector ) return Count_Type;
  
   --
   -- returns the single Groupe matching the primary key fields, or the Based108_Data.Null_Groupe record
   -- if no such record exists
   --
   function Retrieve_By_PK( Nom_Groupe : Unbounded_String ) return Based108_Data.tGroupe;
   
   --
   -- Retrieves a list of Based108_Data.tGroupe matching the criteria, or throws an exception
   --
   function Retrieve( c : d.Criteria ) return Based108_Data.Groupe_List.Vector;
   
   --
   -- Retrieves a list of Based108_Data.tGroupe retrived by the sql string, or throws an exception
   --
   function Retrieve( sqlstr : String ) return Based108_Data.Groupe_List.Vector;
   
   --
   -- Save the given record, overwriting if it exists and overwrite is true, 
   -- otherwise throws DB_Integrity_Violation exception. 
   --
   procedure Save( Groupe : Based108_Data.tGroupe; overwrite : Boolean := True );
   
   --
   -- Delete the given record. Throws DB_Exception exception. Sets value to Based108_Data.Null_Groupe
   --
   procedure Delete( Groupe : in out Based108_Data.tGroupe );
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
   function Retrieve_Associated_Participant_Festivals( Groupe : Based108_Data.tGroupe ) return Based108_Data.Participant_Festival_List.Vector;
   function Retrieve_Associated_Programme_Jour_Festivals( Groupe : Based108_Data.tGroupe ) return Based108_Data.Programme_Jour_Festival_List.Vector;

   --
   -- functions to add something to a criteria
   --
   procedure Add_Nom_Groupe( c : in out d.Criteria; Nom_Groupe : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Nom_Groupe( c : in out d.Criteria; Nom_Groupe : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Nom_Contact( c : in out d.Criteria; Nom_Contact : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Nom_Contact( c : in out d.Criteria; Nom_Contact : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Coord_Contact( c : in out d.Criteria; Coord_Contact : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Coord_Contact( c : in out d.Criteria; Coord_Contact : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Adr_Site( c : in out d.Criteria; Adr_Site : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Adr_Site( c : in out d.Criteria; Adr_Site : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Genre( c : in out d.Criteria; Genre : tgenre_Enum; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   --
   -- functions to add an ordering to a criteria
   --
   procedure Add_Nom_Groupe_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Nom_Contact_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Coord_Contact_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Adr_Site_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Genre_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
 
end Groupe_IO;
