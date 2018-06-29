sub main(args as Dynamic)
    console = ConsoleUtil()
    console.log("Hello World")

    if args.RunTests <> invalid and type(TestRunner) = "Function" then
        runner = TestRunner()
        runner.logger.PrintStatistic = customPrintStatistic
        runner.run()
    end if
end sub

' Override built-in PrintStatistic function
sub customPrintStatistic(statObj as Object)
    ? "*************            Start testing               *************"
    ? ""
    for each testSuite in statObj.Suites
        ? "   "; testSuite.Name; ": "
        for each testCase in testSuite.Tests
            if testCase.Result = "Fail" then
                ? "   >> "; testCase.Result; " - "; testCase.Name
                ? "         Error Message: "; testCase.Error.Message
            else if testCase.Result = "Skipped" then
                ? "   -- "; testCase.Result; " - "; testCase.Name
                ? "         Skip Message: "; testCase.message
            else
                ? "      "; testCase.Result; " - "; testCase.Name
            end if
        end for
        ? ""
        ? "      Test Suite Total ="; testSuite.Total; " ; Passed ="; testSuite.Correct; " ; Failed ="; testSuite.Fail; " ; Skipped ="; testSuite.skipped; " ; Crashes ="; testSuite.Crash; "; Time spent:"; testSuite.Time; "ms"
        ? ""
    end for
    ? ""
    ? "   Tests Total ="; statObj.Total; " ; Passed ="; statObj.Correct; " ; Failed ="; statObj.Fail; " ; Skipped ="; statObj.skipped; " ; Crashes ="; statObj.Crash; "; Time spent:"; statObj.Time; "ms"
    ? ""
    ? "*************             End testing                *************"
end sub
