--
-- Created by ada_generator.py on 2012-05-09 10:13:51.030596
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

with Jour_Festival_IO;
with Participant_Festival_IO;

with Logger;

package body Festival_IO is

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
         "ville_festival, date, lieu, prix_place " &
         "from festival " ;
   
   --
   -- Insert all variables; substring to be competed with output from some criteria
   --
   INSERT_PART : constant String := "insert into festival (" &
         "ville_festival, date, lieu, prix_place " &
         " ) values " ;

   
   --
   -- delete all the records identified by the where SQL clause 
   --
   DELETE_PART : constant String := "delete from festival ";
   
   --
   -- update
   --
   UPDATE_PART : constant String := "update festival set  ";
   
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
   -- returns true if the primary key parts of Festival match the defaults in Based108_Data.Null_Festival
   --
   --
   -- Does this Festival equal the default Based108_Data.Null_Festival ?
   --
   function Is_Null( Festival : Based108_Data.tFestival ) return Boolean is
   use Based108_Data;
   begin
      return Festival = Based108_Data.Null_Festival;
   end Is_Null;


   
   --
   -- returns true if the container is empty
   --
   --
   -- Does this Festival_List empty ?
   --
   function Is_Empty( Festival_Liste : Based108_Data.Festival_List.Vector ) return Boolean is
   use Based108_Data;
   begin
      return Festival_List.Is_Empty(Festival_Liste);
   end Is_Empty;



   --
   -- returns number of items of the container 
   --
   --
   -- return number of elements of Festival_List
   --
   function Card( Festival_Liste : Based108_Data.Festival_List.Vector ) return Count_Type is
   use Based108_Data;
   begin
      return Festival_List.Length(Festival_Liste);
   end Card;



   --
   -- returns the single Festival matching the primary key fields, or the Based108_Data.Null_Festival record
   -- if no such record exists
   --
   function Retrieve_By_PK( Ville_Festival : Unbounded_String ) return Based108_Data.tFestival is
      l : Based108_Data.Festival_List.Vector;
      Festival : Based108_Data.tFestival;
      c : d.Criteria;
   begin      
      Add_Ville_Festival( c, Ville_Festival );
      l := retrieve( c );
      if( not Based108_Data.Festival_List.is_empty( l ) ) then
         Festival := Based108_Data.Festival_List.First_Element( l );
      else
         Festival := Based108_Data.Null_Festival;
      end if;
      return Festival;
   end Retrieve_By_PK;

   
   --
   -- Retrieves a list of Based108_Data.tFestival matching the criteria, or throws an exception
   --
   function Retrieve( c : d.Criteria ) return Based108_Data.Festival_List.Vector is
   begin      
      return Retrieve( d.to_string( c ) );
   end Retrieve;

   
   --
   -- Retrieves a list of Based108_Data.tFestival retrived by the sql string, or throws an exception
   --
   function Retrieve( sqlstr : String ) return Based108_Data.Festival_List.Vector is
      type Timestamp_Access is access all SQL_TIMESTAMP_STRUCT;
      type Real_Access is access all Real;
      type String_Access is access all String;

      l : Based108_Data.Festival_List.Vector;
      ps : SQLHDBC := SQL_NULL_HANDLE;
      has_data : Boolean := false;
      connection : dodbc.Database_Connection := get_connection;
      query : constant String := SELECT_PART & " " & sqlstr;
      --
      -- aliased local versions of fields 
      --
      Ville_Festival: aliased String := 
            "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@";
      Date: aliased SQL_TIMESTAMP_STRUCT;
      Lieu: aliased String := 
            "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" &
            "@@@@@@@@@@@@@@@@@@@@@@@@@@@@";
      Prix_Place: aliased integer;
      --
      -- access variables for any variables retrieved via access types
      --
      Ville_Festival_access : String_Access := Ville_Festival'access;
      Date_access : Timestamp_Access := Date'access;
      Lieu_access : String_Access := Lieu'access;
      --
      -- length holders for each retrieved variable
      --
      Ville_Festival_len : aliased SQLINTEGER := Ville_Festival'Size;
      Date_len : aliased SQLINTEGER := Date'Size;
      Lieu_len : aliased SQLINTEGER := Lieu'Size;
      Prix_Place_len : aliased SQLINTEGER := Prix_Place'Size;
      Festival : Based108_Data.tFestival;
   begin
      logger.info( "retrieve made this as query " & query );
      begin -- exception block
         ps := dodbc.Initialise_Prepared_Statement( connection.connection, query );       
         SQLBindCol(
            StatementHandle  => ps,
            ColumnNumber     => 1,
            TargetType       => SQL_C_CHAR,
            TargetValuePtr   => To_SQLPOINTER( Ville_Festival_access.all'address ),
            BufferLength     => Ville_Festival_len,
            StrLen_Or_IndPtr => Ville_Festival_len'access );
         SQLBindCol(
            StatementHandle  => ps,
            TargetType       => SQL_C_TYPE_TIMESTAMP,
            ColumnNumber     => 2,
            TargetValuePtr   => To_SQLPOINTER( Date_access.all'address ),
            BufferLength     => 0,
            StrLen_Or_IndPtr => Date_len'access );
         SQLBindCol(
            StatementHandle  => ps,
            ColumnNumber     => 3,
            TargetType       => SQL_C_CHAR,
            TargetValuePtr   => To_SQLPOINTER( Lieu_access.all'address ),
            BufferLength     => Lieu_len,
            StrLen_Or_IndPtr => Lieu_len'access );
         dodbc.I_Out_Binding.SQLBindCol(
            StatementHandle  => ps,
            ColumnNumber     => 4,
            TargetValue      => Prix_Place'access,
            IndPtr           => Prix_Place_len'access );
         SQLExecute( ps );
         loop
            dodbc.next_row( ps, has_data );
            if( not has_data ) then
               exit;
            end if;
            Festival.Ville_Festival := Slice_To_Unbounded( Ville_Festival, 1, Natural( Ville_Festival_len ) );
            Festival.Date:= dodbc.Timestamp_To_Ada_Time( Date_access.all );
            Festival.Lieu := Slice_To_Unbounded( Lieu, 1, Natural( Lieu_len ) );
            Festival.Prix_Place := Prix_Place;
            Based108_Data.Festival_List.append( l, Festival );        
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
   procedure Update( Festival : Based108_Data.tFestival ) is
      ps : sql.SQLHDBC := sql.SQL_NULL_HANDLE;
      connection : dodbc.Database_Connection := get_connection;
      query : Unbounded_String := UPDATE_PART & To_Unbounded_String(" ");
      pk_c : d.Criteria;
      values_c : d.Criteria;
   begin
      --
      -- values to be updated
      --
      Add_Date( values_c, Festival.Date );
      Add_Lieu( values_c, Festival.Lieu );
      Add_Prix_Place( values_c, Festival.Prix_Place );
      --
      -- primary key fields
      --
      Add_Ville_Festival( pk_c, Festival.Ville_Festival );
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
   procedure Save( Festival : Based108_Data.tFestival; overwrite : Boolean := True ) is   
      ps : sql.SQLHDBC := sql.SQL_NULL_HANDLE;
      connection : dodbc.Database_Connection;
      query : Unbounded_String := INSERT_PART & To_Unbounded_String(" ");
      c : d.Criteria;
      Festival_Tmp : Based108_Data.tFestival;
   begin
      if( overwrite ) then
         Festival_Tmp := retrieve_By_PK( Festival.Ville_Festival );
         if( not is_Null( Festival_Tmp )) then
            Update( Festival );
            return;
         end if;
      end if;
      Add_Ville_Festival( c, Festival.Ville_Festival );
      Add_Date( c, Festival.Date );
      Add_Lieu( c, Festival.Lieu );
      Add_Prix_Place( c, Festival.Prix_Place );
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
   -- Delete the given record. Throws DB_Exception exception. Sets value to Based108_Data.Null_Festival
   --

   procedure Delete( Festival : in out Based108_Data.tFestival ) is
         c : d.Criteria;
   begin  
      Add_Ville_Festival( c, Festival.Ville_Festival );
      delete( c );
      Festival := Based108_Data.Null_Festival;
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
   function Retrieve_Associated_Jour_Festivals( Festival : Based108_Data.tFestival ) return Based108_Data.Jour_Festival_List.Vector is
      c : d.Criteria;
   begin
      Jour_Festival_IO.Add_Festival( c, Festival.Ville_Festival );
      return Jour_Festival_IO.retrieve( c );
   end Retrieve_Associated_Jour_Festivals;


   function Retrieve_Associated_Participant_Festivals( Festival : Based108_Data.tFestival ) return Based108_Data.Participant_Festival_List.Vector is
      c : d.Criteria;
   begin
      Participant_Festival_IO.Add_Festival( c, Festival.Ville_Festival );
      return Participant_Festival_IO.retrieve( c );
   end Retrieve_Associated_Participant_Festivals;



   --
   -- functions to add something to a criteria
   --
   procedure Add_Ville_Festival( c : in out d.Criteria; Ville_Festival : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "ville_festival", op, join, To_String( Ville_Festival ), 45 );
   begin
      d.add_to_criteria( c, elem );
   end Add_Ville_Festival;


   procedure Add_Ville_Festival( c : in out d.Criteria; Ville_Festival : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "ville_festival", op, join, Ville_Festival, 45 );
   begin
      d.add_to_criteria( c, elem );
   end Add_Ville_Festival;


   procedure Add_Date( c : in out d.Criteria; Date : Ada.Calendar.Time; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "date", op, join, Date );
   begin
      d.add_to_criteria( c, elem );
   end Add_Date;


   procedure Add_Lieu( c : in out d.Criteria; Lieu : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "lieu", op, join, To_String( Lieu ), 100 );
   begin
      d.add_to_criteria( c, elem );
   end Add_Lieu;


   procedure Add_Lieu( c : in out d.Criteria; Lieu : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "lieu", op, join, Lieu, 100 );
   begin
      d.add_to_criteria( c, elem );
   end Add_Lieu;


   procedure Add_Prix_Place( c : in out d.Criteria; Prix_Place : integer; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "prix_place", op, join, Prix_Place );
   begin
      d.add_to_criteria( c, elem );
   end Add_Prix_Place;


   
   --
   -- functions to add an ordering to a criteria
   --
   procedure Add_Ville_Festival_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "ville_festival", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_Ville_Festival_To_Orderings;


   procedure Add_Date_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "date", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_Date_To_Orderings;


   procedure Add_Lieu_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "lieu", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_Lieu_To_Orderings;


   procedure Add_Prix_Place_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "prix_place", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_Prix_Place_To_Orderings;


   
end Festival_IO;
