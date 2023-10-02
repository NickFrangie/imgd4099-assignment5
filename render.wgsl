const WORKGROUP_SIZE : u32 = 4;

struct VertexInput {
  @location(0) pos: vec2f,
  @builtin(instance_index) instance: u32,
}

struct Vant {
  pos: vec2f,
  dir: f32,
  flag: f32
}

@group(0) @binding(0) var<uniform> grid_size: f32;
@group(0) @binding(1) var<uniform> width: f32;
@group(0) @binding(2) var<uniform> height: f32;
@group(0) @binding(3) var<storage> vants: array<Vant>;
@group(0) @binding(4) var<storage> pheromones: array<f32>;
@group(0) @binding(5) var<storage> render: array<f32>;


@fragment 
fn fs( @builtin(position) pos : vec4f ) -> @location(0) vec4f {
  let grid_pos = floor( pos.xy / grid_size);
  
  let pidx = grid_pos.y  * width + grid_pos.x;
  let p = pheromones[ u32(pidx) ];
  let v = render[ u32(pidx) ];

  var out: vec3f;
  switch (i32(v)) {
    case 0, default {
      // No Vant, Pheremones
      out = vec3f(p);
    }
    case 1 {
      // Vant 1, Red
      out = vec3f(1., 0., 0.);
    }
    case 2 {
      // Vant 2, Green
      out = vec3f(0., 1., 0.);
    }
    case 3 {
      // Vant 3, Blue
      out = vec3f(0., 0., 1.);
    }
  }
  
  return vec4f( out, 1. );
}