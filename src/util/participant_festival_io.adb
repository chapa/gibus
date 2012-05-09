--
-- Created by ada_generator.py on 2012-05-09 10:13:51.109727
-- 
with Based108_Data;


with Ada.Containers.Vectors;
with Ada.Containers; use Ada.Containers;

with environment;

with db_commons; 
with db_commons.odbc; 

with GNU.DB.SQLCLI;  
with GNU.DB.SQLCLI.Bind;
with GNU.DB.SQLCLI.Info;
with GNU.DB.SQLCLI.Environment_Attribute;
with GNU.DB.SQLCLI.Connection_Attribute;

with Ada.Exceptions;  
with Ada.Strings; 
with Ada.Strings.Wide_Fixed;
with Ada.Characters.Conversions;
with Ada.Strings.Unbounded; 
with text_io;
with Ada.Strings.Maps;


with Logger;

package body Participant_Festival_IO is

   use Ada.Strings.Unbounded;
   use Ada.Exceptions;
   use Ada.Strings;

   package dodbc renames db_commons.odbc;
   package sql renames GNU.DB.SQLCLI;
   package sql_info renames GNU.DB.SQLCLI.Info;
   use sql;
   use base_types;
   --
   -- generic packages to handle each possible type of decimal, if any, go here
   --
   
   --
   -- Select all variables; substring to be competed with output from some criteria
   --
   SELECT_PART : constant String := "select " &
         "nom_groupe_inscrit, festival, gagnant " &
         "from participant_festival " ;
   
   --
   -- Insert all variables; substring to be competed with output from some criteria
   --
   INSERT_PART : constant String := "insert into participant_festival (" &
         "nom_groupe_inscrit, festival, gagnant " &
         " ) values " ;

   
   --
   -- delete all the records identified by the where SQL clause 
   --
   DELETE_PART : constant String := "delete from participant_festival ";
   
   --
   -- update
   --
   UPDATE_PART : constant String := "update participant_festival set  ";
   
   function get_connection return dodbc.Database_Connection is
      use dodbc;
      con : dodbc.Database_Connection := dodbc.Null_Database_Connection;
   begin
      con := dodbc.connect( 
            environment.Get_Server_Name, 
            environment.Get_Username, 
            environment.Get_Password );
      return con;
      exception 
      when Error : others =>  
         Logger.error( "exception " & Exception_Information(Error) ); 
         Raise_Exception( d.DB_Exception'Identity, 
            "getConnection: exception thrown " & Exception_Information(Error) );
   end get_connection;
   

   --
   -- returns true if the primary key parts of Participant_Festival match the defaults in Based108_Data.Null_Participant_Festival
   --
   --
   -- Does this Participant_Festival equal the default Based108_Data.Null_Participant_Festival ?
   --
   function Is_Null( Participant_Festival : Based108_Data.tParticipant_Festival ) return Boolean is
   use Based108_Data;
   begin
      return Participant_Festival = Based108_Data.Null_Participant_Festival;
   end Is_Null;


   
   --
   -- returns true if the container is empty
   --
   --
   -- Does this Participant_Festival_List empty ?
   --
   function Is_Empty( Participant_Festival_Liste : Based108_Data.Participant_Festival_List.Vector ) return Boolean is
   use Based108_Data;
   begin
      return Participant_Festival_List.Is_Empty(Participant_Festival_Liste);
   end Is_Empty;



   --
   -- returns number of items of the container 
   --
   --
   -- return number of elements of Participant_Festival_List
   --
   function Card( Participant_Festival_Liste : Based108_Data.Participant_Festival_List.Vector ) return Count_Type is
   use Based108_Data;
   begin
      return Participant_Festival_List.Length(Participant_Festival_Liste);
   end Card;



   --
   -- returns the single Participant_Festival matching the primary key fields, or the Based108_Data.Null_Participant_Festival record
   -- if no such record exists
   --
   function Retrieve_By_PK( Nom_Groupe_Inscrit : Unbounded_String; Festival : Unbounded_String ) return Based108_Data.tParticipant_Festival is
      l : Based108_Data.Participant_Festival_List.Vector;
      Participant_Festival : Based108_Data.tParticipant_Festival;
      c : d.Criteria;
   begin      
      Add_Nom_Groupe_Inscrit( c, Nom_Groupe_Inscrit );
      Add_Festival( c, Festival );
      l := retrieve( c );
      if( not Based108_Data.Participant_Festival_List.is_empty( l ) ) then
         Participant_Festival := Based108_Data.Participant_Festival_List.First_Element( l );
      else
         Participant_Festival := Based108_Data.Null_Participant_Festival;
      end if;
      return Participant_Festival;
   end Retrieve_By_PK;

   
   --
   -- Retrieves a list of Based108_Data.tParticipant_Festival matching the criteria, or throws an exception
   --
   function Retrieve( c : d.Criteria ) return Based108_Data.Participant_Festival_List.Vector is
   begin      
      return Retrieve( d.to_string( c ) );
   end Retrieve;

   
   --
   -- Retrieves a list of Based108_Data.tParticipant_Festival retrived by the sql string, or throws an exception
   --
   function Retrieve( sqlstr : String ) return Based108_Data.Participant_Festival_List.Vector is
      type Timestamp_Access is access all SQL_TIMESTAMP_STRUCT;
      type Real_Access is access all Real;
      type String_Access is access all String;

      l : Based108_Data.Participant_Festival_List.Vector;
      ps : SQLHDBC := SQL_NULL_HANDLE;
      has_data : Boolean := false;
      connection : dodbc.Database_Connection := get_connection;
      query : constant String := SELECT_PART & " " & sqlstr;
      --
      -- aliased local versions of fields 
      --
      Nom_Groupe_Inscrit: aliased String := 
            "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" &
            "@@@@@@@@@@@@@@@@@@@@@@@@@@@@";
      Festival: aliased String := 
            "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@";
      Gagnant: aliased Integer;
      --
      -- access variables for any variables retrieved via access types
      --
      Nom_Groupe_Inscrit_access : String_Access := Nom_Groupe_Inscrit'access;
      Festival_access : String_Access := Festival'access;
      --
      -- length holders for each retrieved variable
      --
      Nom_Groupe_Inscrit_len : aliased SQLINTEGER := Nom_Groupe_Inscrit'Size;
      Festival_len : aliased SQLINTEGER := Festival'Size;
      Gagnant_len : aliased SQLINTEGER := Gagnant'Size;
      Participant_Festival : Based108_Data.tParticipant_Festival;
   begin
      logger.info( "retrieve made this as query " & query );
      begin -- exception block
         ps := dodbc.Initialise_Prepared_Statement( connection.connection, query );       
         SQLBindCol(
            StatementHandle  => ps,
            ColumnNumber     => 1,
            TargetType       => SQL_C_CHAR,
            TargetValuePtr   => To_SQLPOINTER( Nom_Groupe_Inscrit_access.all'address ),
            BufferLength     => Nom_Groupe_Inscrit_len,
            StrLen_Or_IndPtr => Nom_Groupe_Inscrit_len'access );
         SQLBindCol(
            StatementHandle  => ps,
            ColumnNumber     => 2,
            TargetType       => SQL_C_CHAR,
            TargetValuePtr   => To_SQLPOINTER( Festival_access.all'address ),
            BufferLength     => Festival_len,
            StrLen_Or_IndPtr => Festival_len'access );
         dodbc.I_Out_Binding.SQLBindCol(
            StatementHandle  => ps,
            ColumnNumber     => 3,
            TargetValue      => Gagnant'access,
            IndPtr           => Gagnant_len'access );
         SQLExecute( ps );
         loop
            dodbc.next_row( ps, has_data );
            if( not has_data ) then
               exit;
            end if;
            Participant_Festival.Nom_Groupe_Inscrit := Slice_To_Unbounded( Nom_Groupe_Inscrit, 1, Natural( Nom_Groupe_Inscrit_len ) );
            Participant_Festival.Festival := Slice_To_Unbounded( Festival, 1, Natural( Festival_len ) );
            Participant_Festival.Gagnant := Boolean'Val( Gagnant );
            Based108_Data.Participant_Festival_List.append( l, Participant_Festival );        
         end loop;
         logger.info( "retrieve: Query Run OK" );
      exception 
         when No_Data => Null; 
         when Error : others =>
            --Raise_Exception( d.DB_Exception'Identity, 
              -- "retrieve: exception " & Exception_Information(Error) );
		Reraise_Occurrence(Error);

      end; -- exception block
      begin
         dodbc.Close_Prepared_Statement( ps );
         dodbc.Disconnect( connection );
      exception 
         when Error : others =>
         --   Raise_Exception( d.DB_Exception'Identity, 
           --    "retrieve: exception " & Exception_Information(Error) );
	Reraise_Occurrence(Error);

      end; -- exception block
      return l;
   end Retrieve;

   
   --
   -- Update the given record 
   -- otherwise throws DB_Exception exception. 
   --
   procedure Update( Participant_Festival : Based108_Data.tParticipant_Festival ) is
      ps : sql.SQLHDBC := sql.SQL_NULL_HANDLE;
      connection : dodbc.Database_Connection := get_connection;
      query : Unbounded_String := UPDATE_PART & To_Unbounded_String(" ");
      pk_c : d.Criteria;
      values_c : d.Criteria;
   begin
      --
      -- values to be updated
      --
      Add_Gagnant( values_c, Participant_Festival.Gagnant );
      --
      -- primary key fields
      --
      Add_Nom_Groupe_Inscrit( pk_c, Participant_Festival.Nom_Groupe_Inscrit );
      Add_Festival( pk_c, Participant_Festival.Festival );
      query := query & d.To_String( values_c, "," ) & d.to_string( pk_c );
      Logger.info( "update; executing query" & To_String(query) );
      begin -- exception block      
         ps := dodbc.Initialise_Prepared_Statement( connection.connection, query );       
         SQLExecute( ps );
         Logger.info( "update; execute query OK" );
      exception 
         when No_Data => Null; -- ignore if no updates made
         when Error : others =>
            Logger.error( "update: failed with message " & Exception_Information(Error)  );
            -- Raise_Exception( d.DB_Exception'Identity, 
               -- "update: exception thrown " & Exception_Information(Error) );
	Reraise_Occurrence(Error);

      end; -- exception block
      dodbc.Close_Prepared_Statement( ps );
      dodbc.Disconnect( connection );
   end Update;


   --
   -- Save the compelete given record 
   -- otherwise throws DB_Integrity_Violation exception. 
   --
   procedure Save( Participant_Festival : Based108_Data.tParticipant_Festival; overwrite : Boolean := True ) is   
      ps : sql.SQLHDBC := sql.SQL_NULL_HANDLE;
      connection : dodbc.Database_Connection;
      query : Unbounded_String := INSERT_PART & To_Unbounded_String(" ");
      c : d.Criteria;
      Participant_Festival_Tmp : Based108_Data.tParticipant_Festival;
   begin
      if( overwrite ) then
         Participant_Festival_Tmp := retrieve_By_PK( Participant_Festival.Nom_Groupe_Inscrit, Participant_Festival.Festival );
         if( not is_Null( Participant_Festival_Tmp )) then
            Update( Participant_Festival );
            return;
         end if;
      end if;
      Add_Nom_Groupe_Inscrit( c, Participant_Festival.Nom_Groupe_Inscrit );
      Add_Festival( c, Participant_Festival.Festival );
      Add_Gagnant( c, Participant_Festival.Gagnant );
      query := query & "( "  & d.To_Crude_Array_Of_Values( c ) & " )";
      Logger.info( "save; executing query" & To_String(query) );
      begin
         connection := get_connection;
         ps := dodbc.Initialise_Prepared_Statement( connection.connection, query );       
         SQLExecute( ps );
         Logger.info( "save; execute query OK" );
         
      exception 
         when Error : others =>
            Logger.error( "save; execute query failed with message " & Exception_Information(Error)  );
            Reraise_Occurrence(Error);
      end;
      begin
         dodbc.Close_Prepared_Statement( ps );
         dodbc.Disconnect( connection );
      exception 
         when Error : others =>
            Logger.error( "save/close " & Exception_Information(Error)  );
            Raise_Exception( d.DB_Exception'Identity, 
               "save/close: exception " & Exception_Information(Error) );
      end;
      
   end Save;


   
   --
   -- Delete the given record. Throws DB_Exception exception. Sets value to Based108_Data.Null_Participant_Festival
   --

   procedure Delete( Participant_Festival : in out Based108_Data.tParticipant_Festival ) is
         c : d.Criteria;
   begin  
      Add_Nom_Groupe_Inscrit( c, Participant_Festival.Nom_Groupe_Inscrit );
      Add_Festival( c, Participant_Festival.Festival );
      delete( c );
      Participant_Festival := Based108_Data.Null_Participant_Festival;
      Logger.info( "delete record; execute query OK" );
   end Delete;


   --
   -- delete the records indentified by the criteria
   --
   procedure Delete( c : d.Criteria ) is
   begin      
      delete( d.to_string( c ) );
      Logger.info( "delete criteria; execute query OK" );
   end Delete;
   
   procedure Delete( where_Clause : String ) is
      ps : sql.SQLHDBC := sql.SQL_NULL_HANDLE;
      connection : dodbc.Database_Connection;
      query : Unbounded_String := DELETE_PART & To_Unbounded_String(" ");
   begin
      query := query & where_Clause;
      begin -- try catch block for execute
         Logger.info( "delete; executing query" & To_String(query) );
         connection := get_connection;
         ps := dodbc.Initialise_Prepared_Statement( connection.connection, query );       
         SQLExecute( ps );
         Logger.info( "delete; execute query OK" );
      exception 
         when Error : No_Data => Null; -- silently ignore no data exception, which is hardly exceptional
         when Error : others =>
            Logger.error( "delete; execute query failed with message " & Exception_Information(Error)  );
            -- Raise_Exception( d.DB_Exception'Identity, 
               -- "delete: exception thrown " & Exception_Information(Error) );
	Reraise_Occurrence(Error);

      end;
      begin -- try catch block for close
         dodbc.Close_Prepared_Statement( ps );
         dodbc.Disconnect( connection );
      exception 
         when Error : others =>
            Logger.error( "delete; execute query failed with message " & Exception_Information(Error)  );
            --Raise_Exception( d.DB_Exception'Identity, 
              -- "delete: exception thrown " & Exception_Information(Error) );
	Reraise_Occurrence(Error);

      end;
   end Delete;


   --
   -- functions to retrieve records from tables with foreign keys
   -- referencing the table modelled by this package
   --

   --
   -- functions to add something to a criteria
   --
   procedure Add_Nom_Groupe_Inscrit( c : in out d.Criteria; Nom_Groupe_Inscrit : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "nom_groupe_inscrit", op, join, To_String( Nom_Groupe_Inscrit ), 100 );
   begin
      d.add_to_criteria( c, elem );
   end Add_Nom_Groupe_Inscrit;


   procedure Add_Nom_Groupe_Inscrit( c : in out d.Criteria; Nom_Groupe_Inscrit : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "nom_groupe_inscrit", op, join, Nom_Groupe_Inscrit, 100 );
   begin
      d.add_to_criteria( c, elem );
   end Add_Nom_Groupe_Inscrit;


   procedure Add_Festival( c : in out d.Criteria; Festival : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "festival", op, join, To_String( Festival ), 45 );
   begin
      d.add_to_criteria( c, elem );
   end Add_Festival;


   procedure Add_Festival( c : in out d.Criteria; Festival : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "festival", op, join, Festival, 45 );
   begin
      d.add_to_criteria( c, elem );
   end Add_Festival;


   procedure Add_Gagnant( c : in out d.Criteria; Gagnant : boolean; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "gagnant", op, join, boolean'Pos( Gagnant ) );
   begin
      d.add_to_criteria( c, elem );
   end Add_Gagnant;


   
   --
   -- functions to add an ordering to a criteria
   --
   procedure Add_Nom_Groupe_Inscrit_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "nom_groupe_inscrit", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_Nom_Groupe_Inscrit_To_Orderings;


   procedure Add_Festival_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "festival", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_Festival_To_Orderings;


   procedure Add_Gagnant_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "gagnant", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_Gagnant_To_Orderings;


   
end Participant_Festival_IO;
