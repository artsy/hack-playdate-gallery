function tableLength(tbl)
	count = 0
	for _ in pairs(tbl) do
		count = count + 1
	end
	return count
end

alreadyRun = {}
function once(uniqKey, fn)
	if alreadyRun[uniqKey] == true then
		return
	end

	fn()
	alreadyRun[uniqKey] = true
end
