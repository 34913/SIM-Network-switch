module Memory
	#(
		// number of output ports
		parameter NUM_OF_PORTS,
		// number of bits required to address the output ports
		PORT_ADDR_LENGTH
	)
	(
		input wire clk,
		input wire reset,

		input wire [$clog2(NUM_OF_PORTS) - 1 : 0] port_index,
		input wire [PORT_ADDR_LENGTH - 1 : 0] port_addr,
		input wire write_enable,

		input wire memory_blocked,

		output reg [PORT_ADDR_LENGTH * NUM_OF_PORTS - 1 : 0] data_addrs
	);

	reg [PORT_ADDR_LENGTH - 1 : 0] mem_data_addrs [NUM_OF_PORTS - 1 : 0];

	always @ (posedge clk, posedge reset) begin
		if (reset) begin: reset_block
			integer i;
			for (i = 0; i < NUM_OF_PORTS; i = i + 1) begin
				mem_data_addrs[i] = 0;
			end
		end else if (write_enable && !memory_blocked && clk) begin
			mem_data_addrs[port_index] = port_addr;
		end
	end

	always @ (*) begin: data_block
		integer i;
		for (i = 0; i < NUM_OF_PORTS; i = i + 1) begin
			data_addrs[i * PORT_ADDR_LENGTH +: PORT_ADDR_LENGTH] = mem_data_addrs[i];
		end
	end

endmodule