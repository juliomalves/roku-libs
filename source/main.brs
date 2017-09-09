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
            if testCase.result = "Fail" then
                ? "   >> "; testCase.Result; " - "; testCase.Name
                ? "         Error Message: "; testCase.Error.Message
            else
                ? "      "; testCase.Result; " - "; testCase.Name
            end if
        end for
        ? ""
        ? "      Test Suite Total ="; testSuite.Total; " ; Passed ="; testSuite.Correct; " ; Failed ="; testSuite.Fail; " ; Crashes ="; testSuite.Crash; "; Time spent:"; testSuite.Time; "ms"
        ? ""
    end for
    ? ""
    ? "   Tests Total ="; statObj.Total; " ; Passed ="; statObj.Correct; " ; Failed ="; statObj.Fail; " ; Crashes ="; statObj.Crash; "; Time spent:"; statObj.Time; "ms"
    ? ""
    ? "*************             End testing                *************"
end sub
