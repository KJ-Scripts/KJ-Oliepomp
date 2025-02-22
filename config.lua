Config = {}

Config.OilWellPrice = 50000  -- Prijs om een pomp te kopen
Config.IncomeInterval = 5   -- Aantal minuten
Config.IncomeAmount = 2000   -- Hoeveel ze verdienen

Config.OilWellLocations = {
    {
        coords = vector3(1668.5499, -1861.2517, 107.417),
        label = "Oliepomp 1"
    },
    {
        coords = vector3(1673.5889, -1835.5259, 108.0445),
        label = "Oliepomp 2"
    },
    {
        coords = vector3(1583.8312, -1856.4441, 93.1018),
        label = "Oliepomp 3"
    }
}

Config.MenuPosition = 'right'

Config.Blip = {
    sprite = 436,   
    color = 5,       
    scale = 0.8,
    label = "Oliepomp"
}