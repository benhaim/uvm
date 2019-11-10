Visualizing UVM indications

Adding report indication to the waveform is not a powerful tool, but it’s fu*#ing convenient.
Thanks to the UVM being all over it is fairly simple.

TODO - need to find the sources I used

Everything is defined and constructed inside a single interface module, so just use some top level interface

interface some_top_if ();

    // this message can be used anywhere in the sequences to visualize
    // current task, or indicate interesting occurrences
    reg [64*8-1:0] verif_msg;

    // these parameters are used to visualize parameters form the UVM
    // reporter catcher
    logic uvm_err;
    reg [128*8-1:0] err_msg;
    reg [128*8-1:0] info_msg;
 
    // to make the uvm error indication to a pulse
    initial uvm_err = 0;
    always @(posedge uvm_err) begin
        #1 uvm_err = 1'b0;
    end
	
    // by extending the uvm_report_catcher class we gain access to
    // many interesting reports and indications generated during the
    // run through the tasks of the class
    class err_wave_ind extends uvm_report_catcher;
        // object constructor
        function new(string name="err_wave_ind");
            super.new(name);
        endfunction
        // add catcher to uvm_error and uvm_info
        function action_e catch();
            if(get_severity() == UVM_ERROR)
            begin
                uvm_err = 1'b1;
                err_msg = get_message();
            end else 
                info_msg = get_message();
            return THROW;
        endfunction
    endclass
    
    err_wave_ind err_wave_ind = new;

    initial begin
        // Catchers are callbacks on report objects (components are report
        // objects, so catchers can be attached to components).
        
        // To affect all reporters, use null for the object
        uvm_report_cb::add(null, err_wave_ind);

        // To affect some specific object use the specific reporter
        //       uvm_report_cb::add(mytest.myenv.myagent.mydriver, err_wave_ind);
        // To affect some set of components using the component name
        //       uvm_report_cb::add_by_name("*.*driver", err_wave_ind);
    end
endinterface


