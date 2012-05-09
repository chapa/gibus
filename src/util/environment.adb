--
-- Created by ada_generator.py on 2012-05-09 10:14:48.817694
-- 
package body environment is
   
   SERVER_NAME     : constant String := "based108";
   USER_NAME       : constant String := "userd108";
   PASSWORD        : Constant String := "p08";


   function Get_Server_Name return String is
   begin
      return SERVER_NAME;
   end Get_Server_Name;
   
   function Get_Username return String is
   begin
      return USER_NAME;
   end Get_Username;
   
   function Get_Password return String is
   begin
      return PASSWORD;
   end Get_Password;

end environment;

