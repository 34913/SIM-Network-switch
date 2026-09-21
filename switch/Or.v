module Or
	#(
		// number of output ports
		parameter NUM_OF_PORTS
	)
	(
		input wire [NUM_OF_PORTS - 1 : 0] eq,

		output wire match
	);

	// perform logical OR on all eq signals to determine match
	assign match = |eq;

endmodule