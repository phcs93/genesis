const oceanVertexShaderSource = `

    uniform mat4 view;
    uniform mat4 normal;
    uniform mat4 projection;

    in vec4 position;
    out vec4 color;
    out vec3 lighting;           

    void main() {

        vec4 d = vec4(0.0);
        float v = fbm(vec4(position.xyz*50.0, time), d, 8);    

        // color = vec4(0.278, 0.49, 0.99, 0.5);
        // gl_Position = projection * view * vec4(position.xyz * (1.75), position.w);
        vec4 c = texture(gradient, vec2(seed, 0.0));
        color = vec4(c.rgb, 0.25 + (v/2.0));
        gl_Position = projection * view * vec4(position.xyz * (1.6 + seed/4.0), position.w);

        vec3 normalized = normalize(position.xyz - (d.xyz * 0.45));
        vec4 transformedNormal = normal * vec4(normalized, 1.0);
        float directional = max(dot(transformedNormal.xyz, directionalVector), 0.0);
        lighting = ambientLight + (directionalLightColor * directional);

    }

`;