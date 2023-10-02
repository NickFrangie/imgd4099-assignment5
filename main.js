import { default as seagulls } from "./seagulls.js";

const WORKGROUP_SIZE = 4,
	GRID_SIZE = 16,
	NUM_AGENTS = 16;

const W = Math.round( window.innerWidth  / GRID_SIZE ),
	H = Math.round( window.innerHeight / GRID_SIZE );

async function main() {
	// Imports
	const sg = await seagulls.init();
	const frag = await seagulls.import("./render.wgsl");
	const render = seagulls.constants.vertex + frag;
	const compute = await seagulls.import("./compute.wgsl");

	// Vant Behavior
	const NUM_PROPERTIES = 4 // must be evenly divisble by 4!
	const pheromones   = new Float32Array( W*H ) // hold pheromone data
	const vants_render = new Float32Array( W*H ) // hold info to help draw vants
	const vants        = new Float32Array( NUM_AGENTS * NUM_PROPERTIES ) // hold vant info
	
	for( let i = 0; i < NUM_AGENTS * NUM_PROPERTIES; i+= NUM_PROPERTIES ) {
		vants[ i ]   = Math.floor( Math.random() * W )
		vants[ i+1 ] = Math.floor( Math.random() * H )
		vants[ i+2 ] = 0 // this is used to hold direction
		vants[ i+3 ] = 0 // this could be used to hold vant "type"
	}

	// Seagull
	sg.buffers({
		vants:vants,
		pheromones:pheromones,
		vants_render
	  })
	.backbuffer( false )
	.compute( compute_shader, 1 )
	.render( render_shader )
	.onframe( ()=> sg.buffers.vants_render.clear() )
	.run( 1, 100 )
}

main();
