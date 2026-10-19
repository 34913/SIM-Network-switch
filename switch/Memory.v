module Memory
	#(
		// number of output ports
		parameter NUM_OF_PORTS = 5,
		// number of bits required to address the output ports
		parameter PORT_ADDR_LENGTH = 3
	)
	(
		input wire clk,
		input wire reset,

		input wire [$clog2(NUM_OF_PORTS) - 1 : 0] port_index,
		input wire [PORT_ADDR_LENGTH - 1 : 0] port_addr,
		input wire write_enable,

		input wire memory_blocked,

		output reg [NUM_OF_PORTS * PORT_ADDR_LENGTH - 1 : 0] data
	);

	reg [PORT_ADDR_LENGTH - 1 : 0] mem_data_addrs [NUM_OF_PORTS - 1 : 0];

	always @ (posedge clk, posedge reset) begin
		// on reset, clear all memory addresses
		if (reset) begin: reset_block
			integer i;
			for (i = 0; i < NUM_OF_PORTS; i = i + 1) begin
				mem_data_addrs[i] = 0;
			end
		end
		// when memory write enabled, memory is not blocked and clock
		else if (write_enable && !memory_blocked && port_index < NUM_OF_PORTS && port_addr != 0 && clk) begin: write_block
			// cant have the same address for different ports
			// check all the addresses and if matched, dont write the new address
			integer j;
			for (j = 0; j < NUM_OF_PORTS; j = j + 1) begin
				if (mem_data_addrs[j] == port_addr) begin
					disable write_block;
				end
			end
			// if no duplicate found, write the address to the matching index
			mem_data_addrs[port_index] = port_addr;
		end
	end

	always @ (*) begin: data_block
		integer i;
		// continuously update the output data based on the current memory addresses
		for (i = 0; i < NUM_OF_PORTS; i = i + 1) begin
			data[i * PORT_ADDR_LENGTH +: PORT_ADDR_LENGTH] = mem_data_addrs[i];
		end
	end

endmodule