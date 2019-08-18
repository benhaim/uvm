###################################
#
#     generate IPXACT
#TODO
ipxact = open('regmodel.ipxact','w')
ipxact.write('<?xml version="1.0" encoding="UTF-8"?>\n')
ipxact.write('<ipxact:component xmlns:ipxact="http://www.accellera.org/XMLSchema/IPXACT/1685-2014" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.accellera.org/ XMLSchema/IPXACT/1685-2014 http://www.accellera.org/XMLSchema/IPXACT/1685-2014/index.xsd">\n')
ipxact.write('  <ipxact:vendor>accellera.org</ipxact:vendor>\n')
ipxact.write('  <ipxact:library>ug</ipxact:library>\n')
ipxact.write('  <ipxact:name>ip</ipxact:name>\n')
ipxact.write('  <ipxact:version>1.0</ipxact:version>\n')
ipxact.write('  <ipxact:memoryMaps>\n')
ipxact.write('    <ipxact:memoryMap>\n')
ipxact.write('      <ipxact:name>some_top_level_name</ipxact:name>\n')
ipxact.write('      <ipxact:addressBlock>\n')
ipxact.write('        <ipxact:name>reg_block_name</ipxact:name>\n')
ipxact.write('        <ipxact:memoryOffset>0x0</ipxact:memoryOffset>\n')
ipxact.write('        <ipxact:range>0x1000</ipxact:range>\n')
ipxact.write('        <ipxact:width>32</ipxact:width>\n')
for idx,reg in enumerate(reg_list): # registers should be listed by order as in the CSV
    ipxact.write(("        <ipxact:register>\n"))
    ipxact.write(("          <ipxact:name>%s</ipxact:name>\n")%(reg))
    ipxact.write(("          <ipxact:size>32</ipxact:size>\n"))
    ipxact.write(("          <ipxact:addressOffset>0x%x</ipxact:addressOffset>\n")%(idx*4))
    if not fields_by_regs[reg]: error("no fields for reg " + reg)
    field_offset = 0
    for field in fields_by_regs[reg]:
        ipxact.write(("          <ipxact:field>\n"))
        ipxact.write(("            <ipxact:name>%s</ipxact:name>\n")%(field['name']))
        ipxact.write(("            <ipxact:bitWidth>%s</ipxact:bitWidth>\n")%(field['bits']))
        ipxact.write(("            <ipxact:bitOffset>%d</ipxact:bitOffset>\n")%(field_offset))
        field_offset += int(field['bits'])
        if not field['name']=='reserved':
            access = "read-only" if field['access']=="ro" else "read-write"
            ipxact.write(("            <ipxact:access>%s</ipxact:access>\n")%(access))
            ipxact.write(("            <ipxact:reset>%s</ipxact:reset>\n")%(field['reset']))
            ipxact.write(("            <ipxact:description>%s</ipxact:description>\n")%(field['desc']))
        ipxact.write(("          </ipxact:field>\n"))
    ipxact.write(("            </ipxact:register>\n"))
ipxact.write('      </ipxact:addressBlock>\n')
ipxact.write('    </ipxact:memoryMap>\n')
ipxact.write('  </ipxact:memoryMaps>\n')
ipxact.write('</ipxact:component>\n')

ipxact.close()
