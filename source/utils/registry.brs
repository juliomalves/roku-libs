'********************************************************************
'**  RegistryService
'********************************************************************

function RegistryUtil() as Object
    registry = {

        '** Writes value to Registry
        '@param key Registry section key
        '@param val value to write
        '@param section Registry section name
        write: function(key as String, val as String, section = "default" as String) as Void
            sec = createObject("roRegistrySection", section)
            sec.write(key, val)
            sec.flush()
        end function

        '** Reads value from Registry
        '@param key Registry section key
        '@param section Registry section name
        read: function(key as String, section = "default" as String) as Dynamic
            sec = createObject("roRegistrySection", section)
            if sec.exists(key) then return sec.read(key)
            return invalid
        end function

        '** Retrieve all entries in the specified section
        '@param section Registry section name
        readSection: function(section = "default" as String) as Object
            sec = createObject("roRegistrySection", section)
            aa = {}
            keyList = sec.getKeyList()
            for each key in keyList
                aa[key] = m.read(key, section)
            end for
            return aa
        end function

        '** Deletes key value from Registry
        '@param key Registry section key
        '@param section Registry section name
        delete: function(key as String, section = "default" as String) as Dynamic
            sec = createObject("roRegistrySection", section)
            if sec.exists(key) then return sec.delete(key)
            return invalid
        end function

        '** Deletes all key values from the specified section
        '@param section Registry section name
        deleteSection: function(section = "default" as String) as Boolean
            reg = createObject("roRegistry")
            return reg.delete(section)
        end function

        '** Deletes all sections from the registry
        '@param section Registry section name
        clear: function()
            sectionList = m.getSections()
            for each section in sectionList
                m.deleteSection(section)
            end for
        end function

        '** Retrieve all sections in the registry
        getSections: function() as Object
            reg = createObject("roRegistry")
            return reg.getSectionList()
        end function
    }

    return registry
end function
