const cloudsVertexShaderSource = `

    uniform mat4 view;
    uniform mat4 normal;
    uniform mat4 projection;

    in vec4 position;
    out vec4 color;
    out vec3 lighting;

    void main() {

        vec4 d = vec4(0.0);
        float v = turbulence(vec4(position.xyz, time/20.0), d, 8);

        vec4 c = texture(gradient, vec2(seed, 0.0));
        color = vec4(c.rgb, v > 0.5 ? smoothstep(0.5, 1.0, v) : 0.0);      
        gl_Position = projection * view * vec4(position.xyz * 2.0, position.w);        

        vec3 normalized = normalize(position.xyz - (d.xyz * 0.45));
        vec4 transformedNormal = normal * vec4(normalized, 1.0);
        float directional = max(dot(transformedNormal.xyz, directionalVector), 0.0);
        lighting = ambientLight + (directionalLightColor * directional);

    }

`;