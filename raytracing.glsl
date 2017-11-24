
// |O+tD|^2 − R^2 = 0
// Origin + t * Direction, - Radius ^ 2

// rewritten in ax2 + bc + c:
// D^2 = a
// 2OD = b
// O^2 - R^2 = c


float discriminant(float b, float c)
{
    return b * b - 4. * c;
}

float solveQuad(float b, float c, float disc)
{
    // q = - .5 * (b + sign(b) sqrt(discriminant))
    // root1 = q / a
    // root2 = c / q
    float s = sqrt(disc);

    float q;
    if(b > 0.)
        q = -.5 * (b + s);
    else
        q = -.5 * (b - s);

    float r1 = q;
    float r2 = c / q;

    return (r1 > r2 ? r2 : r1);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    uv -= .5;
    uv.x *= iResolution.x / iResolution.y;
    
    vec3 cam = vec3(0., 0., 2.);
    vec3 dir = vec3(uv.x, uv.y, 0) - cam;
    
    // vec3 point = vec3(0., 0., cos(iTime) + 3.);
    
    vec3 dirn = normalize(dir);
 
    float b = 2. * dot(dirn, cam);
    float c = dot(cam, cam) - .1;	// radius 2
    
    float f = discriminant(b, c);
    
    // f > 0 ? two roots, f = 0 one root, < 0, no roots
   
    vec4 col = vec4(0., 0., 0., 1.);
    
    // intersect, solve the quadratic
    if(f > 0.)
    {
		float root = solveQuad(b, c, f);

        // collision point = cam + dirn * root;
        vec3 point = cam + dirn * root;        
        vec3 normal = normalize(point);
        
        // lighting 
        vec3 light = vec3(sin(iTime) * 1., cos(iTime), cos(iTime) * 1.);
        float bright = dot(light, normal) * .8;
        
        // texturing
        vec2 uv = vec2(atan(normal.z, normal.x), acos(normal.y));
        uv *= .318309886183790;
        
        uv.x = uv.x + iTime * .1;
        
        vec4 tex = texture(iChannel0, uv);
        
        col = tex * bright;
        col.g *= .5;
        col.b *= .5;
    }
    
    // funky atmosphere type setup!
    if(f < 0. && f > - .1)
        col.r = 1. + (10. * f);
    else if(f >= 0. && f < .05)
        col.r = (col.r + 1. - (f * 20.)) * 1.;
    
	fragColor = vec4(col.r, col.g, col.b, 1.);
}
