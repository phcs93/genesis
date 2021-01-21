const fragmentShaderSource = `#version 300 es

    precision highp float;

    in vec4 color;
    out vec4 fragmentColor;

    void main() {
        fragmentColor = color;
    }
    
`;