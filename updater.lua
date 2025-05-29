local filesToUpdate = {
  {name = "mining/mining_utils.lua", url = "https://raw.githubusercontent.com/theBLUSpycrab/ComputerCraft/refs/heads/main/mining/mining_utils.lua"},
  {name = "mining/stripmine.lua", url = "https://raw.githubusercontent.com/theBLUSpycrab/ComputerCraft/refs/heads/main/mining/stripmine.lua"},
}

local function downloadFile(url, filename)
  local response = http.get(url)
  if response then
    local content = response.readAll()
    response.close()

    local file = fs.open(filename, "w")
    file.write(content)
    file.close()
    print("Downloaded: " .. filename)
    return true
  else
    print("Failed to download: " .. url)
    return false
  end
end

for _, fileData in ipairs(filesToUpdate) do
  if fs.exists(fileData.name) then
    fs.delete(fileData.name)
    print("Deleted old file: " .. fileData.name)
  end

  downloadFile(fileData.url, fileData.name)
end
