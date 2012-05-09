--
-- Created by ada_generator.py on 2012-05-09 10:13:50.783675
-- 
package body base_types is

   function Slice_To_Unbounded( s : String; start : Positive; stop : Natural ) return Unbounded_String is
   begin
      return To_Unbounded_String( Slice( To_Unbounded_String( s ), start, stop ) );
   end Slice_To_Unbounded;


end base_types;
