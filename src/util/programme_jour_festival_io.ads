--
-- Created by ada_generator.py on 2012-05-09 10:14:49.213407
-- 
with Based108_Data;
with db_commons;
with base_types;
with ADA.Calendar;
with Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
with Ada.Containers; use Ada.Containers;

package Programme_Jour_Festival_IO is
  
   package d renames db_commons;   
   use base_types;
   use Ada.Strings.Unbounded;
   
   function Next_Free_Jour_Fest return integer;

   --
   -- returns true if the primary key parts of Programme_Jour_Festival match the defaults in Based108_Data.Null_Programme_Jour_Festival
   --
   function Is_Null( Programme_Jour_Festival : Based108_Data.tProgramme_Jour_Festival ) return Boolean;
   
   --
   -- returns true if the container is empty
   --
   function Is_Empty( Programme_Jour_Festival_Liste : Based108_Data.Programme_Jour_Festival_List.Vector ) return Boolean;

   --
   -- returns number of items of the container 
   --

   function Card( Programme_Jour_Festival_Liste : Based108_Data.Programme_Jour_Festival_List.Vector ) return Count_Type;
  
   --
   -- returns the single Programme_Jour_Festival matching the primary key fields, or the Based108_Data.Null_Programme_Jour_Festival record
   -- if no such record exists
   --
   function Retrieve_By_PK( Nom_Groupe_Programme : Unbounded_String; Jour_Fest : integer ) return Based108_Data.tProgramme_Jour_Festival;
   
   --
   -- Retrieves a list of Based108_Data.tProgramme_Jour_Festival matching the criteria, or throws an exception
   --
   function Retrieve( c : d.Criteria ) return Based108_Data.Programme_Jour_Festival_List.Vector;
   
   --
   -- Retrieves a list of Based108_Data.tProgramme_Jour_Festival retrived by the sql string, or throws an exception
   --
   function Retrieve( sqlstr : String ) return Based108_Data.Programme_Jour_Festival_List.Vector;
   
   --
   -- Save the given record, overwriting if it exists and overwrite is true, 
   -- otherwise throws DB_Integrity_Violation exception. 
   --
   procedure Save( Programme_Jour_Festival : Based108_Data.tProgramme_Jour_Festival; overwrite : Boolean := True );
   
   --
   -- Delete the given record. Throws DB_Exception exception. Sets value to Based108_Data.Null_Programme_Jour_Festival
   --
   procedure Delete( Programme_Jour_Festival : in out Based108_Data.tProgramme_Jour_Festival );
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
   procedure Add_Nom_Groupe_Programme( c : in out d.Criteria; Nom_Groupe_Programme : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Nom_Groupe_Programme( c : in out d.Criteria; Nom_Groupe_Programme : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Jour_Fest( c : in out d.Criteria; Jour_Fest : integer; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Passage( c : in out d.Criteria; Passage : integer; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   --
   -- functions to add an ordering to a criteria
   --
   procedure Add_Nom_Groupe_Programme_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Jour_Fest_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Passage_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
 
end Programme_Jour_Festival_IO;
