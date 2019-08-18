###################################
#
#     generate (just print) ralf
#
ralf = open('regmodel.ralf','w')
for reg in reg_list:
    ralf.write("register " + reg + " {\n")
    ralf.write("    bytes 4;\n")
    if not fields_by_regs[reg]: error("no fields for reg " + reg)
    for field in fields_by_regs[reg]:
        ralf.write("    field " + field['name'] + " {\n")
        ralf.write("        bits     " + field['bits'] + "\n")
        if not field['name']=='reserved':
            ralf.write("        access   " + field['access'] + "\n")
            ralf.write("        reset    " + field['reset'] + "\n")
            ralf.write("        doc      " + field['desc'] + "\n")
        ralf.write("    }\n")
    ralf.write("}\n")
ralf.write("\n\n")
ralf.write("block prtn_fc_rgf {\n")
ralf.write("    bytes 4;\n")
ralf.write("    endian big;\n")
for idx,reg in enumerate(reg_list):
    ralf.write(("    register %-20s   @'h%0x;\n") % ( reg , idx*4 ))
ralf.write("}\n")
ralf.write("""
system prtn {
   bytes 80;
   block prtn_fc_rgf        @'h00000000;
}
""")
ralf.close()
