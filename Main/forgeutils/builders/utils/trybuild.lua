return function(self, logger)
    logger:Info("Trying to build \"" .. self.id .. "\"")
    if not self:hasErrors() then
        self:addToDB()
        logger:Info("Finished adding \"" .. self.id .. "\"")
        return
    end
    logger:Info("Error building \"" .. self.id .. "\", skipped.")
end
