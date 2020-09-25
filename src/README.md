# RNBIP_Pipelined-Microprocessor

Basic 8-bit microprocessor.

3-stage Pipeline:
1. Fetch
2. Read
3. Execute

## Modules

#### ALU
Combinational logic. Performs all the arithmetic and logical operations.
- Addition
- Subtraction
- Bitwise AND
- Bitwise OR
- Bitwise XOR

#### Flag Register
Contains four flags (Sign, Zero, Carry, Parity) which can be modified by ALU operations and can be used as conditions for branch operations.

#### Control Code Generator (CCG)
The CCG generates the control signals and mux select bits for each stage in a given instruction. The fetch stage is always the same.\
The `ControlCodeGen.v` file contains two modules, CCG1 and CCG2, which generate the signals for the read and execute stages respectively.\
There are a total of 17 control bits.

#### Data Memory
This is the memory a program can read from and write to during execution.\
The `DMinit.txt` file is used to initialise the memory in simulation.

#### Program Memory
The program memory stores opcodes and operands of the instructions comprising the program, and cannot be edited by the program. It is the only place where 16-bit data is used (8 bits for the opcode and operand each).\
A plaintext file can be used to initialise the program memory with the opcodes, for simulation.

#### Program Counter
Gives the address of the program memory from where the next operation is to be fetched.

#### Instruction Register
Stores the opcode before it is sent to the control code generator.

#### Register Array
Comprised of eight registers (`R0 - R7`) which are used for ALU & Data Memory operations.

#### Stack Pointer
Gives the address of the top of the stack (which is part of the data memory). The stack is addressed downwards from `0xFF`.
