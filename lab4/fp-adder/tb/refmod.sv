class refmod extends uvm_component;
    `uvm_component_utils(refmod)
    
    packet_in tr_in;
    packet_out tr_out;
    uvm_get_port #(packet_in) in;
    uvm_put_port #(packet_out) out;

    integer pip[4:0] = '{0,0,0,0,0}; //Added integer to use as pipeline
    
    function new(string name = "refmod", uvm_component parent);
        super.new(name, parent);
        in = new("in", this);
        out = new("out", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr_out = packet_out::type_id::create("tr_out", this);
    endfunction: build_phase
    
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        forever begin
            in.get(tr_in);

            //Modified in order to do moltiplications with the floating points
            tr_out.data = $shortrealtobits($bitstoshortreal(tr_in.A) * $bitstoshortreal(tr_in.B));


            //tr_out.data = tr_in.A * tr_in.B;
            
            //$display("refmod_dec: input A = %d, input B = %d, output OUT = %d",tr_in.A, tr_in.B, tr_out.data);
            
            //Added floating point version
			$display("refmod_bin: input A = %x, input B = %x, output OUT = %x",tr_in.A, tr_in.B, tr_out.data);
            $display("refmod_float: input A = %3.9f, input B = %3.9f, output OUT = %3.9f",$bitstoshortreal(tr_in.A), $bitstoshortreal(tr_in.B), $bitstoshortreal(tr_out.data));
            out.put(tr_out);
        end
    endtask: run_phase
endclass: refmod
