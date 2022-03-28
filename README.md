# MIPS-single-cycle
MIPS single cycle Verilog implementation based on Computer Organization and Design by David A. Patterson and John L. Hennessy.

## Overview
The implementation supports 1 cycle per instruction add, sub, lw, sw, beq and slt.
Based on the implementation scheme from chapter 5, The Processor: Datapath and Control of Computer 
Organization and Design by David A. Patterson and John L. Hennessy, 3rd edition.
The memory is structured in 32-bit words.

The instruction memory file, meminstr.dat contains the codes for the following program:
```
add $t0, $zero, $zero
add $t6, $zero, $zero

lw $t1, 64($t0)
lw $t2, 68($t0)
lw $t3, 72($t0)
sw $zero, 76($t0) #the sum will be at this location [76]
loop:
lw $t4, 0($t0)
lw $t5, 76($t6)
add $t5, $t5, $t4
sw $t5, 76($t6)
sub $t1, $t1, $t2
add $t0, $t0, $t3
beq $t1, $zero, done
beq $t1, $t1, loop #actually jump (because $t1 = $t1)
done:
#end
```
The program computes the sum of the first 16 values from the data memory. 
The result will be 5 and will be located in the data memory.

#Tools
Modelsim was used for simulation. There is a free student edition available.
QtSpim was used to view the codes for each instruction.

<hr />

# Assignment

The Verilog code corresponds to the single cycle MIPS and supports the following instructions – add,
sub, lw, sw, beq, slt. Simulate the verilog code for the single cycle MIPS processor with the test bench
provided in the link. Make sure you understand the code and it executes correctly before you do the
exercise.
-  Add the following MIPS instructions – addi, bne, j (use the MIPS instruction encoding format)
-  Test using the assembly level code for Q1 in Exercise L22 (Assume that you have an array of 10 elements with base address in $s0. Write an assembly program to find the minimum value from the array and swap it with the last element in the array) Use SPIM to get the machine language code. Make sure your code uses the 3 new instructions you added (addi, bne & j)

## Adding Instructions
### BNE
We will start by adding the instruction bne as it is pretty similar to
beq.
By analyzing how beq works, we can figure out that the decision
making for branching happens in the andm module and it takes zero
and branch condition as input while PCsel for the beq instruction.

```verilog
assign out=inA&inB;
```
To add support for bne instruction. We need to have additional signal
there such that it will check if we want to do the opposite where the
branch is 1 and the zero should be false.
We will create a signal Ne(wire here) in the module as a input such
that

```verilog
assign out= (ne==0) ? inA&inB:(inA&(!inB));
```
now if ne is 0, it will proceed with normal beq instruction. Now we
need to implement bne instruction in the control unit and add a
additional register there that stores Ne and make required changes
everywhere.
In Control unit, we will add the following new case for the bne
instruction.

```verilog
6'b000101:{RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, AluOP,
Ne}=10'bx0x000_1_01_1; //bne
```
And set Ne=0; for other instructions.
After making all the required changes to add bne instruction:
Summarizing the changes with git version History:


### ADDI

Now we will add support for the addi instruction. It is a I -format
Instruction, So its similar to lw and sw but not by much.
After looking at add and lw instruction. We can see that we just need
to add proper case statement for addi instruction.
As we need instruction[20:16] as the destination register address.

RegDst = 0
As we need immediate value as 2nd operand for ALU.
ALUSrc = 1
As we will not be reading from or writing to the memory.
MemtoReg=0
MemRead=0
MemWrite=0
As we will be writing to the register
RegWrite=1
Since we need ALU to do the add operation, we can just use 00 as
AluOp just like in case of lw or sw. Therefore,
AluOp=00
Ne =x; as we don’t need to write to PC.

Therefore
In Control module, adding a new case statement:
```verilog
6'b001000:{RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, AluOP,
Ne}=10'b010100_0_00_x; //addi
```

### J

Now we will add our final instruction J. It follows Jump addressing
and since our current MIPS CPU doesn’t support such instructions.
We need to make major changes.
First in Control Module, we will need to send another output, rather
than creating a new field. We will just extend our previously added
bit Ne to 2 bit size.
Then let us handle the situation like:
```
Ne = 2’b00 = for the normal beq instruction.
Ne = 2’b01 = for handling bne.
Ne = 2’b10 = for handling J instruction
```
Making Appropriate changes in control module we will have the
following case statement for J:
```verilog
6'b000010:{RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, AluOP,
Ne}=11'bxxxxxx_1_xx_10; //J
```
After making similar changes in other case statements to support the
11th bit.
Now for the Jump Address, we will create a new module Jaddress.
This will take PC[31:28], Instruction[25:0] as input and will give
output = PC[31:28] +2’b00 + (Instruction[25:00])
Note: Not ``` output = PC[31:28] +(Instruction[25:00]<2)``` because here the
memory is designed to be Word addressable and not Byte Addressable..

```verilog
module Jaddress(
input [25:0] in,
input [3:0] pc_in,
output [31:0] out
);
assign out ={pc_in, {2'b00}, in};
endmodule
```

Now to give this as an Input to the Program Counter, We will take a
Mux with Ne[1] as select as that decides the factor to do the normal
Branch instructions or Jump Instruction. The mux inputs will be the
output of Jaddress and SignExtend as they are the required PC
addresses for respective instructions (J and branch instructions.)
Since we already do have a Mux switch Module, we will just
instantiate that and Jaddress module.

```verilog
Jaddress jadd(Instruction[25:0], PC_adr[31:28], Jadr);
mux #(32) muxPC(Ne[1], signExtend, Jadr, muxPC_in);
```

Now we need to change the logic for PCSel. This is handled in the
andm module.
After making appropriate changes our andm module will be:
```verilog
module andm (inA, inB, out, ne);
//1 bit and for (branch & zero)
input inA, inB;
input [1:0] ne;
output [1:0]out;
assign out= (ne==0) ? inA&inB:((ne==2'b01) ? (inA&(!inB)):((ne==2'b10) ?
({{1'b1},inA}):0));
endmodule
```
We need to make changes in PC to handle Jump Instruction. We will
make use of ternary operator to operate depending upon the
instruction.
After making changes to PC sub module instantiation
```verilog
pclogic PC(clk, reset, muxPC_in, PC_adr, PCsel); //generate PC
module pclogic(clk, reset, ain, aout, pcsel);
input reset;
input clk;
input [31:0] ain;
//pecsel = branch & zero
input [1:0]pcsel;
output reg [31:0] aout;
always @(posedge clk ) begin
if (reset==1)
aout<=32'b0;
else
if ((pcsel==2'b00) || (pcsel==2'b10)) begin
aout<=aout+1;
end
if (pcsel==2'b01) begin
aout<=ain+aout+1; //branch
end
if (pcsel==2'b11) begin
aout<=ain; //branch
end
end
endmodule
```
After making required change like changing wire’s width size
wherever required.
We can use git version History to summarize the changes :
## Minimum Swap Program

After making slight changes to the MIPS assembly code written in
Exercise L22 to use only the supported instruction. we get: ( we will
only use the part from main to done, instructions like to print on the
console etc have been removed )

```asm
.data
# storing required data into memory
array: .word 67 43 3 7 2 35 9 62 4 8
.text
.globl main
main:
add $t1, $zero, $zero # i (index) = 0
add $s0, $zero, $zero # base address =0
# initializing minimum = storing a[0] value in minimum
lw $t0, 0($s0)
add $t7, $zero, $zero # index of minimum
# j (index) = 0 for printing updated array
add $t9, $zero, $zero
addi $s1, $zero, 10
loop: slt $t3, $t1, $s1 # if i == 10 goto done
beq $t3, $zero, swapmin
add $t6, $t1, $t1 # offset = index * 4
add $t6, $t6, $t1 # offset = index * 4
add $t6, $t6, $t1 # offset = index * 4
add $t5, $s0, $t6 # address = base_address + offset;
lw $t4, 0($t5) # t4= arr[i]
slt $t2, $t4, $t0 # setting less than in t2
# switching to min branch if a[i]<current_min
bne $t2, $zero, min
# label b_loop for returning after min has been updated
b_loop: addi $t1, $t1, 1 # i++
j loop
# min updates the minimum value and the index containing it
min: add $t0, $zero, $t4 # updating minimum value
# updating index of minimum so that we can swap values letter
add $t7, $zero, $t1
j b_loop
# for swapping the minimum and last array
swapmin:
lw $t4, 36($s0) # saving the last value of the array
add $t6, $t7, $t7 # offset = min_index *4
add $t6, $t6, $t7
add $t6, $t6, $t7
sw $t0, 36($s0) # storing min value in last position
add $t5, $s0, $t6 # min_address = base + offset
# storing the value of last element in the position of minimum value
sw $t4, 0($t5)
j done # to print the updated array
done:
```
In the final code we need to make change to make it compatible to
word addressable instead of byte addressable.
So we will not multiply indexes/offsets by 4.
lIke where we previously did multiply by 4(here add is used 4times).
We just add it ones with a zero.
And where load store operation occurs.
For example for store instruction.
```asm
sw $t0, 36($s0) # storing min value in last position
```
We will divide this by 4,
So in the end it becomes
```asm
sw $t0, 9($s0) # storing min value in last position
```
Considering this for the entire code, The final assembly hex Code:
```asm
00004820 //add $9, $0, $0 ; 8: add $t1, $zero, $zero # i (index) = 0
00008020 //add $16, $0, $0 ; 9: add $s0, $zero, $zero # base address =0
8e080000 //lw $8, 0($16) ; 11: lw $t0, 0($s0)
00007820 //add $15, $0, $0 ; 12: add $t7, $zero, $zero # index of minimum
0000c820 //add $25, $0, $0 ; 14: add $t9, $zero, $zero
2011000a //addi $17, $0, 10 ; 15: addi $s1, $zero, 10
0131582a //slt $11, $9, $17 ; 17: slt $t3, $t1, $s1 # if i == 10 goto done
1160000c //beq $11, $0, 12 [swapmin-0x00400040]
01207020 //add $14, $9, $zero ; 19: add $t6, $t1, $t1 # offset = index //
020e6820 //add $13, $16, $14 ; 22: add $t5, $s0, $t6 # address = base_address +
offset;
8dac0000 //lw $12, 0($13) ; 23: lw $t4, 0($t5) # t4= arr[i]
0188502a //slt $10, $12, $8 ; 24: slt $t2, $t4, $t0 # setting less than in t2
15400002 //bne $10, $0, 2 [min-0x0040005c]
21290001 //addi $9, $9, 1 ; 28: addi $t1, $t1, 1 # i++
08000006 //j 6 should go to line 7 as indexing is from 0 we jump to 6 j loop
000c4020 //add $8, $0, $12 ; 31: add $t0, $zero, $t4 # updating minimum value
00097820 //add $15, $0, $9 ; 33: add $t7, $zero, $t1
0800000D //j Go to line 14 [b_loop] ; 34: j b_loop
8E0C0009 //lw $12, 9($16) ; 37: lw $t4, 9($s0) # saving the last value of the
array 
01E07020 //add $14, $15, $zero ; 38: add $t6, $t7, $zero # offset = min_index //
AE080009 //sw $8, 9($16) ; 41: sw $t0, 9($s0) # storing min value in last
position
020e6820 //add $13, $16, $14 ; 42: add $t5, $s0, $t6 # min_address = base + offset
ADEC0000 //sw $12, 0($15) ; 44: sw $t4, 0($t5)
11200001 //beq
1120FFFF //beq
```
Note: text after // is ignored while reading the data.
It can be seen from the assembly hex code that we have removed the
multiple add operations while accessing/storing in memory to avoid
the multiples of 4 which is usually required for byte addressing.
Similarly Jump/branch instructions are modified to go to the
required nth line considering the same.

We need to store our array in the memory(mem_sync) and store the
base address in memory.
Now memory data : we will store the array starting at location 0 in
the memory.

We will use the same input as from the previous mips assembly code.
```
67 43 3 7 2 35 9 62 4 8
```
```
0000_0043 //0
0000_002B //1
0000_0003 //2
0000_0007 //3
0000_0002 //4
0000_0023 //5
0000_0009 //6
0000_003E //7
0000_0004 //8
0000_0008 //9
0000_0000 //10
0000_0001 //11
0000_0000 //12
0000_0000 //13
0000_0000 //14
0000_0001 //15
@40
0000_0010
@44
0000_0001
@48
0000_0001
```

Simulation:

Initial memory:

We can see that the memory does store the data from our input file.

Instructions memory:

We can see that all the instructions are added into the instruction
memory.

## Verification

We will verify the working of individual Instructions.

### addi:

For the instruction:
```asm
2011000a //addi $17, $0, 10 ; 15: addi $s1, $zero, 10 
```
We can see that after the value of $17($s1) after the instruction
2011000 is 0000000a which is equal to 10 and matches our required
result.


### Bne:

For the Instruction:
```asm
15400002 //bne $10, $0, 2 [min-0x0040005c]
```
Next Instruction:
```asm
21290001 //addi $9, $9, 1 ; 28: addi $t1, $t1, 1 # i++
```
Instruction If Branched:
```asm
000c4020 //add $8, $0, $12 ; 31: add $t0, $zero, $t4 # updating minimum value
```
When branching is done: (zero from alu is low)

We can see that the instruction changes from 15400002 to
000c4020.

When branching is not done: (zero from alu is high)

We can see that it goes from 15400002 to 21290001.

From the above two conditions we can see that it work as required.

### J:
For the Instruction:
```asm
08000006 //j 6 should go to line 7 as indexing is from 0 we jump to 6 j loop
```
Instruction at line 7 (counting from 1):
```asm
0131582a //slt $11, $9, $17 ; 17: slt $t3, $t1, $s1 # if i == 10 goto done
```
We can see that the jump instruction does change the next instruction to 0131582 from 0800006 instead of 000c4020 which is at next line.
Confirming all the 3 instructions added works properly.

Competition of Execution:

We can see that the program does reach the end(last instruction).

Final Memory:

We can see that the value 00000008 in the last index gets replaced
by the minimum value 00000002 and it gets placed into where
00000002 was present.

Confirming Our Code for minimum swap program works as expected.
