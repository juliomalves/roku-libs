'
'    Cache
'
'    Examples:
'    @TODO
'

function CacheUtil(key as string, options = invalid as Dynamic) as Object
    algorithm = "sha1"
    storage = "cachefs:/"
    ttl = 5

    if options <> invalid then
        if options.algorithm <> invalid then algorithm = options.algorithm
        if options.storage <> invalid then storage = options.storage
        if options.ttl <> invalid then ttl = options.ttl
    end if

    ba = createObject("roByteArray")
    ba.fromAsciiString(key)
    digest = createObject("roEVPDigest")
    digest.setup(algorithm)
    cacheKey = digest.process(ba)

    return {
        _filePath: storage + cacheKey
        _ttl: ttl
        _separator: chr(10)

        _getNowTimeAsSeconds: function() as Integer
            date = createObject("roDateTime")
            return date.AsSeconds()
        end function

        match: function() as Boolean
            fs = createObject("roFileSystem")
            return fs.exists(m._filePath)
        end function

        put: function(value as String) as Boolean
            if value = invalid then return false

            stringToCache = m._getNowTimeAsSeconds().toStr() + m._separator + value
            return writeAsciiFile(m._filePath, stringToCache)
        end function

        delete: function() as Boolean
            fs = createObject("roFileSystem")
            return fs.delete(m._filePath)
        end function

        get: function() as Dynamic
            if not m.match() then return invalid

            cachedData = readAsciiFile(m._filePath)

            if cachedData = "" then
                m.delete()
                return invalid
            end if

            cachedArray = cachedData.split(m._separator)

            if cachedArray.count() <> 2 then
                m.delete()
                return invalid
            end if

            cachedValue = cachedArray[1]

            if cachedValue = invalid then
                m.delete()
                return invalid
            end if

            if m._ttl <> invalid then
                cachedTimestamp = cachedArray[0].toInt()
                nowTimestamp = m._getNowTimeAsSeconds()

                if cachedTimestamp + m._ttl < nowTimestamp then
                    m.delete()
                    return invalid
                end if
            end if

            return cachedValue
        end function
    }
end function
