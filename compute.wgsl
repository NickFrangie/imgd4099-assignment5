const WORKGROUP_SIZE : u32 = 4;

struct Vant {
  pos: vec2f,
  dir: f32,
  flag: f32
}

@group(0) @binding(0) var<uniform> grid_size: f32;
@group(0) @binding(1) var<uniform> width: f32;
@group(0) @binding(2) var<uniform> height: f32;
@group(0) @binding(3) var<storage, read_write> vants: array<Vant>;
@group(0) @binding(4) var<storage, read_write> pheremones: array<f32>;
@group(0) @binding(5) var<storage, read_write> render: array<f32>;


fn vantIndex( cell:vec3u ) -> u32 {
  return cell.x + (cell.y * WORKGROUP_SIZE); 
}

fn pheromoneIndex( vant_pos: vec2f ) -> u32 {
  return u32( abs( vant_pos.y % height ) * width + vant_pos.x );
}

@compute
@workgroup_size(WORKGROUP_SIZE, WORKGROUP_SIZE, 1)

fn cs(@builtin(global_invocation_id) cell:vec3u)  {
  let pi2   = 3.14159 * 2;
  let index = vantIndex( cell );
  var vant:Vant  = vants[ index ];

  let pIndex    = pheromoneIndex( vant.pos );
  let pheromone = pheremones[ pIndex ];

  switch (i32(vant.flag)) {
    case 0, default {
      // Vant 1, Red = Normal
      if( pheromone != 0. ) {
        vant.dir += .25; // turn 90 degrees counter-clockwise
        pheremones[ pIndex ] = 0.;  // set pheromone flag
      }else{
        vant.dir -= .25; // turn clockwise
        pheremones[ pIndex ] = 1.;  // unset pheromone flag
      }
    }
    case 1 {
      // Vant 2, Green = Inward Circles
      if( pheromone != 0. ) {
        vant.dir -= .125; // turn 90 degrees counter-clockwise
        pheremones[ pIndex ] = 0.;  // set pheromone flag
      }else{
        vant.dir += .25; // turn clockwise
        pheremones[ pIndex ] = 1.;  // unset pheromone flag
      }
    }
    case 2 {
      // Vant 3, Blue = Outward Circles
      if( pheromone != 0. ) {
        vant.dir += .25; // turn 90 degrees counter-clockwise
        pheremones[ pIndex ] = 0.;  // set pheromone flag
      }else{
        vant.dir -= .125; // turn clockwise
        pheremones[ pIndex ] = 1.;  // unset pheromone flag
      }
    }
  }

  // calculate direction based on vant heading
  let dir = vec2f( cos( vant.dir * pi2 ), sin( vant.dir * pi2 ) );
  
  vant.pos = round( vant.pos + dir ); 

  vants[ index ] = vant;
  
  // we'll look at the render buffer in the fragment shader
  // if we see a value of one a vant is there and we can color
  // it accordingly. in our JavaScript we clear the buffer on every
  // frame.
  render[ pIndex ] = vant.flag + 1.;
}