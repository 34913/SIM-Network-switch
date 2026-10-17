module Comparators
	#(
		// number of bits required to address the output ports
		parameter PORT_ADDR_LENGTH = 3,
		parameter NUM_OF_PORTS = 5
	)
	(
		input wire [PORT_ADDR_LENGTH - 1 : 0] packet_addr,
		input wire [NUM_OF_PORTS * PORT_ADDR_LENGTH - 1 : 0] mem_data_all,

		// output wire [NUM_OF_PORTS - 1 : 0] eq
		output wire [NUM_OF_PORTS - 1 : 0] eq
	);

	// each bit of eq corresponds to a comparison between packet_addr and a segment of mem_data_all
	genvar i;
	generate
		for (i = 0; i < NUM_OF_PORTS; i = i + 1) begin : compare_loop
			assign eq[i] = (packet_addr == mem_data_all[i * PORT_ADDR_LENGTH +: PORT_ADDR_LENGTH]);
		end
	endgenerate

endmodule