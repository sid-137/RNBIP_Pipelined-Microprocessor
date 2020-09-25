# RNBIP_Pipelined-Microprocessor

Basic 8-bit microprocessor.

3-stage Pipeline:
1. Fetch
2. Read
3. Execute

## Architecture Diagram
![RNBIP](doc/Architecture.png)

The letter on the top left corner in each register denotes the cycle in which it is updated.
- F: Fetch
- R: Read
- E: Execute

<br/>

_Fetch_: In the fetch stage, the opcode and operand are read from the program memory, addressed by the program counter. The opcode is stored in the Instruction Register (IR) and operand is stored in the Operand Register 1 (OR1).

_Read_: The operand is buffered and copied into OR2 from OR1. Simultaneously, OR1 gets loaded with a new value of the operand, coming from the next fetch cycle.

_Execute_: The register values are read, ALU/data memory operations take place and any the registers are updated if needed. In case of a branch the program counter and stack pointer are updated as necessary.

<br/>

### More Info
More details about the implemented architecture are present in the [doc](doc) folder.

The code is present in the [src](src) folder.
