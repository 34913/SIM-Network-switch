`timescale 1ns/10ps

`include "uvm_macros.svh"

// import knihovny UVM
// import UVM library
import uvm_pkg::*;

class my_scoreboard extends uvm_scoreboard;

  // registrace do factory
  // registration to factory
  `uvm_component_utils(my_scoreboard)

  // importy pro prijem z jednotlivych monitoru
  // imports for receiving from individual monitors
  uvm_tlm_analysis_fifo #(my_pkg::my_item) inst_in_fifo;
  uvm_tlm_analysis_fifo #(my_pkg::my_item) inst_out_fifo[0:my_pkg::NUM_OF_PORTS-1];
  
  int coverage_done;

  // konstruktor
  // constructor
  function new (string name = "my_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    // sablona pocita, ze na pokryti staci 10 paketu, at uz jsou jakekoli
    // the template assumes that 10 packets are enough to cover the gap, no matter what they are
    coverage_done = 10;
  endfunction

  // faze build
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    // vytvoreni portu pro prijem (muze byt i v konstruktoru)
    // create a port for reception (can also be in the constructor)
    inst_in_fifo = new("inst_in_fifo", this);
    
    for(int i = 0; i < my_pkg::NUM_OF_PORTS; i++) begin
      inst_out_fifo[i] = new($sformatf("inst_out_fifo[%0d]", i), this);
    end
  endfunction

  // faze run - vlakno, ktere bude vybirat data z jednotlivych monitoru
  // phase run - thread that will collect data from individual monitors
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    
    // zamezeni ukonceni testu, dokud neni splneno pokryti
    // prevent test termination until coverage is met
    phase.raise_objection(this);
    
    // vytvoreni samostatnych vlaken - pro kazdy port jedno
    // creation of separate threads - one for each port
    for(int i = 0; i < my_pkg::NUM_OF_PORTS; i++) begin
      fork
        int index = i;
        scoreboard_match(index, phase);
      join_none
    end

    // ekvivalentni kod bez for cyklu
    // equivalent code without the for loop
//    fork
//      scoreboard_match(0, phase);
//      scoreboard_match(1, phase);
//      scoreboard_match(2, phase);
//      scoreboard_match(..., phase);
//    join

  endtask

  task scoreboard_match(int index, uvm_phase phase);
    // objekty, do kterych se budou ukladat data z monitoru
    // objects in which data from the monitor will be stored
    my_pkg::my_item in_item;
    my_pkg::my_item out_item;

    //`uvm_info(get_type_name(), $sformatf("Scoreboard: scoreboard_match: start - thread %0d", index), UVM_LOW)

    forever begin
      // blokujici cteni z vystupni fronty (vystupniho rozhrani)
      // blocking reading from the output queue (output interface)
      inst_out_fifo[index].get(out_item);
      // pokud prisla data z vystupniho portu, tak precti data ze vstupu (v sablone tam jina byt nemohou)
      // if data came from the output port, then read the data from the input (there can't be any other in the template)
      inst_in_fifo.get(in_item);

      // v sablone jsou adresy stejne jako poradova cisla portu -> adresu jde tedy doplnit primo
      // in the template the addresses are the same as the port serial numbers -> the address can be added directly
      out_item.addr = index;

      // porovnani
      // comparison
      if (~in_item.compare(out_item))
        // panika
        // panic
        `uvm_error(get_full_name(), $sformatf("Scoreboard: scoreboard_match - thread %0d : item mismatch\nin_item: \n%s\nout_item: \n%s", index, in_item.sprint(), out_item.sprint()))
      else
        // ok
        `uvm_info(get_full_name(), $sformatf("Scoreboard: scoreboard_match - thread %0d : item match\nin_item: \n%s\nout_item: \n%s", index, in_item.sprint(), out_item.sprint()), UVM_LOW)

      // v sablone se pocita s prenosem 10 paketu
      // in the template it only 10 packets are being transmitted
      coverage_done--;
      
      // pokud probehlo 10 paketu, tak konec testu (nic dalsiho neni potreba, staci stahnout namitku - objection)
      // if 10 packets have passed, then the test is over (nothing else is needed, just drop the objection)
      if (coverage_done <= 0) begin
        `uvm_info(get_full_name(), $sformatf("\n\nScoreboard: dummy coverage done -> finishing test.\n\n"), UVM_LOW)  
        phase.drop_objection(this);
      end
    end
  endtask

  // funkce, do ktere lze vlozit vypis pokryti (i jinou zpravu) po skonceni testu
  // function where you can insert a coverage report (and other messages) after the test is finished
  function void report_phase(uvm_phase phase);
    //`uvm_info(get_full_name(), $sformatf("Dopadlo to vyborne, jsem jen trochu v soku..."), UVM_LOW)
    //`uvm_info(get_full_name(), $sformatf("Th-Th-Th-Thats all Folks!"), UVM_LOW)
  endfunction

endclass
