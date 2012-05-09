--
-- Created by ada_generator.py on 2012-05-09 10:14:49.503709
-- 
with AUnit.Test_Suites; use AUnit.Test_Suites;

with Based108_Test;

function Suite return Access_Test_Suite is
        result : Access_Test_Suite := new Test_Suite;
begin
        Add_Test( result, new Based108_Test.test_Case ); -- Adrs_Data_Ada_Tests.Test_Case
        return result;
end Suite;
