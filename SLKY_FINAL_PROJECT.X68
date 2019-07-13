*-----------------------------------------------------------
* Title      : FINAL PROJECT
* Written by : SLKY
* Date       : 5/15/2019
* Description: SLKY Final Project
*-----------------------------------------------------------
shift            EQU     12                   * Shift 12 bits 
*Program starts here
              ORG     $1000
start        CLR.L  D6
             CLR.L  D4
             MOVE.B   #11,D0
             MOVE.W   #$FF00,D1
             TRAP      #15
             LEA    $FFFFFE,SP                  *Set the stack pointer
**Prompt for User Input (start address):
             LEA    breakLn,A1
             Move.B #14,D0
             Trap   #15
             LEA    prompt,A1
             Move.B #14,D0
             Trap   #15
             LEA    promptSpecs,A1
             Move.B #14,D0
             Trap   #15
             LEA    promptSpecs2,A1
             Move.B #14,D0
             Trap   #15
             LEA    breakLn,A1
             Move.B #14,D0
             Trap   #15
             
             SUBQ   #5,D7
*------------------------------------------------*    
*-* Retreival of User Input for start address: *-*
*------------------------------------------------* 
getStartAddr LEA    center,A1
             Move.B #14,D0
             Trap   #15
             SUBQ   #2,D7
             Move.B  #$1, D4             * 1 in D4 means checking start length
             LEA     startingAddr,A1     * Moving variable startingAddr to A1 to store input
             Move.B  #2,D0               * Moving cin instruction to D0
             Trap     #15                * Executing instruction
             
             JSR     checkLength         * Check Length of input
             JSR     toHex               * Check for valid hex entry
             JSR     checkOdd            * Check if it is and odd number
             JSR     checkRange          * Check for valid range
 
**Prompt for User Input (end address):
             LEA    breakLn,A1
             Move.B #14,D0
             Trap   #15
             LEA    prompt2,A1
             Move.B #14,D0
             Trap   #15
             LEA    promptEnd,A1
             Move.B #14,D0
             Trap   #15
             LEA    promptEnd2,A1
             Move.B #14,D0
             Trap   #15
             LEA    breakLn,A1
             Move.B #14,D0
             Trap   #15
             
             SUBQ   #5,D7
               
               
*------------------------------------------------*    
*-*  Retreival of User Input for end address:  *-*
*------------------------------------------------*               
getEndAddr   LEA    center,A1
             Move.B #14,D0
             Trap   #15
             
             SUBQ   #2,D7
             
             Move.B  #$2, D4             * 2 in D4 means checking end length
             LEA     endingAddr,A1       * Moving variable startingAddr to A1 to store input
             Move.B  #2,D0               * Moving cin instruction to D0
             Trap     #15                * Executing instruction
             
             JSR     checkLength         * Check Length of input
             JSR     toHex               * Check for valid hex entry
             JSR     checkOdd            * Check if it is and odd number
             JSR     checkRange          * Check for valid range

**Input Correct dispay next task: 
             *CMP      #15,D7        * If: D7 >15
             *BGT      cont          * Display next message Else: clear screen
             Move.B   #11, D0       * Trap task 11 will be defined by D1
             Move.W   #$FF00,D1     * Instruction to clear page
             TRAP     #15           * Execute instruction
             Move.B   #30, D7       * Reset D7
           
             LEA    breakLn,A1
             Move.B #14,D0
             Trap   #15
             LEA    corrInput,A1
             Move.B #14,D0
             Trap   #15
             LEA    breakLn,A1
             Move.B #14,D0
             Trap   #15
             MOVE.L #$18,D7
              
mainloop       CMPA.L   A5,A6
               BEQ      maindone
               CMPA.L   A5,A6
               BLT      maindone
               CMP.B    #0,D7
               BEQ      loadnewpage
               LEA      $FFFFFE,SP
               CLR.L    D1
               CLR.L    D2
               CLR.L    D3
               CLR.L    D4
               CLR.L    D5
               CLR.L    D6                      *Clear Registers
               MOVEA.L  A5,A4                   *instruction is now current line
               LEA      message,A2
               LEA      jmp_table,A0            *Index into the table
               CLR.L    D0                      *Zero it
               MOVE.L   A5,D4
               LSR.W    #8,D4
               LSR.W    #8,D4
               JSR      wordtoasc               *Process first half of current address
               MOVE.W   A5,D4
               JSR      wordtoasc               *Process second half of current address
               MOVE.B   #$20,(A2)+              *Add " " to the message
               MOVE.W   (A4)+,D2                *Get the instruction
               MOVE.W   D2,D3
               MOVE.B   #shift,D1               *Shift 12 bits to the right  
               LSR.W    D1,D2                   *Move the bits
               MULU     #6,D2                   
               JSR      0(A0,D2)                *Jump into proper op code
               LEA      message,A1
               CMP.B    #1,D1
               BEQ      error                   *Error flag is set
               CMP.B    #2,D1
               BEQ      invalidea               *Invalid EA flag
               JSR      formatOutput            *Print message
               SUB.B    #1,D7                   *Subtract from line counter
               MOVEA.L  A4,A5                   *Move the current line to the instruction
               BRA      mainloop            

invalidea      LEA      message,A2
               JSR      formatOutput            *Print the message
               ADDA.L   #2,A5                   *Increment address
               SUB.B    #1,D7
               BRA      mainloop
                       
error          LEA      message,A2
               MOVE.L   A5,D4
               LSR.W    #8,D4
               LSR.W    #8,D4
               JSR      wordtoasc               *Process first half of current address
               MOVE.W   A5,D4
               JSR      wordtoasc               *Process second half of current address
               MOVE.B   #$20,(A2)+              *Add " " to the message
               MOVE.B   #$44,(A2)+
               MOVE.B   #$41,(A2)+
               MOVE.B   #$54,(A2)+
               MOVE.B   #$41,(A2)+
               MOVE.B   #$20,(A2)+              *Add "DATA " to the message
               MOVE.W   (A5)+,D4                *Get the original instruction
               JSR      wordtoasc               *convert word to ascii
               MOVE.B   #0,(A2)+                *Add null character
               JSR      formatOutput   
               SUB.B    #1,D7                   *Subtract from line counter
               BRA      mainloop
       
loadnewpage    LEA      instruct,A1
               MOVE.B   #14,D0
               TRAP     #15
               LEA      userInput,A1
               MOVE.B   #2,D0
               TRAP     #15
               MOVE.W   (A1),D4
               CMP.W    #$4E4F,D4
               BEQ      start
               MOVE.B   #11,D0
               MOVE.W   #$FF00,D1
               TRAP     #15
               MOVE.B   #27,D7
               BRA      mainloop
       
maindone       LEA      message,A1
               LEA      message,A2
               MOVE.B   #$45,(A2)+
               MOVE.B   #$4E,(A2)+
               MOVE.B   #$44,(A2)+              *Add "END" to the message
               MOVE.B   #0,(A2)+                *Add null character
               JSR      formatOutput            *Print message
               LEA      instruct,A1
               MOVE.B   #14,D0
               TRAP     #15
               LEA      userInput,A1
               MOVE.B   #2,D0
               TRAP     #15
               MOVE.B   #11,D0
               MOVE.W   #$FF00,D1
               TRAP     #15
               JMP      continueprog
               
continueprog   LEA      againPrompt,A1
               MOVE.B   #14,D0
               TRAP     #15
               LEA      continueprompt,A1
               TRAP     #15
               LEA      userInput,A1
               MOVE.B   #2,D0
               TRAP     #15
               MOVE.W   (A1),D4
               CMP.W    #$4E4F,D4
               BEQ      stopprog
               JMP      start
               
stopprog       MOVE.B   #9,D0
               TRAP     #15
              SIMHALT
*---------------------------------------------------------------------
*TESTINGTESTINGTESTINGTESTINGTESTINGTESTINGTESTINGTESTINGTESTINGTESTING
*---------------------------------------------------------------------               
               
*---------------------------------------------------------------------
*JUMP TABLE for OP CODES
*   D2: Jump offset
*   A0: JUMP TABLE
*---------------------------------------------------------------------
jmp_table      JMP         code0000
               JMP         code0001
               JMP         code0010
               JMP         code0011
               JMP         code0100
               JMP         code0101
               JMP         code0110
               JMP         code0111
               JMP         code1000
               JMP         code1001
               JMP         code1010
               JMP         code1011
               JMP         code1100
               JMP         code1101
               JMP         code1110
               JMP         code1111
               
*---------------------------------------------------------------------
*NOT USED
*---------------------------------------------------------------------
code0000       MOVE.B   #1,D1
               RTS

*---------------------------------------------------------------------
*MOVE.B
*   A2: Message
*   D3: Original Instruction
* TODO: DIFFERENTIATE BETWEEN MOVE AND MOVEA
*---------------------------------------------------------------------
code0001       MOVE.B   #$4D,(A2)+
               MOVE.B   #$4F,(A2)+
               MOVE.B   #$56,(A2)+
               MOVE.B   #$45,(A2)+              *Add "MOVE" to the message
               MOVE.B   #%00,D6
               MOVE.W   D3,D4
               ANDI.W   #%0000000111000000,D4
               LSR      #6,D4
               JSR      isaddress
               MOVE.B   #$2E,(A2)+              *Add ".B  " to the message
               MOVE.B   #$42,(A2)+
               MOVE.B   #$20,(A2)+
               MOVE.W   D3,D2                   *Make a copy of the original instruction
               ANDI.W   #%0000000000111000,D2
               LSR      #3,D2                   *Get source mode
               MULU     #6,D2
               MOVE.W   D3,D4
               ANDI.W   #%0000000000000111,D4
               LEA      ea_jump,A0              *load jump table
               JSR      0(A0,D2)                *jump to source mode
               MOVE.B   #$2C,(A2)+
               MOVE.W   D3,D2
               ANDI.W   #%0000000111000000,D2
               LSR      #6,D2
               MULU     #6,D2
               MOVE.W   D3,D4
               ANDI.W   #%0000111000000000,D4
               LSR      #8,D4
               LSR      #1,D4
               JSR      0(A0,D2)
               MOVE.B   #$0,(A2)                *end message(NULL)
               JSR      movecheck
               RTS

movecheck      MOVE.W   D3,D2
               LSR      #6,D2
               ANDI.W   #$0007,D2               *Get EA mode
               MOVE.W   D3,D4
               LSR      #8,D4                   *Get register
               LSR      #1,D4
               ANDI.W   #$0007,D4
               CMP.B    #%111,D2
               BEQ      moveimm                *Check if destination is Immediate Addressing
               RTS
               
moveimm        CMP.B    #%100,D4
               BEQ      moveerror
               RTS
               
moveerror      LEA      message,A2
               ADDA.W   #9,A2                   *load message and move to after address
               MOVE.B   #$4D,(A2)+
               MOVE.B   #$4F,(A2)+
               MOVE.B   #$56,(A2)+
               MOVE.B   #$45,(A2)+
               MOVE.B   #$20,(A2)+              *Add "MOVE " back to message
               MOVE.B   #2,D1
               JSR      invalidmsg              *Add "INVALID EA" to message
               RTS

*---------------------------------------------------------------------
*MOVE.L
*   A2: Message
*   D3: Original Instruction
* TODO: DIFFERENTIATE BETWEEN MOVE AND MOVEA
*---------------------------------------------------------------------
code0010       MOVE.B   #$4D,(A2)+
               MOVE.B   #$4F,(A2)+
               MOVE.B   #$56,(A2)+
               MOVE.B   #$45,(A2)+              *Add "MOVE" to the message
               MOVE.B   #%10,D6
               MOVE.W   D3,D4
               ANDI.W   #%0000000111000000,D4
               LSR      #6,D4
               JSR      isaddress
               MOVE.B   #$2E,(A2)+              *Add ".L  " to the message
               MOVE.B   #$4C,(A2)+
               MOVE.B   #$20,(A2)+
               MOVE.W   D3,D2                   *Make a copy of the original instruction
               ANDI.W   #%0000000000111000,D2
               LSR.W    #3,D2                   *Get source mode
               MULU     #6,D2
               MOVE.W   D3,D4
               ANDI.W   #%0000000000000111,D4
               LEA      ea_jump,A0              *load jump table
               JSR      0(A0,D2)                *jump to source mode
               MOVE.B   #$2C,(A2)+
               MOVE.W   D3,D2
               ANDI.W   #%0000000111000000,D2
               LSR      #6,D2
               MULU     #6,D2
               MOVE.W   D3,D4
               ANDI.W   #%0000111000000000,D4
               LSR      #8,D4
               LSR      #1,D4
               JSR      0(A0,D2)
               MOVE.B   #$0,(A2) *end message (NULL)
               JSR      movecheck
               RTS
               
*---------------------------------------------------------------------
*MOVE.W
*   A2: MESSAGE
*   D3: Original Instruction
*---------------------------------------------------------------------
code0011       MOVE.B   #$4D,(A2)+
               MOVE.B   #$4F,(A2)+
               MOVE.B   #$56,(A2)+
               MOVE.B   #$45,(A2)+              *Add "MOVE" to the message
               MOVE.B   #%01,D6                 *Set size flag
               MOVE.W   D3,D4
               ANDI.W   #%0000000111000000,D4
               LSR      #6,D4
               JSR      isaddress               *Check if move is movea
               MOVE.W   D3,D2                   *Make a copy of the original instruction
               MOVE.B   #$2E,(A2)+              *Add ".W  " to the message
               MOVE.B   #$57,(A2)+
               MOVE.B   #$20,(A2)+
               ANDI.W   #%0000000000111000,D2
               LSR      #3,D2                   *Get source mode
               MULU     #6,D2
               MOVE.W   D3,D4
               ANDI.W   #%0000000000000111,D4
               LEA      ea_jump,A0              *load jump table
               JSR      0(A0,D2)                *jump to source mode
               MOVE.B   #$2C,(A2)+
               MOVE.W   D3,D2
               ANDI.W   #%0000000111000000,D2
               LSR      #6,D2
               MULU     #6,D2
               MOVE.W   D3,D4
               ANDI.W   #%0000111000000000,D4
               LSR      #8,D4
               LSR      #1,D4
               JSR      0(A0,D2)
               MOVE.B   #$0,(A2)                *end message(NULL)
               JSR      movecheck
               RTS
               
*---------------------------------------------------------------------
*JSR/RTS/NOP/MOVEM/LEA/NOT
*   A2: Message
*   A4: Current Line
*   D3: Original Instruction
*---------------------------------------------------------------------
code0100       CMP.W    #%0100111001110101,D3
               BEQ      returnsub               *Instruction is RTS
               CMP.W    #%0100111001110001,D3
               BEQ      noop                    *Instruction is NOP
               MOVE.W   D3,D4
               LSR      #8,D4
               LSR      #1,D4
               ANDI.W   #$0007,D4
               CMP.B    #$07,D4
               BEQ      jumpsub                 *Instruction is JSR
               CMP.B    #3,D4
               BEQ      _not                    *Instruction is NOT
               MOVE.W   D3,D4
               LSR      #6,D4
               ANDI.W   #$0007,D4
               CMP.B    #$07,D4
               BEQ      loadea                  *Instruction is LEA
               MOVE.W   D3,D4
               LSR      #7,D4
               ANDI.W   #$0007,D4
               CMP.B    #1,D4
               BEQ      movemult                *Instruction is MOVEM
               MOVE.B   #1,D1
               RTS
               
movemult       MOVE.B   #$4D,(A2)+
               MOVE.B   #$4F,(A2)+
               MOVE.B   #$56,(A2)+
               MOVE.B   #$45,(A2)+
               MOVE.B   #$4D,(A2)+              *Add "MOVEM" to the message
               MOVE.W   D3,D4
               LSR      #6,D4  
               ANDI.W   #$0001,D4                
               JSR      movemsize               *Process the size of MOVEM
               MOVE.W   D3,D4
               LSR      #8,D4
               LSR      #2,D4
               ANDI.W   #$0001,D4
               CMP.B    #1,D4                   *Check Direction of themove
               BEQ      memtoreg                *Move from memory to register
               MOVE.W   D3,D4                   *A move from registers to mem
               LSR      #8,D4
               LSR      #2,D4                   *Get direction of transfer
               ANDI.W   #$0001,D4
               CMP.B    #0,D4
               BEQ      regtomem                *Moving registers to memory
               RTS
               
regtomem       MOVE.W   (A4)+,D4                *get the word from the current line
               JSR      loopstart               *start the loop
               MOVE.B   #$2C,-(A2)              *Add "," to the message
               MOVE.B   #$2C,(A2)+
               MOVE.W   D3,D2
               LSR      #3,D2
               ANDI.W   #$0007,D2               *Get EA mode
               MULU     #6,D2
               MOVE.W   D3,D4
               ANDI.W   #$0007,D4               *Get EA register
               LEA      ea_jump,A0
               JSR      0(A0,D2)                *Process EA
               MOVE.B   #0,(A2)+                *Add the null character to the message
               JSR      regtomemcheck           *check for errors
               RTS

regtomemcheck  MOVE.W   D3,D2
               LSR      #3,D2
               ANDI.W   #$0007,D2
               CMP.B    #%000,D2
               BEQ      movemerror
               CMP.B    #%001,D2
               BEQ      movemerror
               CMP.B    #%011,D2
               BEQ      movemerror
               MOVE.W   D3,D4
               ANDI.W   #$0007,D4
               CMP.B    #%111,D2
               BEQ      movemimm
               RTS           

movemimm       CMP.B    #%100,D4
               BEQ      movemerror
               RTS                   
 
movemerror     LEA      message,A2
               ADDA.W   #9,A2
               MOVE.B   #$4D,(A2)+
               MOVE.B   #$4F,(A2)+
               MOVE.B   #$56,(A2)+
               MOVE.B   #$45,(A2)+
               MOVE.B   #$4D,(A2)+
               MOVE.B   #$20,(A2)+
               JSR      invalidmsg
               MOVE.B   #2,D1
               RTS
               
              
loopstart      MOVE.W   D4,-(SP)                *Save the word in the stack
               MOVE.B   #0,D6                   *Start the counter for decrement loop
               MOVE.W   D3,D2
               LSR      #3,D2
               ANDI.W   #$0007,D2
               CMP.B    #%100,D2
               BEQ      movemdecrLoopD           *Start the pre decrement loop
               MOVE.B   #8,D6                    *Otherwise, start counter for other loop
               JMP      movemLoopA               *Start other loop
               
movemLoopA     CMP.B    #0,D6
               BEQ      loopAdone                *Processed the address registers
               SUB.B    #1,D6                    *Otherwise, decrement counter
               LSR      #8,D4
               LSR      #7,D4                    *Get the most significant bit
               CMP.W    #$1,D4
               BEQ      movemAtrue               *Bit is on
               MOVE.W   (SP),D4                  *Get original word from stack
               ROL.W    #1,D4                    *Rotate word to put next bit is MSB
               MOVE.W   D4,(SP)                  *Save word onto the stack again
               BRA      movemLoopA               *Go back to loop

movemAtrue     MOVE.B   D6,D4                    *Current number in the list
               MOVE.B   #$41,(A2)+               *Add "A" to the message
               JSR      hextoasc                 *Process register number
               MOVE.B   #$2F,(A2)+               *Add "/" to the message
               MOVE.W   (SP),D4                  *Get the original word
               ROL.W    #1,D4                    *Rotate word to put next bit in MSB
               MOVE.W   D4,(SP)                  *Save the word onto the stack
               BRA      movemLoopA               *go back to loop   

loopAdone      MOVE.B   #8,D6                    *Reset counter
               BRA      movemLoopD               *Start the next loop        
               
movemLoopD     CMP.B    #0,D6                    *Process data registers
               BEQ      loopDdone                *Similar to movemLoopA
               SUB.B    #1,D6
               LSR      #8,D4
               LSR      #7,D4
               CMP.W    #$1,D4
               BEQ      movemDtrue
               MOVE.W   (SP),D4
               ROL.W    #1,D4
               MOVE.W   D4,(SP)
               BRA      movemLoopD
               
movemDtrue     MOVE.B   #$44,(A2)+               *Add "D" to the message
               MOVE.B   D6,D4
               JSR      hextoasc
               MOVE.B   #$2F,(A2)+
               MOVE.W   (SP),D4
               ROL.W    #1,D4
               MOVE.W   D4,(SP)
               BRA      movemLoopD

loopDdone      MOVE.W   (SP)+,D4                *reset stack
               RTS                              *didn't do A2+ since the null character might need to be overwritten
               
movemdecrLoopD CMP.B    #8,D6                   *Check if the loop is done
               BEQ      decrDdone               *loop is done
               MOVE.W   (SP),D4                 *Get the word from the stack
               LSR      #8,D4
               LSR      #7,D4                   *Get MSB
               CMP.W    #$1,D4
               BEQ      decrDtrue               *Bit is on
               MOVE.W   (SP),D4                 *get word from stack
               ROL.W    #1,D4                   *rotate by 1 to get next MSB
               MOVE.W   D4,(SP)                 *Save word to stack
               ADD.B    #1,D6                   *Increase counter
               BRA      movemdecrLoopD          *enter loop again
               
decrDtrue      MOVE.B   #$44,(A2)+              *Add "D" to the message
               MOVE.B   D6,D4
               JSR      hextoasc                *Process the current register
               MOVE.B   #$2F,(A2)+
               MOVE.W   (SP),D4                 *Get word from stack
               ROL.W    #1,D4                   *Rotate to get next MSB
               MOVE.W   D4,(SP)                 *Save word back to stack
               ADD.B    #1,D6                   *Increase Counter
               BRA      movemdecrLoopD          *go back to loop

decrDdone      MOVE.B   #0,D6                   *Reset the counter
               BRA      decrLoopA               *Start next loop  

decrLoopA      CMP.B    #8,D6
               BEQ      decrAdone               *similar to movemdecrLoopD             
               MOVE.W   (SP),D4
               LSR      #8,D4
               LSR      #7,D4
               CMP.W    #$1,D4
               BEQ      decrAtrue
               MOVE.W   (SP),D4
               ROL.W    #1,D4
               MOVE.W   D4,(SP)
               ADD.B    #1,D6
               BRA      decrLoopA

decrAtrue      MOVE.B   #$41,(A2)+              *Add "A" to the message
               MOVE.B   D6,D4
               JSR      hextoasc                *Process the register number
               MOVE.B   #$2F,(A2)+
               MOVE.W   (SP),D4
               ROL.W    #1,D4
               MOVE.W   D4,(SP)
               ADD.B    #1,D6
               BRA      decrLoopA

decrAdone      MOVE.W   (SP)+,D4
               RTS            
            
returnsub      MOVE.B   #$52,(A2)+
               MOVE.B   #$54,(A2)+
               MOVE.B   #$53,(A2)+              *Add "RTS" to the message
               MOVE.B   #$0,(A2)+               *Add null character
               RTS

noop           MOVE.B   #$4E,(A2)+
               MOVE.B   #$4F,(A2)+
               MOVE.B   #$50,(A2)+              *Add "NOP" to the message
               MOVE.B   #$0,(A2)+               *Add null character
               RTS

jumpsub        MOVE.B   #$4A,(A2)+
               MOVE.B   #$53,(A2)+
               MOVE.B   #$52,(A2)+              *Add "JSR" to the message
               MOVE.B   #$20,(A2)+              *Add "  " to the message
               MOVE.W   D3,D2               
               MOVE.W   D3,D4
               LSR      #3,D2
               ANDI.W   #$0007,D2               *Get EA mode
               ANDI.W   #$0007,D4               *Get Register
               JSR      jsrcheck                *Check for invalid EA
               MULU     #6,D2
               LEA      ea_jump,A0
               JSR      0(A0,D2)                *Process the EA
               MOVE.B   #$0,(A2)+               *Add null character
               RTS

jsrcheck       CMP.B    #%000,D2
               BEQ      jsrerror
               CMP.B    #%001,D2
               BEQ      jsrerror
               CMP.B    #%011,D2
               BEQ      jsrerror
               CMP.B    #%100,D2
               BEQ      jsrerror
               CMP.B    #%111,D2
               BEQ      jsrimm                *Check if the ea is immediate
               RTS                              *No Error
               
jsrimm         CMP.B    #%100,D4
               BEQ      jsrerror
               RTS               
               
jsrerror       LEA      message,A2
               ADDA.W   #9,A2
               MOVE.B   #$4A,(A2)+
               MOVE.B   #$53,(A2)+
               MOVE.B   #$52,(A2)+
               MOVE.B   #$20,(A2)+
               MOVE.B   #2,D1
               JSR      invalidmsg
               RTS               
               
checkimm       CMP.B    #%100,D4
               BEQ      seterror                *Immediate addressing (Invalid)
               RTS                              *absolute addressing (Valid)               

loadea         MOVE.B   #$4C,(A2)+
               MOVE.B   #$45,(A2)+
               MOVE.B   #$41,(A2)+              *Add "LEA" to the message
               MOVE.B   #$20,(A2)+              *Add " " to the message
               MOVE.W   D3,D2
               MOVE.W   D3,D4
               ANDI.W   #$0007,D4               *Get register
               LSR      #3,D2
               ANDI.W   #$0007,D2               *Get EA mode
               JSR      leacheck                *Check for invalid EA
               MULU     #6,D2
               LEA      ea_jump,A0
               JSR      0(A0,D2)                *Jump to the proper EA Code
               MOVE.B   #$2C,(A2)+              *Add "," to the message
               MOVE.B   #$41,(A2)+              *Add "A" to the message
               MOVE.W   D3,D4
               LSR      #8,D4
               LSR      #1,D4
               ANDI.W   #$0007,D4
               JSR      hextoasc                *Process the register
               MOVE.B   #$0,(A2)+               *Add null character
               RTS

leacheck       CMP.B    #%000,D2
               BEQ      seterror
               CMP.B    #%001,D2
               BEQ      seterror
               CMP.B    #%011,D2
               BEQ      seterror
               CMP.B    #%100,D2
               BEQ      seterror
               CMP.B    #%111,D2
               BEQ      checkimm                *Check if the ea is immediate
               RTS                              *No Error

_not           MOVE.B   #$4E,(A2)+
               MOVE.B   #$4F,(A2)+
               MOVE.B   #$54,(A2)+              *Add "NOT" to the message
               MOVE.W   D3,D4
               LSR      #6,D4
               ANDI.W   #$0003,D4
               JSR      notsize                 *Process the size
               MOVE.W   D3,D2
               LSR      #3,D2
               ANDI.W   #$0007,D2               *Get EA mode
               MOVE.W   D3,D4
               ANDI.W   #$0007,D4               *Get Register
               JSR      notcheck                *Check for invalid EAs
               MULU     #6,D2
               LEA      ea_jump,A0
               JSR      0(A0,D2)
               MOVE.B   #$0,(A2)+               *Add null character to the message
               RTS
               
notcheck       CMP.B    #%001,D2
               BEQ      noterror
               CMP.B    #%111,D2
               BEQ      notimm
               RTS
               
notimm         CMP.B    #%100,D4
               BEQ      noterror
               RTS               
               
noterror       LEA      message,A2
               ADDA.W   #9,A2
               MOVE.B   #$4E,(A2)+
               MOVE.B   #$4F,(A2)+
               MOVE.B   #$54,(A2)+
               MOVE.B   #$20,(A2)+
               JSR      invalidmsg
               MOVE.B   #2,D1
               RTS               

notsize        MOVE.B   #$2E,(A2)+              *Add "." to the message
               CMP.B    #0,D4
               BEQ      notbyte
               CMP.B    #1,D4
               BEQ      notword
               CMP.B    #2,D4
               BEQ      notlong
               MOVE.B   #1,D1
               RTS
               
notbyte        MOVE.B   #$42,(A2)+              
               MOVE.B   #$20,(A2)+              *Add "B  " to the message
               RTS
               
notword        MOVE.B   #$57,(A2)+
               MOVE.B   #$20,(A2)+              *Add "L  " to the message
               RTS                              

notlong        MOVE.B   #$4C,(A2)+
               MOVE.B   #$20,(A2)+              *Add "L  " to the message
               RTS       

movemsize      MOVE.B   #$2E,(A2)+
               CMP.B    #0,D4
               BEQ      wordmovem
               MOVE.B   #$4C,(A2)+              *Size is long
               MOVE.B   #$20,(A2)+              *Add ".L  " to the message
               RTS

wordmovem      MOVE.B   #$57,(A2)+
               MOVE.B   #$20,(A2)+              *Add ".W  " to the message
               RTS                              

memtoreg       MOVE.W   D3,D2                   *Otherwise, mem to registers
               MOVE.W   (A4)+,-(SP)             *Get register mask
               LSR      #3,D2
               ANDI.W   #$0007,D2               *get the ea mode
               MULU     #6,D2
               MOVE.W   D3,D4
               ANDI.W   #$0007,D4               *get the register
               LEA      ea_jump,A0
               JSR      0(A0,D2)                *Process the EA
               MOVE.B   #$2C,(A2)+              *Add "," to the message
               MOVE.W   (SP)+,D4                *Get the word from the stack
               JSR      loopstart               *start the loop
               MOVE.B   #0,-(A2)                *Add the null character to the message
               JSR      memtoregcheck
               RTS
               
memtoregcheck  MOVE.W   D3,D2
               LSR      #3,D2
               ANDI.W   #$0007,D2
               CMP.B    #%000,D2
               BEQ      movemerror
               CMP.B    #%001,D2
               BEQ      movemerror
               CMP.B    #%100,D2
               BEQ      movemerror
               MOVE.W   D3,D4
               ANDI.W   #$0007,D4
               CMP.B    #%111,D2
               BEQ      movemimm                *Check for immediate data
               RTS                              *Valid     

     

*---------------------------------------------------------------------
*ADDQ
*   A2: Message
*   D3: Original Instruction
*---------------------------------------------------------------------
code0101      MOVE.B    #$41,(A2)+
              MOVE.B    #$44,(A2)+
              MOVE.B    #$44,(A2)+
              MOVE.B    #$51,(A2)+              *Add "ADDQ" to message
              MOVE.W    D3,D4                   *Make a copy of original
              LSR       #6,D4
              ANDI.W    #%0000000000000011,D4
              JSR       addqsize                *Subroutine to process size
              MOVE.B    #$20,(A2)+              *Add "  "to message
              MOVE.W    D3,D4
              LSR       #8,D4
              LSR       #1,D4
              ANDI.W    #%0000000000000111,D4
              MOVE.B    #$23,(A2)+
              MOVE.B    #$24,(A2)+              *Add "#$" to message
              JSR       hextoasc                *Process data
              MOVE.B    #$2C,(A2)+              *Add "," to message
              MOVE.W    D3,D2
              LSR       #3,D2
              ANDI.W    #%0000000000000111,D2
              MULU      #6,D2
              MOVE.W    D3,D4
              ANDI.W    #%0000000000000111,D4
              LEA       ea_jump,A0
              JSR       0(A0,D2)                *Process destination EA
              MOVE.B    #$00,(A2)+              *Add null characters
              JSR       addqerrorcheck
              RTS
              
addqerrorcheck MOVE.W   D3,D4
              LSR       #6,D4
              ANDI.W    #$0003,D4
              CMP.B     #%11,D4
              BEQ       seterror                *Invalid size
              MOVE.W    D3,D2
              LSR       #3,D2                   *Get ea
              ANDI.W    #$0007,D2
              MOVE.W    D3,D4
              ANDI.W    #$0007,D4               *get register
              CMP.B     #%111,D2
              BEQ       addqimm                *Check for immediate addressing
              RTS                               *Valid
              
addqimm       CMP.B     #%100,D4
              BEQ       addqerror
              RTS              

addqerror     LEA       message,A2
              ADDA.W    #9,A2
              MOVE.B    #$41,(A2)+
              MOVE.B    #$44,(A2)+
              MOVE.B    #$44,(A2)+
              MOVE.B    #$51,(A2)+
              MOVE.B    #$20,(A2)+
              JSR       invalidmsg
              MOVE.B    #2,D1
              RTS

*---------------------------------------------------------------------
*Bcc (BGT,BLE,BEQ,BRA)
*   A2: Message
*   A4: Next Line
*   A5: Current Instruction
*   D3: Original Instruction
*---------------------------------------------------------------------
code0110      MOVE.B   #$42,(A2)+
              MOVE.W   D3,D4
              LSR      #8,D4
              ANDI.W   #$000F,D4
              JSR      proccondition            *Process the conditional
              MOVE.B   #$20,(A2)+
              MOVE.W   D3,D4
              ANDI.W   #$00FF,D4
              CMP.W    #$FF,D4                  *32 bit displacement
              BEQ      bit32
              CMP.W    #$00,D4
              BEQ      bit16                    *16 bit displacement
              JSR      procdisplace             *Process 8 bit displacement
              RTS

bit32         MOVE.L    (A4)+,D4                *Get long displacement
              JMP       procdisplace            *process the displacement

bit16         MOVE.W    (A4)+,D4                *Get the word displacement
              JMP       procdisplace            *Process the displacement

procdisplace  ADD.L     A5,D4                   *Add displacement to the current address
              MOVE.W    D4,-(SP)                *Save the lower word into the stack
              LSR.L     #8,D4
              LSR.L     #8,D4                   *Get the high order word
              MOVE.B    #$24,(A2)+              *Add "$" to the message
              JSR       wordtoasc               *Process the high order word
              MOVE.W    (SP)+,D4                *Get the low order word
              JSR       wordtoasc               *Process the low order word
              MOVE.B    #0,(A2)+
              RTS
*---------------------------------------------------------------------
*MOVEQ
*   A2: Message
*   D3: Original Instruction
*---------------------------------------------------------------------
code0111       MOVE.B   #$4D,(A2)+
               MOVE.B   #$4F,(A2)+
               MOVE.B   #$56,(A2)+
               MOVE.B   #$45,(A2)+              *Add "MOVE" to the message
               MOVE.B   #$51,(A2)+              *Add "Q" to the message      
               MOVE.B   #$20,(A2)+              *Add "  " to the message
               MOVE.B   #$23,(A2)+              *Add "#" to the message
               MOVE.B   #$24,(A2)+              *Add "$" to the  message
               MOVE.W   D3,D4
               LSR      #4,D4
               ANDI.W   #%0000000000001111,D4
               JSR      hextoasc                *Process the first hex digit
               MOVE.W   D3,D4
               ANDI.W   #%0000000000001111,D4
               JSR      hextoasc                *Process the second hex digit
               MOVE.B   #$2C,(A2)+              *Add "," to the message
               MOVE.B   #$44,(A2)+              *Add "D" to the message
               MOVE.W   D3,D4
               LSR      #8,D4
               LSR      #1,D4
               ANDI.W   #%0000000000000111,D4
               JSR      hextoasc                *Process the data register
               MOVE.B   #$0,(A2)+
               RTS

*---------------------------------------------------------------------
*OR
*   A2: Message
*   D3: Original Instruction
*---------------------------------------------------------------------
code1000       MOVE.B   #$4F,(A2)+
               MOVE.B   #$52,(A2)+
               MOVE.W   D3,D4
               LSR      #6,D4
               ANDI.W   #$0007,D4
               JSR      addsize
               MOVE.B   #$20,(A2)+
               CLR      D5                      *Clear the "ADDA" flag (in case it's set)
               JSR      addaddresses
               JSR      orerrorcheck
               MOVE.B   #$0,(A2)+
               RTS                          

orerrorcheck   MOVE.W   D3,D4
               LSR      #6,D4
               ANDI.W   #$0007,D4
               CMP.B    #%011,D4
               BEQ      seterror
               CMP.B    #%111,D4
               BEQ      seterror                *Invalid Sizes
               MOVE.W   D3,D2
               LSR      #3,D2
               ANDI.W   #$0007,D2               *Get EA
               CMP.B    #%011,D4
               BGT      ordestcheck             *check for destination errors
               CMP.B    #%001,D2                *check for source errors
               BEQ      seterror
               RTS                              *Valid EA
               
ordestcheck    CMP.B    #%001,D2
               BEQ      orerr                   *Invalid EA
               CMP.B    #%000,D2
               BEQ      orerr                   *Invalid EA
               MOVE.W   D3,D4
               ANDI.W   #$0007,D4               *get register
               CMP.B    #%111,D2
               BEQ      orimm
               RTS                              *Valid EA
               
orimm          CMP.B    #%100,D4                *Check for immediate addressing
               BEQ      orerr                   *Invalid EA
               RTS               
               
orerr          LEA      message,A2              *Load message again
               ADDA.W   #9,A2                   *Move to after the address section
               MOVE.B   #$4F,(A2)+
               MOVE.B   #$52,(A2)+              *Move "OR" to the message again
               MOVE.B   #$20,(A2)+
               JSR      invalidmsg
               MOVE.B   #$2,D1                  *EA flag
               RTS
                
*---------------------------------------------------------------------
*SUB
*   A2: Message
*   D3: Original Instruction
*---------------------------------------------------------------------
code1001       MOVE.B   #$53,(A2)+
               MOVE.B   #$55,(A2)+
               MOVE.B   #$42,(A2)+              *Add "SUB" to the message
               MOVE.W   D3,D4
               LSR      #6,D4
               ANDI.W   #$0007,D4
               JSR      addsize
               MOVE.B   #$20,(A2)+
               CLR      D5                      *Clear the "ADDA" flag (in case it's set)
               JSR      addaddresses            *Process addresses
               JSR      suberrorcheck           *check for errors
               MOVE.B   #$0,(A2)+           
               RTS

suberrorcheck  MOVE.W   D3,D4
               LSR      #6,D4
               ANDI.W   #$0007,D4
               CMP.B    #%111,D4
               BEQ      seterror
               CMP.B    #%011,D4
               BEQ      seterror                *Invalid sizes
               CMP.B    #%011,D4
               BGT      subdestcheck            *Destination error check
               RTS                              *All ea valid for source
               
subdestcheck   MOVE.W   D3,D2
               LSR      #3,D2                   *Get EA mode
               CMP.B    #%000,D2
               BEQ      suberror
               CMP.B    #%001,D2
               BEQ      suberror
               MOVE.W   D3,D4
               ANDI.W   #$0007,D4               *get Register
               CMP.B    #%111,D2
               BEQ      subimm
               RTS                              *EA valid   

subimm         CMP.B    #%100,D4
               BEQ      suberror
               RTS

suberror       LEA      message,A2
               ADDA.W   #9,A2
               MOVE.B   #$53,(A2)+
               MOVE.B   #$55,(A2)+
               MOVE.B   #$42,(A2)+              *Add "SUB" back to message
               MOVE.B   #$20,(A2)+
               JSR      invalidmsg
               MOVE.B   #2,D1
               RTS            

*---------------------------------------------------------------------
*NOT NEEDED
*---------------------------------------------------------------------
code1010       MOVE.B   #$1,D1
               RTS

*---------------------------------------------------------------------
*NOT NEEDED
*---------------------------------------------------------------------
code1011       MOVE.B   #1,D1
               RTS

*---------------------------------------------------------------------
*AND
*   A2: Message
*   D3: Original Instruction
*---------------------------------------------------------------------
code1100       MOVE.B   #$41,(A2)+
               MOVE.B   #$4E,(A2)+
               MOVE.B   #$44,(A2)+              *Add "AND" to the message
               MOVE.W   D3,D4
               LSR      #6,D4
               ANDI.W   #%0000000000000111,D4
               JSR      addsize
               MOVE.B   #$20,(A2)+
               CLR.W    D5
               JSR      addaddresses
               JSR      anderrorcheck
               MOVE.B   #$0,(A2)+
               RTS
               
anderrorcheck  MOVE.W   D3,D4
               LSR      #6,D4
               ANDI.W   #$0007,D4
               CMP.B    #%111,D4
               BEQ      seterror
               CMP.B    #%011,D4
               BEQ      seterror                *Invalid sizes
               CMP.B    #%100,D4
               MOVE.W   D3,D2
               LSR      #3,D2                   *get ea
               ANDI.W   #$0007,D2
               CMP.B    #%011,D4
               BGT      anddestcheck            *check for destination errors
               CMP.B    #%001,D2                *check for source errors
               BEQ      anderror
               RTS                              *Valid EA

anddestcheck   CMP.B    #%000,D2
               BEQ      anderror
               CMP.B    #%001,D2
               BEQ      anderror
               MOVE.W   D3,D4
               ANDI.W   #$0007,D4               *get Register
               CMP.B    #%111,D2
               BEQ      andimm
               RTS                              *EA valid
               
andimm         CMP.B    #%100,D4
               BEQ      anderror
               RTS               

anderror       LEA      message,A2
               ADDA.W   #9,A2
               MOVE.B   #$41,(A2)+
               MOVE.B   #$4E,(A2)+
               MOVE.B   #$44,(A2)+
               MOVE.B   #$20,(A2)+
               JSR      invalidmsg
               MOVE.B   #2,D1
               RTS                 
               
*---------------------------------------------------------------------
*ADD/ADDA
*   A2: Message
*   D3: Original Instruction
*---------------------------------------------------------------------
code1101       MOVE.B   #$41,(A2)+
               MOVE.B   #$44,(A2)+
               MOVE.B   #$44,(A2)+              *Add "ADD" to the message
               MOVE.W   D3,D4
               LSR      #6,D4
               ANDI.W   #%0000000000000111,D4
               JSR      checkadd                *Check for adda
               MOVE.W   D3,D4
               LSR      #6,D4                   *Process Size
               ANDI.W   #%0000000000000111,D4
               JSR      addsize
               MOVE.B   #$20,(A2)+              *Add "  " to the message
               JSR      addaddresses            *Add addresses to message
               MOVE.B   #$0,(A2)+               *Add null character
               JSR      adderrorcheck           *check for errors
               RTS               

adderrorcheck  MOVE.W   D3,D4
               LSR      #6,D4
               ANDI.W   #$0007,D4
               CMP.B    #%011,D4
               BGT      adddestcheck            *Check destination
               RTS                              *other forms of add valid
              
adddestcheck   MOVE.W   D3,D2
               LSR      #3,D2
               ANDI.W   #$0007,D2
               CMP.B    #%000,D2              
               BEQ      adderror
               CMP.B    #%001,D2
               BEQ      adderror
               MOVE.W   D3,D2
               ANDI.W   #$0007,D2
               CMP.B    #%111,D2
               BEQ      addimm
               RTS               
               
addimm         CMP.B    #%100,D4
               BEQ      adderror
               RTS               
               
adderror       LEA      message,A2
               ADDA.W   #9,A2
               MOVE.B   #$41,(A2)+
               MOVE.B   #$44,(A2)+
               MOVE.B   #$44,(A2)+
               MOVE.B   #$20,(A2)+
               JSR      invalidmsg
               MOVE.B   #2,D1
               RTS               
*---------------------------------------------------------------------
*ROL/ROR/LSL/LSR/ASL/ASR
*   A2: Message
*   D3: Original Instruction
*---------------------------------------------------------------------               
code1110       MOVE.W   D3,D4
               LSR      #6,D4
               ANDI.W   #3,D4
               CMP.B    #$03,D4
               BEQ      memshift                *Instruction a memory shift
               MOVE.W   D3,D4                   *Instruction a register shift
               LSR      #3,D4
               ANDI.W   #3,D4
               CMP.B    #$03,D4
               BEQ      regrotate               *Instruction a register RO
               CMP.B    #$01,D4
               BEQ      reglogical              *Instruction a register LS
               CMP.B    #$00,D4
               BEQ      regarith                *Instruction a register AS
               MOVE.B   #1,D1                   *Not a valid shift
               RTS

memshift       MOVE.W   D3,D4
               LSR      #8,D4
               LSR      #1,D4
               ANDI.W   #$0007,D4
               CMP.B    #%000,D4
               BEQ      memarith                *Instruction is memory AS
               CMP.B    #%001,D4
               BEQ      memlogical              *Instruction is memory LS
               CMP.B    #%011,D4
               BEQ      memrotate               *Instruction is memory RO
               MOVE.B   #1,D1                   *Not a valid shift
               RTS

memarith       MOVE.B   #$41,(A2)+              
               MOVE.B   #$53,(A2)+              *Add "AS" to the message
               JSR      direction               *Process direction of shift
               MOVE.B   #$2E,(A2)+
               MOVE.B   #$57,(A2)+              *Add ".W" to the message
               MOVE.B   #$20,(A2)+
               MOVE.W   D3,D2
               LSR      #3,D2
               ANDI.W   #$0007,D2
               MULU     #6,D2
               MOVE.W   D3,D4
               ANDI.W   #$0007,D4
               LEA      ea_jump,A0
               JSR      0(A0,D2)                *Process EA
               MOVE.B   #$0,(A2)+               *Add null character
               JSR      memerrorcheck           *Check for errors
               RTS
                
memlogical     MOVE.B   #$4C,(A2)+
               MOVE.B   #$53,(A2)+              *Add "LS" to the message
               JSR      direction               *Process direction of shift
               MOVE.B   #$2E,(A2)+
               MOVE.B   #$57,(A2)+              *Add ".W" to the message
               MOVE.B   #$20,(A2)+
               MOVE.W   D3,D2
               LSR      #3,D2
               ANDI.W   #$0007,D2
               MULU     #6,D2
               MOVE.W   D3,D4
               ANDI.W   #$0007,D4
               LEA      ea_jump,A0
               JSR      0(A0,D2)                *Process EA
               MOVE.B   #$0,(A2)+               *Add null character
               JSR      memerrorcheck           *Check for errors
               RTS
               
memrotate      MOVE.B   #$52,(A2)+
               MOVE.B   #$4F,(A2)+              *Add "RO" to the message
               JSR      direction               *Process direction of rotation
               MOVE.B   #$2E,(A2)+
               MOVE.B   #$57,(A2)+              *Add ".W" to the message
               MOVE.B   #$20,(A2)+
               MOVE.W   D3,D2
               LSR      #3,D2
               ANDI.W   #$0007,D2
               MULU     #6,D2
               MOVE.W   D3,D4
               ANDI.W   #$0007,D4
               LEA      ea_jump,A0
               JSR      0(A0,D2)                *Process EA
               MOVE.B   #$0,(A2)+               *Add null character
               JSR      memerrorcheck           *check for errors
               RTS            

regrotate      MOVE.B   #$52,(A2)+
               MOVE.B   #$4F,(A2)+              *Add "RO" to the message
               JSR      direction               *Process direction of rotate
               JSR      regsize                 *Process the size of the shift
               JSR      shiftcount              *Process shift count
               MOVE.B   #$2C,(A2)+              *Add "," to the message
               MOVE.W   D3,D4
               ANDI.W   #$0007,D4               *Get the destination register
               MOVE.B   #$44,(A2)+              *Add "D" to the message
               JSR      hextoasc                *Add the register number to the message
               MOVE.B   #$0,(A2)+               *Add null character to message
               JSR      regerrorcheck           *check for errors
               RTS

reglogical     MOVE.B   #$4C,(A2)+
               MOVE.B   #$53,(A2)+              *Add "LS" to the message
               JSR      direction               *Process direction of shift
               JSR      regsize                 *Process the size of the shift
               JSR      shiftcount              *Process shift count
               MOVE.B   #$2C,(A2)+              *Add "," to the message
               MOVE.W   D3,D4
               ANDI.W   #$0007,D4               *Get the destination register
               MOVE.B   #$44,(A2)+              *Add "D" to the message
               JSR      hextoasc                *Add the register number to the message
               MOVE.B   #$0,(A2)+               *Add null character to message
               JSR      regerrorcheck           *check for errors
               RTS

regarith       MOVE.B   #$41,(A2)+
               MOVE.B   #$53,(A2)+              *Add "AS" to the message
               JSR      direction               *Process direction of shift
               JSR      regsize                 *Process the size of the shift
               JSR      shiftcount              *Process shift count
               MOVE.B   #$2C,(A2)+              *Add "," to the message
               MOVE.W   D3,D4
               ANDI.W   #$0007,D4               *Get the destination register
               MOVE.B   #$44,(A2)+              *Add "D" to the message
               JSR      hextoasc                *Add the register number to the message
               MOVE.B   #$0,(A2)+               *Add null character to message
               JSR      regerrorcheck           *check for errors
               RTS
               
direction      MOVE.W   D3,D4                   *Same for mem and reg shifts
               LSR      #8,D4
               ANDI.W   #$0001,D4
               CMP.B    #0,D4
               BEQ      right                   *Direction is right
               MOVE.B   #$4C,(A2)+              *Add "L" to the message
               RTS
               
right          MOVE.B   #$52,(A2)+              *Add "R" to the message
               RTS  
               
regsize        MOVE.W   D3,D4
               LSR      #6,D4
               ANDI.W   #$0003,D4
               CMP.B    #%00,D4
               BEQ      shiftbyte               *Size is a byte
               CMP.B    #%01,D4
               BEQ      shiftword               *Size is a word
               CMP.B    #%10,D4
               BEQ      shiftlong               *Size is a long
               RTS
               
shiftbyte      MOVE.B   #$2E,(A2)+
               MOVE.B   #$42,(A2)+
               MOVE.B   #$20,(A2)+              *Add ".B " to the message
               RTS

shiftword      MOVE.B   #$2E,(A2)+
               MOVE.B   #$57,(A2)+
               MOVE.B   #$20,(A2)+              *Add ".W " to the message
               RTS

shiftlong      MOVE.B   #$2E,(A2)+
               MOVE.B   #$4C,(A2)+
               MOVE.B   #$20,(A2)+              *Add ".L " to the message
               RTS
               
shiftcount     MOVE.W   D3,D4
               LSR      #5,D4
               ANDI.W   #$0001,D4
               CMP.B    #0,D4
               BEQ      immcount                *The instruction has immediate shift count
               MOVE.B   #$44,(A2)+              *Add "D" to the message
               MOVE.W   D3,D4
               LSR      #8,D4
               LSR      #1,D4
               ANDI.W   #$0007,D4
               JSR      hextoasc                *Add the register number to the message
               RTS
               
immcount       MOVE.B   #$23,(A2)+              *Add "#" to the message
               MOVE.W   D3,D4
               LSR      #8,D4
               LSR      #1,D4
               ANDI.W   #$0007,D4
               CMP.B    #0,D4                   *Check the amount to shift
               BEQ      immeight                *The shift is 8
               JSR      hextoasc                *Add the shift count to the message
               RTS

immeight       MOVE.B   #8,D4                   *Change the count to 8
               JSR      hextoasc                *Add 8 to the message
               RTS

regerrorcheck  MOVE.W   D3,D4
               LSR      #6,D4
               ANDI.W   #$0003,D4
               CMP.B    #%11,D4
               BEQ      seterror                *Invalid size
               RTS                              *Valid size
               
memerrorcheck  MOVE.W   D3,D2
               LSR      #3,D2
               ANDI.W   #$0007,D2
               CMP.B    #%000,D2
               BEQ      shifterror
               CMP.B    #%001,D2
               BEQ      shifterror
               MOVE.W   D3,D4
               ANDI.W   #$0007,D2
               CMP.B    #%111,D2
               BEQ      memimm
               RTS                              *Valid ea 
               
memimm         CMP.B    #%100,D4
               BEQ      shifterror
               RTS               
               
shifterror     LEA      message,A2
               ADDA.W   #12,A2               
               MOVE.B   #$20,(A2)+              *Move message past opcode
               JSR      invalidmsg
               MOVE.B   #2,D1
               RTS
               

*---------------------------------------------------------------------
*NOT NEEDED
*---------------------------------------------------------------------
code1111      MOVE.B    #1,D1
              RTS

*---------------------------------------------------------------------
*EA JUMP TABLE     
*---------------------------------------------------------------------
ea_jump       JMP          code000
              JMP          code001
              JMP          code010
              JMP          code011
              JMP          code100
              JMP          code101
              JMP          code110
              JMP          code111
              
*---------------------------------------------------------------------
*EA: Data Register Direct
*   D4: Register
*   A2: Message
*---------------------------------------------------------------------              
code000       MOVE.B    #$44,(A2)+              *Add "D" to the message
              JSR       hextoasc                *Add the register to the message
              RTS

*---------------------------------------------------------------------
*EA: Address Register Direct
*   D4: Register
*   A2: Message
*---------------------------------------------------------------------              
code001       MOVE.B    #$41,(A2)+              *Add "A" to the message
              JSR       hextoasc                *Add the register to the message
              RTS

*---------------------------------------------------------------------
*EA: Address Register Indirect
*   D4: Register
*   A2: Message
*---------------------------------------------------------------------
code010       MOVE.B    #$28,(A2)+
              MOVE.B    #$41,(A2)+              *Add "(A" to the message
              JSR       hextoasc                *Process the register
              MOVE.B    #$29,(A2)+              *Add ")" to the message
              RTS

*---------------------------------------------------------------------
*EA: Address Register Indirect w/ Post-Increment
*   D4: Register
*   A2: Message
*---------------------------------------------------------------------              
code011       MOVE.B    #$28,(A2)+              *Add "(" to the message
              MOVE.B    #$41,(A2)+              *Add "A" to the message
              JSR       hextoasc                *Process the register
              MOVE.B    #$29,(A2)+              *Add ")" to the message
              MOVE.B    #$2B,(A2)+              *Add "+" to the message
              RTS

*---------------------------------------------------------------------
*EA: Address Register Indirect w/ Pre-Decrement
*   D4: Register
*   A2: Message
*---------------------------------------------------------------------
code100       MOVE.B    #$2D,(A2)+              
              MOVE.B    #$28,(A2)+
              MOVE.B    #$41,(A2)+              *Add "-(A" to the message
              JSR       hextoasc                *Process the register
              MOVE.B    #$29,(A2)+              *Add ")" to the message
              RTS

*---------------------------------------------------------------------
*NOT NEEDED
*---------------------------------------------------------------------
code101       MOVE.B    #1,D1
              RTS

*---------------------------------------------------------------------
*NOT NEEDED
*---------------------------------------------------------------------
code110       MOVE.B    #1,D1
              RTS

*---------------------------------------------------------------------
*EA: Absolute Address/Immediate Addressing
*   D4: Register
*   D6: Size
*   A2: Message
*   A4: NEXT INSTRUCTION
*---------------------------------------------------------------------
code111       CMP.B     #%001,D4
              BEQ       absolLong               *Absolute Long Addressing
              CMP.B     #%100,D4
              BEQ       immaddressing           *Immediate addressing
              CMP.B     #%000,D4
              BEQ       absolWord               *Absolute Word Addressing
              MOVE.B    #1,D1                   *Invalid addressing
              RTS
              
absolLong     MOVE.B    #$24,(A2)+              *Add "$" to the message
              MOVE.W    (A4)+,D4                *Read from the high order word
              JSR       wordtoasc               *Process high order word
              MOVE.W    (A4)+,D4                *Read from low order word
              JSR       wordtoasc               *Process low order word
              RTS
              
absolWord     MOVE.B    #$24,(A2)+              *Add "$" to the message
              MOVE.W    (A4)+,D4                *Read from the next line
              EXT.L     D4                      *Sign extension of the word
              MOVE.W    D4,-(SP)                *Save the low order word
              LSR.L     #8,D4
              LSR.L     #8,D4
              JSR       wordtoasc               *Process the sign extension
              MOVE.W    (SP)+,D4                *Get the original word
              JSR       wordtoasc               *Process the original word
              RTS

immaddressing MOVE.B    #$23,(A2)+              *Add "#" to the message
              CMP.B     #%00,D6                 *Check the size flag
              BEQ       immbyte                 *Immediate byte
              CMP.B     #%01,D6
              BEQ       absolWord               *Immediate word (Process like immediate)
              CMP.B     #%10,D6
              BEQ       absolLong               *Immediate Long
              MOVE.B    #1,D1                   *Invalid addressing
              RTS       

immbyte       MOVE.B    #$24,(A2)+              *Add "$" to the message
              MOVE.W    (A4)+,D4                *Read the word
              MOVE.W    D4,-(SP)                *Store the word in the stack
              LSR       #4,D4
              ANDI.W    #$000F,D4
              JSR       hextoasc                *Process the first digit       
              MOVE.W    (SP)+,D4                *Get the word again
              ANDI.W    #$000F,D4
              JSR       hextoasc                *Process the second digit
              RTS 
              
*---------------------------------------------------------------------
*SUBROUTINE: HEX TO ASCII (ADDS A HEX NUMBER TO END OF MESSAGE)
*   D4: Target Hex Value
*   A2: Message
*---------------------------------------------------------------------
hextoasc      CMP.B    #$A,D4
              BLT      baseten
              ADD.B    #$37,D4
              MOVE.B   D4,(A2)+
              RTS
baseten       ADD.B    #$30,D4
              MOVE.B   D4,(A2)+
              RTS
              
*---------------------------------------------------------------------
*SUBROUTINE: isaddress (USED TO CHECK FOR MOVEA)
*   D4: MODE
*   A2: Message
*---------------------------------------------------------------------
isaddress    CMP.B    #%001,D4
             BEQ      moveaddress
             RTS
             
moveaddress  MOVE.B   #$41,(A2)+
             RTS

*---------------------------------------------------------------------
*SUBROUTINE: addsize (USED TO CHECK SIZE OF ADD)
*   D4: Size
*   A2: Message
*---------------------------------------------------------------------            
addsize     MOVE.B  #$2E,(A2)+                  *Add "." to the message
            CMP.B   #%000,D4
            BEQ     addsbyte                    *size is byte
            CMP.B   #%100,D4
            BEQ     addsbyte                    *Size is byte
            CMP.B   #%001,D4
            BEQ     addsword                    *Size is word
            CMP.B   #%101,D4
            BEQ     addsword                    *Size is word
            CMP.B   #%011,D4
            BEQ     addsword                    *Size is word
            CMP.B   #%010,D4
            BEQ     addslong                    *Size is long
            CMP.B   #%110,D4
            BEQ     addslong                    *Size is long
            CMP.B   #%111,D4
            BEQ     addslong                    *Size is long
            
addsbyte    MOVE.B  #$42,(A2)+                  *Add "B" to the message
            MOVE.B  #%00,D6
            RTS

addsword    MOVE.B  #$57,(A2)+                  *Add "W" to the message
            MOVE.B  #%01,D6
            RTS

addslong    MOVE.B  #$4C,(A2)+                  *Add "L" to the message
            MOVE.B  #%10,D6
            RTS
            
*---------------------------------------------------------------------
*SUBROUTINE checkadd (Check if ADD or ADDA)
*   D4: OPMode
*   D5: Address flag (used for printing out the address later)
*   A2: Message
*---------------------------------------------------------------------
checkadd    CLR   D5
            CMP.B   #%011,D4
            BEQ     addamsg
            CMP.B   #%111,D4
            BEQ     addamsg
            RTS

addamsg     MOVE.B  #1,D5 *set the address flag
            MOVE.B  #$41,(A2)+
            RTS
            
*---------------------------------------------------------------------
*SUBROUTINE addaddresses (processes addresses for Add/Adda/And)
*   D3: Original Instruction
*   D5: Address flag (ONLY FOR ADD/ADDA)
*   A2: Message
*---------------------------------------------------------------------
addaddresses CMP.B  #1,D5                       *Check if address flag is set
            BEQ     adda
            MOVE.W  D3,D4
            LSR     #6,D4                       *Get OPMode
            ANDI.W  #%0000000000000111,D4
            CMP.B   #4,D4                       *Check if register is destination
            BLT     adddest
            MOVE.B  #$44,(A2)+                  *Register is source, add "D" to message
            MOVE.W  D3,D4
            LSR     #8,D4
            LSR     #1,D4
            ANDI.W  #%0000000000000111,D4
            JSR     hextoasc                    *Process Register
            MOVE.B  #$2C,(A2)+                  *Add "," to message
            MOVE.W  D3,D2
            LSR     #3,D2
            ANDI.W  #%0000000000000111,D2
            MULU    #6,D2
            MOVE.W  D3,D4
            ANDI.W  #%0000000000000111,D4
            LEA     ea_jump,A0
            JSR     0(A0,D2)                    *Process EA
            RTS
            
adda        MOVE.W  D3,D2                       *Get EA
            LSR     #3,D2
            ANDI.W  #%0000000000000111,D2
            MOVE.W  D3,D4                       *Get Register
            ANDI.W  #%0000000000000111,D4
            LEA     ea_jump,A0
            MULU    #6,D2
            JSR     0(A0,D2)                    *Process EA
            MOVE.B  #$2C,(A2)+                  *Add "," to message
            MOVE.B  #$41,(A2)+                  *Add "A" to message
            MOVE.W  D3,D4
            LSR     #8,D4               
            LSR     #1,D4
            ANDI.W  #%0000000000000111,D4
            JSR     hextoasc                    *Process Register
            RTS            
            
adddest     MOVE.W  D3,D2
            LSR     #3,D2                       *Get EA
            ANDI.W  #%0000000000000111,D2
            MOVE.W  D3,D4                       *Get register
            ANDI.W  #%0000000000000111,D4
            LEA     ea_jump,A0
            MULU    #6,D2         
            JSR     0(A0,D2)                    *Process EA
            MOVE.B  #$2C,(A2)+
            MOVE.B  #$44,(A2)+                  *Add ",D" to the message
            MOVE.W  D3,D4
            LSR     #8,D4
            LSR     #1,D4
            ANDI.W  #%0000000000000111,D4
            JSR     hextoasc                    *Process register
            RTS

*---------------------------------------------------------------------
*SUBROUTINE: addqsize
*   D4: Size
*   A2: Message
*---------------------------------------------------------------------
addqsize   CMP.B    #%00,D4
           BEQ      addqb                       *Size is a byte
           CMP.B    #%01,D4
           BEQ      addqw                       *Size is a word
           CMP.B    #%10,D4
           BEQ      addql                       *Size is a long
           MOVE.B   #1,D1                       *Invalid Size
           RTS
           
addqb      MOVE.B   #$2E,(A2)+
           MOVE.B   #$42,(A2)+
           RTS                                  *Add ".B" to the message

addqw      MOVE.B   #$2E,(A2)+
           MOVE.B   #$57,(A2)+
           RTS                                  *Add ".W" to the message

addql      MOVE.B   #$2E,(A2)+
           MOVE.B   #$4C,(A2)+
           RTS                                  *Add ".L" to the message     
           
*---------------------------------------------------------------------
*SUBROUTINE: proccondition AS OF NOW ONLY DOES GT,LE,EQ,BRA
*   D4: Condition
*   A2: Message
*---------------------------------------------------------------------
proccondition  CMP.B   #%1110,D4
           BEQ      gt                          *BGT
           CMP.B    #%1111,D4
           BEQ      le                          *BLE
           CMP.B    #%0111,D4
           BEQ      eq                          *BEQ
           CMP.B    #%0000,D4
           BEQ      ra                          *BRA
           MOVE.B   #1,D1                       *Not one of the conditionals required
           RTS

gt         MOVE.B   #$47,(A2)+
           MOVE.B   #$54,(A2)+                  *Add "GT" to the message
           RTS

eq         MOVE.B   #$45,(A2)+
           MOVE.B   #$51,(A2)+                  *Add "EQ" to the message
           RTS

le         MOVE.B   #$4C,(A2)+
           MOVE.B   #$45,(A2)+                  *Add "LE" to the message
           RTS

ra         MOVE.B   #$52,(A2)+
           MOVE.B   #$41,(A2)+                  *Add "RA" to the message
           RTS
           
*---------------------------------------------------------------------
*SUBROUTINE: wordtoasc Converts a word into ASCII
*   D4: Word to process
*   A2: Message
*---------------------------------------------------------------------
wordtoasc  MOVE.W   D4,-(SP)            *Save the word to the stack
           LSR      #8,D4
           LSR      #4,D4
           ANDI.W   #$000F,D4
           JSR      hextoasc            *Process the first digit
           MOVE.W   (SP),D4
           LSR      #8,D4
           ANDI.W   #$000F,D4
           JSR      hextoasc            *Process the second digit
           MOVE.W   (SP),D4
           LSR      #4,D4
           ANDI.W   #$000F,D4
           JSR      hextoasc            *Process the third digit
           MOVE.W   (SP)+,D4            *Move the stack pointer back
           ANDI.W   #$000F,D4
           JSR      hextoasc            *Process the fourth digit
           RTS

*---------------------------------------------------------------------
*SUBROUTINE: seterror
*   D1: Error Flag
*---------------------------------------------------------------------
seterror    MOVE.B  #1,D1
            RTS
           
************************* THE SUBROUTINE ******************************
*---------------------------------------------------------------------
*   Subroutine: formatOutput2
*   Parameters: A1- Contains Message to be printed
*---------------------------------------------------------------------
formatOutput    LEA     OutputBuffer,A2 * Empty String variable
outerLoop       MOVE.B  #9,D6           * D7: counter for formating tab space

copyChars       Move.B   (A1),D5        * Move contents of A1 to D5
                CMP      #$00,D5        * If:   D5 == #$00 end of string reached
                BEQ      printResult    *         Print new string contents 
                
                CMP.B    #$20,(A1)      * If:   Char in A1 is a space
                BEQ      addSpaces      *         Add more spaces until D7 == 0

                MOVE.B   (A1)+,(A2)+    * Else: Copy A1 contents to A2
                SUB.B    #1,D6          *         Subtract 1 from D7 (format counter)
                BRA      copyChars      * Do it again until a space or string end is reached

addSpaces       Move.B   (A1)+,(A2)+
spacesLoop      CMP.B    #0,D6          * if D7 == 0...
                BEQ      outerLoop      *      Go to next step & copy the rest
                Move.B   #$20,(A2)+     * Add a space to the formatted string
                SUB.B    #1,D6          * Subtract 1 from D7 (format counter)
                BRA      spacesLoop     * Do it again until D7 == 0

printResult    MOVE.B   #$0D,(A2)+           * Loading Carriage Return to message
               MOVE.B   #$0A,(A2)+           * Loading Line Feed to message
               MOVE.B   #$00,(A2)+           * Adding 'End of string' to message
               LEA      OutputBuffer, A1     * Moving new message to A1
               Move.B   #14,D0               * Loading print instruction to D0
               Trap     #15                  * Printing to output window
               
               RTS                           * Return from Subroutine 
  

********************* SUBROUTINES **************************

*---------------------------------------------------------------------
*SUBROUTINE: invalidmsg adds "INVALID EA" to the message
*   A2: end of message
*---------------------------------------------------------------------
invalidmsg  MOVE.B  #$49,(A2)+
            MOVE.B  #$4E,(A2)+
            MOVE.B  #$56,(A2)+
            MOVE.B  #$41,(A2)+
            MOVE.B  #$4C,(A2)+
            MOVE.B  #$49,(A2)+
            MOVE.B  #$44,(A2)+
            MOVE.B  #$20,(A2)+
            MOVE.B  #$45,(A2)+
            MOVE.B  #$41,(A2)+                  *Add "INVALID EA" to message
            MOVE.B  #0,(A2)+                    *Add null character
            RTS

*---------------------------------------------------------------------
*   Subroutine: checkStartLength
*   Parameters: D1 has the length of the user input
*               D4 has 1 if checking start length 2 if end length
*---------------------------------------------------------------------
checkLength    CMP      #$4,D1        * If: Length is less than 1
               BLT      invalidLength *     Invalid Length
               CMP      #6,D1         * If: Length is greater than 6
               BGT      invalidLength *     Invalid Length
               CMP      #1,D4         * If: D4 contains 1
               BEQ      startStuff1   *     Do start address specific stuff
               CMP      D6,D1         * If: D4 == 2 and D6 < D1 
               BLT      invalidLength *     Invalid Length
               RTS
               
startStuff1    Move.B   D1,D6         * Storing length to D6 to compare 
               RTS                    * to endingAddr later on
               
invalidLength  LEA      invalidLen,A1 * Moving error message to A1 
               Move.B   #14,D0        * Moving cout instruction to D0
               Trap     #15           * Executing instruction
               SUBQ     #2,D7
               CMP      #1,D4         * If D4 == 1
               BEQ      getStart      *     Get the starting adress again
               JSR      getEndAddr    * Else: get the ending address again
               
getStart       JSR      getStartAddr  * Goes back to get starting address
        
        
*---------------------------------------------------------------------
*   Subroutine: toHex           
*   Parameters: A1 has the string to be converted
*               D1 has the length of the string
*               D4 has 1 if converting startAddress 2 if endAddress
*---------------------------------------------------------------------
toHex          Move.B   D1, D5        * copying length to D5 for counter
               CLR.L    D3 
convertLoop    Move.B   (A1)+,D2      * Move number to data register for conversion
               CMPI.B   #$39,D2       * If it is a number
               BLE      number        *   go to number conversion
               
               CMPI.B   #$47,D2       * If its a letter >= G or lowercase
               BGE      invHex        *   Invalid Entry
               
               CMPI.B   #$40,D2       * If it is : ; < = > ? or @ 
               BLE      invHex        *   Invalid Entry
               
               SUBI.B   #$37,D2       * Else: it is a capital letter A-F
               BRA      saveValue     *       save value
               
               
number         CMPI.B   #$2F,D2       * If: It is a symbol:
               BLE      invHex        *     invalid entry
               SUBI.B   #$30,D2       * Else: subtract #$30 from D2
               BRA      saveValue     *       save value
               
saveValue      SUBI.B   #%1,D5        * Deincrement Counter
               ADD.B    D2,D3         * Add D2 to D3
               CMPI.B   #%0,D5        * If: counter is at 0
               BEQ      Done          *     then we are done converting
               ROL.L    #4,D3         * Else: shift bits over for next number
               BRA      convertLoop   * repeat the loop until D5 == 0

done           CMP      #1,D4         * If D4 == 1
               BEQ      saveStart     *    Do startAddr specific stuff
               MoveA.L  D3, A6        * Else: Move Address to A6
               RTS                    * Return to system

saveStart      MoveA.L  D3, A5        * Move Start Address to A5
               RTS                    * end range later

invHex         LEA      invalidHex,A1 * Moving error message to A1 
               Move.B   #14,D0        * Moving cout instruction to D0
               Trap     #15           * Executing instruction
               SUBQ     #2,D7
               CMP      #1,D4         * If D4 == 1
               BEQ      getStart2     *    Get the start address again
               JSR      getEndAddr    * Else: get the ending address
               
getStart2      JSR      getStartAddr  * Retreive start address again

*---------------------------------------------------------------------
*   Subroutine: Check Odd          
*   Parameters: A1 has the string to be converted
*               D3 has the converted Hex value of A1
*               D2 has the last digit of D3
*               D4 has 1 if checking start Address 2 if end Address
*---------------------------------------------------------------------
checkOdd      Move.B    #$2, D1       * Move 2 into D1 for division
              DIVU      D1,D2         * Divide D2 by D1
              SWAP      D2            * Swap bit to check remainder
              CMP.B     #$1,D2        * If: remainder == 1
              BEQ       invalidOdd    *     Invalid Entry  
              CLR.L     D2
              RTS                     * Else: Return to system
              
invalidOdd    LEA      invalidMod,A1  * Moving error message to A1 
              Move.B   #14,D0         * Moving cout instruction to D0
              Trap     #15            * Executing instruction
              CLR.L    D2
              SUBQ     #2,D7
              CMP      #1,D4          * If D4 == 1
              BEQ      getStart3      *    Get start address again
              JSR      getEndAddr     * Else: get ending address
               
getStart3     JSR      getStartAddr   * Retreive start address again

*---------------------------------------------------------------------
*   Subroutine: Check Range         
*   Parameters: D3 has the converted Hex value of A1
*               D4 has 1 if checking start Address 2 if end Address
*               A5 is the starting address if D4 == 2
*---------------------------------------------------------------------
checkRange    CMP.B    #$1,D4        * If: D4 == 1
              BEQ      checkStartR   *     Check start range
              CMP.L    A5,D3         * If: D5(startAddr) < D3(currentAddr)
              BLT      invalidRange  *     Invalid Entry
              BRA      checkEndR     * Else: Check End Range
                          
checkStartR   Move.L   #$003000,D1   * Loading minimum address required
              CMP.L    D1,D3         * If: D1 < D3
              BLT      invalidRange  *     Invalid Entry

checkEndR     Move.L   #$A00000,D1   * Loading maximum address required 
              CMP.L    D1,D3         * If: D1 > D3
              BGT      invalidRange  *     Invalid Entry
              RTS                    * Else: Entry is valid, return
              
invalidRange  LEA      invalidRan,A1 * Moving error message to A1 
              Move.B   #14,D0        * Moving cout instruction to D0
              Trap     #15           * Executing instruction
              CLR.L    D2            * Clear D2 for next iteration
              SUBQ     #2,D7
              CMP      #1,D4         * If: D4 == 1
              BEQ      getStart4     *     Get new starting address
              JSR      getEndAddr    * Else: Get new ending address
               
getStart4     JSR      getStartAddr  * Get starting address again   

*---------------------------------------------------------------------
*   Subroutine: anotherPage        
*   Parameters: D1 has length of the user input 0 == go again
*---------------------------------------------------------------------                
anotherPage  CMP      #$1,D1        * If: Length is less than 1
             BLT      another       *     show another page
             RTS                    * Else: ask if new range desired

another      Move.B   #11, D0       * Trap task 11 will be defined by D1
             Move.W   #$FF00,D1     * Instruction to clear page
             TRAP     #15           * Execute instruction
             Move.B   #30,D7        * Resetting print counter
             RTS  ****** TODO ******* 

*---------------------------------------------------------------------
*   Subroutine: goAgain       
*   Parameters: 
*--------------------------------------------------------------------- 
goAgain      LEA      userInput, A1
             Move.B   #2,D0         * Moving cin instruction to D0
             Trap     #15           * Executing instruction
            
             SUBQ     #5,D7
             
             CMP      #$1,D1        * If: Length is less than 1
             BLT      newRange      *     Restart program
             RTS                    * Else: End Program

newRange     Move.B   #11, D0       * Trap task 11 will be defined by D1
             Move.W   #$FF00,D1     * Instruction to clear page
             TRAP     #15           * Execute instruction
             JMP      START

****************** Variables and Constants for the Test *************************    
InputLocation   EQU     $3000 

CR      EQU    $0D
LF      EQU    $0A
OutputBuffer  DS.L  80
message        DS.L        25
********************* Prompt Messages **************************       
prompt       DC.B  ' *     Please Enter an Even Starting Address in Hexidecimal      * ',CR,LF,0
promptSpecs  DC.B  ' * Entry should be a long-word (no more than 6 characters long)  * ',CR,LF,0
promptSpecs2 DC.B  ' *          with no symbols and between 3000 and A00000          * ',CR,LF,0
breakLn      DC.B  '-------------------------------------------------------------------',CR,LF,0


prompt2     DC.B   ' *      Please Enter an Even Ending Address in Hexidecimal       * ',CR,LF,0
promptEnd   DC.B   ' * Entry should be a long-word (no more than 6 characters long)  * ',CR,LF,0
PromptEnd2  DC.B   ' * with no symbols and between your starting address and A00000) * ',CR,LF,0

corrInput   DC.B   ' *  Here are the first few instructions from your start address  * ',CR,LF,0

prompt3     DC.B   ' *         Would you like to view another page of memory?        * ',CR,LF,0
instruct    DC.B   ' *     Press Enter to Continue or type "NO" to enter another range  * ',CR,LF,0

againPrompt DC.B   ' *    Would you like to disassemble another segment of memory?   * ',CR,LF,0
continueprompt  DC.B ' *         Type "NO" to quit or press enter to continue         * ',CR,LF,0
center      DC.B   '                             ',0                                  

startingAddr    DS.B    80      Stores starting address from user input
endingAddr      DS.B    80      Stores ending address from user input
userInput       DS.B    80      Stores user input

********************** Error Messages ************************** 
invalidMess DC.B   CR,LF,'*-* !!!! Sorry, that is an invalid entry, please try again !!!! *-*',CR,LF,0

invalidLen  DC.B   CR,LF,'*-* !!!! Sorry, that is an invalid length please try again !!!! *-*',CR,LF,CR,LF,0
invalidHex  DC.B   CR,LF,'*-* !! Sorry, that is an invalid hex number please try again !! *-*',CR,LF,CR,LF,0
invalidMod  DC.B   CR,LF,'*-* !!!!!! Sorry, that is an odd number please try again !!!!!! *-*',CR,LF,CR,LF,0
invalidRan  DC.B   CR,LF,'*-* !!!! Sorry, that is an invalid range, please try again !!!! *-*',CR,LF,CR,LF,0


               END   $1000 



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
