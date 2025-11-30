if CLIENT then
    list.Set( "GlideCategories", "RandomExperiments", {
        name = "Styled's Experiments",
        icon = "glide_experiments/glide_experiments.png"
    } )

    list.Set( "GlideProjectileModels", "models/glide_experiments/weapons/firework_rocket.mdl", { scale = 1.5 } )
end

--[[ TODO: get workshop ID after publishing
if SERVER then
    resource.AddWorkshop( 99999 )
end]]

hook.Add( "InitPostEntity", "GlideExperiments.GlideCheck", function()
    if Glide then
        Glide.AddSoundSet( "GlideExperiments.Suspension.CompressHotRod", 70, 120, 130, {
            "glide/suspension/compress_heavy_1.wav",
            "glide/suspension/compress_heavy_2.wav",
            "glide/suspension/compress_heavy_3.wav"
        } )

        Glide.AddSoundSet( "GlideExperiments.Rotary.ExhaustPop", 75, 95, 105, {
            "glide_experiments/rotary/exhaust_pop1.wav",
            "glide_experiments/rotary/exhaust_pop2.wav",
            "glide_experiments/rotary/exhaust_pop3.wav",
            "glide_experiments/rotary/exhaust_pop4.wav"
        } )

        Glide.AddSoundSet( "GlideExperiments.Rotary.DumpValve", 80, 95, 105, {
            "glide_experiments/rotary/dump_valve1.wav",
            "glide_experiments/rotary/dump_valve2.wav"
        } )

        Glide.AddSoundSet( "GlideExperiments.BlazerAqua.ExhaustPop", 75, 95, 105, {
            "glide_experiments/blazer_aqua/exhaust_pop_1.wav",
            "glide_experiments/blazer_aqua/exhaust_pop_2.wav",
            "glide_experiments/blazer_aqua/exhaust_pop_3.wav",
            "glide_experiments/blazer_aqua/exhaust_pop_4.wav",
            "glide_experiments/blazer_aqua/exhaust_pop_5.wav"
        } )

        Glide.AddSoundSet( "GlideExperiments.DumpValve", 80, 95, 105, {
            "glide_experiments/dump_valve4.wav",
            "glide_experiments/dump_valve5.wav",
            "glide_experiments/dump_valve6.wav"
        } )

        return
    end

    timer.Simple( 5, function()

        local BASE_ADDON_NAME = "Glide // Styled's Vehicle Base"
        local SUB_ADDON_NAME = "Glide // Styled's Experiments"

        local colorHighlight = Color( 255, 0, 0 )
        local colorText = Color( 255, 200, 200 )

        local function Print( ... )
            if SERVER then MsgC( ..., "\n" ) end
            if CLIENT then chat.AddText( ... ) end
        end

        Print(
            colorHighlight, SUB_ADDON_NAME,
            colorText, " is installed, but ",
            colorHighlight, BASE_ADDON_NAME,
            colorText, " is missing! Please install the base addon."
        )

    end )
end )
