
concommand.Add("FindMostComplicatedBrushes", function(player, command, arguments)
	local map, count = arguments[1], tonumber(arguments[2])

	-- Prepare the map name and brush count
	if (!map) then
		MsgC(Color(255, 100, 100), "Invalid map. (Ex: gm_construct.vmf 10)\n")

		return
	end

	map = string.lower(map)

	local extension = string.GetExtensionFromFilename(map)

	if (extension) then
		if (extension != "vmf") then
			MsgC(Color(255, 100, 100), "Invalid map. (Ex: gm_construct.vmf 10)\n")

			return
		end
	else
		map = map .. ".vmf"
	end

	if (!count or count < 1) then
		MsgC(Color(255, 100, 100), "Invalid brush count. (Ex: gm_construct.vmf 10)\n")

		return
	end

	local vmfInfo = file.Read(map, "DATA") -- Get the VMF file from the data folder in txt form

	if (!vmfInfo) then
		MsgC(Color(255, 100, 100), "Invalid map. (Ex: gm_construct.vmf 10)\n")

		return
	end

	vmfInfo = "vmf\n{" .. vmfInfo .. "\n}" -- Add the required formatting to the VMF

	local kvTable = util.KeyValuesToTablePreserveOrder(vmfInfo) -- Convert to a table
	local brushes = {}

	-- Loop through the table and find all the materials from solids and entities
	for _, v in pairs(kvTable) do
		if (v.Key != "world" and v.Key != "entity") then continue end

		for _, v2 in pairs(v.Value) do
			if (v2.Key != "solid" or !istable(v2.Value)) then continue end

			local brushID
			local sideCount = 0

			for _, v3 in pairs(v2.Value) do
				if (v3.Key != "side") then
					if (v3.Key == "id") then
						brushID = v3.Value
					end

					continue
				end

				sideCount = sideCount + 1
			end

			if (brushID and sideCount > 0) then
				brushes[brushID] = sideCount
			end
		end
	end

	local sortedBrushes = {}

	for k, v in pairs(brushes) do
		table.insert(sortedBrushes, {brush = k, count = v})
	end

	-- Sort the brushes by face count
	table.sort(sortedBrushes, function(a, b) return a.count > b.count end)

	-- Print the top brushes with the most faces
	MsgC(Color(200, 200, 50), "TOP " .. count .. " MOST COMPLICATED BRUSHES IN " .. string.upper(string.StripExtension(map)) .. ":\n")
	MsgC(Color(200, 150, 100), "==================================================\n")

	for i = 1, count do
		local brush = sortedBrushes[i]

		MsgC(Color(200, 200, 100), string.format("%-5s ", brush.brush), color_white, string.rep(".", 50 - #tostring(brush.brush)), Color(100, 150, 255), " " .. brush.count .. " FACES", "\n") -- Overcomplicated formatting to make it look nicer
	end
end, nil, "Outputs the most complicated brushes in a .vmf file.")
