#define TEXT_EFFECT(r, g, b) return true; case ((uint(r/4) << 16) | (uint(g/4) << 8) | (uint(b/4))):

TEXT_EFFECT(224, 48, 8) { // Red/Orange Gradient (#e03008)
    apply_gradient_3(rgb(146, 0, 0), rgb(255, 0, 0), rgb(243, 123, 10), 0.5);
    textData.shouldScale = true;
}

TEXT_EFFECT(31, 122, 253) { // Blue Character Gradient (#1f7afd)
    apply_gradient_3(rgb(0, 46, 253), rgb(86, 68, 252), rgb(10, 177, 255), 0.5);
    textData.shouldScale = true;
}

TEXT_EFFECT(190, 26, 244) { // Purple/Pink Gradient (#be1af4) // Text
    apply_gradient_3(rgb(102, 0, 161), rgb(156, 35, 255), rgb(224, 10, 243), 0.5);
    textData.shouldScale = true;
}

TEXT_EFFECT(190, 26, 248) { // Purple/Pink Gradient (#be1af8) // Tag
    apply_gradient_3(rgb(102, 0, 161), rgb(156, 35, 255), rgb(224, 10, 243), 0.5);
    textData.shouldScale = true;
}

TEXT_EFFECT(191, 33, 33) { // Christmas Gradient (#bf2121) // Text
    apply_gradient_4(rgb(255, 50, 50), rgb(123, 255, 119), rgb(255, 50, 50), rgb(123, 255, 119), 0.6);
    apply_gloss(0.6, 0.45);	
    textData.shouldScale = true;
}

TEXT_EFFECT(191, 33, 38) { // Christmas Gradient (#bf2126) // Tag
    apply_gradient_4(rgb(255, 50, 50), rgb(123, 255, 119), rgb(255, 50, 50), rgb(123, 255, 119), 0.6);
    apply_gloss_basic(0.6, 0.45);
    textData.shouldScale = true;
}

TEXT_EFFECT(173, 50, 255) { // Sparkplug Gradient (#ad32ff)
    apply_gradient_4(rgb(173, 50, 255), rgb(255, 0, 234), rgb(255, 45, 45), rgb(251, 255, 0), 0.8);
    textData.shouldScale = true;
}

TEXT_EFFECT(25, 201, 9) { // Sprite Gradient (#19c909) // Text
    apply_gradient_4(rgb(50, 88, 255), rgb(79, 252, 26), rgb(50, 88, 255), rgb(79, 252, 26), 0.8);
    apply_gloss(0.6, 0.45);	
    textData.shouldScale = true;
}

TEXT_EFFECT(25, 201, 12) { // Sprite Gradient (#19c909) // Tag
    apply_gradient_4(rgb(50, 88, 255), rgb(79, 252, 26), rgb(50, 88, 255), rgb(79, 252, 26), 0.8);
    apply_gloss_basic(0.6, 0.45);
    textData.shouldScale = true;
}

TEXT_EFFECT(255, 207, 50) { // Gold Gradient (#ffcf32) // Text
    apply_gradient_4(rgb(255, 196, 0), rgb(255, 219, 101), rgb(252, 255, 99), rgb(255, 250, 195), 1.0);
    apply_gloss(0.6, 0.45);
    textData.shouldScale = true;
}

TEXT_EFFECT(235, 235, 235) { // White Gradient (#ebebeb) // Text
    apply_gradient_4(rgb(215, 215, 215), rgb(235, 235, 235), rgb(250, 250, 250), rgb(225, 225, 225), 1.0);
    apply_gloss(0.6, 0.45);
    textData.shouldScale = true;
}

TEXT_EFFECT(250, 106, 255) { // Pink/Blue Gradient (#fa6aff) // Text
    apply_gradient_4(rgb(250, 106, 255), rgb(0, 251, 255), rgb(250, 106, 255), rgb(0, 251, 255), 0.8);
    apply_gloss(0.6, 0.45);	
    textData.shouldScale = true;
}

TEXT_EFFECT(250, 106, 251) { // Pink/Blue Gradient (#fa6afb) // Tag
    apply_gradient_4(rgb(250, 106, 255), rgb(0, 251, 255), rgb(250, 106, 255), rgb(0, 251, 255), 0.8);
    apply_gloss_basic(0.6, 0.45);
    textData.shouldScale = true;
}

TEXT_EFFECT(255, 40, 170) { // Pink Gradient (#ff28aa)
    apply_gradient_4(rgb(255, 40, 170), rgb(255, 150, 215), rgb(255, 90, 195), rgb(255, 150, 215), 0.8);
    textData.shouldScale = true;
}

TEXT_EFFECT(127, 127, 0) { // Rainbow Gradient (#7f7f00)
    apply_rainbow();
    textData.shouldScale = true;
}

TEXT_EFFECT(245, 245, 170) { // Pastel Gradient (#f5f5aa)
    apply_pastel();
    textData.shouldScale = true;
}

TEXT_EFFECT(170, 245, 245) { // Ice Fractal (#aaf5f5) // Text
    apply_fractal(rgb(27, 139, 243), rgb(72, 197, 255), rgb(135, 227, 255), rgb(209, 248, 253), rgb(135, 227, 255), rgb(72, 197, 255), rgb(27, 139, 243), 0.55);	
    apply_gloss(0.6, 0.45);	
    textData.shouldScale = true;
}

TEXT_EFFECT(170, 245, 249) { // Ice Fractal (#aaf5f9) // Tag
    apply_fractal(rgb(27, 139, 243), rgb(72, 197, 255), rgb(135, 227, 255), rgb(209, 248, 253), rgb(135, 227, 255), rgb(72, 197, 255), rgb(27, 139, 243), 0.55);
    apply_gloss_basic(0.6, 0.45);
    textData.shouldScale = true;
}

TEXT_EFFECT(237, 59, 59) { // Peppermint Swirl (#ed3b3b) // Text
    apply_fractal(rgb(200, 30, 30), rgb(255, 90, 90), rgb(255, 141, 221), rgb(255, 255, 255), rgb(255, 141, 221), rgb(255, 90, 214), rgb(200, 30, 30), 0.4);
    apply_gloss(0.55, 0.45);
    textData.shouldScale = true;
}

TEXT_EFFECT(237, 59, 64) { // Peppermint Swirl (#ed3b40) // Tag
    apply_fractal(rgb(200, 30, 30), rgb(255, 90, 90), rgb(255, 141, 221), rgb(255, 255, 255), rgb(255, 141, 221), rgb(255, 90, 214), rgb(200, 30, 30), 0.4);
    apply_gloss_basic(0.55, 0.45);
    textData.shouldScale = true;
}

TEXT_EFFECT(255, 102, 102) { // Valentine Heart (#FF6666) // Text
    apply_cloud(rgb(255, 99, 229), rgb(247, 0, 0), rgb(255, 153, 255), rgb(255, 68, 108), 2.5);
    apply_gloss(0.45, 0.35);      
    textData.shouldScale = true;
}

TEXT_EFFECT(255, 102, 106) { // Valentine Heart (#ff666a) // Tag
    apply_cloud(rgb(255, 99, 229), rgb(247, 0, 0), rgb(255, 153, 255), rgb(255, 68, 108), 2.5);
    apply_gloss_basic(0.45, 0.35);
    textData.shouldScale = true;
}

TEXT_EFFECT(50, 205, 50) { // Emerald Green (#32CD32) // Text
    apply_fractal(rgb(21, 128, 21), rgb(50, 205, 50), rgb(124, 252, 0), rgb(255, 255, 255), rgb(124, 252, 0), rgb(50, 205, 50), rgb(22, 112, 22), 0.4);
    apply_gloss(0.55, 0.45);
    textData.shouldScale = true;
}

TEXT_EFFECT(50, 205, 54) { // Emerald Green (#32cd36) // Tag
    apply_fractal(rgb(21, 128, 21), rgb(50, 205, 50), rgb(124, 252, 0), rgb(255, 255, 255), rgb(124, 252, 0), rgb(50, 205, 50), rgb(22, 112, 22), 0.4);
    apply_gloss_basic(0.55, 0.45);
    textData.shouldScale = true;
}

TEXT_EFFECT(86, 16, 218) { // Enchanted Magic (#5610DA) // Text
    apply_fractal(rgb(86, 16, 218), rgb(167, 65, 235), rgb(18, 219, 226), rgb(8, 196, 165), rgb(18, 219, 226), rgb(167, 65, 235), rgb(86, 16, 218), 0.41);
    apply_gloss(0.55, 0.45);
    textData.shouldScale = true;
}

TEXT_EFFECT(86, 16, 222) { // Enchanted Magic (#5610de) // Tag
    apply_fractal(rgb(86, 16, 218), rgb(167, 65, 235), rgb(18, 219, 226), rgb(8, 196, 165), rgb(18, 219, 226), rgb(167, 65, 235), rgb(86, 16, 218), 0.41);
    apply_gloss_basic(0.55, 0.45);
    textData.shouldScale = true;
}

TEXT_EFFECT(245, 245, 125) { // Christmas #F5F57D
    apply_animated_gradient_6_smoother(rgb(133, 0, 0),rgb(253, 30, 30),rgb(252, 119, 119),rgb(1, 70, 1),rgb(3, 160, 3),rgb(157, 238, 157), 0.5);
    textData.shouldScale = true;
}

TEXT_EFFECT(160, 200, 120) { // Spring #A0C878
    apply_animated_gradient_7_smoother(rgb(255, 192, 203),rgb(255, 255, 153),rgb(144, 238, 144),rgb(173, 216, 230),rgb(221, 160, 221),rgb(255, 222, 173),rgb(240, 230, 140));
    textData.shouldScale = true;
}

TEXT_EFFECT(200, 80, 20) { // halloween #C85014
    apply_animated_gradient_7_smoother(rgb(120, 30, 200),rgb(180, 60, 255),rgb(255, 140, 0),rgb(230, 100, 20),rgb(255, 190, 60),rgb(200, 80, 255),rgb(100, 20, 160));
    textData.shouldScale = true;
}

TEXT_EFFECT(255, 140, 60) { // summer #FF8C3C
    apply_animated_gradient_7_smoother(rgb(255, 60, 70), rgb(255, 100, 50), rgb(255, 140, 40), rgb(255, 180, 50), rgb(255, 220, 70), rgb(255, 160, 60), rgb(255, 90, 80));
    textData.shouldScale = true;
}

TEXT_EFFECT(100, 180, 255) { // Bloom cycle (#64B4FF)
    apply_blob_cycle(
        rgb(255, 200, 220), rgb(255, 160, 200), rgb(240, 120, 180), rgb(200, 80, 150),
        rgb(210, 255, 200), rgb(150, 240, 170), rgb(80, 210, 130), rgb(40, 170, 100),
        25.0, 1.0
    );
    textData.shouldScale = true;
}

TEXT_EFFECT(255, 220, 80) { // Prism cycle (#FFDC50) // Text
    apply_blob_rainbow(50.0, 25.0);
    apply_blob_rainbow_outline(75.0, 25.0);
    textData.shouldScale = true;
}

TEXT_EFFECT(255, 182, 193) { // Spring Garden (#FFB6C1)
    apply_animated_gradient_6_smoother(
        rgb(255, 90, 140),   // pink
        rgb(255, 130, 170),  // soft pink
        rgb(255, 190, 80),   // golden
        rgb(255, 240, 130),  // light yellow
        rgb(120, 255, 140),  // fresh green
        rgb(180, 255, 120),   // lime
        0.5);
    apply_gloss_basic(0.6, 0.4);
    textData.shouldScale = true;
}

TEXT_EFFECT(255, 75, 195) { // Peach (#FF4BC3)
    apply_animated_gradient_7_smoother(rgb(255, 190, 215), rgb(255, 155, 95), rgb(255, 105, 145), rgb(255, 120, 70), rgb(255, 220, 130), rgb(255, 135, 175), rgb(255, 85, 125));
    textData.shouldScale = true;
}

TEXT_EFFECT(25, 59, 255) { // Aurora Petal (#193BFF)
    apply_animated_gradient_7_smoother(rgb(255, 140, 220), rgb(255, 100, 200), rgb(190, 60, 150), rgb(170, 150, 255), rgb(140, 200, 255), rgb(90, 160, 255), rgb(70, 110, 220));
    textData.shouldScale = true;
}

TEXT_EFFECT(43, 13, 58) { // Hack #2B0D3A
    override_text_color(rgb(255, 255, 255));
    override_shadow_color(rgb(30, 30, 30));
    apply_outline(rgb(30, 30, 30));
    apply_hack(0.075, 0.6);
    textData.shouldScale = true;
}

TEXT_EFFECT(226, 141, 255) { // Flip #e28dff
    apply_flip(1.0, 1.0);
    apply_blob_pastel_rainbow(50.0, 25.0);
    apply_blob_pastel_rainbow_outline(75.0, 25.0);
    textData.shouldScale = true;
}

TEXT_EFFECT(80, 220, 180) { // Palm Lagoon (#50dcb4)
    apply_animated_gradient_7_smoother(rgb(220, 255, 170), rgb(170, 255, 120), rgb(100, 220, 120), rgb(80, 220, 180), rgb(80, 240, 255), rgb(60, 190, 255), rgb(40, 130, 220));
    textData.shouldScale = true;
}

TEXT_EFFECT(255, 190, 90) { // Tropical Paradise (#ffbe5a)
    apply_animated_gradient_7_smoother(rgb(255, 255, 170), rgb(255, 230, 120), rgb(255, 190, 90), rgb(255, 170, 140), rgb(120, 255, 220), rgb(70, 220, 200), rgb(30, 170, 180));
    textData.shouldScale = true;
}

TEXT_EFFECT(0, 200, 140) { // Mint (#00c88c)
    apply_animated_gradient_7_smoother(rgb(220, 255, 235), rgb(140, 255, 200), rgb(80, 240, 170), rgb(0, 200, 140), rgb(180, 255, 220), rgb(90, 180, 150), rgb(40, 120, 100));
    textData.shouldScale = true;
}

TEXT_EFFECT(10, 20, 80) { // USA (#0A1450) 
    apply_animated_gradient_6_smoother(rgb(255, 255, 255), rgb(208, 0, 0), rgb(7, 11, 210), rgb(255, 255, 255), rgb(208, 0, 0), rgb(7, 11, 210), 0.375);
    textData.shouldScale = true;
}

TEXT_EFFECT(255, 140, 0) { // Summer Flames (#FF8C00)
    apply_camo(rgb(234, 24, 0), rgb(255, 69, 0), rgb(255, 140, 0), rgb(255, 215, 0), 37.5);
    apply_chromatic_abberation(0.39, 0.78, vec4(1.0, 0.3, 0.0, 1.0), vec4(0.8, 0.0, 0.0, 1.0));
    apply_fire();
    textData.shouldScale = true;
}

TEXT_EFFECT(80, 120, 255) { // #5078FF USA Join Message
    apply_waving(1.0, 1.0, 1.0);
    apply_animated_gradient_6_smoother(rgb(255, 255, 255), rgb(208, 0, 0), rgb(7, 11, 210), rgb(255, 255, 255), rgb(208, 0, 0), rgb(7, 11, 210), 0.375);
    textData.shouldScale = true;
}

TEXT_EFFECT(255, 90, 5) { // #FF5A00 Summer Join Message
    apply_camo(rgb(234, 24, 0), rgb(255, 69, 0), rgb(255, 140, 0), rgb(255, 215, 0), 37.5);
    apply_chromatic_abberation(0.39, 0.78, vec4(1.0, 0.3, 0.0, 1.0), vec4(0.8, 0.0, 0.0, 1.0));
    apply_fire();
    apply_shake();
    textData.shouldScale = true;
}

TEXT_EFFECT(120, 60, 160) { // #783CA0 Nebula
    apply_animated_gradient_7_smoother(rgb(55, 15, 170), rgb(95, 30, 200), rgb(105, 25, 145), rgb(170, 50, 110), rgb(235, 80, 55), rgb(240, 150, 70), rgb(245, 200, 110));
    textData.shouldScale = true;
}

TEXT_EFFECT(255, 180, 120) { // #FFB478 Cyber Horizon
    apply_animated_gradient_7_smoother(rgb(255, 255, 140), rgb(255, 200, 80), rgb(255, 120, 120), rgb(255, 60, 180), rgb(180, 80, 255), rgb(80, 180, 255), rgb(120, 255, 220));
    textData.shouldScale = true;
}

TEXT_EFFECT(255, 170, 60) { // #FFA83C Solar Radiance
    apply_animated_gradient_7_smoother(rgb(255, 255, 210), rgb(255, 230, 120), rgb(255, 210, 70), rgb(255, 180, 30), rgb(255, 140, 0), rgb(255, 100, 0), rgb(255, 60, 0));
    textData.shouldScale = true;
}

TEXT_EFFECT(29, 120, 224) { // Crystal (#1D78E0)
	apply_cloud(rgb(29, 120, 224), rgb(0, 163, 255), rgb(66, 188, 255), rgb(66, 188, 255), 2.85);
	apply_cloud_outline(rgb(60, 60, 60), rgb(60, 60, 60), rgb(60, 60, 60), rgb(60, 60, 60), 2.85);
    textData.shouldScale = true;
}