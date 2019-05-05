--AutoUpdate for your script!
--Is required:
    --> File .Version
--When creating and defining the version of the file, you can use this example function:

local Version_File = "1.0" --You should get the same version as the .version file.

function AutoUpdate(data) --By: Deftsu
    if tonumber(data) > tonumber(Version_File) then --API Lua: tonumber
        PrintChat("<font color='#00ffff'>New version found!"  .. data)
        PrintChat("<font color='#00ffff'>Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/TTulio1/Gaming-On-Steroids-/master/AutoUpdateFile/AutoUpdateFile.lua", SCRIPT_PATH .. "AutoUpdateFile.lua", function() PrintChat("<font color='#00ffff'>Update Complete, please 2x F6!") return end)
    else
        PrintChat("<font color='#00ffff'>No updates found!")
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/TTulio1/Gaming-On-Steroids-/master/AutoUpdateFile/AutoUpdateFile.version", AutoUpdate)

--^^ This has several scripts and can be used by everyone!
--All this is provided by the GoS API itself, not all platforms contain this!
