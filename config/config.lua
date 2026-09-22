Config = {}

Config.Commands = {
    Create = 'scene',
    Manage = 'scenes'
}

Config.Permissions = {
    Create = 'kruiger.scenes.create',
    Permanent = 'kruiger.scenes.permanent',
    Manage = 'kruiger.scenes.manage'
}

Config.AllowEveryoneToCreate = false
Config.MaxScenesPerPlayer = 10
Config.MaxTextLength = 150
Config.CreateCooldownSeconds = 3
Config.DefaultViewDistance = 12.0
Config.MaxViewDistance = 30.0
Config.InteractDistance = 2.0
Config.DefaultDurationMinutes = 30
Config.PersistentFile = 'scenes.json'

Config.Durations = {
    { label = '5 Minutes', minutes = 5 },
    { label = '15 Minutes', minutes = 15 },
    { label = '30 Minutes', minutes = 30 },
    { label = '1 Hour', minutes = 60 },
    { label = 'Until Removed', minutes = 0, permanent = true }
}

Config.Presets = {
    { label = 'Blood', icon = '🩸', defaultText = 'Blood is visible in this area.' },
    { label = 'Shell Casings', icon = '🔫', defaultText = 'Spent shell casings are visible.' },
    { label = 'Broken Glass', icon = '🪟', defaultText = 'Broken glass is scattered across the area.' },
    { label = 'Vehicle Debris', icon = '🚗', defaultText = 'Vehicle debris is scattered across the roadway.' },
    { label = 'Burn Marks', icon = '🔥', defaultText = 'Burn marks are visible in this area.' },
    { label = 'Footprints', icon = '👣', defaultText = 'Footprints are visible leading through this area.' },
    { label = 'Evidence', icon = '📦', defaultText = 'Potential evidence is visible here.' },
    { label = 'Custom', icon = '✏️', defaultText = '' }
}
