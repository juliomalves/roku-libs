sub main(args as Dynamic)
    console = ConsoleUtil()
    console.log("Hello World")

    if args.RunTests <> invalid and type(TestRunner) = "Function" then
        runner = TestRunner()
        runner.setFunctions([
            TestSuite__GoogleAnalytics,
            TestSuite__HttpRequest,
            TestSuite__Array,
            TestSuite__Math
            TestSuite__String
        ])
        runner.logger.PrintStatistic = customPrintStatistic
        runner.run()
    end if
end sub

' Override built-in PrintStatistic function
sub customPrintStatistic(statObj as Object)
    ? "*** Starting all test suites"
    ? ""
    for each testSuite in statObj.Suites
        ? "   "; iif(testSuite.Fail > 0 or testSuite.Crash > 0, "[FAIL] ", "[PASS] "); testSuite.Name; " "
        for each testCase in testSuite.Tests
            if testCase.Result = "Fail" then
                ? "    ✕ "; testCase.Name
                ? "         FAIL: "; testCase.Error.Message
            else if testCase.Result = "Skipped" then
                ? "    - "; testCase.Name
                ? "         SKIP: "; testCase.message
            else
                ? "    ✓ "; testCase.Name
            end if
        end for
        ? ""
    end for
    ? "   Tests:"; iif(statObj.Fail > 0, " " + statObj.Fail.toStr() + " failed,", ""); statObj.Correct; " passed,"; iif(statObj.skipped > 0, " " + statObj.skipped.toStr() + " skipped,", ""); iif(statObj.Crash > 0, " " + statObj.Crash.toStr() + " crashed,", ""); statObj.Total; " total"
    ? "   Time:"; statObj.Time; "ms"
    ? ""
    ? "*** Ran all test suites."
end sub

function iif(condition as Boolean, ifTrue, ifFalse) as Dynamic
    if condition then return ifTrue
    return ifFalse
end function
