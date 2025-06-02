local dhcp_type = Field.new("dhcp.option.dhcp")
local dhcp_hw = Field.new("dhcp.hw.mac_addr")
local dhcp_req_ip = Field.new("dhcp.option.requested_ip_address")
local dhcp_txid = Field.new("dhcp.id")


-- This program will register a menu that will open a window with a count of occurrences
-- of every address in the capture
local function menuable_tap()

	-- Declare the window we will use
	local tw = TextWindow.new("DHCP TX Counter")

    local txids = {}
	-- this is our tap
	local tap = Listener.new();

	local function remove()
		-- this way we remove the listener that otherwise will remain running indefinitely
		tap:remove();
	end

	-- we tell the window to call the remove() function when closed
	tw:set_atclose(remove)

	-- this function will be called once for each packet
	function tap.packet(pinfo,tvb)
 		local txid_field = dhcp_txid()
		local dhcptype = dhcp_type()
		local dhcp_hw_field = dhcp_hw()
		local dhcp_req_ip_field = dhcp_req_ip()
		if txid_field and dhcptype then

			-- we need to convert the txid to a string
			local txid = string.format("0x%08x", tonumber( tostring(txid_field.value) ) )
			
		
			
			txids[txid] = txids[txid] or {}
			local bucket = txids[txid]
			-- if we have a hw address, we will store it
			if dhcp_hw_field and not bucket["HW"]  then
				bucket["HW"] = tostring(dhcp_hw_field.value)
			end
			-- if we have a requested ip address, we will store it
			if dhcp_req_ip_field and not txids[txid]["REQIP"] then
				bucket["REQIP"] = tostring(dhcp_req_ip_field.value)
			end

			dhcptype = dhcptype.value

			local label = "ERROR_PARSED"
			if dhcptype == 1 then
				label = "DHCPDISCOVER" 
			elseif dhcptype == 2 then
				label = "DHCPOFFER"
			elseif dhcptype == 3 then
				 label = "DHCPREQUEST"
			elseif dhcptype == 4 then
				 label = "DHCPDECLINE"
			elseif dhcptype == 5 then
				 label = "DHCPACK"
			elseif dhcptype == 6 then
				 label = "DHCPNAK"
			elseif dhcptype == 7 then
				 label = "DHCPRELEASE"
			elseif dhcptype == 8 then
				 label = "DHCPINFORM"
			elseif dhcptype == 9 then
				 label = "DHCPFORCERENEW"
			elseif dhcptype == 10 then
				 label = "DHCPLEASEQUERY"
			elseif dhcptype == 11 then
				 label = "DHCPLEASEUNASSIGNED"
			elseif dhcptype == 12 then
				 label = "DHCPLEASEUNKNOWN"
			elseif dhcptype == 13 then
				 label = "DHCPLEASEACTIVE"
			elseif dhcptype == 14 then
				 label = "DHCPBULKLEASEQUERY"
			elseif dhcptype == 15 then
				 label = "DHCPLEASEQUERYDONE"
			elseif dhcptype == 16 then
				 label = "DHCPACTIVELEASEQUERY"
			elseif dhcptype == 17 then
				 label = "DHCPLEASEQUERYSTATUS"
			elseif dhcptype == 18 then
				 label = "DHCPTLS"
			end
			local count = txids[txid][label] or 0
			bucket[label] = count + 1
		end
	end
	local textBuffer = ""
	-- this function will be called once every few seconds to update our window
	function tap.draw(t)
		print("Updating window")
		tw:clear()
		tw:append("TXID\t")
		tw:append("HWADDR\t")
		tw:append("REQIP\t")
		tw:append("DHCPDISCOVER\t") 
		tw:append("DHCPOFFER\t") 
		tw:append("DHCPREQUEST\t") 
		tw:append("DHCPDECLINE\t") 
		tw:append("DHCPACK\t") 
		tw:append("DHCPNAK\t") 
		tw:append("DHCPRELEASE\t") 
		tw:append("DHCPINFORM\t") 
		tw:append("DHCPFORCERENEW\t") 
		tw:append("DHCPLEASEQUERY\t") 
		tw:append("DHCPLEASEUNASSIGNED\t") 
		tw:append("DHCPLEASEUNKNOWN\t") 
		tw:append("DHCPLEASEACTIVE\t") 
		tw:append("DHCPBULKLEASEQUERY\t") 
		tw:append("DHCPLEASEQUERYDONE\t") 
		tw:append("DHCPACTIVELEASEQUERY\t") 
		tw:append("DHCPLEASEQUERYSTATUS\t") 
		tw:append("DHCPTLS\t") 
		tw:append("\n")
		
		
		local t = {}
		for txid, dhcptypesTable in pairs(txids) do
			t[#t+1] = table.concat({
				txid,
				dhcptypesTable["HW"] or "",
				dhcptypesTable["REQIP"] or "",
				dhcptypesTable["DHCPDISCOVER"] or 0,
				dhcptypesTable["DHCPOFFER"] or 0,
				dhcptypesTable["DHCPREQUEST"] or 0,
				dhcptypesTable["DHCPDECLINE"] or 0,
				dhcptypesTable["DHCPACK"] or 0,
				dhcptypesTable["DHCPNAK"] or 0,
				dhcptypesTable["DHCPRELEASE"] or 0,
				dhcptypesTable["DHCPINFORM"] or 0,
				dhcptypesTable["DHCPFORCERENEW"] or 0,
				dhcptypesTable["DHCPLEASEQUERY"] or 0,
				dhcptypesTable["DHCPLEASEUNASSIGNED"] or 0,
				dhcptypesTable["DHCPLEASEUNKNOWN"] or 0,
				dhcptypesTable["DHCPLEASEACTIVE"] or 0,
				dhcptypesTable["DHCPBULKLEASEQUERY"] or 0,
				dhcptypesTable["DHCPLEASEQUERYDONE"] or 0,
				dhcptypesTable["DHCPACTIVELEASEQUERY"] or 0,
				dhcptypesTable["DHCPLEASEQUERYSTATUS"] or 0,
				dhcptypesTable["DHCPTLS"] or 0
			}, "\t")
		end
		lines = table.concat(t, "\n") .. "\n"
		tw:append(lines)
		print("Updated window")
	end

	-- this function will be called whenever a reset is needed
	-- e.g. when reloading the capture file
	function tap.reset()
		tw:clear()
        txids = {}
	end

	-- Ensure that all existing packets are processed.
	retap_packets()
end
local function menuable_tap_not_acked()

	-- Declare the window we will use
	local tw = TextWindow.new("DHCP TX Counter")

	-- This will contain a hash of counters of appearances of a certain address
	local ips = {}

    local txids = {}
	-- this is our tap
	local tap = Listener.new();

	local function remove()
		-- this way we remove the listener that otherwise will remain running indefinitely
		tap:remove();
	end

	-- we tell the window to call the remove() function when closed
	tw:set_atclose(remove)

	-- this function will be called once for each packet
	function tap.packet(pinfo,tvb)
 		local txid_field = dhcp_txid()
		local dhcptype = dhcp_type().value

		
		
		if txid_field and dhcptype then
			local txid = string.format("0x%08x", tonumber( tostring(txid_field.value) ) )
			txids[txid] = txids[txid] or {}
			
			-- if we have a hw address, we will store it
			if dhcp_hw_field then
				txids[txid]["HW"] = tostring(dhcp_hw_field.value)
			end
			-- if we have a requested ip address, we will store it
			if dhcp_req_ip_field then
				txids[txid]["REQIP"] = tostring(dhcp_req_ip_field.value)
			end

			local label = "ERROR_PARSED"
			if dhcptype == 1 then
				label = "DHCPDISCOVER" 
			elseif dhcptype == 2 then
				label = "DHCPOFFER"
			elseif dhcptype == 3 then
				 label = "DHCPREQUEST"
			elseif dhcptype == 4 then
				 label = "DHCPDECLINE"
			elseif dhcptype == 5 then
				 label = "DHCPACK"
			elseif dhcptype == 6 then
				 label = "DHCPNAK"
			elseif dhcptype == 7 then
				 label = "DHCPRELEASE"
			elseif dhcptype == 8 then
				 label = "DHCPINFORM"
			elseif dhcptype == 9 then
				 label = "DHCPFORCERENEW"
			elseif dhcptype == 10 then
				 label = "DHCPLEASEQUERY"
			elseif dhcptype == 11 then
				 label = "DHCPLEASEUNASSIGNED"
			elseif dhcptype == 12 then
				 label = "DHCPLEASEUNKNOWN"
			elseif dhcptype == 13 then
				 label = "DHCPLEASEACTIVE"
			elseif dhcptype == 14 then
				 label = "DHCPBULKLEASEQUERY"
			elseif dhcptype == 15 then
				 label = "DHCPLEASEQUERYDONE"
			elseif dhcptype == 16 then
				 label = "DHCPACTIVELEASEQUERY"
			elseif dhcptype == 17 then
				 label = "DHCPLEASEQUERYSTATUS"
			elseif dhcptype == 18 then
				 label = "DHCPTLS"
			end
			local count = txids[txid][label] or 0
			txids[txid][label] = count + 1
		end
	end

	-- this function will be called once every few seconds to update our window
	function tap.draw(t)
		tw:clear()
		tw:append("TXID\t")
		tw:append("DHCPDISCOVER\t") 
		tw:append("DHCPOFFER\t") 
		tw:append("DHCPREQUEST\t") 
		tw:append("DHCPDECLINE\t") 
		tw:append("DHCPACK\t") 
		tw:append("DHCPNAK\t") 
		tw:append("DHCPRELEASE\t") 
		tw:append("DHCPINFORM\t") 
		tw:append("DHCPFORCERENEW\t") 
		tw:append("DHCPLEASEQUERY\t") 
		tw:append("DHCPLEASEUNASSIGNED\t") 
		tw:append("DHCPLEASEUNKNOWN\t") 
		tw:append("DHCPLEASEACTIVE\t") 
		tw:append("DHCPBULKLEASEQUERY\t") 
		tw:append("DHCPLEASEQUERYDONE\t") 
		tw:append("DHCPACTIVELEASEQUERY\t") 
		tw:append("DHCPLEASEQUERYSTATUS\t") 
		tw:append("DHCPTLS\t") 
		tw:append("\n")

		for txid,dhcptypesTable in pairs(txids) do
			if not dhcptypesTable["DHCPACK"] then
				tw:append(txid .. "\t")
				tw:append((dhcptypesTable["DHCPDISCOVER"] or 0) .. "\t")
				tw:append((dhcptypesTable["DHCPOFFER"] or 0) .. "\t")
				tw:append((dhcptypesTable["DHCPREQUEST"] or 0) .. "\t")
				tw:append((dhcptypesTable["DHCPDECLINE"] or 0) .. "\t")
				tw:append((dhcptypesTable["DHCPACK"] or 0) .. "\t")
				tw:append((dhcptypesTable["DHCPNAK"] or 0) .. "\t")
				tw:append((dhcptypesTable["DHCPRELEASE"] or 0) .. "\t")
				tw:append((dhcptypesTable["DHCPINFORM"] or 0) .. "\t")
				tw:append((dhcptypesTable["DHCPFORCERENEW"] or 0) .. "\t")
				tw:append((dhcptypesTable["DHCPLEASEQUERY"] or 0) .. "\t")
				tw:append((dhcptypesTable["DHCPLEASEUNASSIGNED"] or 0) .. "\t")
				tw:append((dhcptypesTable["DHCPLEASEUNKNOWN"] or 0) .. "\t")
				tw:append((dhcptypesTable["DHCPLEASEACTIVE"] or 0) .. "\t")
				tw:append((dhcptypesTable["DHCPBULKLEASEQUERY"] or 0) .. "\t")
				tw:append((dhcptypesTable["DHCPLEASEQUERYDONE"] or 0) .. "\t")
				tw:append((dhcptypesTable["DHCPACTIVELEASEQUERY"] or 0) .. "\t")
				tw:append((dhcptypesTable["DHCPLEASEQUERYSTATUS"] or 0) .. "\t")
				tw:append((dhcptypesTable["DHCPTLS"] or 0) .. "\n")			
			end
		end
	end

	-- this function will be called whenever a reset is needed
	-- e.g. when reloading the capture file
	function tap.reset()
		tw:clear()
        txids= {}
	end

	-- Ensure that all existing packets are processed.
	retap_packets()
end
register_menu("DHCP/Summary", menuable_tap, MENU_TOOLS_UNSORTED)
--register_menu("DHCP/DHCP Unanswered Transactions", menuable_tap_not_acked, MENU_TOOLS_UNSORTED)