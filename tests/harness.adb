--
-- Created by ada_generator.py on 2012-05-09 10:13:51.408178
-- 
with Suite;

-- with AUnit.Run;
-- with AUnit.Reporter.Text;

with AUnit.Test_results.text_reporter;
with AUnit.Test_runner ;

procedure Harness is
-- procedure RunTestSuite is new AUnit.Run.Test_Runner( Suite );
-- reporter : AUnit.Reporter.Text.Text_Reporter;

   procedure RunTestSuite is new AUnit.Test_Runner( Suite );
   
begin
--   RunTestSuite( reporter );
   RunTestSuite ;
end Harness;
