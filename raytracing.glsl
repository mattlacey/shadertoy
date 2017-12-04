
// Equation for a sphere is:
// P^2 - RT2 = 0
// where P is a point on the surface, and R is the Radius

// A Ray can be thouht be a parametric equation:
// O(rigin) + t * D(irection)

// Substituting thatin for P gives:
// |O+tD|^2 − R^2 = 0

// rewritten in a(x^x) + bx + c:
// D^2 = a
// 2OD = b
// O^2 - R^2 = c

// Factoring in the centre, C of the spehere:
// |O+tD-C|^2 - R^2 = 0
// |(O-C) + tD|^2 = R^2
// a = D^2
// b = 2D(O-C)
// c = (O-C)^2 - R^2

struct ray
{
    vec3 o;
    vec3 d;
    int life;
    vec4 col;
};

ray makeRay(vec3 cam, vec3 target, vec2 uv)
{
    ray r;

    vec3 cz = normalize(target - cam);
   	vec3 cx = cross(cam, vec3(0., 1., 0.));
    vec3 cy = cross(cz, cx);
    
    r.o = cam;
    r.d = normalize(cz * 2. + (uv.x * cx) + (uv.y * cy));
   
    r.life = 3;
    r.col = vec4(0., 0., 0., 1.);
    
    return r;
}

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

ray iterateRay(ray r)
{
    float b = 2. * dot(r.d, r.o);
    float c = dot(r.o, r.o) - .1;	// radius 2 ???
    
    float f = discriminant(b, c);
    
    // f > 0 ? two roots (passing through sphere),
    // f = 0 one root (on the surface)
    // f < 0, no roots (we missed)
    
    // intersect, solve the quadratic
    if(f > 0.)
    {
		float root = solveQuad(b, c, f);

        // collision point = cam + dirn * root;
        vec3 point = r.o + r.d * root;        
        vec3 normal = normalize(point);
        
        // lighting 
        vec3 light = vec3(1., -1., 1.);
        float bright = dot(light, normal);
        
        // texturing
        vec2 uv = vec2(atan(normal.z, normal.x), acos(normal.y));
        uv.x *= 1. * 0.31830988618379067153776752674503; // 0.15915494309189533576888376337251;
        uv.y *= - 0.31830988618379067153776752674503;
        
        vec4 tex = texture(iChannel0, uv);
        
        r.col += vec4(1., 1., 1., 1.) * tex * bright;
    }
    
    // funky atmosphere type setup!
    if(f < 0. && f > - .1)
        r.col.r = 1. + (10. * f);
    else if(f >= 0. && f < .01)
        r.col.r = (r.col.r + 1. - (f * 100.)) * 1.;
        
    return r;
}

vec3 finaliseRay(ray r)
{
    return vec3(.7, .7, 1.) * smoothstep(0., 1., r.o.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    uv -= .5;
    uv.x *= iResolution.x / iResolution.y;
    
    vec3 cam = vec3(sin(iTime), 0., 2.);
    ray r = makeRay(cam, vec3(0., 0., 0.), uv);
    
    r = iterateRay(r);
    
	fragColor = r.col;
}
