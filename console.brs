'
'   console.brs
'
'
function ConsoleLib(var = invalid) as Object

    console = {

        _outputIdent: ""
        _timers: {}
        _groupLevel: 0

        log: function(msg)
            m._print(0, msg)
        end function

        info: function(msg)
            m._print(1, msg)
        end function

        error: function(msg)
            m._print(2, msg)
        end function

        assert: function(condition as Boolean, msg)
            if condition then m._print(3, msg)
        end function

        time: function(eventName as String)
            m._startTimer(eventName.trim())
            m.log(eventName + ": timer started")
        end function

        timeEnd: function(eventName)
            ellapsedTime = m._endTimer(eventName.trim())
            if ellapsedTime <> invalid then m.log(eventName + ": " + ellapsedTime + "ms")
        end function

        group: function()
            m._groupLevel = m._groupLevel + 1
        end function

        groupEnd: function()
            if m._groupLevel > 0 then m._groupLevel = m._groupLevel - 1
        end function

        _startTimer: function(event as String)
            m._timers[event] = createObject("roTimespan")
        end function

        _endTimer: function(event as String) as Dynamic
            if m._timers[event] = invalid then return invalid
            eventTime = m._timers[event].totalMilliseconds().toStr()
            m._timers.delete(event)
            return eventTime
        end function

        '** Gets current time
        '@return string with the following format: "HH:MM:SS:MMM"
        _getCurrentTime: function() as String
            now = CreateObject("roDateTime")
            now.ToLocalTime()

            hours% = now.GetHours()
            mins% = now.GetMinutes()
            seconds% = now.GetSeconds()
            millis% = now.GetMilliseconds()

            sHours$ = hours%.ToStr()
            if sHours$.Len() = 1  then sHours$ = "0" + sHours$

            sMins$ = mins%.ToStr()
            if sMins$.Len() = 1  then sMins$ = "0" + sMins$

            sSecs$ = seconds%.ToStr()
            if sSecs$.Len() = 1  then sSecs$ = "0" + sSecs$

            sMillis$ = millis%.ToStr()
            if sMillis$.Len() = 2  then sMillis$ = "0" + sMillis$
            if sMillis$.Len() = 1  then sMillis$ = "00" + sMillis$

            return sHours$ + ":" + sMins$ + ":" + sSecs$ + ":" + sMillis$
        end function

        _print: function(logLevel as Integer, output)
            print "[" + m._getCurrentTime() + "] "; m._getGroupIndent(); m._getLabelFromLogLevel(logLevel); output
        end function

        _getGroupIndent: function()
            ident = ""
            for i = 0 to m._groupLevel-1
                ident = ident + "    "
            end for
            return ident
        end function

        _getLabelFromLogLevel: function(logLevel as Integer) as String
            if logLevel = 1 then
                return "[INFO] "
            else if logLevel = 2 then
                return "[ERROR] "
            else if logLevel = 3 then
                return "[ASSERT] "
            else
                return ""
            end if
        end function
    }

    return console

end function
