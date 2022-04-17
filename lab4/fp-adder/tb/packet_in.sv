class packet_in extends uvm_sequence_item;
    rand integer A;
    rand integer B;    

    //A,B between -100000:0.00001 and 0.00001:100000
    constraint ab_range {
        //         -0.000001     -100000         0.00001  100000
        A inside {['hb58637bd:'hc7c35000],0,['h358637bd:'h47c35000]};
        B inside {['hb58637bd:'hc7c35000],0,['h358637bd:'h47c35000]};
        
    }

    `uvm_object_utils_begin(packet_in)
        `uvm_field_int(A, UVM_ALL_ON|UVM_HEX)
        `uvm_field_int(B, UVM_ALL_ON|UVM_HEX)
    `uvm_object_utils_end

    function new(string name="packet_in");
        super.new(name);
    endfunction: new
endclass: packet_in
