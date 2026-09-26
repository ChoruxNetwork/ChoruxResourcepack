#version 150
#if defined(RENDERTYPE_TEXT) || defined(RENDERTYPE_TEXT_INTENSITY)

struct TextData {
    vec4 color;
    vec4 topColor;
    vec4 backColor;
    vec2 position;
    vec2 characterPosition;
    vec2 localPosition;
    vec2 uv;
    vec2 uvMin;
    vec2 uvMax;
    vec2 uvCenter;
    bool isShadow;
    bool doTextureLookup;
    bool shouldScale;
};

TextData textData;

// Pre-calculated time values (calculate once per frame, not per pixel)
float fastTime;
float medTime;
float slowTime;

void initTimeValues() {
    fastTime = GameTime * 500.0;
    medTime = GameTime * 1200.0;
    slowTime = GameTime * 300.0;
}

bool uvBoundsCheck(vec2 uv, vec2 uvMin, vec2 uvMax) {
    if(isnan(uv.x) || isnan(uv.y)) return true;
    const float error = 0.0001;
    return uv.x < textData.uvMin.x + error || uv.y < textData.uvMin.y + error || uv.x > textData.uvMax.x - error || uv.y > textData.uvMax.y - error;
}

// OPTIMIZED: 4-sample cross pattern instead of 9-sample grid
vec3 textSdf() {
    vec3 value = vec3(0.0, 0.0, 1.0);
    vec2 texelSize = 1.0 / vec2(256.0);
    
    // Check 4 cardinal directions + center
    vec2 offsets[5] = vec2[](
        vec2(0.0, 0.0),
        vec2(texelSize.x, 0.0),
        vec2(-texelSize.x, 0.0),
        vec2(0.0, texelSize.y),
        vec2(0.0, -texelSize.y)
    );
    
    for(int i = 0; i < 5; i++) {
        vec2 uv = textData.uv + offsets[i];
        if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) continue;

        vec4 s = texture(Sampler0, uv);
        if(s.a >= 0.1) {
            vec3 v = vec3(fract(uv * 256.0), 0.0);
            
            if(offsets[i].x == 0.0) v.x = 0.0;
            if(offsets[i].y == 0.0) v.y = 0.0;
            if(offsets[i].x > 0.0) v.x = 1.0 - v.x;
            if(offsets[i].y > 0.0) v.y = 1.0 - v.y;
            
            v.z = length(v.xy);
            if(v.z < value.z) value = v;
        }
    }
    return value;
}

void override_text_color(vec4 color) {
    textData.color = color;
    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void override_text_color(vec3 color) {
    textData.color.rgb = color;
    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void override_shadow_color(vec4 color) {
    if(textData.isShadow) {
        textData.color = color;
        textData.topColor.rgb = color.rgb;
        textData.topColor.a *= color.a;
        textData.backColor.rgb = color.rgb;
        textData.backColor.a *= color.a;
    }
}

void override_shadow_color(vec3 color) {
    override_shadow_color(vec4(color, 1.0));
}

void apply_outline(vec3 color) {
    vec2 texelSize = 1.0 / vec2(256.0);
    vec2 offsets[4] = vec2[](
        vec2(texelSize.x, 0.0),
        vec2(-texelSize.x, 0.0),
        vec2(0.0, texelSize.y),
        vec2(0.0, -texelSize.y)
    );
    for(int i = 0; i < 4; i++) {
        vec2 uv = textData.uv + offsets[i];
        if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) continue;
        if(texture(Sampler0, uv).a >= 0.1) {
            textData.backColor = vec4(color, 1.0);
            return;
        }
    }
}

void apply_flip(float speed, float space) {
    float tY = mod((textData.characterPosition.x * 0.8 - GameTime * 18000.0 * speed) / TAU, 5.0 * space);
    
    textData.uv.y = textData.uvCenter.y + (textData.uv.y - textData.uvCenter.y) / cos(TAU * min(tY, 1.0));

    textData.shouldScale = false;
}

void apply_hack(float intensity, float speed) {
    textData.shouldScale = true;
    if(textData.isShadow) return;

    float time = floor(GameTime * speed * 6000.0);
    float time2 = floor(GameTime * speed * 6000.0 * 3.7);
    float time3 = floor(GameTime * speed * 6000.0 * 0.3);

    float hackLine = floor(textData.uv.y * 256.0);
    float hackBlock = floor(textData.uv.y * 32.0);

    if (random(vec2(hackLine, time)) < intensity) {
        float offset = (random(vec2(hackLine, time + 1.0)) * 2.0 - 1.0) * 8.0 / 256.0;
        textData.uv.x += offset;
    }

    if (random(vec2(hackBlock, time2)) < intensity * 0.6) {
        float offset = (random(vec2(hackBlock, time2 + 1.0)) * 2.0 - 1.0) * 16.0 / 256.0;
        textData.uv.x += offset;
        textData.uv.y += (random(vec2(hackBlock, time2 + 2.0)) * 2.0 - 1.0) * 4.0 / 256.0;
    }

    if (random(vec2(floor(textData.characterPosition.x), time3)) < intensity * 0.3) {
        float snapX = (random(vec2(time3, 99.0)) * 2.0 - 1.0) * 24.0 / 256.0;
        float snapY = (random(vec2(time3, 77.0)) * 2.0 - 1.0) * 8.0 / 256.0;
        textData.uv.x += snapX;
        textData.uv.y += snapY;
    }

    float fringeNoise = random(vec2(hackLine, time + 5.0));
    if (fringeNoise < intensity * 0.5) {
        float fringe = random(vec2(hackLine, time + 6.0)) * 6.0 / 256.0;
        vec4 redSample = texture(Sampler0, clamp(textData.uv + vec2(fringe, 0.0), textData.uvMin, textData.uvMax));
        vec4 blueSample = texture(Sampler0, clamp(textData.uv - vec2(fringe, 0.0), textData.uvMin, textData.uvMax));
        textData.color.r = mix(textData.color.r, redSample.r * 1.5, 0.6);
        textData.color.b = mix(textData.color.b, blueSample.b * 1.5, 0.6);
        textData.doTextureLookup = false;
    }

    if (random(vec2(time2, floor(textData.characterPosition.x * 0.5))) < intensity * 0.15) {
        float flash = random(vec2(time2 + 3.0, 42.0));
        textData.color.rgb = flash > 0.5 ? vec3(1.0) : vec3(0.0);
        textData.doTextureLookup = false;
    }

    textData.uv = clamp(textData.uv, textData.uvMin, textData.uvMax);
}

void apply_shake() {
    float noiseX = noise(textData.characterPosition.x + textData.characterPosition.y + GameTime * 32000.0) - 0.75;
    float noiseY = noise(textData.characterPosition.x - textData.characterPosition.y + GameTime * 32000.0) - 0.75;
    textData.shouldScale = false;
    textData.uv += vec2(noiseX, noiseY) / 256.0;
}

void apply_waving(float speed, float frequency, float amplitude) {
    textData.uv.y += sin(textData.characterPosition.x * 0.1 * frequency - GameTime * 7500.0 * speed) * amplitude / 256.0;
    textData.shouldScale = false;
}

void apply_gloss(float speed, float intensity) { // Text gloss
    if(textData.isShadow) return;
    float f = textData.localPosition.x + textData.localPosition.y - GameTime * 6400.0 * speed;

    if(mod(f, 5) < 0.75) textData.topColor = vec4(1.0, 1.0, 1.0, intensity);
    textData.shouldScale = true;
}

void apply_gloss_basic(float speed, float intensity) { // Rank tags gloss
    if(textData.isShadow) return;
    float f = textData.localPosition.x + textData.localPosition.y - GameTime * 6400.0 * speed;

    if(mod(f, 5) < 0.35) textData.topColor = vec4(1.0, 1.0, 1.0, intensity);
    textData.shouldScale = true;
}

void apply_chromatic_abberation(float speed, float intensity, vec4 color1, vec4 color2) {
    textData.shouldScale = true;
    
    float timeVal = GameTime * 12000.0 * speed;
    float noiseX = noise(timeVal) - 0.5;
    float noiseY = noise(timeVal + 19732.134) - 0.5;
    
    vec2 offset = vec2(0.5 / 256, 0.0) + vec2(0.5, 1.0) * vec2(noiseX, noiseY) / 256 * intensity;
    
    vec2 uv = textData.uv + offset;
    vec4 s1 = texture(Sampler0, uv);
    s1.rgb *= s1.a;
    if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) s1 = vec4(0.0);
    
    uv = textData.uv - offset;
    vec4 s2 = texture(Sampler0, uv);
    s2.rgb *= s2.a;
    if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) s2 = vec4(0.0);
    
    textData.backColor = (s1 * color1 * intensity) + (s2 * color2 * intensity);
    textData.backColor.rgb *= textData.color.rgb;
}

void apply_rainbow() {
    textData.color.rgb = hsvToRgb(vec3(0.005 * (textData.position.x + textData.position.y) - slowTime, 0.7, 1.0));
    if(textData.isShadow) textData.color.rgb *= 0.25;
    textData.shouldScale = true;
}

void apply_pastel() {
    vec3 hsvColor = vec3(0.005 * (textData.position.x + textData.position.y) - slowTime, 0.43, 0.94);
    textData.color.rgb = hsvToRgb(hsvColor);
    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_fire() {
    textData.shouldScale = true;
    if(textData.isShadow) return;

    float h = fract(textData.uv.y * 256.0);
    vec2 uv = textData.uv + vec2(0.0, 1.0 / 256);
    if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) return;
    vec4 s = texture(Sampler0, uv);
    if(s.a > 0.1) {
        float f = noise(textData.localPosition * 32.0 + vec2(0.0, GameTime * 6400.0)) * 0.5 + 0.5;
        f -= (1.0 - sqrt(h)) * 0.8;

        if(f > 0.5)
        textData.backColor = vec4(mix(vec3(1.0, 0.2, 0.2), vec3(1.0, 0.7, 0.3), (f - 0.5) / 0.5), 1.0);
    }
}

float fast_hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float fast_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f); // Smoothstep
    
    float a = fast_hash(i);
    float b = fast_hash(i + vec2(1.0, 0.0));
    float c = fast_hash(i + vec2(0.0, 1.0));
    float d = fast_hash(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fast_fbm(vec2 p) {
    float value = 0.0;
    value += 0.5 * fast_noise(p);
    value += 0.25 * fast_noise(p * 2.0);
    return value;
}

void apply_rainbow_fractal() {
    #ifdef FSH
        vec2 uv = floor(vec2(gl_FragCoord.xy) / 2.0) * 2.0 / 100.0;
        float fractalShade = fast_fbm(uv + medTime);
        
        vec2 smoothCoord = vec2(gl_FragCoord.xy);
        float baseHue = 0.003 * (smoothCoord.x + smoothCoord.y) - slowTime;
        
        float hue = mod(baseHue + fractalShade * 1.0, 1.0); // Full fractal influence restored

        textData.color.rgb = hsvToRgb(vec3(hue, 0.7, 1.0));

        if (textData.isShadow) {
            textData.color.rgb *= 0.25;
        }
    #endif
}

void apply_fractal(vec3 color1, vec3 color2, vec3 color3, vec3 color4, vec3 color5, vec3 color6, vec3 color7, float speed) {
    #ifdef FSH
        vec2 uv = floor(vec2(gl_FragCoord.xy) / 2.0) * 2.0 / 100.0;
        float fractalShade = fast_fbm(uv + medTime * speed);
        
        float baseHue = 0.005 * (textData.position.x + textData.position.y) - slowTime * speed;
        float hue = mod(baseHue + fractalShade * 3.0, 1.0);
        
        float colorIndex = hue * 7.0;
        int index1 = int(floor(colorIndex));
        int index2 = (index1 + 1) % 7;
        float t = fract(colorIndex);
        
        vec3 fractalColors[7];
        fractalColors[0] = color1;
        fractalColors[1] = color2;
        fractalColors[2] = color3;
        fractalColors[3] = color4;
        fractalColors[4] = color5;
        fractalColors[5] = color6;
        fractalColors[6] = color7;
        
        textData.color.rgb = mix(fractalColors[index1 % 7], fractalColors[index2 % 7], t);
        
        if (textData.isShadow) {
            textData.color.rgb *= 0.25;
        }
    #endif
}

void apply_fractal_outline(vec3 color1, vec3 color2, vec3 color3, vec3 color4, vec3 color5, vec3 color6, vec3 color7, float speed) {
    textData.shouldScale = false;
    vec2 texelSize = 0.26 / vec2(256.0);
    vec2 offsets[4] = vec2[](
        vec2(texelSize.x, 0.0),
        vec2(-texelSize.x, 0.0),
        vec2(0.0, texelSize.y),
        vec2(0.0, -texelSize.y)
    );
    for(int i = 0; i < 4; i++) {
        vec2 uv = textData.uv + offsets[i];
        if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) continue;
        if(texture(Sampler0, uv).a >= 0.1) {
            #ifdef FSH
                vec2 fragUV = floor(vec2(gl_FragCoord.xy) / 2.0) * 2.0 / 100.0;
                float fractalShade = fast_fbm(fragUV + medTime * speed);

                vec2 smoothCoord = vec2(gl_FragCoord.xy);
                float baseHue = 0.003 * (smoothCoord.x + smoothCoord.y) - slowTime * speed;
                float hue = mod(baseHue + fractalShade * 3.0, 1.0);

                float colorIndex = hue * 7.0;
                int index1 = int(floor(colorIndex));
                int index2 = (index1 + 1) % 7;
                float t = fract(colorIndex);

                vec3 colors[7];
                colors[0] = color1;
                colors[1] = color2;
                colors[2] = color3;
                colors[3] = color4;
                colors[4] = color5;
                colors[5] = color6;
                colors[6] = color7;

                vec3 outlineColor = mix(colors[index1 % 7], colors[index2 % 7], t);
                outlineColor *= 0.65;

                if(textData.isShadow) outlineColor *= 0.25;
                textData.backColor = vec4(outlineColor, 1.0);
            #endif
            return;
        }
    }
}

void apply_cloud(vec3 color1, vec3 color2, vec3 color3, vec3 color4, float speed) {
    #ifdef FSH
        float t = medTime * speed;
        vec2 p = floor(vec2(gl_FragCoord.xy) / 2.0) * 2.0 / 100.0;
        vec2 q = p * 5.0;
        
        q.x += sin(q.y * 2.0 + t) * 0.2;
        q.y += cos(q.x * 2.0 + t) * 0.2;
        
        float n1 = fast_fbm(q + t);
        float n2 = fast_fbm(q * 1.5 - t * 0.5);
        
        vec3 col = n1 * color1 + n2 * color2;
        col += fast_noise(q * 3.0 + t * 0.25) * color3 * 0.5;
        col += fast_noise(q * 3.0 - t * 0.25) * color4 * 0.5;
        col = pow(col, vec3(1.3));
        
        float star = fract(sin(dot(p * 20.0, vec2(12.9898, 78.233))) * 43758.5453);
        star = smoothstep(2.95, 5.0, star) * 0.2;
        textData.color.rgb = col + vec3(star);

        if (textData.isShadow) {
            textData.color.rgb *= 0.25;
        }
    #endif
}

void apply_cloud_outline(vec3 color1, vec3 color2, vec3 color3, vec3 color4, float speed) {
    textData.shouldScale = false;
    vec2 texelSize = 0.26 / vec2(256.0);
    vec2 offsets[4] = vec2[](
        vec2(texelSize.x, 0.0),
        vec2(-texelSize.x, 0.0),
        vec2(0.0, texelSize.y),
        vec2(0.0, -texelSize.y)
    );
    for (int i = 0; i < 4; i++) {
        vec2 uv = textData.uv + offsets[i];
        if (uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) continue;
        if (texture(Sampler0, uv).a >= 0.1) {
            #ifdef FSH
                float t = medTime * speed;
                vec2 p = floor(vec2(gl_FragCoord.xy) / 2.0) * 2.0 / 100.0;
                vec2 q = p * 5.0;
                q.x += sin(q.y * 2.0 + t) * 0.2;
                q.y += cos(q.x * 2.0 + t) * 0.2;
                float n1 = fast_fbm(q + t);
                float n2 = fast_fbm(q * 1.5 - t * 0.5);
                float cloudShade = n1 * 0.6 + n2 * 0.4;
                cloudShade += fast_noise(q * 3.0 + t * 0.25) * 0.3;
                cloudShade = clamp(cloudShade, 0.0, 1.0);
                float baseHue = 0.003 * (p.x + p.y) - slowTime * speed;
                float hue = mod(baseHue + cloudShade * 2.5, 1.0);
                // 4-color palette mapping
                float colorIndex = hue * 4.0;
                int index1 = int(floor(colorIndex));
                int index2 = (index1 + 1) % 4;
                float mixT = fract(colorIndex);
                vec3 colors[4];
                colors[0] = color1;
                colors[1] = color2;
                colors[2] = color3;
                colors[3] = color4;
                vec3 outlineColor = mix(colors[index1 % 4], colors[index2 % 4], mixT);
                outlineColor *= 0.6;
                if (textData.isShadow) outlineColor *= 0.25;
                textData.backColor = vec4(outlineColor, 1.0);
            #endif
            return;
        }
    }
}

float camo_hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float camo_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = camo_hash(i);
    float b = camo_hash(i + vec2(1.0, 0.0));
    float c = camo_hash(i + vec2(0.0, 1.0));
    float d = camo_hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float camo_fbm(vec2 p) {
    float total = 0.0;
    float amplitude = 0.6;
    for (int i = 0; i < 4; i++) {
        total += camo_noise(p) * amplitude;
        p *= 1.8;
        amplitude *= 0.5;
    }
    return total;
}

void apply_camo(vec3 color1, vec3 color2, vec3 color3, vec3 color4, float speed) {
    #ifdef FSH
        vec2 uv = vec2(gl_FragCoord.xy) / 50.0;
        float time = GameTime * 400.0 * speed;
        
        // Create chunky camo blobs
        float n1 = camo_fbm(uv * 2.0 + vec2(time * 0.08, 0.0));
        float n2 = camo_fbm(uv * 1.5 + vec2(100.0, time * 0.06));
        
        // Combine and create sharp transitions
        float pattern = n1 * 0.6 + n2 * 0.4;
        
        // Stretch the pattern to use full range (noise tends to cluster 0.3-0.7)
        pattern = clamp((pattern - 0.3) * 2.0, 0.0, 1.0);
        
        // Even color bands - 25% each
        vec3 color;
        if (pattern < 0.25) {
            color = color4;  // darkest
        } else if (pattern < 0.5) {
            color = color3;
        } else if (pattern < 0.75) {
            color = color2;
        } else {
            color = color1;  // brightest
        }
        
        textData.color.rgb = color;
        
        if (textData.isShadow) {
            textData.color.rgb *= 0.25;
        }
    #endif
}

void apply_gradient_3(vec3 color1, vec3 color2, vec3 color3, float speed) {
    float t = 0.05 * (textData.position.x + textData.position.y) - fastTime * 10.0 * speed;
    float smoothT = fract(t / (2.0 * 3.14159)) * 3.0;
    vec3 resultColor;
    if (smoothT < 1.0) {
        resultColor = mix(color1, color2, smoothT);
    } else if (smoothT < 2.0) {
        resultColor = mix(color2, color3, smoothT - 1.0);
    } else {
        resultColor = mix(color3, color1, smoothT - 2.0);
    }
    textData.color.rgb = resultColor;
    if(textData.isShadow) textData.color.rgb *= 0.25;
    textData.shouldScale = true;
}

void apply_gradient_4(vec3 color1, vec3 color2, vec3 color3, vec3 color4, float speed) {
    float t = 0.05 * (textData.position.x + textData.position.y) - fastTime * 10.0 * speed;
    float smoothT = fract(t / (2.0 * 3.14159)) * 4.0;
    vec3 resultColor;
    if (smoothT < 1.0) {
        resultColor = mix(color1, color2, smoothT);
    } else if (smoothT < 2.0) {
        resultColor = mix(color2, color3, smoothT - 1.0);
    } else if (smoothT < 3.0) {
        resultColor = mix(color3, color4, smoothT - 2.0);
    } else {
        resultColor = mix(color4, color1, smoothT - 3.0);
    }
    textData.color.rgb = resultColor;
    if(textData.isShadow) textData.color.rgb *= 0.25;
    textData.shouldScale = true;
}

void apply_gradient_5(vec3 color1, vec3 color2, vec3 color3, vec3 color4, vec3 color5, float speed) {
    float t = 0.05 * (textData.position.x + textData.position.y) - fastTime * 10.0 * speed;
    float smoothT = fract(t / (2.0 * 3.14159)) * 5.0;
    vec3 resultColor;
    if (smoothT < 1.0) {
        resultColor = mix(color1, color2, smoothT);
    } else if (smoothT < 2.0) {
        resultColor = mix(color2, color3, smoothT - 1.0);
    } else if (smoothT < 3.0) {
        resultColor = mix(color3, color4, smoothT - 2.0);
    } else if (smoothT < 4.0) {
        resultColor = mix(color4, color5, smoothT - 3.0);
    } else {
        resultColor = mix(color5, color1, smoothT - 4.0);
    }
    textData.color.rgb = resultColor;
    if(textData.isShadow) textData.color.rgb *= 0.25;
    textData.shouldScale = true;
}

void apply_gradient_7(vec3 color1, vec3 color2, vec3 color3, vec3 color4, vec3 color5, vec3 color6, vec3 color7) {
    float t = 0.01 * (textData.position.x + textData.position.y) - fastTime;
    float smoothT = fract(t) * 12.0;

    vec3 resultColor;
    if (smoothT < 1.0) {
        resultColor = mix(color1, color2, smoothT);
    } else if (smoothT < 2.0) {
        resultColor = mix(color2, color3, smoothT - 1.0);
    } else if (smoothT < 3.0) {
        resultColor = mix(color3, color4, smoothT - 2.0);
    } else if (smoothT < 4.0) {
        resultColor = mix(color4, color5, smoothT - 3.0);
    } else if (smoothT < 5.0) {
        resultColor = mix(color5, color6, smoothT - 4.0);
    } else if (smoothT < 6.0) {
        resultColor = mix(color6, color7, smoothT - 5.0);
    } else if (smoothT < 7.0) {
        resultColor = mix(color7, color6, smoothT - 6.0);
    } else if (smoothT < 8.0) {
        resultColor = mix(color6, color5, smoothT - 7.0);
    } else if (smoothT < 9.0) {
        resultColor = mix(color5, color4, smoothT - 8.0);
    } else if (smoothT < 10.0) {
        resultColor = mix(color4, color3, smoothT - 9.0);
    } else if (smoothT < 11.0) {
        resultColor = mix(color3, color2, smoothT - 10.0);
    } else {
        resultColor = mix(color2, color1, smoothT - 11.0);
    }

    float wave = sin(10.0 * t + textData.position.x * 0.2) * 0.5 + 0.5;
    resultColor = mix(resultColor, vec3(1.0), wave * 0.15);

    textData.color.rgb = resultColor;
    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_animated_gradient_6_smoother(
    vec3 color1, vec3 color2, vec3 color3,
    vec3 color4, vec3 color5, vec3 color6,
    float speed
) {
    float t = 0.05 * (textData.position.x + textData.position.y)
            - fastTime * 10.0 * speed;

    // Full forward + backward cycle = 10 segments
    float smoothT = fract(t / (2.0 * 3.14159)) * 10.0;

    float idx = floor(smoothT);
    float blend = fract(smoothT);

    vec3 resultColor = vec3(0.0);

    // Forward transitions
    resultColor += mix(color1, color2, blend) * (1.0 - step(1.0, idx));
    resultColor += mix(color2, color3, blend) * step(1.0, idx) * (1.0 - step(2.0, idx));
    resultColor += mix(color3, color4, blend) * step(2.0, idx) * (1.0 - step(3.0, idx));
    resultColor += mix(color4, color5, blend) * step(3.0, idx) * (1.0 - step(4.0, idx));
    resultColor += mix(color5, color6, blend) * step(4.0, idx) * (1.0 - step(5.0, idx));

    // Backward transitions
    resultColor += mix(color6, color5, blend) * step(5.0, idx) * (1.0 - step(6.0, idx));
    resultColor += mix(color5, color4, blend) * step(6.0, idx) * (1.0 - step(7.0, idx));
    resultColor += mix(color4, color3, blend) * step(7.0, idx) * (1.0 - step(8.0, idx));
    resultColor += mix(color3, color2, blend) * step(8.0, idx) * (1.0 - step(9.0, idx));
    resultColor += mix(color2, color1, blend) * step(9.0, idx);

    float wave = sin(10.0 * t + textData.position.x * 0.2) * 0.5 + 0.5;
    resultColor = mix(resultColor, vec3(1.0), wave * 0.15);

    textData.color.rgb = resultColor;

    if (textData.isShadow)
        textData.color.rgb *= 0.25;

    textData.shouldScale = true;
}

void apply_animated_gradient_7_smoother(vec3 color1, vec3 color2, vec3 color3, vec3 color4, vec3 color5, vec3 color6, vec3 color7) {
    float t = 0.01 * (textData.position.x + textData.position.y) - fastTime;
    float smoothT = fract(t) * 12.0;
    float idx = floor(smoothT);
    float blend = fract(smoothT);

    vec3 resultColor = vec3(0.0);

    resultColor += mix(color1, color2, blend) * (1.0 - step(1.0, idx)) * step(0.0, idx);
    resultColor += mix(color2, color3, blend) * step(1.0, idx) * (1.0 - step(2.0, idx));
    resultColor += mix(color3, color4, blend) * step(2.0, idx) * (1.0 - step(3.0, idx));
    resultColor += mix(color4, color5, blend) * step(3.0, idx) * (1.0 - step(4.0, idx));
    resultColor += mix(color5, color6, blend) * step(4.0, idx) * (1.0 - step(5.0, idx));
    resultColor += mix(color6, color7, blend) * step(5.0, idx) * (1.0 - step(6.0, idx));

    resultColor += mix(color7, color6, blend) * step(6.0, idx) * (1.0 - step(7.0, idx));
    resultColor += mix(color6, color5, blend) * step(7.0, idx) * (1.0 - step(8.0, idx));
    resultColor += mix(color5, color4, blend) * step(8.0, idx) * (1.0 - step(9.0, idx));
    resultColor += mix(color4, color3, blend) * step(9.0, idx) * (1.0 - step(10.0, idx));
    resultColor += mix(color3, color2, blend) * step(10.0, idx) * (1.0 - step(11.0, idx));
    resultColor += mix(color2, color1, blend) * step(11.0, idx);
    
    float wave = sin(10.0 * t + textData.position.x * 0.2) * 0.5 + 0.5;
    resultColor = mix(resultColor, vec3(1.0), wave * 0.15);
    textData.color.rgb = resultColor * mix(1.0, 0.25, float(textData.isShadow));
}

void apply_cycle_2(vec3 startRGB, vec3 endRGB, float speed, float frequency) {
    float timeOffset = fastTime * speed;
    float positionOffset = textData.characterPosition.x * frequency;
    float wave = sin(positionOffset - timeOffset) * 0.5 + 0.5;

    textData.color.rgb = mix(startRGB, endRGB, wave);

    if (textData.isShadow) {
        textData.color.rgb *= 0.25;
    }
    textData.shouldScale = true;
}
float blob_hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float blob_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = blob_hash(i);
    float b = blob_hash(i + vec2(1.0, 0.0));
    float c = blob_hash(i + vec2(0.0, 1.0));
    float d = blob_hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float blob_fbm(vec2 p) {
    float total = 0.0;
    float amplitude = 0.6;
    for (int i = 0; i < 4; i++) {
        total += blob_noise(p) * amplitude;
        p *= 2.2;
        amplitude *= 0.45;
    }
    return total;
}
void apply_blob_cycle(vec3 c0, vec3 c1, vec3 c2, vec3 c3, vec3 c4, vec3 c5, vec3 c6, vec3 c7, float speed, float cycleSpeed) {
    #ifdef FSH
        vec2 uv = vec2(gl_FragCoord.xy) / 50.0;
        float time = GameTime * 400.0 * speed;

        float n1 = blob_fbm(uv * 1.8 + vec2(time * 0.08, 0.0));
        float n2 = blob_fbm(uv * 1.3 + vec2(100.0, time * 0.06));

        float pattern = n1 * 0.6 + n2 * 0.4;
        pattern = clamp((pattern - 0.3) * 2.0, 0.0, 1.0);

        float band = pattern * 4.0;
        float f = fract(band);
        int idx = int(floor(band));
        float t = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

        vec3 fireColors[4] = vec3[](c3, c2, c1, c0);
        vec3 waterColors[4] = vec3[](c7, c6, c5, c4);

        vec3 firCol = mix(fireColors[clamp(idx, 0, 3)], fireColors[clamp(idx + 1, 0, 3)], t);
        vec3 watCol = mix(waterColors[clamp(idx, 0, 3)], waterColors[clamp(idx + 1, 0, 3)], t);

        float crawlTime = GameTime * cycleSpeed * 500.0;
        float crawlNoise = blob_fbm(uv * 1.5 + vec2(crawlTime * 0.15, crawlTime * 0.08));

        float front = mod(crawlTime, 4.0);
        float normFront = (front / 4.0) * 2.5 - 0.5;

        float edge = smoothstep(normFront - 0.2, normFront + 0.2, crawlNoise);

        float ping = mod(floor(crawlTime / 4.0), 2.0);
        float paletteMix = mix(edge, 1.0 - edge, ping);

        textData.color.rgb = paletteMix > 0.5 ? watCol : firCol;

        if (textData.isShadow) {
            textData.color.rgb *= 0.25;
        }
    #endif
}

void apply_blob_pastel_rainbow(float speed, float cycleSpeed) {
    #ifdef FSH
        vec2 uv = vec2(gl_FragCoord.xy) / 50.0;
        float time = GameTime * 400.0 * speed;

        float n1 = blob_fbm(uv * 1.8 + vec2(time * 0.08, 0.0));
        float n2 = blob_fbm(uv * 1.3 + vec2(100.0, time * 0.06));

        float pattern = n1 * 0.6 + n2 * 0.4;
        pattern = clamp((pattern - 0.3) * 2.0, 0.0, 1.0);

        float band = pattern * 4.0;
        float f = fract(band);
        int idx = int(floor(band));
        float t = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

        vec3 palettes[36];

        // Vibrant pastel red
        palettes[0]  = rgb(255, 204, 204);
        palettes[1]  = rgb(255, 164, 164);
        palettes[2]  = rgb(255, 133, 133);
        palettes[3]  = rgb(255, 106, 106);

        // Vibrant pastel orange
        palettes[4]  = rgb(255, 227, 195);
        palettes[5]  = rgb(255, 196, 141);
        palettes[6]  = rgb(255, 168, 110);
        palettes[7]  = rgb(255, 144, 85);

        // Vibrant pastel yellow
        palettes[8]  = rgb(255, 255, 208);
        palettes[9]  = rgb(255, 247, 178);
        palettes[10] = rgb(255, 238, 131);
        palettes[11] = rgb(255, 231, 94);

        // Vibrant pastel green
        palettes[12] = rgb(223, 255, 223);
        palettes[13] = rgb(192, 255, 192);
        palettes[14] = rgb(147, 255, 147);
        palettes[15] = rgb(107, 255, 107);

        // Vibrant pastel cyan
        palettes[16] = rgb(211, 249, 255);
        palettes[17] = rgb(160, 241, 255);
        palettes[18] = rgb(120, 228, 255);
        palettes[19] = rgb(79, 211, 255);

        // Vibrant pastel blue
        palettes[20] = rgb(215, 226, 255);
        palettes[21] = rgb(166, 191, 255);
        palettes[22] = rgb(126, 159, 255);
        palettes[23] = rgb(94, 131, 255);

        // Vibrant pastel purple
        palettes[24] = rgb(235, 212, 255);
        palettes[25] = rgb(202, 159, 255);
        palettes[26] = rgb(182, 126, 255);
        palettes[27] = rgb(150, 74, 255);

        // Vibrant pastel pink
        palettes[28] = rgb(255, 217, 244);
        palettes[29] = rgb(255, 154, 216);
        palettes[30] = rgb(255, 100, 201);
        palettes[31] = rgb(255, 75, 198);

        // Loop back to red
        palettes[32]  = rgb(255, 204, 204);
        palettes[33]  = rgb(255, 164, 164);
        palettes[34]  = rgb(255, 133, 133);
        palettes[35]  = rgb(255, 106, 106);

        float crawlTime = GameTime * cycleSpeed * 500.0;
        float crawlNoise = blob_fbm(uv * 1.5 + vec2(crawlTime * 0.15, crawlTime * 0.08));

        float huePos = mod(crawlNoise + crawlTime * 0.09, 8.0);

        int hueIdx = int(floor(huePos));
        int nextIdx = hueIdx + 1;

        float hueBlend = fract(huePos);
        hueBlend = smoothstep(0.0, 1.0, hueBlend);

        vec3 fireColors[4] = vec3[](
            palettes[hueIdx*4+3], palettes[hueIdx*4+2],
            palettes[hueIdx*4+1], palettes[hueIdx*4+0]
        );
        vec3 waterColors[4] = vec3[](
            palettes[nextIdx*4+3], palettes[nextIdx*4+2],
            palettes[nextIdx*4+1], palettes[nextIdx*4+0]
        );

        vec3 colA = mix(fireColors[clamp(idx, 0, 3)], fireColors[clamp(idx + 1, 0, 3)], t);
        vec3 colB = mix(waterColors[clamp(idx, 0, 3)], waterColors[clamp(idx + 1, 0, 3)], t);

        textData.color.rgb = mix(colA, colB, hueBlend);

        if (textData.isShadow) {
            textData.color.rgb *= 0.25;
        }
    #endif
}

void apply_blob_pastel_rainbow_outline(float speed, float cycleSpeed) {
    textData.shouldScale = false;
    vec2 texelSize = 0.26 / vec2(256.0);
    vec2 offsets[4] = vec2[](
        vec2(texelSize.x, 0.0),
        vec2(-texelSize.x, 0.0),
        vec2(0.0, texelSize.y),
        vec2(0.0, -texelSize.y)
    );
    for(int i = 0; i < 4; i++) {
        vec2 uv = textData.uv + offsets[i];
        if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) continue;
        if(texture(Sampler0, uv).a >= 0.1) {
            #ifdef FSH
                vec2 uvCoord = vec2(gl_FragCoord.xy) / 50.0;
                float time = GameTime * 400.0 * speed;

                float n1 = blob_fbm(uvCoord * 1.8 + vec2(time * 0.08, 0.0));
                float n2 = blob_fbm(uvCoord * 1.3 + vec2(100.0, time * 0.06));

                float pattern = n1 * 0.6 + n2 * 0.4;
                pattern = clamp((pattern - 0.3) * 2.0, 0.0, 1.0);

                float band = pattern * 4.0;
                float f = fract(band);
                int idx = int(floor(band));
                float t = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

                vec3 palettes[36];

                // Darker pastel red
                palettes[0]  = rgb(200, 120, 120);
                palettes[1]  = rgb(185, 90,  90);
                palettes[2]  = rgb(165, 60,  60);
                palettes[3]  = rgb(145, 35,  35);

                // Darker pastel orange
                palettes[4]  = rgb(200, 155, 100);
                palettes[5]  = rgb(185, 125, 65);
                palettes[6]  = rgb(165, 95,  40);
                palettes[7]  = rgb(145, 70,  15);

                // Darker pastel yellow
                palettes[8]  = rgb(195, 195, 100);
                palettes[9]  = rgb(180, 180, 75);
                palettes[10] = rgb(165, 160, 40);
                palettes[11] = rgb(150, 145, 10);

                // Darker pastel green
                palettes[12] = rgb(120, 195, 120);
                palettes[13] = rgb(90,  185, 90);
                palettes[14] = rgb(55,  165, 55);
                palettes[15] = rgb(25,  145, 25);

                // Darker pastel cyan
                palettes[16] = rgb(95,  185, 205);
                palettes[17] = rgb(65,  170, 190);
                palettes[18] = rgb(35,  150, 175);
                palettes[19] = rgb(10,  130, 155);

                // Darker pastel blue
                palettes[20] = rgb(100, 130, 210);
                palettes[21] = rgb(70,  105, 195);
                palettes[22] = rgb(45,  80,  175);
                palettes[23] = rgb(20,  55,  155);

                // Darker pastel purple
                palettes[24] = rgb(155, 110, 210);
                palettes[25] = rgb(130, 80,  195);
                palettes[26] = rgb(110, 55,  175);
                palettes[27] = rgb(85,  20,  155);

                // Darker pastel pink
                palettes[28] = rgb(205, 110, 180);
                palettes[29] = rgb(190, 75,  160);
                palettes[30] = rgb(170, 40,  140);
                palettes[31] = rgb(150, 15,  120);

                // Loop back
                palettes[32] = rgb(200, 120, 120);
                palettes[33] = rgb(185, 90,  90);
                palettes[34] = rgb(165, 60,  60);
                palettes[35] = rgb(145, 35,  35);

                float crawlTime = GameTime * cycleSpeed * 500.0;
                float crawlNoise = blob_fbm(uvCoord * 1.5 + vec2(crawlTime * 0.15, crawlTime * 0.08));

                float huePos = mod(crawlNoise + crawlTime * 0.09, 8.0);

                int hueIdx = int(floor(huePos));
                int nextIdx = hueIdx + 1;

                float hueBlend = fract(huePos);
                hueBlend = smoothstep(0.0, 1.0, hueBlend);

                vec3 fireColors[4] = vec3[](
                    palettes[hueIdx*4+3], palettes[hueIdx*4+2],
                    palettes[hueIdx*4+1], palettes[hueIdx*4+0]
                );
                vec3 waterColors[4] = vec3[](
                    palettes[nextIdx*4+3], palettes[nextIdx*4+2],
                    palettes[nextIdx*4+1], palettes[nextIdx*4+0]
                );

                vec3 colA = mix(fireColors[clamp(idx, 0, 3)], fireColors[clamp(idx + 1, 0, 3)], t);
                vec3 colB = mix(waterColors[clamp(idx, 0, 3)], waterColors[clamp(idx + 1, 0, 3)], t);

                vec3 outlineColor = mix(colA, colB, hueBlend);

                if(textData.isShadow) outlineColor *= 0.25;
                textData.backColor = vec4(outlineColor, 1.0);
            #endif
            return;
        }
    }
}

void apply_blob_rainbow(float speed, float cycleSpeed) {
    #ifdef FSH
        vec2 uv = vec2(gl_FragCoord.xy) / 50.0;
        float time = GameTime * 400.0 * speed;

        float n1 = blob_fbm(uv * 1.8 + vec2(time * 0.08, 0.0));
        float n2 = blob_fbm(uv * 1.3 + vec2(100.0, time * 0.06));

        float pattern = n1 * 0.6 + n2 * 0.4;
        pattern = clamp((pattern - 0.3) * 2.0, 0.0, 1.0);

        float band = pattern * 4.0;
        float f = fract(band);
        int idx = int(floor(band));
        float t = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

        vec3 palettes[36];

        palettes[0]  = rgb(255, 210, 210);
        palettes[1]  = rgb(255, 150, 150);
        palettes[2]  = rgb(230, 50,  50);
        palettes[3]  = rgb(180, 0,   0);

        palettes[4]  = rgb(255, 241, 200);
        palettes[5]  = rgb(255, 191, 77);
        palettes[6]  = rgb(230, 115, 0);
        palettes[7]  = rgb(180, 64,  0);

        palettes[8]  = rgb(255, 255, 207);
        palettes[9]  = rgb(255, 242, 102);
        palettes[10] = rgb(230, 204, 0);
        palettes[11] = rgb(228, 194, 0);

        palettes[12] = rgb(210, 255, 210);
        palettes[13] = rgb(170, 255, 170);
        palettes[14] = rgb(90, 230, 90);
        palettes[15] = rgb(60, 170, 60);

        palettes[16] = rgb(220, 255, 255);
        palettes[17] = rgb(120, 235, 255);
        palettes[18] = rgb(60, 180, 240);
        palettes[19] = rgb(50, 130, 190);

        palettes[20] = rgb(210, 225, 255);
        palettes[21] = rgb(120, 160, 255);
        palettes[22] = rgb(70, 110, 230);
        palettes[23] = rgb(60, 90, 180);

        palettes[24] = rgb(225, 210, 255);
        palettes[25] = rgb(190, 130, 255);
        palettes[26] = rgb(140, 80, 220);
        palettes[27] = rgb(110, 70, 180);

        palettes[28] = rgb(255, 210, 245);
        palettes[29] = rgb(255, 130, 220);
        palettes[30] = rgb(220, 80, 190);
        palettes[31] = rgb(180, 70, 150);

        palettes[32]  = rgb(255, 214, 214);
        palettes[33]  = rgb(255, 150, 150);
        palettes[34]  = rgb(230, 50,  50);
        palettes[35]  = rgb(180, 0,   0);

        float crawlTime = GameTime * cycleSpeed * 500.0;
        float crawlNoise = blob_fbm(uv * 1.5 + vec2(crawlTime * 0.15, crawlTime * 0.08));

        float huePos = mod(crawlNoise + crawlTime * 0.09, 8.0);

        int hueIdx = int(floor(huePos));
        int nextIdx = hueIdx + 1;

        float hueBlend = fract(huePos);
        hueBlend = smoothstep(0.0, 1.0, hueBlend);

        vec3 fireColors[4] = vec3[](
            palettes[hueIdx*4+3], palettes[hueIdx*4+2],
            palettes[hueIdx*4+1], palettes[hueIdx*4+0]
        );
        vec3 waterColors[4] = vec3[](
            palettes[nextIdx*4+3], palettes[nextIdx*4+2],
            palettes[nextIdx*4+1], palettes[nextIdx*4+0]
        );

        vec3 colA = mix(fireColors[clamp(idx, 0, 3)], fireColors[clamp(idx + 1, 0, 3)], t);
        vec3 colB = mix(waterColors[clamp(idx, 0, 3)], waterColors[clamp(idx + 1, 0, 3)], t);

        textData.color.rgb = mix(colA, colB, hueBlend);

        if (textData.isShadow) {
            textData.color.rgb *= 0.25;
        }
    #endif
}

void apply_blob_rainbow_outline(float speed, float cycleSpeed) {
    textData.shouldScale = false;
    vec2 texelSize = 0.25 / vec2(256.0);
    vec2 offsets[4] = vec2[](
        vec2(texelSize.x, 0.0),
        vec2(-texelSize.x, 0.0),
        vec2(0.0, texelSize.y),
        vec2(0.0, -texelSize.y)
    );
    for(int i = 0; i < 4; i++) {
        vec2 uv = textData.uv + offsets[i];
        if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) continue;
        if(texture(Sampler0, uv).a >= 0.1) {
            #ifdef FSH
                vec2 uvCoord = vec2(gl_FragCoord.xy) / 50.0;
                float time = GameTime * 400.0 * speed;

                float n1 = blob_fbm(uvCoord * 1.8 + vec2(time * 0.08, 0.0));
                float n2 = blob_fbm(uvCoord * 1.3 + vec2(100.0, time * 0.06));

                float pattern = n1 * 0.6 + n2 * 0.4;
                pattern = clamp((pattern - 0.3) * 2.0, 0.0, 1.0);

                float band = pattern * 4.0;
                float f = fract(band);
                int idx = int(floor(band));
                float t = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

                vec3 palettes[36];

                palettes[0]  = rgb(180, 100, 100);
                palettes[1]  = rgb(160, 60,  60);
                palettes[2]  = rgb(130, 20,  20);
                palettes[3]  = rgb(90,  0,   0);

                palettes[4]  = rgb(180, 150, 80);
                palettes[5]  = rgb(160, 110, 20);
                palettes[6]  = rgb(130, 70,  0);
                palettes[7]  = rgb(90,  30,  0);

                palettes[8]  = rgb(180, 180, 80);
                palettes[9]  = rgb(160, 155, 20);
                palettes[10] = rgb(130, 120, 0);
                palettes[11] = rgb(100, 90,  0);

                palettes[12] = rgb(80,  160, 80);
                palettes[13] = rgb(50,  140, 50);
                palettes[14] = rgb(20,  110, 20);
                palettes[15] = rgb(0,   60,  0);

                palettes[16] = rgb(80,  160, 160);
                palettes[17] = rgb(20,  120, 160);
                palettes[18] = rgb(0,   80,  140);
                palettes[19] = rgb(0,   40,  90);

                palettes[20] = rgb(80,  100, 180);
                palettes[21] = rgb(20,  60,  160);
                palettes[22] = rgb(0,   20,  130);
                palettes[23] = rgb(0,   15,  80);

                palettes[24] = rgb(110, 80,  180);
                palettes[25] = rgb(90,  30,  160);
                palettes[26] = rgb(55,  0,   120);
                palettes[27] = rgb(35,  0,   80);

                palettes[28] = rgb(160, 80,  150);
                palettes[29] = rgb(140, 20,  120);
                palettes[30] = rgb(110, 0,   110);
                palettes[31] = rgb(80,  0,   85);

                palettes[32] = rgb(180, 100, 100);
                palettes[33] = rgb(160, 60,  60);
                palettes[34] = rgb(130, 20,  20);
                palettes[35] = rgb(90,  0,   0);
                float crawlTime = GameTime * cycleSpeed * 500.0;
                float crawlNoise = blob_fbm(uvCoord * 1.5 + vec2(crawlTime * 0.15, crawlTime * 0.08));

                float huePos = mod(crawlNoise + crawlTime * 0.09, 8.0);

                int hueIdx = int(floor(huePos));
                int nextIdx = hueIdx + 1;

                float hueBlend = fract(huePos);
                hueBlend = smoothstep(0.0, 1.0, hueBlend);

                vec3 fireColors[4] = vec3[](
                    palettes[hueIdx*4+3], palettes[hueIdx*4+2],
                    palettes[hueIdx*4+1], palettes[hueIdx*4+0]
                );
                vec3 waterColors[4] = vec3[](
                    palettes[nextIdx*4+3], palettes[nextIdx*4+2],
                    palettes[nextIdx*4+1], palettes[nextIdx*4+0]
                );

                vec3 colA = mix(fireColors[clamp(idx, 0, 3)], fireColors[clamp(idx + 1, 0, 3)], t);
                vec3 colB = mix(waterColors[clamp(idx, 0, 3)], waterColors[clamp(idx + 1, 0, 3)], t);

                vec3 outlineColor = mix(colA, colB, hueBlend);

                if(textData.isShadow) {
                    outlineColor *= 0.25;
                }
                textData.backColor = vec4(outlineColor, 1.0);
            #endif
            return;
        }
    }
}
#define TEXT_EFFECT(r, g, b) return true; case ((uint(r/4) << 16) | (uint(g/4) << 8) | (uint(b/4))):

bool applyTextEffects() {
    uint vertexColorId = colorId(floor(round(textData.color.rgb * 255.0) / 4.0) / 255.0);
    if(textData.isShadow) { vertexColorId = colorId(textData.color.rgb);}
    switch(vertexColorId >> 8) {
        case 0xFFFFFFFFu:

        #moj_import<text_effects_config.glsl>
        return true;
    }
    return false;
}

#define SPHEYA_PACK_9

#ifdef FSH
flat in float vctfx_applyTextEffect;
flat in float vctfx_isShadow;
flat in float vctfx_changedScale;

in vec4 vctfx_screenPos;

in vec3 vctfx_ipos1;
in vec3 vctfx_ipos2;
in vec3 vctfx_ipos3;
in vec3 vctfx_ipos4;

in vec3 vctfx_uvpos1;
in vec3 vctfx_uvpos2;
in vec3 vctfx_uvpos3;
in vec3 vctfx_uvpos4;

bool applySpheyaPack9() {
    if(vctfx_applyTextEffect < 0.5) return false;

    // OPTIMIZATION: Initialize time values once
    initTimeValues();

    textData.isShadow = vctfx_isShadow > 0.5;
    textData.backColor = vec4(0.0);
    textData.topColor = vec4(0.0);
    textData.doTextureLookup = true;
    textData.color = baseColor;

    vec2 ip1 = vctfx_ipos1.xy / vctfx_ipos1.z;
    vec2 ip2 = vctfx_ipos2.xy / vctfx_ipos2.z;
    vec2 ip3 = vctfx_ipos3.xy / vctfx_ipos3.z;
    vec2 ip4 = vctfx_ipos4.xy / vctfx_ipos4.z;
    vec2 innerMin = min(ip1.xy,min(ip2.xy,min(ip3.xy,ip4.xy)));
    vec2 innerMax = max(ip1.xy,max(ip2.xy,max(ip3.xy,ip4.xy)));
    vec2 innerSize = innerMax - innerMin;

    vec2 uvp1 = vctfx_uvpos1.xy / vctfx_uvpos1.z;
    vec2 uvp2 = vctfx_uvpos2.xy / vctfx_uvpos2.z;
    vec2 uvp3 = vctfx_uvpos3.xy / vctfx_uvpos3.z;
    vec2 uvp4 = vctfx_uvpos4.xy / vctfx_uvpos4.z;
    vec2 uvMin = min(uvp1.xy,min(uvp2.xy,min(uvp3.xy, uvp4.xy)));
    vec2 uvMax = max(uvp1.xy,max(uvp2.xy,max(uvp3.xy, uvp4.xy)));
    vec2 uvSize = uvMax - uvMin;
    textData.uvMin = uvMin;
    textData.uvMax = uvMax;
    textData.uvCenter = uvMin + 0.25 * uvSize;
    textData.localPosition = ((vctfx_screenPos.xy - innerMin) / innerSize);
    textData.localPosition.y = 1.0 - textData.localPosition.y;
    textData.uv = textData.localPosition * uvSize + uvMin;
    if(vctfx_changedScale < 0.5) {
        textData.uv = texCoord0;
    }
    textData.position = vctfx_screenPos.xy * uvSize * 256.0 / innerSize;
    textData.characterPosition = 0.5 * (innerMin + innerMax) * uvSize * 256.0 / innerSize;
    if(textData.isShadow) {
        textData.characterPosition += vec2(-1.0, 1.0);
        textData.position += vec2(-1.0, 1.0);
    }
    applyTextEffects();
    if(uvBoundsCheck(textData.uv, uvMin, uvMax)) textData.doTextureLookup = false;

    vec4 textureSample = texture(Sampler0, textData.uv);

#ifdef RENDERTYPE_TEXT_INTENSITY
    textureSample = textureSample.rrrr;
    textureSample = vec4(0.0);
#endif

    if(!textData.doTextureLookup) textureSample = vec4(0.0);
    textData.topColor.a *= textureSample.a;

    fragColor = mix(vec4(textData.backColor.rgb, textData.backColor.a * textData.color.a), textureSample * textData.color, textureSample.a);
    fragColor.rgb = mix(fragColor.rgb, textData.topColor.rgb, textData.topColor.a);
    fragColor *= lightColor * ColorModulator;

    if (fragColor.a < 0.1) {
        discard;
    }

#ifdef IS_1_21_6
    fragColor = apply_fog(
        fragColor,
        sphericalVertexDistance,
        cylindricalVertexDistance,
        FogEnvironmentalStart,
        FogEnvironmentalEnd,
        FogRenderDistanceStart,
        FogRenderDistanceEnd,
        FogColor
    );
#else
    fragColor = linear_fog(fragColor, vertexDistance, FogStart, FogEnd, FogColor);
#endif
    return true;
}

#endif

#ifdef VSH
out vec4 vctfx_screenPos;
flat out float vctfx_applyTextEffect;
flat out float vctfx_isShadow;
flat out float vctfx_changedScale;

out vec3 vctfx_ipos1;
out vec3 vctfx_ipos2;
out vec3 vctfx_ipos3;
out vec3 vctfx_ipos4;

out vec3 vctfx_uvpos1;
out vec3 vctfx_uvpos2;
out vec3 vctfx_uvpos3;
out vec3 vctfx_uvpos4;

bool applySpheyaPack9() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vctfx_isShadow = fract(Position.z) < 0.01 ? 1.0 : 0.0;
    vctfx_applyTextEffect = 1.0;
    vctfx_changedScale = 0.0;

    textData.isShadow = vctfx_isShadow > 0.5;
    textData.color = Color;
    textData.shouldScale = false;

    if(!applyTextEffects()) {
        vctfx_isShadow = 0.0;

#ifdef IS_1_21_6
        if (textData.isShadow)
        {
#else
        if(Position.z == 0.0 && textData.isShadow) {
#endif
            textData.isShadow = false;
            if(applyTextEffects()) {
                vctfx_isShadow = 0.0;
            }else {
                vctfx_applyTextEffect = 0.0;
                return false;
            }
        }else{
            vctfx_applyTextEffect = 0.0;
            return false;
        }
    }

    vec2 corner = vec2[](vec2(-1.0, +1.0), vec2(-1.0, -1.0), vec2(+1.0, -1.0), vec2(+1.0, +1.0))[gl_VertexID % 4];
    if(textureSize(Sampler0, 0) != ivec2(256, 256)) {
        vctfx_applyTextEffect = 0.0;
        return false;
    }

    vctfx_uvpos1 = vctfx_uvpos2 = vctfx_uvpos3 = vctfx_uvpos4 = vctfx_ipos1 = vctfx_ipos2 = vctfx_ipos3 = vctfx_ipos4 = vec3(0.0);
    switch (gl_VertexID % 4) {
        case 0: vctfx_ipos1 = vec3(gl_Position.xy, 1.0); vctfx_uvpos1 = vec3(UV0.xy, 1.0); break;
        case 1: vctfx_ipos2 = vec3(gl_Position.xy, 1.0); vctfx_uvpos2 = vec3(UV0.xy, 1.0); break;
        case 2: vctfx_ipos3 = vec3(gl_Position.xy, 1.0); vctfx_uvpos3 = vec3(UV0.xy, 1.0); break;
        case 3: vctfx_ipos4 = vec3(gl_Position.xy, 1.0); vctfx_uvpos4 = vec3(UV0.xy, 1.0); break;
    }

if(textData.shouldScale) {
    gl_Position.xy += corner * 0.03; 
    vctfx_changedScale = 1.0;
}

    vctfx_screenPos = gl_Position;
#ifdef IS_1_21_6
    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);
#else
    vertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);
#endif
    vertexColor = baseColor * lightColor;
    texCoord0 = UV0;
    return true;
}

#endif

#endif

