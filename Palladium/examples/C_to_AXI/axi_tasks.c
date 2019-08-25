#include <stdio.h>
#include <stdlib.h>
#include <math.h>


// 
//          AXI transactions sender
//
// this file is actually functions used by the verilog AXI driver, the
// driver is the one initiating the communication every AXI clock cycle.
// this slows down the emulation but allows the most flexability from 
// the FW side.
//

// struct for AXI command
typedef struct {
  char*             cmd;
  unsigned int      addr;
  unsigned int      data;
} AxiTransaction;

// global command to be used by all tasks
AxiTransaction g_next_command;

// this function is called by the driver once read
// flow is completed, in order to return the 
// value read
void set_axi_read_data (int rdata) 
{
    FILE *fptr;
    fptr = fopen("read_data.txt","w");
    printf ("\nC_CODE: read from addr 0x%x : 0x%x\n",g_next_command.addr,rdata);
    fprintf(fptr,"read 0x%x 0x%x",g_next_command.addr,rdata);
    fclose(fptr);
}

// this function is the one called every AXI clock
// cycle, it looks for the test file and parse and
// execute the command
char* get_next_axi_command_op   (int cmd_cnt) { 
    FILE *fp;
    fp = fopen("command.txt","r");
    if (fp == NULL)
    {
        return "null";
    }
    else
    {
        char* cmd_from_file;
        int addr_from_file,data_from_file;
        fscanf(fp,"%s 0x%x 0x%x",cmd_from_file,&addr_from_file,&data_from_file);
        //printf ("from file: %s 0x%x 0x%x\n",cmd_from_file,addr_from_file,data_from_file);
        if ( (cmd_from_file  != g_next_command.cmd)
           | (addr_from_file != g_next_command.addr)
           | (data_from_file != g_next_command.data) )
        {
            printf ("to exec: %s 0x%x 0x%x\n",cmd_from_file,addr_from_file,data_from_file);
            g_next_command.cmd  = cmd_from_file;
            g_next_command.addr = addr_from_file;
            g_next_command.data = data_from_file;
            remove("command.txt");
            return g_next_command.cmd;
        }
        else
        {
            return "null";
        }
    }
    fclose(fp);
    return "null";
}

// those functions handles the address and data of the
// AXI command, as every one of AXI command parts (operation,
// address, data) has a seperate flow to execute.
int   get_next_axi_command_addr (int cmd_cnt) { return g_next_command.addr; }
int   get_next_axi_command_data (int cmd_cnt) { return g_next_command.data; }

