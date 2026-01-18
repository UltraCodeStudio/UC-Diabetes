Config = {}

Config.items = {
    insulin = {
        sugarDecrease = 5.0, -- Decreases sugar level by 5
        animation = {
            dict = "rcmpaparazzo1ig_4",
            clip = "miranda_shooting_up",
            duration = 6000,
            prop = {
                model = "prop_syringe_01",
                bone = 18905,
                pos = {0.12, 0.03, 0.02},
                rot = {10.0, 160.0, 10.0},
            }
        },
    },
    energyTablet = {
        sugarIncrease = 10.0, -- Increases sugar level by 10
        animation = {
            dict = "mp_suicide",
            clip = "pill",
            duration = 2500,
            prop = {
                model = "xm3_prop_xm3_pill_01a",
                bone = 58866,
                pos = {0.00, 0.00, 0.00},
                rot = {0.0, 0.0, 0.0},
            }
        },
    },
    bloodSugarMonitor = {
        animation = {
            dict = "cellphone@",
            clip = "cellphone_text_in",
            duration = 1500,
            flag = 16,
            prop = {
                model = "prop_amb_phone",
                bone = 28422,
                pos = {0.0, 0.0, 0.0,},
                rot = {0.0, 0.0, 0.0}, 
            }
        },
    },
}

Config.Type1 = {
    SugarDecreaseAmount = 2.5,
    SugarDecreaseInterval = 5, -- Interval in minutes
}

Config.Type2 = {
    SugarDecreaseAmount = 3.0,
    SugarDecreaseInterval = 4, -- Interval in minutes
}

Config.Effects = {
    highSugar = {
        threshold = 80.0,
        screenEffect = "DrugsMichaelAliensFightIn",
        walkingSpeed = 0.3,
        animation = "MOVE_M@DRUNK@MODERATEDRUNK_HEAD_UP",
        healthLoss = 2.0,

    },
    lowSugar = {
        threshold = 20.0,
        screenEffect = "DrugsMichaelAliensFightIn",
        walkingSpeed = 0.3,
        animation = "MOVE_M@DRUNK@MODERATEDRUNK_HEAD_UP",
        healthLoss = 2.0,
    },
}