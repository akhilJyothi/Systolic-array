# Systolic Array

## Overview

Systolic array is a grid of Multiply-Accumulate(MAC) units and is used for efficient matrix multiplication and other linear algebra applications . These are used in CNN were better speed for matirx multiplication matters.

First a mac unit which simply does the job of acc<=acc +(a_in*b_in) was implemented.
Then this was used in a 2x2 systolic array.
The 2x2 systolic array we mannually wired and the simulations showed this was working pefectly.

Later this mac unit was used to build a parameterized scaleable systolic array.
The design was generalized using parameters for array size and data width, enabling the same RTL to instantiate an N×N systolic array without requiring manual wiring. This scalable architecture can therefore be configured for different matrix dimensions while maintaining the same underlying design.


# mac_unit

## (architecture update)

Architecture is now updated so that the the pipeline registers a_out and b
-out are updated only if there is a valid signal.
Earlier valid signal was used only to flag the operation of the accumulator but now this is changed to function as a switch to start the mac unit operation.

When `valid` is asserted, the MAC unit performs three operations simultaneously:

1. Registers `a_in` into `a_out`.
2. Registers `b_in` into `b_out`.
3. Performs the multiply-accumulate operation:
   ```
   accum_out <= accum_out + ACCUM_WIDTH'(a_in * b_in);

## Module operation
The module has an actively asynchronous reset (rst_n) and when the reset is asserted the pipeline registers a_out, b_out and the accumulator accum_out are cleared. If the rst_n signal is de-asserted the a_out and b_out signal will be loaded with a_in and b_in irrespective of valid signal.

If there is a clear signal now, the accum_out gets cleared. This is actually done when computation of one tile is done and the input matrices of the next tile is to be fed to the PE.
The purpose of clear is not to flush the pipeline but  it is to reset the accumulated partial sums so the MAC can begin computing the next output tile from zero. So the pipeline registers are not cleared and only the accumulator is cleared since they simply forward operands to neighboring MACs and are overwritten with new input values on the first valid cycle of the next tile..

Now if there is a valid signal, then the accum_out action happens, multiplication is done and the running sum in the accumulator register is updated. Also in the multiplier part, the width of a_in*b_in is extended to ACCUM_WIDTH to remove the ambiguity.


# Systolic array

## Module overview

Systolic array module instatiates ARRAY_SIZE × ARRAY_SIZE mac_units and the design was generalized using parameters for array size and data width.These are interconnected by the busses(a_bus and b_bus)which again are parameterised and doesnt need any mannual wiring. There are seperate  generate blocks maintained for:
             -Left-edge assignments (a_in → a_bus)
             -Top-edge assignments (b_in → b_bus)
             -Instantiation of the mac_unit array

## Module functioning

mac_units are initiated and the parameters are passed explicitly for avoiding any ambiguity during future scaling. The units will be instatioated as :
                       gen_rows[i]gen_coloums[j].[pe]

The wiring is done in such a way that the edge assignments are done explicitly and if it is not an edge mac_unit, then a fill be fed from the left edge and b will be fed form the top edge.

Each MAC performs the mac operation whenever the valid signal is asserted. The accumulated output (accum_out) of every processing element is directly connected to the corresponding element of the results matrix, where results[i][j] represents the accumulated output of the processing element located at row i and column j
